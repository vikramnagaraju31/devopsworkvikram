variable "region" {
  default     = "us-west-1"
  description = "AWS region"
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "tscekscluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "tsceksclusterauth" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "tsceksavailable" {
}

locals {
  cluster_name = "sandbox-${var.region}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "sandbox-${var.region}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.tsceksavailable.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.tscekscluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.tscekscluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.tsceksclusterauth.token
}

module "eks" {
  source              = "terraform-aws-modules/eks/aws"
  cluster_version     = "1.20"
  cluster_name        = local.cluster_name
  vpc_id              = module.vpc.vpc_id
  subnets             = module.vpc.private_subnets
  worker_groups = [
    {
      instance_type = "t3.large"
      asg_max_size  = 2
      asg_min_size  = 1
    }
  ]
}

data "tls_certificate" "tscekstlscertificate" {
  url = data.aws_eks_cluster.tscekscluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "tsceksoidcprovider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tscekstlscertificate.certificates.0.sha1_fingerprint]
  url             = data.aws_eks_cluster.tscekscluster.identity.0.oidc.0.issuer
}

resource "aws_iam_policy" "albingresscontrolleriampolicy" {
  name        = "albingresscontrolleriampolicy-${var.region}"
  policy = file("iam-policy.json")
}

resource "aws_iam_role" "eksalbingresscontroller" {
  name = "eksalbingresscontroller-${var.region}"
  assume_role_policy = jsonencode({
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Principal":{
            "Federated":"${aws_iam_openid_connect_provider.tsceksoidcprovider.arn}"
         },
         "Action":"sts:AssumeRoleWithWebIdentity",
         "Condition":{
            "StringEquals":{
               "${aws_iam_openid_connect_provider.tsceksoidcprovider.url}:sub":"system:serviceaccount:kube-system:alb-ingress-controller"
            }
         }
       }
     ]
  })
}

resource "aws_iam_role_policy_attachment" "albingresscontrolleriampolicy" {
  policy_arn = "${aws_iam_policy.albingresscontrolleriampolicy.arn}"
  role       = aws_iam_role.eksalbingresscontroller.name
}

resource "aws_iam_role_policy_attachment" "amazoneksworkernodepolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eksalbingresscontroller.name
}

resource "aws_iam_role_policy_attachment" "amazonekscnipolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eksalbingresscontroller.name
}

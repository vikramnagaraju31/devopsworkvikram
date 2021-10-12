output "aws_iam_openid_connect_provider_arn" {
  description = "aws_iam_openid_connect_provider_arn"
  value = aws_iam_openid_connect_provider.tsceksoidcprovider.arn
}

output "aws_iam_openid_connect_provider_url" {
  description = "aws_iam_openid_connect_provider_url"
  value = aws_iam_openid_connect_provider.tsceksoidcprovider.url
}

output "cluster_name" {
  description = "cluster_name"
  value       = module.eks.cluster_id
}

output "aws_iam_policy_albingresscontrolleriampolicy_arn" {
  description = "aws_iam_policy_albingresscontrolleriampolicy_arn"
  value = aws_iam_policy.albingresscontrolleriampolicy.arn
}

output "aws_iam_role_eksalbingresscontroller_arn" {
  description = "aws_iam_role_eksalbingresscontroller"
  value = aws_iam_role.eksalbingresscontroller.arn
}

output "region" {
  description = "region"
  value       = var.region
}
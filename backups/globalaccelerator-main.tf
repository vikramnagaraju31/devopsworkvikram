variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

provider "aws" {
  region = var.region
}

resource "aws_globalaccelerator_accelerator" "eks" {
  name            = "sandbox-${var.region}-globalaccelerator"
  ip_address_type = "IPV4"
  enabled         = true
}

resource "aws_globalaccelerator_listener" "eks" {
  accelerator_arn = aws_globalaccelerator_accelerator.eks.id
  client_affinity = "NONE"
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}

resource "aws_globalaccelerator_endpoint_group" "eks-us-east-1" {
  listener_arn = aws_globalaccelerator_listener.eks.id
  endpoint_group_region           = "us-east-1"
  health_check_port               = 80
  health_check_protocol           = "TCP"
  health_check_interval_seconds   = 30
  threshold_count                 = 10
  traffic_dial_percentage         = 100

  endpoint_configuration {
    endpoint_id                     = "arn:aws:elasticloadbalancing:us-east-1:137740421094:loadbalancer/app/08939fc8-2048game-2048ingr-6fa0/e58ffbea93dcdf5f"
    weight                          = 100
  }
}
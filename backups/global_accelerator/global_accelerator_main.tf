variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

provider "aws" {
  region = var.region
}

variable "tsceksalbdomainarnuseast1" {
  type = string
}

variable "tsceksalbdomainarnuswest1" {
  type = string
}

resource "aws_globalaccelerator_accelerator" "tsceksglobalaccelerator" {
  name            = "sandbox-${var.region}-globalaccelerator"
  ip_address_type = "IPV4"
  enabled         = true
}

resource "aws_globalaccelerator_listener" "tsceksglobalacceleratorlistner" {
  accelerator_arn = aws_globalaccelerator_accelerator.tsceksglobalaccelerator.id
  client_affinity = "NONE"
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}

resource "aws_globalaccelerator_endpoint_group" "eks-us-east-1" {
  listener_arn = aws_globalaccelerator_listener.tsceksglobalacceleratorlistner.id
  endpoint_group_region           = "us-east-1"
  health_check_port               = 80
  health_check_protocol           = "TCP"
  health_check_interval_seconds   = 30
  threshold_count                 = 10
  traffic_dial_percentage         = 100
  endpoint_configuration {
    endpoint_id                     = "${var.tsceksalbdomainarnuseast1}"
    weight                          = 100
  }
}

resource "aws_globalaccelerator_endpoint_group" "eks-us-west-1" {
  listener_arn = aws_globalaccelerator_listener.tsceksglobalacceleratorlistner.id
  endpoint_group_region           = "us-west-1"
  health_check_port               = 80
  health_check_protocol           = "TCP"
  health_check_interval_seconds   = 30
  threshold_count                 = 10
  traffic_dial_percentage         = 100

  endpoint_configuration {
    endpoint_id                     = "${var.tsceksalbdomainarnuswest1}"
    weight                          = 100
  }
}
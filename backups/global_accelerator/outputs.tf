output "region" {
  description = "region"
  value       = var.region
}

output "albdomain" {
  description = "alb_domain_arn"
  value       = var.tsceksalbdomainarn
}

output "aws_globalaccelerator_accelerator_tsceksglobalaccelerator_id" {
  description = "aws_globalaccelerator_accelerator_tsceksglobalaccelerator_id"
  value = aws_globalaccelerator_accelerator.tsceksglobalaccelerator.id
}

output "aws_globalaccelerator_listener_tsceksglobalacceleratorlistner_id" {
  description = "aws_globalaccelerator_listener_tsceksglobalacceleratorlistner_id"
  value = aws_globalaccelerator_listener.tsceksglobalacceleratorlistner.id
}
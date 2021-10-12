output "infraname" {
  value = var.infraname
}

output "region" {
  value = var.region
}

output "eksalbdomainurl" {
  value = var.tsceksalbdomain
}

output "stage" {
  value = var.stage
}

output "zone_or_domain" {
  value = var.zone
}

output "app_host_domain" {
  value = var.domain
}

output "subdomain" {
  value = var.subdomain
}

output "failoverroutingpolicy" {
  value = var.failoverroutingpolicy
}

output "setidentifier" {
  value = var.setidentifier
}

output "aws_api_gateway_rest_api_tsc_infra_api_id" {
  value = aws_api_gateway_rest_api.tsc_infra_api.id
}

output "aws_api_gateway_resource_tsc_infra_api_resource_id" {
  value = aws_api_gateway_resource.tsc_infra_api_resource.id
}

output "aws_api_gateway_deployment_tsc_infra_api_deployment_id" {
  value = aws_api_gateway_deployment.tsc_infra_api_deployment.id
}

output "aws_acm_certificate_tsc_infra_certificate_arn" {
  value = aws_acm_certificate.tsc_infra_certificate.arn
}

output "aws_acm_certificate_validation_tsc_infra_acm_validation_certificate_arn" {
  value = aws_acm_certificate_validation.tsc_infra_acm_validation.certificate_arn
}

output "aws_api_gateway_domain_name_tsc_infra_custom_domain_regional_domain_name" {
  value = aws_api_gateway_domain_name.tsc_infra_custom_domain.regional_domain_name
}

output "aws_api_gateway_deployment_tsc_infra_api_deployment_invoke_url" {
  value = aws_api_gateway_deployment.tsc_infra_api_deployment.invoke_url
}

output "aws_api_gateway_stage_tsc_infra_api_stage_invoke_url" {
  value = aws_api_gateway_stage.tsc_infra_api_stage.invoke_url
}

output "aws_route53_health_check_tsc_infra_health_check_id" {
  value = aws_route53_health_check.tsc_infra_health_check.id
}

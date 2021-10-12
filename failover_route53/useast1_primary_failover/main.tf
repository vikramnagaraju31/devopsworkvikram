#create rest api gateway
resource "aws_api_gateway_rest_api" "tsc_infra_api" {
 name = "${var.infraname}-apigateway-${var.region}"
}

#create rest api gateway resource
resource "aws_api_gateway_resource" "tsc_infra_api_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.tsc_infra_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.tsc_infra_api.root_resource_id}"
  path_part   = "{proxy+}"
}

#create rest api gateway method
resource "aws_api_gateway_method" "tsc_infra_api_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.tsc_infra_api.id}"
  resource_id   = "${aws_api_gateway_resource.tsc_infra_api_resource.id}"
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

#create rest api gateway integration
resource "aws_api_gateway_integration" "tsc_infra_api_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.tsc_infra_api.id}"
  resource_id = "${aws_api_gateway_resource.tsc_infra_api_resource.id}"
  http_method = "${aws_api_gateway_method.tsc_infra_api_method.http_method}"
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.tsceksalbdomain}/{proxy}/"
  request_parameters =  {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

#create rest api gateway deployment
resource "aws_api_gateway_deployment" "tsc_infra_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.tsc_infra_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.tsc_infra_api_resource.id,
      aws_api_gateway_method.tsc_infra_api_method.id,
      aws_api_gateway_integration.tsc_infra_api_integration.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

#create rest api gateway staging
resource "aws_api_gateway_stage" "tsc_infra_api_stage" {
  deployment_id = aws_api_gateway_deployment.tsc_infra_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.tsc_infra_api.id
  stage_name    = "${var.stage}"
}

#create certificate on acm
resource "aws_acm_certificate" "tsc_infra_certificate" {
  domain_name       = "${var.domain}"
  validation_method = "DNS"
}

#create record set for acm certificate
resource "aws_route53_record" "tsc_infra_acm_record" {
  for_each = {
    for dvo in aws_acm_certificate.tsc_infra_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.tsc_infra_zone.zone_id
}

#validate acm certificate
resource "aws_acm_certificate_validation" "tsc_infra_acm_validation" {
  certificate_arn         = aws_acm_certificate.tsc_infra_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.tsc_infra_acm_record : record.fqdn]
}

#create custom domain for rest api gateway
resource "aws_api_gateway_domain_name" "tsc_infra_custom_domain" {
  domain_name              = "${var.domain}"
  regional_certificate_arn = aws_acm_certificate_validation.tsc_infra_acm_validation.certificate_arn
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

#create api mapping for custom domain
resource "aws_api_gateway_base_path_mapping" "tsc_infra_custom_domain_api_mapping" {
  api_id      = aws_api_gateway_rest_api.tsc_infra_api.id
  stage_name  = "${var.stage}"
  domain_name = aws_api_gateway_domain_name.tsc_infra_custom_domain.domain_name
}

#create route53 health check for failover
resource "aws_route53_health_check" "tsc_infra_health_check" {
  fqdn              = trim(aws_api_gateway_deployment.tsc_infra_api_deployment.invoke_url,"https://")
  port              = 443
  type              = "HTTPS"
  resource_path     = "/${var.stage}/cafe"
  failure_threshold = "3"
  request_interval  = "10"
  tags = {
    Name = "${var.infraname}-healthcheck-${var.region}"
  }
}

#create primary record set and associate health check
resource "aws_route53_record" "tsc_infra_failover_record_Set" {
  zone_id = data.aws_route53_zone.tsc_infra_zone.zone_id
  name    = "${var.subdomain}"
  type    = "A"
  failover_routing_policy {
    type = "${var.failoverroutingpolicy}"
  }
  set_identifier = "${var.setidentifier}"
  health_check_id = "${aws_route53_health_check.tsc_infra_health_check.id}"
  alias {
    name                   = aws_api_gateway_domain_name.tsc_infra_custom_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.tsc_infra_custom_domain.regional_zone_id
    evaluate_target_health = true
  }
}

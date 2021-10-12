data "aws_route53_zone" "tsc_infra_zone" {
  name         = "${var.zone}"
}
variable "tsceksalbdomain" {
  type = string
  description = "EKS ALB Domain URL"
}

variable "infraname" {
  description = "Infrastructure Name"
}

variable "region" {
  description = "AWS Region"
}

variable "stage" {
  description = "API Gateway Stage"
}

variable "zone" {
  description = "Zone or Domain Purchased"
}

variable "domain" {
  description = "Domain Name To Host App"
}

variable "subdomain" {
  description = "Sub Domain To Create Record Set"
}

variable "failoverroutingpolicy" {
  description = "Failover Routing Policy"
}

variable "setidentifier" {
  description = "Set Identifier"
}
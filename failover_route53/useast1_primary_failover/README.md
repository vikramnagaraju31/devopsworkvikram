Failover Primary: 

IAAC to
->create rest api gateway
->create rest api gateway resource
->create rest api gateway method
->create rest api gateway integration
->create rest api gateway deployment
->create rest api gateway staging
->create certificate on acm
->create record set for acm certificate
->validate acm certificate
->create custom domain for rest api gateway
->create api mapping for custom domain
->create route53 health check for failover
->create primary record set and associate health check

Command1: terraform init

Command2: terraform plan -var="tsceksalbdomain=<provide alb url created post eks deployment>"
         
          example: terraform plan -var="tsceksalbdomain=532b0051-tscsandboxdeploym-439d-716102070.us-east-1.elb.amazonaws.com"

Command3: terraform apply -var="tsceksalbdomain=<provide alb url created post eks deployment>" --auto-approve

          example: terraform apply -var="tsceksalbdomain=532b0051-tscsandboxdeploym-439d-716102070.us-east-1.elb.amazonaws.com" --auto-approve

Command4: terraform destroy -var="tsceksalbdomain=<provide alb url created post eks deployment>" --auto-approve

          example: terraform destroy -var="tsceksalbdomain=532b0051-tscsandboxdeploym-439d-716102070.us-east-1.elb.amazonaws.com" --auto-approve
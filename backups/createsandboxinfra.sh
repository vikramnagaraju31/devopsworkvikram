#!/bin/bash

cd eks-us-east-1/
terraform init
terraform plan
terraform apply --auto-approve
cd ../
cd eks-ap-south-1
terraform init
terraform plan
terraform apply --auto-approve
cd ../
cd globalaccelerator-us-east-1
terraform init
terraform plan
terraform apply --auto-approve
#!/bin/bash

cd globalaccelerator-us-east-1
terraform destroy --auto-approve
cd ../
cd eks-ap-south-1
terraform destroy --auto-approve
cd ../
cd eks-us-east-1/
terraform destroy --auto-approve


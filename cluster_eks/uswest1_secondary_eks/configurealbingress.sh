#!/bin/bash

TEMP_REGION=`terraform output region`
REGION=$(echo "$TEMP_REGION" | tr -d '"')

TEMP_CLUSTER_NAME=`terraform output cluster_name`
CLUSTER_NAME=$(echo "$TEMP_CLUSTER_NAME" | tr -d '"')

TEMP_ROLE_ARN=`terraform output aws_iam_role_eksalbingresscontroller_arn`
ROLE_ARN=$(echo "$TEMP_ROLE_ARN" | tr -d '"')

aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME
kubectl apply -f rbac-role-alb-ingress-controller.yaml
kubectl annotate serviceaccount -n kube-system alb-ingress-controller eks.amazonaws.com/role-arn=$ROLE_ARN
curl -o alb-ingress-controller.yaml https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.8/docs/examples/alb-ingress-controller.yaml
sed -i '' 's/# - --cluster-name=devCluster/- --cluster-name='"$CLUSTER_NAME"'/g' alb-ingress-controller.yaml
kubectl apply -f alb-ingress-controller.yaml
kubectl get pods -n kube-system

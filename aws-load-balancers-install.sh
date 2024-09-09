#!/bin/bash
echo "######### 1of4 初始化环境变量....."

CLUSTER_NAME=airbyte-on-eks
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' \
    --output text)

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy-${CLUSTER_NAME} \
    --policy-document file://iam_policy.json

eksctl create iamserviceaccount \
  --cluster=${CLUSTER_NAME} \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole-${CLUSTER_NAME} \
  --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=${CLUSTER_NAME} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 
  
aws ec2 create-tags \
        --tags "Key=kubernetes.io/role/elb,Value=1" \
        --resources "$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=PublicSubnet*' --query 'Subnets[*].SubnetId')"

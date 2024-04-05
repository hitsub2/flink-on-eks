#!/bin/bash

set -e

echo "install  required tools \n"
sudo yum install -y bash-completion moreutils jq

echo "install kubectl,eksctl \n"
sudo curl --silent --location -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
sudo chmod +x /usr/bin/kubectl
sudo -H -u ec2-user bash -c "kubectl completion bash >>  ~/.bash_completion"
sudo -H -u ec2-user bash -c ". /etc/profile.d/bash_completion.sh"
sudo -H -u ec2-user bash -c ". ~/.bash_completion"

ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

sudo curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

sudo tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

sudo mv /tmp/eksctl /usr/local/bin

sudo -H -u ec2-user bash -c "eksctl completion bash >> ~/.bash_completion"
echo "install  helm \n"
sudo curl --silent --location "https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/linux-amd64/helm /usr/bin
sudo chmod +x /usr/bin/helm

echo "Configure cloud9 to access the EKS cluster"
export ARN=$(aws sts get-caller-identity --output text --query Arn) 
export CLUSTER_NAME="eks-cluster-test"
aws eks create-access-entry --cluster-name $CLUSTER_NAME --principal-arn $ARN --type Standard
aws eks associate-access-policy --cluster-name $CLUSTER_NAME --principal-arn $ARN --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy


echo "Configuring Cloud9 Done \n"

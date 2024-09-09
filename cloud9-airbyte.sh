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

sudo tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp

sudo mv /tmp/eksctl /usr/bin

sudo -H -u ec2-user bash -c "eksctl completion bash >> ~/.bash_completion"
echo "install  helm \n"
sudo curl --silent --location "https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/linux-amd64/helm /usr/bin
sudo chmod +x /usr/bin/helm

echo "Configure cloud9 to access the EKS cluster"
echo export ROLE=$(aws sts get-caller-identity --query Arn | awk -F '/' '{print $2}') >> /home/ec2-user/.bashrc
echo export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region') >> /home/ec2-user/.bashrc
echo export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account) >> /home/ec2-user/.bashrc
echo export ROLE_ARN="arn:aws:iam::$(aws sts get-caller-identity --output text --query Account):role/$(aws sts get-caller-identity --query Arn | awk -F '/' '{print $2}')" >> /home/ec2-user/.bashrc
echo export CLUSTER_NAME="airbyte-on-eks" >> /home/ec2-user/.bashrc
source /home/ec2-user/.bashrc
aws eks create-access-entry --cluster-name airbyte-on-eks --principal-arn "arn:aws:iam::$(aws sts get-caller-identity --output text --query Account):role/$(aws sts get-caller-identity --query Arn | awk -F '/' '{print $2}')" --type STANDARD
aws eks associate-access-policy --cluster-name airbyte-on-eks --principal-arn "arn:aws:iam::$(aws sts get-caller-identity --output text --query Account):role/$(aws sts get-caller-identity --query Arn | awk -F '/' '{print $2}')" --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy --access-scope type=cluster

aws eks update-kubeconfig --name airbyte-on-eks
echo "Configuring Cloud9 Done \n"

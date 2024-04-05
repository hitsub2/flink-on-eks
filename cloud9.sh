#!/bin/bash

set -e

sudo yum install -y bash-completion moreutils jq

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

sudo curl --silent --location "https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/linux-amd64/helm /usr/bin
sudo chmod +x /usr/bin/helm

cat << EOF > /home/ec2-user/.bashrc.d/env.bash
export EKS_CLUSTER_NAME=flink-on-eks
export ACCOUNTID=${ACCOUNTID}
export AWS_DEFAULT_REGION=${REGION}
export KARPENTER_VERSION="v0.27.1"
export KARPENTER_IAM_ROLE_ARN="arn:aws:iam::${ACCOUNTID}:role/${EKS_CLUSTER_NAME}-karpenter"

aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME}
EOF

curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v2.4.1/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
sudo mv ec2-instance-selector /usr/local/bin/

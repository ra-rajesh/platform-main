terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = ">= 5.0"
    }
  }
}

locals {
  default_user_data = <<-EOF
    #!/bin/bash
    set -e

    apt-get update -y
    apt-get install -y curl unzip wget snapd gnupg software-properties-common jq

    # Install AWS CLI if not present
    if ! command -v aws &> /dev/null; then
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
      unzip /tmp/awscliv2.zip -d /tmp
      /tmp/aws/install
    fi

    # Install SSM Agent
    snap install amazon-ssm-agent --classic
    systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent
    systemctl start  snap.amazon-ssm-agent.amazon-ssm-agent

    # Install CloudWatch Agent
    wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/amazon-cloudwatch-agent.deb
    dpkg -i /tmp/amazon-cloudwatch-agent.deb || true
    chmod +x /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl || true

    # Retry fetching config and starting CloudWatch Agent
    for i in {1..60}; do
      /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config \
        -m ec2 \
        -c ssm:${var.cloudwatch_ssm_config_path} \
        -s && break

      echo "CloudWatch config not ready, retrying in 20s..."
      sleep 20
    done
  EOF

  user_data_final = (
    var.user_data != null && trimspace(var.user_data) != ""
  ) ? var.user_data : local.default_user_data
}

resource "aws_instance" "idlms_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.instance_profile_name
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address

  user_data                   = local.user_data_final
  user_data_replace_on_change = true

  tags = merge(var.ec2_tags, { Name = var.name })
}

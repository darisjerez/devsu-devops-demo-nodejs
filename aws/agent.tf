data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_iam_role" "agent" {
  name = "${var.project_name}-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "agent" {
  name = "${var.project_name}-agent-policy"
  role = aws_iam_role.agent.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "agent" {
  name = "${var.project_name}-agent-profile"
  role = aws_iam_role.agent.name
}

resource "aws_security_group" "agent" {
  name   = "${var.project_name}-agent-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "agent" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.agent_instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.agent.id]
  associate_public_ip_address = true
  key_name                    = var.agent_key_name
  iam_instance_profile        = aws_iam_instance_profile.agent.name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker git libicu
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user

    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install kubectl /usr/local/bin/

    mkdir -p /home/ec2-user/azagent
    chown ec2-user:ec2-user /home/ec2-user/azagent
  EOF

  tags = {
    Name = "${var.project_name}-azdevops-agent"
  }
}


data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*x86_64"]
  }
}

locals {
  ecr_url = aws_ecr_repository.app.repository_url
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y docker jq
    systemctl enable docker
    systemctl start docker
    REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
    aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${local.ecr_url}
    IMAGE="${local.ecr_url}:${var.image_tag}"
    docker pull $IMAGE || true
    docker rm -f app || true
    docker run -d --name app --restart unless-stopped -p 80:80 -e APP_VERSION=${var.image_tag} $IMAGE
  EOF

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

output "public_ip"    { value = aws_instance.web.public_ip }
output "public_dns"   { value = aws_instance.web.public_dns }
output "ecr_repo_url" { value = aws_ecr_repository.app.repository_url }
output "instance_id"  { value = aws_instance.web.id }

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl enable --now docker
    usermod -aG docker ubuntu

    docker run -d \
      --name java-springboot-api \
      --restart unless-stopped \
      -p 8080:8080 \
      -e SPRING_DATASOURCE_URL="jdbc:postgresql://${aws_db_instance.postgres_db.address}:5432/springbootdb" \
      -e SPRING_DATASOURCE_USERNAME="postgres" \
      -e SPRING_DATASOURCE_PASSWORD="${var.db_password}" \
      ghcr.io/mdsfelpe/docker-java-api:latest
  EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-app-server"
  }
}

resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.project_name}-${var.environment}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "${var.project_name}-${var.environment}-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}
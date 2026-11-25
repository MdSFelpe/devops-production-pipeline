output "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  value       = var.aws_region
}

output "ec2_public_ip" {
  description = "Public IP address of the Spring Boot EC2 server"
  value       = aws_instance.app_server.public_ip
}

output "rds_endpoint" {
  description = "Connection endpoint for the PostgreSQL RDS instance"
  value       = aws_db_instance.postgres_db.address
}

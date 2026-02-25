output "public_ip" {
  description = "Public ip address of the ci/cd agent"
  value       = aws_instance.this.public_ip
}

output "iam_role_arn" {
  description = "Arn of the agent IAM role"
  value       = aws_iam_role.this.arn
}

output "security_group_id" {
  description = "ID of the agent security group"
  value       = aws_security_group.this.id
}

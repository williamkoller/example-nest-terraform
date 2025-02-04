output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = [for i in aws_instance.example_nest_terraform_instance : i.id]
}

output "instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = [for i in aws_instance.example_nest_terraform_instance : i.public_ip]
}
output "public_subnet_ids" {
  value = [for i in aws_subnet.public_subnets : i.id]
}

output "private_subnet_ids" {
  value = [for i in aws_subnet.private_subnets : i.id]
}

output "vpc_id" {
  value = aws_vpc.new-vpc.id
}

output "subnet_ids" {
  value = concat(aws_subnet.public_subnets[*].id, aws_subnet.private_subnets[*].id)
}
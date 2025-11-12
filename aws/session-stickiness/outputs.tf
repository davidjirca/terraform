# ALB Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.web.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.web.arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.web.zone_id
}

# Target Group Outputs
output "target_group_arn" {
  description = "ARN of the Target Group with stickiness enabled"
  value       = aws_lb_target_group.web.arn
}

output "target_group_name" {
  description = "Name of the Target Group"
  value       = aws_lb_target_group.web.name
}

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_1_id" {
  description = "ID of public subnet 1"
  value       = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  description = "ID of public subnet 2"
  value       = aws_subnet.public_2.id
}

# Auto Scaling Group Outputs
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.web.arn
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

# Stickiness Configuration Info
output "stickiness_enabled" {
  description = "Whether stickiness is enabled on the target group"
  value       = true
}

output "stickiness_duration" {
  description = "Duration of stickiness cookie in seconds (24 hours)"
  value       = 86400
}

# Testing Instructions
output "testing_instructions" {
  description = "Quick testing command"
  value       = "Test stickiness with: curl -c cookies.txt http://${aws_lb.web.dns_name} && curl -b cookies.txt http://${aws_lb.web.dns_name}"
}
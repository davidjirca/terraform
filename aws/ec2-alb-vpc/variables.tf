variable "region" {
  type = string
  default = "eu-central-1"
}

variable "profile" {
  type = string
  default = "iamadmin"
}

variable "project_name" {
  description = "value"
  type = string
  default = "asg-demo"
}

variable "asg_min_size" {
  description = "value"
  type = number
  default = 1
}

variable "asg_max_size" {
  description = "value"
  type = number
  default = 3
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type = number
  default = 2
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type = string
  default = "10.0.0.0/16"
}
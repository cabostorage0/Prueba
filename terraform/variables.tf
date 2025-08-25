
variable "project_name"  { type = string  default = "devops-lab-free" }
variable "aws_region"    { type = string  default = "us-east-1" }
variable "instance_type" { type = string  default = "t2.micro" }
variable "image_tag"     { type = string  default = "latest" }
variable "github_repo"   { type = string  default = "OWNER/REPO" }

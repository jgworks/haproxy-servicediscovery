variable "vpc_id" {}
variable "ecs_cluster_name" {}
variable "subnets" { type = "list" }
variable "image" { }
variable "backend_count" { }

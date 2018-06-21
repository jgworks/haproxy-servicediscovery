#####################
# Serivce Discovery #
#####################

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

resource "aws_security_group" "allow_all" {
  name        = "haproxy-service-discovery"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    Name = "haproxy-service-discovery"
  }
}

resource "aws_service_discovery_private_dns_namespace" "private-service-discovery" {
  name        = "internal.local"
  description = "Private Service Discovery"
  vpc         = "${var.vpc_id}"
}

output "private-service-discovery-id" {
  value = "${aws_service_discovery_private_dns_namespace.private-service-discovery.id}"
}

resource "aws_elb" "elb-haproxy" {
  name = "haproxy-service-discovery"

  security_groups             = ["${aws_security_group.allow_all.id}"]
  subnets                     = ["${var.subnets}"]
  internal                    = "true"
  cross_zone_load_balancing   = "true"

  listener {
    instance_port      = 80
    instance_protocol  = "tcp"
    lb_port            = 80
    lb_protocol        = "tcp"
  }

  listener {
    instance_port     = 9000
    instance_protocol = "tcp"
    lb_port           = 9000
    lb_protocol       = "tcp"
  }

  tags {
    Name        = "haproxy-service-discovery"
    role        = "boomerang-haproxy"
    project     = "nebula"
    owner       = "Jonathan Works"
    department  = "Engineering"
    environment = "dev"
    created     = "Terraform"
  }
}

resource "aws_ecs_service" "haproxy-service" {
  name                               = "haproxy-service"
  cluster                            = "${var.ecs_cluster_name}"
  task_definition                    = "${aws_ecs_task_definition.haproxy-task.arn}"
  desired_count                      = "1"
  deployment_minimum_healthy_percent = "0"
  deployment_maximum_percent         = "100"

  load_balancer {
    elb_name       = "haproxy-service-discovery"
    container_name = "haproxy-service"
    container_port = "80"
  }
}

resource "aws_ecs_task_definition" "haproxy-task" {
  family                = "haproxy-service"
  container_definitions = "${data.template_file.task_definition.rendered}"
}

data "template_file" "task_definition" {
  template = "${file("haproxy-task.json")}"

  vars = {
	IMAGE = "${var.image}"
  }
}

resource "aws_ecs_service" "backend-service" {
  name                               = "backend-service"
  cluster                            = "${var.ecs_cluster_name}"
  task_definition                    = "${aws_ecs_task_definition.backend-task.arn}"
  desired_count                      = "${var.backend_count}"
  deployment_minimum_healthy_percent = "0"
  deployment_maximum_percent         = "100"

  service_registries {
    registry_arn = "${aws_service_discovery_service.backend-service-discovery.arn}"

    container_name = "backend-service"
    container_port = "80"
  }
}

resource "aws_ecs_task_definition" "backend-task" {
  family                = "backend-service"
  container_definitions = "${file("backend-task.json")}"
}

resource "aws_service_discovery_service" "backend-service-discovery" {
  name = "_backend._tcp"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.private-service-discovery.id}"

    dns_records {
      ttl  = 10
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

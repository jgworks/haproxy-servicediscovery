# AWS Service discovery with HAProxy

## Clone the repo
    git clone https://github.com/jgworks/haproxy-servicediscovery.git
    
## Build the container
    cd docker/
    docker build -t ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/haproxy-service-discovery:latest .
    docker push ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/haproxy-service-discovery:latest

## Run terraform

Create a terraform.tfvars and fill out the following values:

    vpc_id = "vpc-xxxxxxxx"
	ecs_cluster_name = "test-cluster"
	subnets = ["subnet-xxxxxx", "subnet-xxxxxx"]
	image = "ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/haproxy-service-discovery:latest"
    backend_count = "4"

Then Run

	terraform init
    terraform apply

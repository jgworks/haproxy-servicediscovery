# AWS Service discovery with HAProxy

## Create an AWS / ECS cluster

In AWS / ECS GUI page, click on "create cluster".
Use the following information when filling up the form:

    EC2 Linux + Networking
    name: test-cluster
    key/pair: YOURKEYPAIR
    security inbound rule: 22-9000

NOTE: ensure your AWS region support this feature...

## Clone the repo
    git clone https://github.com/jgworks/haproxy-servicediscovery.git

## Set up docker registry on AWS / ECS

    eval $(aws ecr get-login --no-include-email --region=us-east-1)
    aws ecr create-repository --repository-name haproxy-service-discovery --region=us-east-1

## Build the container
    VERSION=1
    docker build -t ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/haproxy-service-discovery:$VERSION docker/
    docker push ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/haproxy-service-discovery:$VERSION

## Run terraform

Create a terraform.tfvars and fill out the following values (VPC ID and subnet ID are the ones provided at ECS cluster creation step):

    vpc_id = "vpc-xxxxxxxx"
    ecs_cluster_name = "test-cluster"
    subnets = ["subnet-xxxxxx", "subnet-xxxxxx"]
    image = "ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/haproxy-service-discovery:VERSION"
    backend_count = "4"

Then Run

    terraform init
    terraform apply

NOTE: I had to "apply" twice


## Troubleshooting DNS

SSH into the EC2 instance running the HAProxy container, then:

    docker exec -it xxxxx bash
    while true ; do clear ; echo "show resolvers" | socat /tmp/socket - ; drill -t _backend._tcp.internal.local @10.0.0.2 SRV ; sleep 1 ; done


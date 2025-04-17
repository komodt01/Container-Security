provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "ecs_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "ecs-vpc"
  }
}

# Subnet
resource "aws_subnet" "ecs_subnet" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "ecs-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id
  tags = {
    Name = "ecs-igw"
  }
}

# Route Table
resource "aws_route_table" "ecs_public_rt" {
  vpc_id = aws_vpc.ecs_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_igw.id
  }
  tags = {
    Name = "ecs-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "ecs_public_rta" {
  subnet_id      = aws_subnet.ecs_subnet.id
  route_table_id = aws_route_table.ecs_public_rt.id
}

# Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Allow HTTP/HTTPS egress"
  vpc_id      = aws_vpc.ecs_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-security-group"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "secure_cluster" {
  name = "secure-container-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "secure_task" {
  family                   = "secure-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = "arn:aws:iam::248830917024:role/AWS-Security-Container"
  container_definitions    = file("container-definitions.json")
}

# ECS Service
resource "aws_ecs_service" "secure_service" {
  name            = "secure-container-service"
  cluster         = aws_ecs_cluster.secure_cluster.id
  task_definition = aws_ecs_task_definition.secure_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = [aws_subnet.ecs_subnet.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_route_table_association.ecs_public_rta]
}

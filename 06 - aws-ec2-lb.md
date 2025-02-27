main.tf

```
provider "aws" {
  region = var.region
}

# Security Group to allow inbound HTTP traffic
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create two EC2 instances with a web server using count
resource "aws_instance" "web" {
  count         = 2
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id     = var.subnet_id  # If you are specifying a single subnet

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "Hello from instance $(hostname)" > /var/www/html/index.html
  EOF

  tags = {
    Name = "WebInstance-${count.index + 1}"
  }
}

# Create an Application Load Balancer
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = var.alb_subnets

  tags = {
    Name = "WebALB"
  }
}

# Create a Target Group for the web instances
resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200-399"
  }
}

# Create a Listener for the ALB to forward traffic to the target group
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Register the EC2 instances with the target group
resource "aws_lb_target_group_attachment" "web_attachment" {
  count            = length(aws_instance.web)
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}


```

### variables.tf
```
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Provide an appropriate AMI ID (for example, an Amazon Linux 2 AMI)
variable "ami" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where resources will be deployed"
  type        = string
}

# If your instances are launched into a specific subnet, set that subnet id here.
variable "subnet_id" {
  description = "Subnet ID for EC2 instances"
  type        = string
}

# List of subnet IDs for the load balancer (should span at least two AZs for high availability)
variable "alb_subnets" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
}

```

### outputs.tf

```
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}
```
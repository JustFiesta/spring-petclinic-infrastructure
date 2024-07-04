# Create VPC
resource "aws_vpc" "this" {
    cidr_block        = "${var.vpc_cidr}"
}

# Create peering with default VPC to enable SSH connection from workstation
data "aws_vpc" "default" {
  default = true
}

resource "aws_vpc_peering_connection" "this" {
  vpc_id        = aws_vpc.this.id
  peer_vpc_id   = data.aws_vpc.default.id
  peer_region   = var.region

  tags = {
    Name = "capstone-vpc-peering"
  }
}

# Accept VPC peering
resource "aws_vpc_peering_connection_accepter" "this" {
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  auto_accept               = true

  tags = {
    Name = "capstone-vpc-peering-accepted"
  }
}

# Create subnets
resource "aws_subnet" "private_a" {
    vpc_id                  = aws_vpc.this.id
    cidr_block              = var.private_a
    map_public_ip_on_launch = false
    availability_zone       = "${var.region}a"

    tags = {
        Name = "capstone_private_a"
    }
}

resource "aws_subnet" "private_b" {
    vpc_id                  = aws_vpc.this.id
    cidr_block              = var.private_b
    map_public_ip_on_launch = false
    availability_zone       = "${var.region}b"

    tags = {
        Name = "capstone_private_b"
    }
}

# Create rdb subnet group
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "capstone_subnet_group"
  }
}

# Create internet gateway for subnet
resource "aws_internet_gateway" "gw" {
    vpc_id            = aws_vpc.this.id
        tags = {
        Name = "capstone_igw_gateway"
    }
}

# Create route tables in new VPC
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "capstone_private_route_table"
  }
}

resource "aws_route" "to_peer_vpc" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# Create route tables in default VPC
data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_route" "to_new_vpc" {
  route_table_id            = data.aws_route_table.default.id
  destination_cidr_block    = aws_vpc.this.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# Create security groups (allow: ssh - private, http - app, 8080 - jenkins, mysql)
resource "aws_security_group" "http" {
    name_prefix = "app_sg"
    vpc_id      = aws_vpc.this.id

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

    tags = {
        Name = "capstone_http"
    }
}

resource "aws_security_group" "ssh" {
    name_prefix = "ssh_sg"
    vpc_id      = aws_vpc.this.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "capstone_ssh"
    }
}

resource "aws_security_group" "jenkins" {
    name_prefix = "jenkins_sg"
    vpc_id      = aws_vpc.this.id

    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "capstone_jenkins"
    }
}

resource "aws_security_group" "rds" {
    name_prefix = "rds_sg"
    vpc_id      = aws_vpc.this.id

    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "mysql"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "capstone_rds"
    }
}

# Create Application Load Balancer
resource "aws_lb" "this" {
    name               = "capstone-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.http.id]
    subnets            = [aws_subnet.private_a.id, aws_subnet.private_b.id]

    tags = {
        Name = "capstone_alb"
    }
}

# Create Target Groups
resource "aws_lb_target_group" "app" {
    name     = "capstone-app-targets"
    port     = "${var.alb_app_port}"
    protocol = "HTTP"
    vpc_id   = aws_vpc.this.id

    health_check {
        path                = "/"
        interval            = 30
        timeout             = 3
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200-299"
    }

    tags = {
        Name = "capstone_target_group"
    }
}

resource "aws_lb_target_group" "jenkins" {
    name     = "capstone-jenkins-targets"
    port     = "${var.alb_jenkins_port}"
    protocol = "HTTP"
    vpc_id   = aws_vpc.this.id

    health_check {
        path                = "/"
        interval            = 30
        timeout             = 3
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200-299"
    }

    tags = {
        Name = "capstone_target_group"
    }
}

# Create Listeners
resource "aws_lb_listener" "app" {
    load_balancer_arn = aws_lb.this.arn
    port              = "${var.alb_app_port}"
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.app.arn
    }
}

resource "aws_lb_listener" "jenkins" {
    load_balancer_arn = aws_lb.this.arn
    port              = "${var.alb_jenkins_port}"
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.jenkins.arn
    }
}
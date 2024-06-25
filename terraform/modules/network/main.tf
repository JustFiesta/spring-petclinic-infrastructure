# Create VPC
resource "aws_vpc" "this" {
    cidr_block        = "${var.vpc_cidr}"
}

# Create subnets (public, private)
resource "aws_subnet" "public_a" {
    vpc_id                  = aws_vpc.this.id
    cidr_block              = var.public_sub_a
    map_public_ip_on_launch = true
    availability_zone       = "${var.region}a"
    tags = {
        Name = "capstone_public_a"
    }
}

resource "aws_subnet" "public_b" {
    vpc_id                  = aws_vpc.this.id
    cidr_block              = var.public_sub_b
    map_public_ip_on_launch = true
    availability_zone       = "${var.region}b"
    tags = {
        Name = "capstone_public_b"
    }
}

resource "aws_subnet" "private" {
    vpc_id            = aws_vpc.this.id
    cidr_block        = "${var.private_sub}"
    availability_zone = "${var.region}a"
    tags = {
        Name = "capstone_private"
    }
}

# Create internet gateway for public subnet
resource "aws_internet_gateway" "gw" {
    vpc_id            = aws_vpc.this.id
        tags = {
        Name = "capstone_igw_gateway"
    }
}

# Create NAT Gataway for private subnet
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.private.id
    tags = {
        Name = "capstone_nat_gateway"
    }
}

# Create IP for NAT Gataway
resource "aws_eip" "nat" {
    vpc = true
}

# Create route tables
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
    tags = {
        Name = "capstone_public_route_table"
    }
}

resource "aws_route_table_association" "public_a" {
    subnet_id      = aws_subnet.public_a.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
    subnet_id      = aws_subnet.public_b.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.this.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }
    tags = {
        Name = "capstone_private_route_table"
    }
}

resource "aws_route_table_association" "private" {
    subnet_id      = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}

# Create security groups (allow: ssh - private, http - app, 8080 - jenkins)
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

# Create Application Load Balancer
resource "aws_lb" "app" {
    name               = "capstone-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.http.id]
    subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

    tags = {
        Name = "capstone_alb"
    }
}

# Create Target Group
resource "aws_lb_target_group" "app" {
    name     = "capstone-targets"
    port     = "${var.alb_port}"
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

# Create Listener
resource "aws_lb_listener" "app" {
    load_balancer_arn = aws_lb.app.arn
    port              = "${var.alb_port}"
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.app.arn
    }
}
# Create VPC
resource "aws_vpc" "this" {
    cidr_block        = "${var.vpc_cidr}"
}

# Create subnets
resource "aws_subnet" "public" {
    vpc_id            = aws_vpc.this.id
    cidr_block        = "${var.public_sub}"
    map_public_ip_on_launch = true
    availability_zone = "${var.region}a"
    tags = {
        Name = "capstone_public"
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

resource "aws_internet_gateway" "gw" {
    vpc_id            = aws_vpc.this.id
        ags = {
        Name = "capstone_igw_gateway"
    }
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.public.id
    tags = {
        Name = "capstone_nat_gateway"
    }
}

resource "aws_eip" "nat" {
    vpc = true
}

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

resource "aws_route_table_association" "public" {
    subnet_id      = aws_subnet.public.id
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
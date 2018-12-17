provider "aws" {
    region = "ap-southeast-1"
}

# CREATE VPC AND ITS COMPONENTS -> INTERNET GATEWAY, ELASTIC IP AND NAT-GATEWAY
resource "aws_vpc" "vpc" {
    cidr_block = "${var.cidr_block}"
    
    tags {
        Name = "${var.this}-vpc"
    }
}
resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.this}-igw"
    }
}
resource "aws_eip" "eip" {
    vpc = true

    tags {
        Name = "${var.this}-eip"
    }
}
resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.eip.id}"
    subnet_id = "${aws_subnet.public.id}"
    
    tags {
        Name = "${var.this}-nat-gateway"
    }
    
    depends_on = ["aws_internet_gateway.igw"]
}

# CREATE PUBLIC ENTITIES -> SUBNET, ROUTE TABLE, AND TABLE ASSOCIATION
resource "aws_subnet" "public" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.1.0/24"
    availability_zone = "${data.aws_availability_zones.all.names[0]}"
    map_public_ip_on_launch = true
    
    tags {
        Name = "${var.this}-public-subnet"
    }
}
resource "aws_route_table" "public-route-table" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }
    
    tags {
        Name = "${var.this}-public-route"
    }
}
resource "aws_route_table_association" "public-route-table-assoc" {
    subnet_id = "${aws_subnet.public.id}"
    route_table_id = "${aws_route_table.public-route-table.id}"  
}
# CREATE PRIVATE ENTITIES -> SUBNET, ROUTE TABLE, AND TABLE ASSOCIATION
resource "aws_subnet" "private" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.2.0/24"
    availability_zone = "${data.aws_availability_zones.all.names[1]}"
    map_public_ip_on_launch = false
    
    tags {
        Name = "${var.this}-private-subnet"
    }
}
resource "aws_route_table" "private-route-table" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat.id}"
    }
    
    tags {
        Name = "${var.this}-private-route"
    }
}
resource "aws_route_table_association" "private-route-table-assoc" {
    subnet_id = "${aws_subnet.private.id}"
    route_table_id = "${aws_route_table.private-route-table.id}"
}

# SETUP EC2 COMPONENTS LAUNCH CONFIGURATION AND AUTOSCALING AND SECURITY GROUPS\
resource "aws_launch_configuration" "ec2_launch_configuration" {
    image_id        = "${var.ec2_instance_image}"  #"ami-0c88c9d4475a247f4"
    instance_type   = "t2.micro"
    security_groups = ["${aws_security_group.ec2_security_group.id}"]
    key_name        = "amazonlinux"  
    user_data       = "${data.template_file.user_data.rendered}"

    # provisioner "file" {
    #     content = "${data.template_file.index.rendered}"
    #     destination = "/var/www/sample/index.html"
    # }
       
    # wait new instance to be created before destroying the old ones
    # lifecycle {
    #     create_before_destroy = true
    # }
}
resource "aws_security_group" "ec2_security_group" {
    name = "cluster-servers-security-group"
    vpc_id = "${aws_vpc.vpc.id}"
    
    ingress { # HTTP port to be connected to ELB
        from_port   = "${var.server_http_port}"
        to_port     = "${var.server_http_port}"
        protocol    = "tcp"
        #cidr_blocks = ["0.0.0.0/0"]
        security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
    } 
    
    ingress { # SSH for debugging
        from_port    = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress { # HTTPS for updating packages in HTTPS
        from_port   = "443"
        to_port     = "443"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress { # connect to internet
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
    
    lifecycle {
        create_before_destroy = true
    }
}

# Autoscaling helps expands the number of instances
resource "aws_autoscaling_group" "ec2_autoscaling_group" {
    launch_configuration = "${aws_launch_configuration.ec2_launch_configuration.id}"
    # availability_zones   = ["${data.aws_availability_zones.all.names}"]
    vpc_zone_identifier = ["${aws_subnet.private.id}"]
    load_balancers    = ["${aws_elb.load_balancer.name}"]
    health_check_type = "ELB"
    
    min_size = 2
    max_size = 10
    
    tag {
        key   = "${var.this}-autoscaling-group"
        value = "cluster-servers"
        propagate_at_launch = true
    }
}
resource "aws_autoscaling_schedule" "scale_out_at_daytime" {
    scheduled_action_name = "scale_out_at_daytime"
    min_size = 2
    max_size = 4
    desired_capacity = 4
    recurrence = "0 9 * * *"
    
    autoscaling_group_name = "${aws_autoscaling_group.ec2_autoscaling_group.name}"
}
resource "aws_autoscaling_schedule" "scale_in_at_nighttime" {
    scheduled_action_name = "scale_out_at_nighttime"
    min_size = 2
    max_size = 4
    desired_capacity = 2
    recurrence = "0 17 * * *"
    
    autoscaling_group_name = "${aws_autoscaling_group.ec2_autoscaling_group.name}"
}

# SETUP ELB AND ITS SECURITY GROUP
resource "aws_elb" "load_balancer" {
    name = "clusters-elb"
    #availability_zones = ["${data.aws_availability_zones.all.names}"]
    security_groups    = ["${aws_security_group.load_balancer_security_group.id}"]
    subnets = ["${aws_subnet.public.id}", "${aws_subnet.private.id}"]
    
    listener {
        lb_port     = 80
        lb_protocol = "http"
        instance_port     = "${var.server_http_port}"
        instance_protocol = "http"
    }
    
    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout  = 3
        interval = 30
        target   = "HTTP:${var.server_http_port}/"
    }
    tags {
        Name = "${var.this}-elb"
    }
}

resource "aws_security_group" "load_balancer_security_group" {
    name = "clusters-elb-SG"
    vpc_id = "${aws_vpc.vpc.id}"
    
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
    
    tags {
        Name = "${var.this}-elb-sg"
    }
}


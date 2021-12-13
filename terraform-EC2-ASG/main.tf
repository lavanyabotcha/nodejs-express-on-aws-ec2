//data "aws_availability_zones" "all" {}

provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_vpc" "test-vpc-01" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"
    tags = {
        Environment = "test"
        Name = "test-vpc-01"
    }
}

resource "aws_internet_gateway" "test-igw-01" {
    vpc_id = "${aws_vpc.test-vpc-01.id}"
    tags = {
        Environment = "test"
        Name = "test-igw-01"
    }
}

resource "aws_subnet" "test-pub-subnet-01" {
    vpc_id                  = "${aws_vpc.test-vpc-01.id}"
    cidr_block              = "10.0.10.0/24"
    availability_zone       = "us-east-1d"
    map_public_ip_on_launch = true
    tags = {
        Name = "test-subnet-01"
    }
}

resource "aws_route_table" "test-pub-rt-01" {
    vpc_id     = "${aws_vpc.test-vpc-01.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.test-igw-01.id}"
    }
    tags = {
        Name = "test-pub-rt-01"
    }
}

resource "aws_route_table_association" "test-rt-association-01" {
  subnet_id      = "${aws_subnet.test-pub-subnet-01.id}"
  route_table_id = "${aws_route_table.test-pub-rt-01.id}"
}


resource "aws_security_group" "test-autoscaling-sg-01" {
    name        = "test-autoscaling-sg-01"
    description = "AutoScaling-Security-Group-1"
    vpc_id      = "${aws_vpc.test-vpc-01.id}"
    
    ingress {
        from_port       = 0
        to_port         = -1
        protocol        = "icmp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 3000
        to_port         = 3000
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_launch_configuration" "test-lc-01" {
    name_prefix                 = "test-lc-"
    image_id                    = "ami-061ac2e015473fbe2"
    instance_type               =  "${var.instance_type}"
    iam_instance_profile        = "${aws_iam_instance_profile.main.name}"
    security_groups             = ["${aws_security_group.test-autoscaling-sg-01.id}"]
    enable_monitoring           = false
    ebs_optimized               = false

      user_data = <<-EOF
              #!/bin/bash
              echo "userdata-start"
              logfile=/var/log/install_agent.log
              exec >> $logfile 2>&1
              sudo yum -y update
              sudo yum -y install ruby
              sudo yum -y install wget
              sudo yum -y install httpd
              cd /home/ec2-user
              wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
              sudo chmod +x ./install
              sudo ./install auto
              sudo service httpd start
              echo "userdata-end"
              EOF  

    lifecycle {
    create_before_destroy = true
    }

    root_block_device {
        volume_type           = "gp2"
        volume_size           = 8
        delete_on_termination = true
    }
}

resource "aws_elb" "test-lb-01" {
    name                        = "test-lb-01"
    subnets                     = ["${aws_subnet.test-pub-subnet-01.id}"]
    security_groups             = ["${aws_security_group.test-autoscaling-sg-01.id}"]
    instances                   = []
    cross_zone_load_balancing   = true
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 300
    internal                    = false
    listener {
        instance_port      = 80
        instance_protocol  = "http"
        lb_port            = 80
        lb_protocol        = "http"
        ssl_certificate_id = ""
    }
    health_check {
        healthy_threshold   = 10
        unhealthy_threshold = 2
        interval            = 30
        target              = "HTTP:80/index.html"
        timeout             = 5
    }
    tags = {
        Environment = "test"
        Name = "test-elb-01"
    }
}

resource "aws_autoscaling_group" "test-asg-01" {
    desired_capacity          = "${var.desired_capacity}"
    health_check_grace_period = 300
    health_check_type         = "EC2"
    launch_configuration      = "${aws_launch_configuration.test-lc-01.name}"
    max_size                  = "${var.max_size}"
    min_size                  = "${var.min_size}"
    name                      = "test-asg-01"
    vpc_zone_identifier       = ["${aws_subnet.test-pub-subnet-01.id}"]
    
    lifecycle {
    create_before_destroy = true
    }

    tags = [
      {
        key   = "Environment"
        value = "test"
        propagate_at_launch = true
      },
      {
        key   = "Name"
        value = "${var.ec2_tag}"
        propagate_at_launch = true
      }
    ]
}

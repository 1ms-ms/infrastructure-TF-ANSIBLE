provider "aws" {
  region     = "eu-west-1"
  access_key = ""
  secret_key = ""
}

resource "aws_instance" "myec2" {
   count = length(aws_subnet.subnet.*.id)
   ami = "ami-0bf84c42e04519c85"
   instance_type = "t2.micro"
   key_name = "ansible"
   subnet_id = element(aws_subnet.subnet.*.id, count.index)
   security_groups = [aws_security_group.sg.id, ]
   tags = {
     Name = element(var.instance_tags, count.index)
   }
}
resource "aws_vpc" "VPC" {
  cidr_block       = var.VPC
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC_TERRAFORM"
  }
}
resource "aws_subnet" "subnet" {
  count = 3
  vpc_id = aws_vpc.VPC.id
  cidr_block = element(cidrsubnets(var.VPC, 8, 4, 4), count.index)
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  tags = {
    Name = element(var.sub_tags, count.index)
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "GW_TERRAFORM"
  }
}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "RT_TERRAFORM"
  }
}
resource "aws_route_table_association" "RT_ASSOCIATION" {
  count = 3
  subnet_id = element(aws_subnet.subnet.*.id, count.index)
  route_table_id = aws_route_table.rt.id
}
resource "aws_security_group" "sg" {
  name        = "SG_TERRAFORM"
  vpc_id      = aws_vpc.VPC.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTPs"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG_TERRAFORM"
  }
}
resource "aws_eip" "eip" {
  count            = length(aws_instance.myec2.*.id)
  instance         = element(aws_instance.myec2.*.id, count.index)
  public_ipv4_pool = "amazon"
  vpc              = true

  tags = {
    "Name" = "EIP-${count.index}"
  }
}
resource "aws_eip_association" "eip_association" {
  count         = length(aws_eip.eip)
  instance_id   = element(aws_instance.myec2.*.id, count.index)
  allocation_id = element(aws_eip.eip.*.id, count.index)
}
resource "aws_lb_target_group" "tg" {
  name        = "TargetGroup"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.VPC.id

  health_check {
    path = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout = 4
    interval = 5
    matcher = "200"
  }
}
resource "aws_alb_target_group_attachment" "tgattachment" {
  count            = 3
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = element(aws_instance.myec2.*.id, count.index)
}
resource "aws_lb" "lb" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id, ]
  subnets            = aws_subnet.subnet.*.id
}
resource "aws_lb_listener" "me" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
    }
}
resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.me.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn

  }

  condition {
    path_pattern {
      values = ["/var/www/html/index.html"]
    }
  }
}
data "aws_availability_zones" "azs" {}

output "instance_ip_addr" {
  value = aws_eip.eip.*.public_ip
}

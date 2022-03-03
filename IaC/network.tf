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

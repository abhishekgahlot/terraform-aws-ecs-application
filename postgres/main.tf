provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.123.0.0/16"
}

data "aws_availability_zones" "available" {}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "private" {
  count             = 2
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc.main.id}"
}

resource "aws_db_subnet_group" "rdsmain_private" {
  name        = "rdsmain-private"
  description = "Private subnets for RDS instance"
  subnet_ids  = [ "${aws_subnet.private.*.id}" ]
}


resource "aws_db_instance" "default" {
  allocated_storage    = 100
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "10.6"
  instance_class       = "db.t2.micro"
  name                 = "trademany"
  username             = "trademany"
  availability_zone    = "ap-southeast-1a"
  password             = "password here"
  db_subnet_group_name = "${aws_db_subnet_group.rdsmain_private.name}"
}
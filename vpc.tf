resource "aws_vpc" "bastion" {
   cidr_block		= "10.0.0.0/16"
   enable_dns_support 	= true
   enable_dns_hostnames	= true
   tags = {
      Name = "${var.project_name}"
   }
}

resource "aws_subnet" "PN1" {
   vpc_id		= "${aws_vpc.bastion.id}"
   cidr_block		= "10.0.1.0/24"
   availability_zone 	= "us-east-2a"
   map_public_ip_on_launch = "true"

   tags = {
      Name 		= "PN1"
   }
}

resource "aws_subnet" "PN2" {
   vpc_id		= "${aws_vpc.bastion.id}"
   cidr_block		= "10.0.2.0/24"
   availability_zone 	= "us-east-2b"

   tags = {
      Name 		= "PN2"
   }
}

resource "aws_subnet" "PN3" {
   vpc_id		= "${aws_vpc.bastion.id}"
   cidr_block		= "10.0.3.0/24"
   availability_zone 	= "us-east-2c"

   tags = {
      Name 		= "PN3"
   }
}

resource "aws_internet_gateway" "bastion" {
   vpc_id 		= "${aws_vpc.bastion.id}"

   tags = {
      Name 		= "${var.project_name}"
   }
}

resource "aws_nat_gateway" "bastion" {
   allocation_id	= "${aws_eip.bastion.id}"
   subnet_id		= "${aws_subnet.PN1.id}"

   tags = {
      Name 		= "gw NAT"
   }
}

resource "aws_security_group" "allow_ssh" {
   name			= "allow_ssh"
   description		= "Allow SSH inbound traffic"
   vpc_id		= "${aws_vpc.bastion.id}"

   ingress {
      from_port		= 0
      to_port		= 22
      protocol		= "tcp"
      cidr_blocks	= ["0.0.0.0/0"]
   }

   tags = {
      Name 	= "${var.project_name}"
   }
}

resource "aws_route_table" "pub" {
   vpc_id		= "${aws_vpc.bastion.id}"
 
   route {
      cidr_block 	= "0.0.0.0/0"
      gateway_id 	= "${aws_internet_gateway.bastion.id}"
   }

   tags = {
      Name 		= "${var.project_name}_pub"
   }
}

resource "aws_route_table" "priv" {
   vpc_id		= "${aws_vpc.bastion.id}"
   
   route {
      cidr_block 	= "0.0.0.0/0"
      gateway_id 	= "${aws_nat_gateway.bastion.id}"
   }

   tags = {
      Name 		= "${var.project_name}"
   }
}

resource "aws_route_table_association" "pub_ass" {
   subnet_id		= "${aws_subnet.PN1.id}"
   route_table_id 	= "${aws_route_table.pub.id}"
}

resource "aws_route_table_association" "priv_ass" {
   subnet_id		= "${aws_subnet.PN2.id}"
   route_table_id	= "${aws_route_table.priv.id}"
}

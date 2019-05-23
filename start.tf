provider "aws" {
   access_key	= "${var.access_key}"
   secret_key	= "${var.secret_key}"
   region	= "us-east-2"
   shared_credentials_file = "/home/akakiy/.ssh"
   profile	= "ld_rsa"  
}

resource "aws_instance" "web" {
   ami	= "ami-0ebbf2179e615c338"
   instance_type = "t2.micro"
   
   key_name = "liver"
   subnet_id = "${aws_subnet.PN1.id}"
}

resource "aws_eip" "bastion" {
   vpc = true
}

data "aws_ami" "ubuntu" {
   most_recent		= true

   filter {
      name		= "name"
      values		= ["ubuntu/images/hvm-ssd/ubuntu-*-18.04-amd64-server-*"]
   }

   filter {
      name		= "virtualization-type"
      values		= ["hvm"]
   }

   owners		= ["099720109477"]
}

resource "aws_launch_configuration" "as_conf" {
   name_prefix		= "terraform-lc-example-"
   image_id		= "${data.aws_ami.ubuntu.id}"
   instance_type	= "t2.micro"

   security_groups	= ["${aws_security_group.allow_ssh.id}"]
   key_name		= "liver"

   lifecycle {
      create_before_destroy	= true
   }
}

resource "aws_placement_group" "bast" {
   name			= "bast"
   strategy		= "cluster"
}

resource "aws_autoscaling_group" "app" {
   name			= "terraform-asg"
   launch_configuration = "${aws_launch_configuration.as_conf.name}"
   min_size		= 2
   max_size		= 2
   health_check_grace_period = 300
   health_check_type	= "ELB"
   vpc_zone_identifier	= ["${aws_subnet.PN2.id}", "${aws_subnet.PN3.id}"]

   lifecycle {
      create_before_destroy = true
   }
}

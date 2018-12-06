resource "aws_launch_configuration" "LCPub1" {
  name_prefix = "LCPub1-"
  image_id = "${var.amiId}"
  instance_type = "t2.micro"
  associate_public_ip_address  = true
  key_name = "${var.KeyPairName}"
  security_groups = ["${aws_security_group.PubSg.id}"]
  root_block_device {
    volume_size = "${var.RootVolume}"
  }
  ebs_block_device {
    volume_size = "${var.EbsVolume}"
    device_name = "/dev/xvda"
  }
}

resource "aws_launch_configuration" "LCPub2" {
  name_prefix = "LCPub2-"
  image_id = "${var.amiId}"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = "${var.KeyPairName}"
  security_groups = ["${aws_security_group.PubSg.id}"]
}


resource "aws_launch_configuration" "LCPri1" {
  name_prefix = "LCPri1-"
  image_id = "${var.amiId}"
  instance_type = "t2.micro"
  key_name = "${var.KeyPairName}"
  security_groups = ["${aws_security_group.PriSg.id}"]

}
resource "aws_launch_configuration" "LCPri2" {
  name_prefix = "LCPri2-"
  image_id = "${var.amiId}"
  instance_type = "t2.micro"
  key_name = "${var.KeyPairName}"
  security_groups = ["${aws_security_group.PriSg.id}"]
}


resource "aws_autoscaling_group" "Webinstance2" {
  name_prefix          = "Webinstance2"
  launch_configuration = "${aws_launch_configuration.LCPub1.id}"
  vpc_zone_identifier  = ["${aws_subnet.PubSub1.id}"]
  max_size             = "${var.desired_capacity}"
  min_size             = 1
  desired_capacity     = "${var.desired_capacity}"
  load_balancers       = ["${aws_elb.PublicElb.id}"]

  tag {
        key = "Name"
        value = "raj-WebServer1"
        propagate_at_launch = true
    }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "Webinstance1" {
  name_prefix          = "Webinstance1"
  launch_configuration = "${aws_launch_configuration.LCPub2.id}"
  vpc_zone_identifier  = ["${aws_subnet.PubSub2.id}"]
#  associate_public_ip_address  = true
  max_size             = "${var.desired_capacity}"
  min_size             = 1
  desired_capacity     = "${var.desired_capacity}"

  load_balancers       = ["${aws_elb.PublicElb.id}"]

  lifecycle {
    create_before_destroy = true
  }

    tag {
        key = "Name"
        value = "raj-WebServer2"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_group" "AppServer1" {
  name_prefix          = "AppServer1"
  launch_configuration = "${aws_launch_configuration.LCPri1.id}"
  vpc_zone_identifier  = ["${aws_subnet.PriSub1.id}"]
  max_size             = "${var.desired_capacity}"
  min_size             = 1
  desired_capacity     = "${var.desired_capacity}"

  load_balancers       = ["${aws_elb.PrivateElb.id}"]

  lifecycle {
    create_before_destroy = true
  }
    tag {
        key = "Name"
        value = "raj-AppServer1"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_group" "Appinstance2" {
  name_prefix          = "Appinstance2"
  launch_configuration = "${aws_launch_configuration.LCPri2.id}"
  vpc_zone_identifier  = ["${aws_subnet.PriSub2.id}"]
  max_size             = "${var.desired_capacity}"
  min_size             = 1
  desired_capacity     = "${var.desired_capacity}"

  load_balancers       = ["${aws_elb.PrivateElb.id}"]

  lifecycle {
    create_before_destroy = true
  }
      tag {
        key = "Name"
        value = "raj-Appinstance2"
        propagate_at_launch = true
    }
}
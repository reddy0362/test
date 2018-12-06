resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags {
    Name = "Test-VPC"
  }
}
######################################################################
resource "aws_subnet" "PubSub1" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
  tags {
    Name = "Test_PubSubnet1"
  }
}

resource "aws_subnet" "PubSub2" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = true
  tags {
    Name = "Test_PubSubnet2"
  }
}

resource "aws_subnet" "PriSub1" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.region}a"
  tags {
    Name = "Test_PriSubnet1"
  }
}

resource "aws_subnet" "PriSub2" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "${var.region}b"
  tags {
    Name = "Test_PriSubnet2"
  }
}
resource "aws_subnet" "DbSub1" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.5.0/24"
  availability_zone = "${var.region}a"
  tags {
    Name = "DatabaseSubnet1"
  }
}
resource "aws_subnet" "DbSub2" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.6.0/24"
  availability_zone = "${var.region}b"
  tags {
    Name = "DatabaseSubnet2"
  }
}

############################################################################
resource "aws_ebs_volume" "WebVol1" {
    availability_zone = "${aws_subnet.PubSub1.availability_zone}"
    size = "${var.EbsVolume}"
    tags {
        Name = "Test-webEbsVolume"
    }
}


resource "aws_ebs_volume" "WebVol2" {
    availability_zone = "${aws_subnet.PubSub2.availability_zone}"
    size = "${var.EbsVolume}"
    tags {
        Name = "Test-webEbsVolume"
    }
}

resource "aws_ebs_volume" "AppVol1" {
    availability_zone = "${aws_subnet.PriSub1.availability_zone}"
    size = "${var.EbsVolume}"
    tags {
        Name = "Test-appEbsVolume"
    }
}

resource "aws_ebs_volume" "AppVol2" {
    availability_zone = "${aws_subnet.PriSub2.availability_zone}"
    size = "${var.EbsVolume}"
    tags {
        Name = "Test-appEbsVolume"
    }
}
#################################################################################################
resource "aws_security_group" "PubSg" {
  vpc_id     = "${aws_vpc.vpc.id}"
  description = "Allow all http,https and ssh conection from internet"
  tags{
    Name= "public Security Group"
  }

ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "Test_Public_SecurityGroup"
  }
}

#######
resource "aws_security_group" "PrivateSG" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
        Name = "Test_Private_Security_Group"
  }
  description = "ONLY tcp CONNECTION INBOUND"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
      security_groups = ["${aws_security_group.PubSg.id}"]
  }
  ingress {
      from_port   = "22"
      to_port     = "22"
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
    egress { # MySQL
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["${var.Dbsubnet_cidr}"]
    }
}
########DB
resource "aws_security_group" "Database" {
  name = "Database"
  tags {
        Name = "Database securitygroups"
  }
  description = "ONLY tcp CONNECTION INBOUND"
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
      from_port = 3306
      to_port = 3306
      protocol = "TCP"
      security_groups = ["${aws_security_group.PrivateSG.id}"]
  }
  #ingress {
     # from_port   = "22"
     # to_port     = "22"
     # protocol    = "TCP"
    #  cidr_blocks = ["0.0.0.0/0"]
 # }
  ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
##############
#bastian host


resource "aws_security_group" "bastion-sg" {
  name   = "bastion-security-group"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion"
{
  ami                         = "ami-009d6802948d06e52"
  key_name                    = "${var.KeyPairName}"
  instance_type               = "t2.micro"
  vpc_security_group_ids             = ["${aws_security_group.bastion-sg.id}"]
  subnet_id = "${aws_subnet.PubSub1.id}"
  associate_public_ip_address = true
  root_block_device {
    volume_size = "${var.RootVolume}"
  }
  ebs_block_device {
    volume_size = "${var.EbsVolume}"
    device_name = "/dev/xvda"
  }
}
resource "aws_eip" "lb" {
  instance = "${aws_instance.bastion.id}"
  vpc      = true
}

###########################################################
#network
##############################
################################INTERNET GATEWAY ########################
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "INTERNET GATEWAY"
  }
}
#################################adding a route to internet gateway ############
resource "aws_route" "pub_route" {
  route_table_id   = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id  = "${aws_internet_gateway.ig.id}"
}
##############################ADDING A ELASTIC IP ########################
resource "aws_eip" "eip1" {
  vpc = true
  depends_on = ["aws_internet_gateway.ig"]
}
resource "aws_eip" "eip2" {
  vpc = true
  depends_on = ["aws_internet_gateway.ig"]
}

###############################CREATING A NAT GATEWAY FOR SUBNET ########
resource "aws_nat_gateway" "natpub1" {
  allocation_id ="${aws_eip.eip1.id}"
  subnet_id = "${aws_subnet.PubSub1.id}"
  depends_on = ["aws_internet_gateway.ig"]
}
resource "aws_nat_gateway" "natpub2" {
  allocation_id ="${aws_eip.eip2.id}"
  subnet_id = "${aws_subnet.PubSub2.id}"
  depends_on = ["aws_internet_gateway.ig"]
}

################################CREATING A PriSub1 & prisub 2ROUTE TABLEs#############
resource "aws_route_table" "private_route_table1" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "private subnet1 route table"
  }
}
resource "aws_route_table" "private_route_table2" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "private subnet2 route table"
  }
}
###################################adding Prisub1 route& prisub 2 to NAT###################
resource "aws_route" "private_route1" {
  route_table_id = "${aws_route_table.private_route_table1.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id   = "${aws_nat_gateway.natpub1.id}"
}
resource "aws_route" "private_route2" {
  route_table_id = "${aws_route_table.private_route_table2.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id   = "${aws_nat_gateway.natpub2.id}"
}
##################################Associate a Route table to public###############
resource "aws_route_table_association" "public_association1" {
  subnet_id = "${aws_subnet.PubSub1.id}"
  route_table_id = "${aws_vpc.vpc.main_route_table_id}"
}
resource "aws_route_table_association" "public_association2" {
  subnet_id = "${aws_subnet.PubSub2.id}"
  route_table_id = "${aws_vpc.vpc.main_route_table_id}"
}

#resource "aws_route_table_association" "public_association2" {
#  subnet_id = "${aws_subnet.PubSub2.id}"
#  route_table_id = "${aws_vpc.vpc.main_route_table_id}"
#}

#####################################Associate Route to private##########
resource "aws_route_table_association" "private_association1" {
  subnet_id = "${aws_subnet.PriSub1.id}"
  route_table_id = "${aws_route_table.private_route_table1.id}"
}
resource "aws_route_table_association" "private_association2" {
  subnet_id = "${aws_subnet.PriSub2.id}"
  route_table_id = "${aws_route_table.private_route_table2.id}"
}

#######################################################################
###############
/*resource "aws_network_acl" "Test_nacl" {
  vpc_id = "${aws_vpc.vpc.id}"
  subnet_ids = ["${aws_subnet.PriSub1.id}"]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags {
    Name = "Nacl for Private Subnets "
  }
}*/
#####################
data "aws_elb_service_account" "main" {}
resource "aws_s3_bucket" "bucket-logs" {
  bucket = "${var.bucket_logs}"
  acl    = "log-delivery-write"
  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.bucket_logs}/my-logs/AWSLogs/127311923021/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}

##########################################################################################
resource "aws_elb" "PublicElb" {
  name               = "PublicElb"
  #availability_zones = ["${var.region}a, ${var.region}b"]

  access_logs {
    bucket        = "${var.bucket_logs}"
    bucket_prefix = "PublicElb"
  }
  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }
  //instances             = ["${aws_instance.Webinstance1.id}" , "${aws_instance.Webinstance2.id}"]
  subnets  = ["${aws_subnet.PubSub1.id}" , "${aws_subnet.PubSub2.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tags {
    Name = "Test-PublicElb"
  }
}
resource "aws_elb" "PrivateElb" {
  name               = "PrivateElb"
  #availability_zones = ["${var.region}a", "${var.region}b"]
  access_logs {
    bucket        = "${var.bucket_logs}"
    bucket_prefix = "PrivateElb"
  }
  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  //instances             = ["${aws_instance.Appinstance1.id}", "${aws_instance.Appinstance2.id}"]
  subnets  = ["${aws_subnet.PriSub1.id}", "${aws_subnet.PriSub2.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "Test-PrivateElb"
  }
}

###########################################################################################
##############################################################################################
resource "aws_db_subnet_group" "DBgroup" {
  name = "final"
  subnet_ids = ["${aws_subnet.DbSub1.id}", "${aws_subnet.DbSub2.id}"]

  tags {
    Name = "my DB group"
 }
}
resource "aws_rds_cluster" "MainRDS" {
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora-mysql"
  availability_zones      = ["${aws_subnet.PriSub1.availability_zone}"]
  database_name           = "MainDB"
  master_username         = "admin"
  master_password         = "${var.pwd}"
  backup_retention_period = 5
  preferred_backup_window = "03:00-05:00"
  db_subnet_group_name    = "${aws_db_subnet_group.DBgroup.name}"
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  skip_final_snapshot     = true

}


resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 2
  engine             = "aurora-mysql"
  identifier         = "aurora-cluster-${count.index}"
  cluster_identifier = "${aws_rds_cluster.MainRDS.id}"
  instance_class     = "${var.rdsInstanceType}"
  db_subnet_group_name    = "${aws_db_subnet_group.DBgroup.name}"

}

resource "aws_db_cluster_snapshot" "example" {
  db_cluster_identifier          = "${aws_rds_cluster.MainRDS.id}"
  db_cluster_snapshot_identifier = "aurora-cluster-snapshot"
}


output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

#### autoscaling
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
  security_groups = ["${aws_security_group.PrivateSG.id}"]

}
resource "aws_launch_configuration" "LCPri2" {
  name_prefix = "LCPri2-"
  image_id = "${var.amiId}"
  instance_type = "t2.micro"
  key_name = "${var.KeyPairName}"
  security_groups = ["${aws_security_group.PrivateSG.id}"]
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
        value = "Test-WebServer1"
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

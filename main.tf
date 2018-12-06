resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  tags {
    Name = "raj-VPC"
  }
}
######################################################################
resource "aws_subnet" "PubSub1" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  tags {
    Name = "raj-PubSubnet1"
  }
}

resource "aws_subnet" "PubSub2" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.region}b"
  tags {
    Name = "raj-PubSubnet2"
  }
}

resource "aws_subnet" "PriSub1" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.region}a"
  tags {
    Name = "raj-PriSubnet1"
  }
}

resource "aws_subnet" "PriSub2" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "${var.region}b"
  tags {
    Name = "raj-PriSubnet2"
  }
}
############################################################################
resource "aws_ebs_volume" "WebVol1" {
    availability_zone = "${aws_subnet.PubSub1.availability_zone}"
    size = "${var.EbsVolume}"
    tags {
        Name = "raj-webEbsVolume"
    }
}


resource "aws_ebs_volume" "WebVol2" {
    availability_zone = "${aws_subnet.PubSub2.availability_zone}"
    size = "${var.EbsVolume}"
    tags {
        Name = "raj-webEbsVolume"
    }
}

resource "aws_ebs_volume" "AppVol1" {
    availability_zone = "${aws_subnet.PriSub1.availability_zone}"
    size = "${var.EbsVolume}"
    tags {
        Name = "raj-appEbsVolume"
    }
}

resource "aws_ebs_volume" "AppVol2" {
    availability_zone = "${aws_subnet.PriSub2.availability_zone}"
    size = "${var.EbsVolume}"
    tags {
        Name = "raj-appEbsVolume"
    }
}
#################################################################################################
resource "aws_security_group" "PubSg" {
  vpc_id     = "${aws_vpc.vpc.id}"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 65535
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

  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  ingress {

    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
}


  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags {
    Name = "raj Public SG"
  }
}

resource "aws_security_group" "PriSg" {
  vpc_id = "${aws_vpc.vpc.id}"
  name = "sg_test_web"
  description = "Allow traffic from public subnet"
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  tags {
    Name = "raj Private SG"
  }
}
###########################################################
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
          "arn:aws:iam::127311923021:root"
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
    Name = "raj-PublicElb"
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
    Name = "raj-PrivateElb"
  }
}

###########################################################################################
##############################################################################################
resource "aws_db_subnet_group" "DBgroup" {
  name = "final"
  subnet_ids = ["${aws_subnet.PriSub1.id}", "${aws_subnet.PriSub2.id}"]

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
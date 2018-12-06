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
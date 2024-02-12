### Networking ###
# One VPC 
# Three Public Subnets
# Three Private Subnets
# Internet Gateway
# Route Table

resource "aws_vpc" "wordpress-vpc" {
  cidr_block       = var.vpc_cidr_block 
  tags = {
    Name = var.vpc_tag
  } 
}

resource "aws_subnet" "pub-subnet" {
  vpc_id     = aws_vpc.wordpress-vpc.id
  for_each = var.pubsubnets
  cidr_block = each.value
  availability_zone = var.azs_pub[each.key]
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "priv-subnet" {
  vpc_id     = aws_vpc.wordpress-vpc.id
  for_each = var.privsubnets
  cidr_block = each.value
  availability_zone = var.azs_priv[each.key] 
  tags = {
    Name = each.key
  }
}

resource "aws_internet_gateway" "wordpress_igw" {
  vpc_id = aws_vpc.wordpress-vpc.id
  tags = {
    Name = var.igw_tag
  }
}

resource "aws_route_table" "wordpress_rt" {
  vpc_id = aws_vpc.wordpress-vpc.id
  tags = {
    Name = var.rt_tag
  }

  route {
    cidr_block = var.cidr_rt
    gateway_id = aws_internet_gateway.wordpress_igw.id
  }
}

resource "aws_route_table_association" "wordpress_rt_as_pubsubnet" {
  for_each = var.pubsubnets
  subnet_id      = aws_subnet.pub-subnet[each.key].id
  route_table_id = aws_route_table.wordpress_rt.id
}


### Server
# Security Groups
# SSH key
# EC2

resource "aws_security_group" "wordpress-sg" {
  name        = var.wordpress_sg_name 
  description = var.wordpress_sg_description 
  vpc_id      = aws_vpc.wordpress-vpc.id
  tags =  {
    Name = var.wordpress_sg_tag
  }

  dynamic "ingress" {
  for_each = var.ports
  content {
    from_port        = ingress.value
    to_port          = ingress.value
    protocol         = var.wordpress_sg_protocol 
    cidr_blocks      = var.wordpress_sg_cidr_blocks
  }
  }
   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "my-key" {
  key_name = "my-key"
  public_key = file("/Users/aizirekmuratova/.ssh/test.pub")
}

resource "aws_instance" "wordpress_ec2" {
  ami = "ami-0cf10cdf9fcd62d37"
  instance_type = var.instance_type 
  vpc_security_group_ids = [aws_security_group.wordpress-sg.id]
  subnet_id = aws_subnet.pub-subnet["pub_sub1"].id
  associate_public_ip_address = var.pub_ip_address
  key_name = aws_key_pair.my-key.key_name 
  tags = {
    Name = var.instance_tag
  }
  user_data = <<-EOF
            #!/bin/bash
            yum update -y
            yum install -y httpd
            systemctl start httpd.service
            systemctl enable httpd.service
            amazon-linux-extras enable php7.4
            yum clean metadata
            yum install -y php php-mysqlnd php-fpm php-json
            yum install -y mariadb-server
            systemctl start mariadb
            systemctl enable mariadb
            wget https://wordpress.org/latest.tar.gz
            tar -xzf latest.tar.gz
            cp -r wordpress/* /var/www/html/
            chown -R apache:apache /var/www/html/
            find /var/www/html/ -type d -exec chmod 750 {} \;
            find /var/www/html/ -type f -exec chmod 640 {} \;
            systemctl restart httpd.service
            systemctl restart mariadb.service
            rm -f latest.tar.gz
            EOF
}

resource "aws_security_group" "rds-sg" {
  name        = var.rds_sg_name 
  description = var.rds_sg_description 
  vpc_id      = aws_vpc.wordpress-vpc.id
  tags =  {
    Name = var.rds_sg_tag
  }
}

resource "aws_security_group_rule" "rds-ingress-sg" {
  type              = "ingress"
  from_port         = var.rds_sg_fromport 
  to_port           = var.rds_sg_toport
  protocol          = var.rds_sg_protocol
  security_group_id = aws_security_group.rds-sg.id 
  source_security_group_id = aws_security_group.wordpress-sg.id # Source security group to allow traffic from
}

resource "aws_db_instance" "wordpress_db" {
  allocated_storage    = var.storage
  db_name              = var.db_name
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.db_class
  username             = var.username
  password             = var.password
  vpc_security_group_ids  = [aws_security_group.rds-sg.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  skip_final_snapshot  = var.skip_final_snapshot
}

resource "aws_db_subnet_group" "db_subnet" {
    name       = var.db_subnet_name
    subnet_ids = [aws_subnet.priv-subnet["priv_sub1"].id, aws_subnet.priv-subnet["priv_sub2"].id, aws_subnet.priv-subnet["priv_sub3"].id]
}
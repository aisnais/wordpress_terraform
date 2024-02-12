provider "aws" {
  region = "us-east-1"
}

module network_server {
  source  = "../child_modules/network_server"
  vpc_cidr_block = "10.0.0.0/16"
  vpc_tag = "wordpress-vpc"
  pubsubnets = {
    pub_sub1 = "10.0.10.0/24"
    pub_sub2 = "10.0.20.0/24" 
    pub_sub3 = "10.0.30.0/24" 
  }
    privsubnets = {
    priv_sub1 = "10.0.40.0/24"
    priv_sub2 = "10.0.50.0/24" 
    priv_sub3 = "10.0.60.0/24" 
  }
  azs_pub = {
    pub_sub1 = "us-east-1a"
    pub_sub2 = "us-east-1b"
    pub_sub3 = "us-east-1c"
  }
   azs_priv = {
    priv_sub1 = "us-east-1f"
    priv_sub2 = "us-east-1b"
    priv_sub3 = "us-east-1c"
  }
  igw_tag = "wordpress_igw"
  rt_tag = "wordpress_rt"
  cidr_rt = "0.0.0.0/0"
  wordpress_sg_name = "wordpress-sg"
  wordpress_sg_description = "Allow HTTP, HTTPS and SSH ports inbound traffic and all outbound traffic"
  wordpress_sg_tag = "wordpress"
  ports = {
    port1 = 22
    port2 = 80
    port3 = 443
  }
  wordpress_sg_protocol = "tcp"
  wordpress_sg_cidr_blocks = ["0.0.0.0/0"]
  instance_type = "t2.micro"
  pub_ip_address = true
  instance_tag = "wordpress_ec2"
  rds_sg_name = "rds-sg"
  rds_sg_description = "Allow traffic from Wordpress sg"
  rds_sg_tag = "rds"
  rds_sg_fromport = 3306
  rds_sg_toport = 3306
  rds_sg_protocol = "tcp"
  storage = 20
  db_name = "wordpress_db"
  engine = "mysql"
  engine_version = "5.7"
  db_class = "db.t2.micro"
  username = "admin"
  password = "adminadmin"
  skip_final_snapshot = true
  db_subnet_name = "wordpress-db-subnet"
}



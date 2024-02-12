variable vpc_cidr_block {
  type        = string
  description = "CIDR block of VPC"
}

variable vpc_tag {
  type = string
}

variable pubsubnets {
  type        = map(string)
}

variable privsubnets {
  type        = map(string)
}

variable igw_tag {
  type = string
}

variable cidr_rt {
  type        = string
  description = "CIDR of route table"
}

variable rt_tag {
  type = string
}

variable azs_pub {
  type = map(string)
}

variable azs_priv {
  type = map(string)
}

#Server variables

variable wordpress_sg_name  {
  type        = string
}

variable wordpress_sg_description {
  type        = string
}

variable wordpress_sg_tag {
  type = string
}

variable ports {
  type        = map(number)
}

variable wordpress_sg_protocol {
  type        = string
}

variable wordpress_sg_cidr_blocks {
  type        = list(string)
}

variable instance_type {
  type        = string
}

variable pub_ip_address {
  type        = bool
}

variable instance_tag {
  type        = string
}

variable rds_sg_name {
  type        = string
}

variable rds_sg_description {
  type        = string
}

variable rds_sg_tag {
  type = string
}

variable rds_sg_fromport {
  type        = number
}

variable rds_sg_toport {
  type        = number
}

variable rds_sg_protocol {
  type        = string
}

variable storage {
  type        = number
}

variable db_name {
  type        = string
}

variable engine {
  type        = string
}

variable engine_version {
  type        = string
}

variable db_class {
  type        = string
}

variable username {
  type        = string
}

variable password {
  type        = string
}

variable skip_final_snapshot {
  type        = bool
}

variable db_subnet_name {
  type        = string
}













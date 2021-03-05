variable "region" { default = "ap-northeast-1" }
variable "cidr_block" { default = "172.16.0.0/16" }

variable "public_subnets" {
  default = {
    "a" = "172.16.0.0/19"
    "c" = "172.16.32.0/19"
    "d" = "172.16.64.0/19"
    #"x" = "172.16.96.0/19"   # reserved
  }
}

variable "private_subnets" {
  default = {
    "a" = "172.16.128.0/19"
    "c" = "172.16.160.0/19"
    "d" = "172.16.192.0/19"
    #"x" = "172.16.224.0/19"  # reserved
  }
}

variable "ecr_repositories" {
  default = [
    "docker-rails/mysql",
    "docker-rails/rails",
    "docker-rails/nginx"
  ]
}


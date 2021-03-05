terraform {
  required_version = "0.14.7"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.28.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "example" {
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "example"
  }
}

# パブリックネットワーク
## サブネット
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id = aws_vpc.example.id
  availability_zone = "ap-northeast-1${each.key}"
  cidr_block = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "example-public-${each.key}"
  }
}

## インターネットゲートウェイ
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example-public"
  }
}

## ルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example-public"
  }
}

## ルートテーブルのレコード
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.example.id
  destination_cidr_block = "0.0.0.0/0"
}

## ルートテーブルとサブネットの関連付け
resource "aws_route_table_association" "public" {
  for_each = var.public_subnets

  subnet_id = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# ECR
resource "aws_ecr_repository" "example" {
  for_each = toset(var.ecr_repositories)

  name = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

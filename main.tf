terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_availability_zones" "available" {}

# Создаем VPC1
resource "aws_vpc" "final-vpc1" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "final-vpc1"
  }
}

# Создаем публичную сеть в VPC1
resource "aws_subnet" "vpc1-Public" {
  vpc_id            = aws_vpc.final-vpc1.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "vpc1-Public"
  }
  map_public_ip_on_launch = true
}

# Создаем приватную сеть1 в VPC1
resource "aws_subnet" "vpc1-Private1" {
  vpc_id            = aws_vpc.final-vpc1.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "vpc1-Private"
  }
}

# Создаем приватную сеть2 в VPC1
resource "aws_subnet" "vpc1-Private2" {
  vpc_id            = aws_vpc.final-vpc1.id
  cidr_block        = "10.0.30.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "vpc1-Private2"
  }
}

# Создаем VPC2
resource "aws_vpc" "final-vpc2" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "final-vpc2"
  }
}

# Создаем публичную сеть 1 в VPC2
resource "aws_subnet" "vpc2-Public1" {
  vpc_id            = aws_vpc.final-vpc2.id
  cidr_block        = "10.1.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "vpc2-Public1"
  }
  map_public_ip_on_launch = true
}

# Создаем публичную сеть 2 в VPC2
resource "aws_subnet" "vpc2-Public2" {
  vpc_id            = aws_vpc.final-vpc2.id
  cidr_block        = "10.1.40.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "vpc2-Public2"
  }
  map_public_ip_on_launch = true
}


# Создаем приватную сеть в VPC2
resource "aws_subnet" "vpc2-Private1" {
  vpc_id            = aws_vpc.final-vpc2.id
  cidr_block        = "10.1.20.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "vpc2-Private"
  }
}

# Создаем приватную сеть 2 в VPC2
resource "aws_subnet" "vpc2-Private2" {
  vpc_id            = aws_vpc.final-vpc2.id
  cidr_block        = "10.1.30.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "vpc2-Private2"
  }
}

# Создаем интернет-шлюз для VPC1
resource "aws_internet_gateway" "vpc1-igw" {
  vpc_id = aws_vpc.final-vpc1.id

  tags = {
    Name = "vpc1-igw"
  }
}

# Создаем интернет-шлюз для VPC2
resource "aws_internet_gateway" "vpc2-igw" {
  vpc_id = aws_vpc.final-vpc2.id

  tags = {
    Name = "vpc2-igw"
  }
}

# Создаем пиринг между VPC
resource "aws_vpc_peering_connection" "peering-between-vpc" {
  vpc_id      = aws_vpc.final-vpc1.id
  peer_vpc_id = aws_vpc.final-vpc2.id
  auto_accept = true
}

# Создаем таблицу маршрутизации для публичной сети в VPC1 c выходом в интернет
resource "aws_route_table" "vpc1-Public-RT" {
  vpc_id = aws_vpc.final-vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1-igw.id
  }
  route {
    cidr_block                = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering-between-vpc.id
  }
  tags = {
    Name = "vpc1-Public-RT"
  }
}

# Связываем таблицу маршрутизации для публичной сети в VPC1 с публичной сетью
resource "aws_route_table_association" "vpc1-Public-RT-Assoc" {
  subnet_id      = aws_subnet.vpc1-Public.id
  route_table_id = aws_route_table.vpc1-Public-RT.id
}

# Создаем таблицу маршрутизации для приватной сети 1 в VPC1 без выхода в интернет
resource "aws_route_table" "vpc1-Private1-RT" {
  vpc_id = aws_vpc.final-vpc1.id
  #route  = []
  route {
    cidr_block                = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering-between-vpc.id
  }
  tags = {
    Name = "vpc1-Private1-RT"
  }
}

# Связываем таблицу маршрутизации для приватной сети 1 в VPC1 с приватной сетью
resource "aws_route_table_association" "vpc1-Private1-RT-Assoc" {
  subnet_id      = aws_subnet.vpc1-Private1.id
  route_table_id = aws_route_table.vpc1-Private1-RT.id
}

# Создаем таблицу маршрутизации для приватной сети 2 в VPC1 без выхода в интернет
resource "aws_route_table" "vpc1-Private2-RT" {
  vpc_id = aws_vpc.final-vpc1.id
  #route  = []
  route {
    cidr_block                = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering-between-vpc.id
  }
  tags = {
    Name = "vpc1-Private2-RT"
  }
}

# Связываем таблицу маршрутизации для приватной сети 2 в VPC1 с приватной сетью
resource "aws_route_table_association" "vpc1-Private2-RT-Assoc" {
  subnet_id      = aws_subnet.vpc1-Private2.id
  route_table_id = aws_route_table.vpc1-Private2-RT.id
}

# Создаем таблицу маршрутизации для публичной сети 1 в VPC2 c выходом в интернет
resource "aws_route_table" "vpc2-Public1-RT" {
  vpc_id = aws_vpc.final-vpc2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc2-igw.id
  }
  route {
    cidr_block                = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering-between-vpc.id
  }
  tags = {
    Name = "vpc2-Public1-RT"
  }
}

# Связываем таблицу маршрутизации публичной сети 1 в VPC2 c публичной сетью
resource "aws_route_table_association" "vpc2-Public1-RT-Assoc" {
  subnet_id      = aws_subnet.vpc2-Public1.id
  route_table_id = aws_route_table.vpc2-Public1-RT.id
}

# Создаем таблицу маршрутизации для публичной сети 1 в VPC2 c выходом в интернет
resource "aws_route_table" "vpc2-Public2-RT" {
  vpc_id = aws_vpc.final-vpc2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc2-igw.id
  }
  route {
    cidr_block                = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering-between-vpc.id
  }
  tags = {
    Name = "vpc2-Public2-RT"
  }
}

# Связываем таблицу маршрутизации публичной сети в VPC2 c публичной сетью
resource "aws_route_table_association" "vpc2-Public2-RT-Assoc" {
  subnet_id      = aws_subnet.vpc2-Public2.id
  route_table_id = aws_route_table.vpc2-Public2-RT.id
}

# Создаем таблицу маршрутизации для приватной сети 1 в VPC2 без выхода в интернет
resource "aws_route_table" "vpc2-Private1-RT" {
  vpc_id = aws_vpc.final-vpc2.id
  #route  = []
  route {
    cidr_block                = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering-between-vpc.id
  }
  tags = {
    Name = "vpc2-Private1-RT"
  }
}

# Связываем таблицу маршрутизации для приватной сети 1 в VPC2 с приватной сетью
resource "aws_route_table_association" "vpc2-Private1-RT-Assoc" {
  subnet_id      = aws_subnet.vpc2-Private1.id
  route_table_id = aws_route_table.vpc2-Private1-RT.id
}

# Создаем таблицу маршрутизации для приватной сети 2 в VPC2 без выхода в интернет
resource "aws_route_table" "vpc2-Private2-RT" {
  vpc_id = aws_vpc.final-vpc2.id
  #route  = []
  route {
    cidr_block                = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering-between-vpc.id
  }
  tags = {
    Name = "vpc2-Private2-RT"
  }
}

# Связываем таблицу маршрутизации для приватной сети 2 в VPC2 с приватной сетью
resource "aws_route_table_association" "vpc2-Private2-RT-Assoc" {
  subnet_id      = aws_subnet.vpc2-Private2.id
  route_table_id = aws_route_table.vpc2-Private2-RT.id
}

# Создаем группу безопасности для доступов к инстансам VPC1
resource "aws_security_group" "vpc1_Allow_ssh_icmp_http8888_inbound_traffic" {
  name        = "vpc1_Allow_ssh_icmp_http8888_inbound_traffic"
  description = "vpc1_Allow_ssh_icmp_http8888_inbound_traffic"
  vpc_id      = aws_vpc.final-vpc1.id

  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "icmp from the internet"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP on 8888 port from the internet"
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc1_Allow_ssh_icmp_http8888_inbound_traffic"
  }
}

# Создаем группу безопасности для доступов к инстансам VPC2
resource "aws_security_group" "vpc2_Allow_ssh_icmp_http8888_inbound_traffic" {
  name        = "vpc2_Allow_ssh_icmp_http8888_inbound_traffic"
  description = "vpc2_Allow_ssh_icmp_http8888_inbound_traffic"
  vpc_id      = aws_vpc.final-vpc2.id

  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "icmp from the internet"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP on 8888 port from the internet"
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc2_Allow_ssh_icmp_http8888_inbound_traffic"
  }
}

# Создаем группу безопасности для ALB
resource "aws_security_group" "Security_group_for_ALB" {
  name        = "Security_group_for_ALB"
  description = "Security_group_for_ALB"
  vpc_id      = aws_vpc.final-vpc2.id

  ingress {
    description = "HTTP on 80 port from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security_group_for_ALB"
  }
}

# Создаем роль для EC2 с доступами к бакетам (понадобится позже)
resource "aws_iam_role" "Ec2tobS3" {
  name               = "Ec2tobS3"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Создаем политику роли для EC2 с доступами к бакетам (понадобится позже)
resource "aws_iam_role_policy" "Ec2tobS3_policy" {
  name = "Ec2tobS3_policy"
  role = aws_iam_role.Ec2tobS3.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
     "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Создаем профиль для инстансов, с ролью с доступами к S3 бакетам
resource "aws_iam_instance_profile" "ProfileForEc2tobS3" {
  name = "ProfileForEc2tobS3"
  role = aws_iam_role.Ec2tobS3.name
}

# Создаем Endpoint к S3 (для того, чтобы можно было установить nginx без интернета)
resource "aws_vpc_endpoint" "s3_1" {
  vpc_id       = aws_vpc.final-vpc1.id
  service_name = "com.amazonaws.us-east-1.s3"

  tags = {
    Environment = "final-quest"
  }
}
resource "aws_vpc_endpoint" "s3_2" {
  vpc_id       = aws_vpc.final-vpc2.id
  service_name = "com.amazonaws.us-east-1.s3"

  tags = {
    Environment = "final-quest"
  }
}

# Добавляем Endpoint к таблицам маршрутизации приватной сети 1 в VPC1
resource "aws_vpc_endpoint_route_table_association" "vpc1-priv1-ep" {
  route_table_id  = aws_route_table.vpc1-Private1-RT.id
  vpc_endpoint_id = aws_vpc_endpoint.s3_1.id
}

# Добавляем Endpoint к таблицам маршрутизации приватной сети 2 в VPC1
resource "aws_vpc_endpoint_route_table_association" "vpc1-priv2-ep" {
  route_table_id  = aws_route_table.vpc1-Private2-RT.id
  vpc_endpoint_id = aws_vpc_endpoint.s3_1.id
}

# Добавляем Endpoint к таблицам маршрутизации приватной сети 1 в VPC2
resource "aws_vpc_endpoint_route_table_association" "vpc2-priv1-ep" {
  route_table_id  = aws_route_table.vpc2-Private1-RT.id
  vpc_endpoint_id = aws_vpc_endpoint.s3_2.id
}

# Добавляем Endpoint к таблицам маршрутизации приватной сети 2 в VPC1
resource "aws_vpc_endpoint_route_table_association" "vpc2-priv2-ep" {
  route_table_id  = aws_route_table.vpc2-Private2-RT.id
  vpc_endpoint_id = aws_vpc_endpoint.s3_2.id
}

# Создаем бастион :)
resource "aws_instance" "Bastion" {
  ami           = "ami-087c17d1fe0178315"
  instance_type = "t2.micro"
  # доступ к S3 бакетам пока не нужен, закладочка на будущее
  # iam_instance_profile   = aws_iam_instance_profile.ProfileForEc2tobS3.name
  key_name               = "prod"
  subnet_id              = aws_subnet.vpc1-Public.id
  vpc_security_group_ids = [aws_security_group.vpc1_Allow_ssh_icmp_http8888_inbound_traffic.id]
  user_data              = <<EOF
  #!/bin/bash
  sudo adduser teacher
  sudo usermod -a -G wheel teacher
  sudo mkdir /home/teacher/.ssh
  sudo chown teacher:teacher /home/teacher/.ssh
  sudo chmod 700 /home/teacher/.ssh
  sudo cd /home/teacher/.ssh
  sudo echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkBIEsfJD6d0J4tqTnVq4z3Ve0bop71b+27j75gncRsLdAHLVg/InhJdrtnVszNGzPIPTXM8jsb/cc0e0JDD7Teoqz0YxJH+ZhY5Y6iy5n8Vx+CCWr5Rra5IpfJclvDPbH+okiUqGyt1fmvS+VkoBWxOFiAOsfdSdTwJWyGs0kplZouOh93cRc/9mp16mNcR5B86+ORLrMZCq3ZGVj2F3YjlhXb1/aUz7Mi1E6Ze9UQQe2oKqf4w8wXIiSejCcrsZ9CT6SX28Kqw2Ilb+7cr84vXIQDKxZySupztn8qMFlDvtoeK4b+RvEtpRmJaC/no9yjTeDTnBYVsV+vQvxiaaeLzkbPRhd0Ovlayoz/gXqI4DOCaQTfISHxG7X+NLfpW6Hmvgf+2i9OStUMJatDx6y1BAj5cjBKo1JRS73U2o5wYYTAlq6jaDAUzWE8Ili7cZ2Qx2dz5uFq6S8NteIt9yR6LsfaHYKG/5WmaA3LOnYAqV+S7nq2WQVQ2Z5bzpJC9s= andrey@MBP-Andrey > authorized_keys
  sudo chown teacher:teacher /home/teacher/.ssh/authorized_keys
  sudo chmod 600 /home/teacher/.ssh/authorized_keys
EOF
  tags = {
    "Name" = "Bastion"
  }
}

# Создаем вер сервер 1 в приватной сети VPC1
resource "aws_instance" "vpc1-private1-webserver1" {
  ami           = "ami-087c17d1fe0178315"
  instance_type = "t2.micro"
  # доступ к S3 бакетам пока не нужен, закладочка на будущее
  #  iam_instance_profile   = aws_iam_instance_profile.ProfileForEc2tobS3.name
  key_name               = "prod"
  subnet_id              = aws_subnet.vpc1-Private1.id
  vpc_security_group_ids = [aws_security_group.vpc1_Allow_ssh_icmp_http8888_inbound_traffic.id]
  user_data              = <<EOF
  #!/bin/bash
  yum update -y
  sudo amazon-linux-extras install nginx1
  IP=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep privateIp)
  REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep region)
  AZ=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep "availabilityZone")
  sudo sed -i 's/listen       80;/listen       8888;/' /etc/nginx/nginx.conf
  sudo echo -e "<center><h2>$IP</h2><br><h2>$REGION</h2><br><h2>$AZ</h2></center>" > /usr/share/nginx/html/index.html
  sudo systemctl start nginx
  sudo systemctl enable nginx
  sudo adduser teacher
  sudo usermod -a -G wheel teacher
  sudo mkdir /home/teacher/.ssh
  sudo chown teacher:teacher /home/teacher/.ssh
  sudo chmod 700 /home/teacher/.ssh
  sudo cd /home/teacher/.ssh
  sudo echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkBIEsfJD6d0J4tqTnVq4z3Ve0bop71b+27j75gncRsLdAHLVg/InhJdrtnVszNGzPIPTXM8jsb/cc0e0JDD7Teoqz0YxJH+ZhY5Y6iy5n8Vx+CCWr5Rra5IpfJclvDPbH+okiUqGyt1fmvS+VkoBWxOFiAOsfdSdTwJWyGs0kplZouOh93cRc/9mp16mNcR5B86+ORLrMZCq3ZGVj2F3YjlhXb1/aUz7Mi1E6Ze9UQQe2oKqf4w8wXIiSejCcrsZ9CT6SX28Kqw2Ilb+7cr84vXIQDKxZySupztn8qMFlDvtoeK4b+RvEtpRmJaC/no9yjTeDTnBYVsV+vQvxiaaeLzkbPRhd0Ovlayoz/gXqI4DOCaQTfISHxG7X+NLfpW6Hmvgf+2i9OStUMJatDx6y1BAj5cjBKo1JRS73U2o5wYYTAlq6jaDAUzWE8Ili7cZ2Qx2dz5uFq6S8NteIt9yR6LsfaHYKG/5WmaA3LOnYAqV+S7nq2WQVQ2Z5bzpJC9s= andrey@MBP-Andrey > authorized_keys
  sudo chown teacher:teacher /home/teacher/.ssh/authorized_keys
  sudo chmod 600 /home/teacher/.ssh/authorized_keys
EOF
  # смена порта проверяется с бастиона командой curl 10.0.20.36:8888 - на локальный ip адрес приватного инстанса
  tags = {
    "Name" = "vpc1-private1-webserver1"
  }
}
# Создаем вер сервер 2 во 2 приватной сети VPC1
resource "aws_instance" "vpc1-private2-webserver2" {
  ami           = "ami-087c17d1fe0178315"
  instance_type = "t2.micro"
  # доступ к S3 бакетам пока не нужен, закладочка на будущее
  #  iam_instance_profile   = aws_iam_instance_profile.ProfileForEc2tobS3.name
  key_name               = "prod"
  subnet_id              = aws_subnet.vpc1-Private2.id
  vpc_security_group_ids = [aws_security_group.vpc1_Allow_ssh_icmp_http8888_inbound_traffic.id]
  user_data              = <<EOF
  #!/bin/bash
  yum update -y
  sudo amazon-linux-extras install nginx1
  IP=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep privateIp)
  REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep region)
  AZ=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep "availabilityZone")
  sudo sed -i 's/listen       80;/listen       8888;/' /etc/nginx/nginx.conf
  sudo echo -e "<center><h2>$IP</h2><br><h2>$REGION</h2><br><h2>$AZ</h2></center>" > /usr/share/nginx/html/index.html
  sudo systemctl start nginx
  sudo systemctl enable nginx
  sudo adduser teacher
  sudo usermod -a -G wheel teacher
  sudo mkdir /home/teacher/.ssh
  sudo chown teacher:teacher /home/teacher/.ssh
  sudo chmod 700 /home/teacher/.ssh
  sudo cd /home/teacher/.ssh
  sudo echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkBIEsfJD6d0J4tqTnVq4z3Ve0bop71b+27j75gncRsLdAHLVg/InhJdrtnVszNGzPIPTXM8jsb/cc0e0JDD7Teoqz0YxJH+ZhY5Y6iy5n8Vx+CCWr5Rra5IpfJclvDPbH+okiUqGyt1fmvS+VkoBWxOFiAOsfdSdTwJWyGs0kplZouOh93cRc/9mp16mNcR5B86+ORLrMZCq3ZGVj2F3YjlhXb1/aUz7Mi1E6Ze9UQQe2oKqf4w8wXIiSejCcrsZ9CT6SX28Kqw2Ilb+7cr84vXIQDKxZySupztn8qMFlDvtoeK4b+RvEtpRmJaC/no9yjTeDTnBYVsV+vQvxiaaeLzkbPRhd0Ovlayoz/gXqI4DOCaQTfISHxG7X+NLfpW6Hmvgf+2i9OStUMJatDx6y1BAj5cjBKo1JRS73U2o5wYYTAlq6jaDAUzWE8Ili7cZ2Qx2dz5uFq6S8NteIt9yR6LsfaHYKG/5WmaA3LOnYAqV+S7nq2WQVQ2Z5bzpJC9s= andrey@MBP-Andrey > authorized_keys
  sudo chown teacher:teacher /home/teacher/.ssh/authorized_keys
  sudo chmod 600 /home/teacher/.ssh/authorized_keys
EOF
  # смена порта проверяется с бастиона командой curl 10.0.20.36:8888 - на локальный ip адрес приватного инстанса
  tags = {
    "Name" = "vpc1-private2-webserver2"
  }
}

# Создаем вер сервер 1 в приватной сети VPC2
resource "aws_instance" "vpc2-private1-webserver1" {
  ami           = "ami-087c17d1fe0178315"
  instance_type = "t2.micro"
  # доступ к S3 бакетам пока не нужен, закладочка на будущее
  #  iam_instance_profile   = aws_iam_instance_profile.ProfileForEc2tobS3.name
  key_name               = "prod"
  subnet_id              = aws_subnet.vpc2-Private1.id
  vpc_security_group_ids = [aws_security_group.vpc2_Allow_ssh_icmp_http8888_inbound_traffic.id]
  user_data              = <<EOF
  #!/bin/bash
  yum update -y
  sudo amazon-linux-extras install nginx1
  IP=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep privateIp)
  REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep region)
  AZ=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep "availabilityZone")
  sudo sed -i 's/listen       80;/listen       8888;/' /etc/nginx/nginx.conf
  sudo echo -e "<center><h2>$IP</h2><br><h2>$REGION</h2><br><h2>$AZ</h2></center>" > /usr/share/nginx/html/index.html
  sudo systemctl start nginx
  sudo systemctl enable nginx
  sudo adduser teacher
  sudo usermod -a -G wheel teacher
  sudo mkdir /home/teacher/.ssh
  sudo chown teacher:teacher /home/teacher/.ssh
  sudo chmod 700 /home/teacher/.ssh
  sudo cd /home/teacher/.ssh
  sudo echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkBIEsfJD6d0J4tqTnVq4z3Ve0bop71b+27j75gncRsLdAHLVg/InhJdrtnVszNGzPIPTXM8jsb/cc0e0JDD7Teoqz0YxJH+ZhY5Y6iy5n8Vx+CCWr5Rra5IpfJclvDPbH+okiUqGyt1fmvS+VkoBWxOFiAOsfdSdTwJWyGs0kplZouOh93cRc/9mp16mNcR5B86+ORLrMZCq3ZGVj2F3YjlhXb1/aUz7Mi1E6Ze9UQQe2oKqf4w8wXIiSejCcrsZ9CT6SX28Kqw2Ilb+7cr84vXIQDKxZySupztn8qMFlDvtoeK4b+RvEtpRmJaC/no9yjTeDTnBYVsV+vQvxiaaeLzkbPRhd0Ovlayoz/gXqI4DOCaQTfISHxG7X+NLfpW6Hmvgf+2i9OStUMJatDx6y1BAj5cjBKo1JRS73U2o5wYYTAlq6jaDAUzWE8Ili7cZ2Qx2dz5uFq6S8NteIt9yR6LsfaHYKG/5WmaA3LOnYAqV+S7nq2WQVQ2Z5bzpJC9s= andrey@MBP-Andrey > authorized_keys
  sudo chown teacher:teacher /home/teacher/.ssh/authorized_keys
  sudo chmod 600 /home/teacher/.ssh/authorized_keys
EOF
  # смена порта проверяется с бастиона командой curl 10.0.20.36:8888 - на локальный ip адрес приватного инстанса
  tags = {
    "Name" = "vpc2-private1-webserver1"
  }
}

# Создаем вер сервер 2 в приватной сети VPC2
resource "aws_instance" "vpc2-private2-webserver2" {
  ami           = "ami-087c17d1fe0178315"
  instance_type = "t2.micro"
  # доступ к S3 бакетам пока не нужен, закладочка на будущее
  #  iam_instance_profile   = aws_iam_instance_profile.ProfileForEc2tobS3.name
  key_name               = "prod"
  subnet_id              = aws_subnet.vpc2-Private2.id
  vpc_security_group_ids = [aws_security_group.vpc2_Allow_ssh_icmp_http8888_inbound_traffic.id]
  user_data              = <<EOF
  #!/bin/bash
  yum update -y
  sudo amazon-linux-extras install nginx1
  IP=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep privateIp)
  REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep region)
  AZ=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep "availabilityZone")
  sudo sed -i 's/listen       80;/listen       8888;/' /etc/nginx/nginx.conf
  sudo echo -e "<center><h2>$IP</h2><br><h2>$REGION</h2><br><h2>$AZ</h2></center>" > /usr/share/nginx/html/index.html
  sudo systemctl start nginx
  sudo systemctl enable nginx
  sudo adduser teacher
  sudo usermod -a -G wheel teacher
  sudo mkdir /home/teacher/.ssh
  sudo chown teacher:teacher /home/teacher/.ssh
  sudo chmod 700 /home/teacher/.ssh
  sudo cd /home/teacher/.ssh
  sudo echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkBIEsfJD6d0J4tqTnVq4z3Ve0bop71b+27j75gncRsLdAHLVg/InhJdrtnVszNGzPIPTXM8jsb/cc0e0JDD7Teoqz0YxJH+ZhY5Y6iy5n8Vx+CCWr5Rra5IpfJclvDPbH+okiUqGyt1fmvS+VkoBWxOFiAOsfdSdTwJWyGs0kplZouOh93cRc/9mp16mNcR5B86+ORLrMZCq3ZGVj2F3YjlhXb1/aUz7Mi1E6Ze9UQQe2oKqf4w8wXIiSejCcrsZ9CT6SX28Kqw2Ilb+7cr84vXIQDKxZySupztn8qMFlDvtoeK4b+RvEtpRmJaC/no9yjTeDTnBYVsV+vQvxiaaeLzkbPRhd0Ovlayoz/gXqI4DOCaQTfISHxG7X+NLfpW6Hmvgf+2i9OStUMJatDx6y1BAj5cjBKo1JRS73U2o5wYYTAlq6jaDAUzWE8Ili7cZ2Qx2dz5uFq6S8NteIt9yR6LsfaHYKG/5WmaA3LOnYAqV+S7nq2WQVQ2Z5bzpJC9s= andrey@MBP-Andrey > authorized_keys
  sudo chown teacher:teacher /home/teacher/.ssh/authorized_keys
  sudo chmod 600 /home/teacher/.ssh/authorized_keys
EOF
  # смена порта проверяется с бастиона командой curl 10.0.20.36:8888 - на локальный ip адрес приватного инстанса
  tags = {
    "Name" = "vpc2-private2-webserver2"
  }
}

# Создаем ALB
resource "aws_lb" "lackros-alb" {
  name               = "lackros-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Security_group_for_ALB.id]
  subnets            = [aws_subnet.vpc2-Public1.id, aws_subnet.vpc2-Public2.id]

  tags = {
    "name" = "lackros-alb"
  }
}

# Создаем слушателя для ALB
resource "aws_lb_listener" "lackros-alb_listener" {
  load_balancer_arn = aws_lb.lackros-alb.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG_WEB.arn
  }
}

# Создаем целевую группу для ALB
resource "aws_lb_target_group" "TG_WEB" {
  name        = "TG-WEB"
  port        = 8888
  protocol    = "HTTP"
  vpc_id      = aws_vpc.final-vpc2.id
  target_type = "instance"
  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = 8888
    path                = "/"
    matcher             = "200"
    interval            = 60
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = {
    "Name" = "TG_WEB"
  }
}

# Связываем целевую группу с веб-сервером 1
resource "aws_lb_target_group_attachment" "TG_attache_web-server1" {
  target_group_arn = aws_lb_target_group.TG_WEB.arn
  target_id        = aws_instance.vpc2-private1-webserver1.id
  port             = 8888
}

# Связываем целевую группу с веб-сервером 2
resource "aws_lb_target_group_attachment" "TG_attache_web-server2" {
  target_group_arn = aws_lb_target_group.TG_WEB.arn
  target_id        = aws_instance.vpc2-private2-webserver2.id
  port             = 8888
}

# Блок AUTO SCALING GROUP
# Создаем Launch template
resource "aws_launch_template" "Lackros_Template_final" {
  name                   = "Lackros_Template_final"
  image_id               = "ami-087c17d1fe0178315"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.vpc2_Allow_ssh_icmp_http8888_inbound_traffic.id]
  user_data              = filebase64("udnginx.sh")
  metadata_options {
    http_endpoint = "enabled"
  }
}

# Создаем группу автоматического масштабирования
resource "aws_autoscaling_group" "LackrosASG" {
  name = "LackrosASG"
  //availability_zones        = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  target_group_arns         = [aws_lb_target_group.TG_WEB.arn]
  vpc_zone_identifier       = [aws_subnet.vpc2-Private1.id, aws_subnet.vpc2-Private2.id]
  desired_capacity          = 0
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 120
  health_check_type         = "ELB"

  launch_template {
    id      = aws_launch_template.Lackros_Template_final.id
    version = "$Latest"
  }
}

# Создаем политику масштабирования
resource "aws_autoscaling_policy" "Lackros_autoscaling_policy" {
  name        = "Lackros_autoscaling_policy"
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = "80"
  }
  autoscaling_group_name = aws_autoscaling_group.LackrosASG.name
}

# Для удобства выводим IP адреса инстансов
# output "Bastion_Public_IP" {
#   value = aws_instance.Bastion.public_ip
# }
#
# output "vpc1-private1-webserver1_private_IP" {
#   value = aws_instance.vpc1-private1-webserver1.private_ip
# }
#
# output "vpc1-private2-webserver2_private_IP" {
#   value = aws_instance.vpc1-private2-webserver2.private_ip
# }
#
# output "vpc2-private1-webserver1_private_IP" {
#   value = aws_instance.vpc2-private1-webserver1.private_ip
# }
#
# output "vpc2-private2-webserver2_private_IP" {
#   value = aws_instance.vpc2-private2-webserver2.private_ip
# }

output "ALB-DNS-NAME" {
  value = aws_lb.lackros-alb.dns_name
}

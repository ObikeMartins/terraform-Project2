
# Providers

provider "aws" {
  region = "us-east-1"
}

# 1. Create VPC
resource "aws_vpc" "chisom_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "chisom_vpc"
  }
}


# 2. Create a subnet
resource "aws_subnet" "chisom_subnet" {
  vpc_id            = aws_vpc.chisom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "chisom_subnet"
  }
}


# 3. Create Internet Gateway
resource "aws_internet_gateway" "chisom_igw" {
  vpc_id = aws_vpc.chisom_vpc.id

  tags = {
    Name = "chisom_igw"
  }
}



# 4. Create Route Table
resource "aws_route_table" "chisom_route_table" {
  vpc_id = aws_vpc.chisom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.chisom_igw.id
  }
  tags = {
    Name = "chisom_route_table"
  }
}



# 5. Associate the subnet with the route table

resource "aws_route_table_association" "chisom_route_table_association" {
  subnet_id      = aws_subnet.chisom_subnet.id
  route_table_id = aws_route_table.chisom_route_table.id
}






# 6. Create a security group to allow port 22 and 80
resource "aws_security_group" "webserver_sg" {
  name        = "allow_web_traffic"
  description = "Allow inbound traffic on port 22 and 80"
  vpc_id      = aws_vpc.chisom_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
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
    Name = "webserver_sg"
  }
}




# 7. Create a network interface with an IP in the subnet that was created in no 2
resource "aws_network_interface" "chisom_network_interface" {
  subnet_id       = aws_subnet.chisom_subnet.id
  private_ips     = ["10.0.0.50"]
  security_groups = [aws_security_group.webserver_sg.id]
}



# 8. Assign an elastic IP to the network interface created in #7
# 9. Create an Ubuntu server and install/enabled apachez
# 10. Output the public IP of the Ubuntu server
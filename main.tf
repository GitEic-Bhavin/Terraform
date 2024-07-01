
# Create web server


resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type

  key_name               = "Bhavin_rsaKey" # This will use your local id_rsa key. 
  vpc_security_group_ids = [aws_security_group.web-sg.id]


  # To print  web-server public ip into local file named inventory.ini
  # If file name "inventory.ini" is not present it will created. if present this will put outout in this file.
  provisioner "local-exec" {
    command = "echo webserver ansible_host=${aws_instance.web.public_ip} ansible_connection=ssh ansible_private_key_file=your ssh private key path >> /your inventory file paht/inventory.ini"
  }


  # Give Tags to web instance
  tags = {
    "Name"       = var.Name_web
    "Department" = var.Department
    "owner"      = var.owner
    "DM"         = var.DM
    "End Date"   = var.End_Date
  }

  # Create web server after create web sg
  depends_on = [aws_security_group.web-sg]

  # Assign EBS Root Volume Bydefault size 8 GB to web server
  root_block_device {
    volume_size = var.volume_size_web
    volume_type = "gp3"

    # Give Tag to Root Volume
    tags = {
      "Name"       = var.Name_web
      "Department" = var.Department
      "owner"      = var.owner
      "DM"         = var.DM
      "End Date"   = var.End_Date
    }

  }

  # To make SSH Connection use connection block
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("Your Private_Key Path")
  }

  # To Ensure SSH Connection is done.
  provisioner "remote-exec" {
    inline = ["echo You are connnected to web server by ssh"]

  }
   # To prevent from destroy bymistakely use below lifecycle. Just enable it by uncomment.
  # lifecycle {
  #   prevent_destroy = true
  # }

}

# For select range in cidr block as My Ip
data "http" "myip" {
  url = "https://ipv4.icanhazip.com/"
}

# Create Security Group for web server.

# We define IP source as MY IP in aws. 
# There are 2 MY IP, one is consider by aws itself, second is check on browser by myipaddress.
# Both IP should be same. if ssh is not working , then seach myipadress on browser & use this ip in aws SG.
resource "aws_security_group" "web-sg" {
  name        = "Your_SG_Name for web_server"
  description = "allow ssh access from internet"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]


  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]

  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  # To give outbound rule for make connectivity outside of network.(By Default)
  # Terraform does not create OutBound Rule in SG ByDefault. without this you cant ping , and update, install packages in server.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # To prevent from destroy bymistakely use below lifecycle. Just enable it by uncomment.
  # lifecycle {
  #   prevent_destroy = true
  # }
}
# Print Public Ip of web server in your screen.
output "web_public_ip" {
  value = aws_instance.web.public_ip

}



# For Database server 
resource "aws_instance" "data" {
  ami           = var.ami
  instance_type = var.instance_type

  key_name               = "Your ssh key name"
  vpc_security_group_ids = [aws_security_group.data-sg.id]

  # To print  data-server public ip into local file named inventory.ini
  provisioner "local-exec" {
    command = "echo dataserver ansible_host=${aws_instance.data.public_ip} ansible_connection=ssh ansible_private_key_file=your ssh private key path >> /your inventory file paht/inventory.ini"

  }

  # Tags for Database server
  tags = {
    "Name"       = var.Name_data
    "Department" = var.Department
    "owner"      = var.owner
    "DM"         = var.DM
    "End Date"   = var.End_Date
  }

  # Assign EBS Root Volume for Database Server
  root_block_device {
    volume_size = var.volume_size_data
    volume_type = "gp3"

    # Give Tags to EBS Root Volume
    tags = {
      "Name"       = var.Name_data
      "Department" = var.Department
      "owner"      = var.owner
      "DM"         = var.DM
      "End Date"   = var.End_Date
    }

  }

  # Create Data server after create web sg
  depends_on = [aws_security_group.data-sg]

  # To make SSH Connection use connection block
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("Your SSH Private key file path")
  }

  # To Ensure SSH Connection is done.
  # Bydefault Teffaform will tell you that your ssh conection is done! while ssh connection is done.
  provisioner "remote-exec" {
    inline = ["echo You are connnected to data server by ssh"]

  }

}

data "http" "yourip" {
  url = "https://ipv4.icanhazip.com/"
}

# Create Security Group for Database Server.
resource "aws_security_group" "data-sg" {
  name        = "your_SG_Name_for_Database_server"
  description = "allow ssh access from internet"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }
  # To allow traffic from webserver into database server only.
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.web.public_ip}/32"]
  }

  # To give outbound rule for make connectivity outside of network.(By Default)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }



}

# Print Public Ip of Database Server.
output "data_public_ip" {
  value = aws_instance.data.public_ip

}


# null resource block not work for provision the resource but, for working on local.
resource "null_resource" "null" {
  # To run playbook from terraform use provisioner block for execute command.
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.ini main.yml"
    # Run Playbook after web & data instance and inventory file created.
  }
  depends_on = [aws_instance.web, aws_instance.data]


}

# To run only ansible by terrafrom use target in run time.

# terraform plan -target="Your_target_resource_ref."
# terraform apply -target="Your_target_resource_ref."

# terraform apply -target=null_resource.null
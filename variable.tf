variable "ami" {
  default = "ami-of-ec2"

}
variable "instance_type" {
  default = "t2.micro"

}
variable "volume_size_web" {
  default = "By_Default root volume size"

}
variable "volume_size_data" {
  default = "YOur Custom root volume size for Database server"

}
variable "Name_web" {
  default = "Web-server-Bhavin"

}
variable "Name_data" {
  default = "Database-sever-Bhavin"

}
variable "owner" {
  default = "owner_deatail"

}
variable "DM" {
  default = "DM_Name"

}
variable "Department" {
  default = "Dep._Name"

}
variable "End_Date" {
  default = "Date"

}


# To give tag from one value like tag = var.tags
# use map type data
# variable "tags" {
#   description = "Tags for the server"
#   type        = map(string)
#   default     = {
#     Name        = "Application server"
#     Environment = "development"
#   }
# }
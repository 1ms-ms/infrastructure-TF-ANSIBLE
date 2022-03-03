module "infrasctructure" {
  source = "path/to/the/IaC/folder"
  
  variable "instance_count" {
  default = "3"
  }

  variable "instance_tags" {
  default = ["EC-1", "EC-2", "EC-3"]
  }
  
  variable "sub_tags"{
  default = ["SUB-1","SUB-2","SUB-3"]
  }
  
  variable "VPC"{
  type = string
  default = "10.0.0.0/16"
  }
}

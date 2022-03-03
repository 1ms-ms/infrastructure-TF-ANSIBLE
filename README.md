# Full infrastructure create by Terraform and configured by Ansible
The whole project has been divided onto two parts: Terraform (IaC) and Ansible (ansible). The end result are 3 EC2 instances with Apache HTTP Server installed on them and network traffic load balanced by Application Load Balancer.
## Terraform
The code shown in IaC folder provisions 3 EC2 instances with 3 subnets and Application Load Balancer. AMI, instance type and private key name (in ec2.tf file), as well as region, access and secret key (in provider.tf file) needs to be provisioned by the user. All the files provided in IaC folder need to be compiled within the same folder by using ```terraform init``` and ```terraform apply``` or using [terraform module](https://www.terraform.io/language/modules/syntax).
## Ansible
The code shown in ansible folder configures 3 EC2 instances created earlier. This implementation uses roles and the whole tree looks as follows:
```
.
├── roles
│   └── server
│       └── tasks
│           └── main.yml
├── server.yml
├── .inventory
│   └── my_aws_ec2.yml
├── ansible.cfg
```

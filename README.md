# Full infrastructure create by Terraform and configured by Ansible
The whole project has been divided onto two parts: Terraform (IaC) and Ansible (ansible). The end result are 3 EC2 instances with Apache HTTP Server installed on them and network traffic load balanced by Application Load Balancer.
## Terraform
The code shown in IaC folder provisions 3 EC2 instances with 3 subnets and Application Load Balancer. AMI, instance type and private key name (in ec2.tf file), as well as region, access and secret key (in provider.tf file) needs to be provisioned by the user. All the files provided in IaC folder need to be compiled within the same folder by using ```terraform init``` and ```terraform apply``` or using [terraform module](https://www.terraform.io/language/modules/syntax).
## Ansible
The code shown in ansible folder configures 3 EC2 instances created earlier. This implementation uses roles and the whole tree needs to look as follows:
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
The ```roles/server/tasks/``` directory follows the structure which can be found [here](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#id2). It consists of a ```main.yml``` file, which hold the whole server configuration, that allows printing of server ip (used to check if ALB works correctly) by using ```ansible_hostname```. This task is called from ```server.yml```, which consists of ```hosts``` part (instances to be connected to), privelage escalation using ```become: true``` and ```roles```, which describes which role shall be used.<br />
In order to connect to the EC2 instance, ```ansible.cfg``` needs to be properly configured. First of all, ```aws_ec2``` plugin shall be installed and ```remote_user``` set to ```ec2-user```. Then, path to the private key that has been created and downloaded from AWS, as well as, path to the inventory file shall be described.<br />
Within the inventory file, that is ```my_aws_ec2.yml``` all the information like plugin, regions, filters (used to make sure we use only instances we want, rely on tags created via terraform), access and secret key need to be specified.

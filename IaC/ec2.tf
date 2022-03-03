resource "aws_instance" "myec2" {
   count = length(aws_subnet.subnet.*.id)
   ami = ""
   instance_type = ""
   key_name = ""
   subnet_id = element(aws_subnet.subnet.*.id, count.index)
   security_groups = [aws_security_group.sg.id, ]
   tags = {
     Name = element(var.instance_tags, count.index)
   }
}

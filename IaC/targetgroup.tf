resource "aws_lb_target_group" "tg" {
  name        = "TargetGroup"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.VPC.id

  health_check {
    path = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout = 4
    interval = 5
    matcher = "200"
  }
}

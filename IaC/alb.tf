resource "aws_lb" "lb" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id, ]
  subnets            = aws_subnet.subnet.*.id
}
resource "aws_lb_listener" "me" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
    }
}
resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.me.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn

  }

  condition {
    path_pattern {
      values = ["/var/www/html/index.html"]
    }
  }
}

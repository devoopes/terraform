resource "aws_alb" "default" {
  name            = "alb"
  security_groups = [aws_security_group.alb.id]
  subnets         = [for subnet in aws_subnet.public : subnet.id]
}

# alb_target_group

resource "aws_alb_target_group" "default" {
  health_check {
    path = "/"
  }

  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"

  stickiness {
    type = "lb_cookie"
    # If you're using Socket, for example, you need to make sure all connections go to the same group, in this case, use the stickiness { type = "lb_cookie" } to stick the session and avoid Round Robin that will normally send the connection to some instance with less process.
  }

  vpc_id = aws_vpc.default.id
}

# alb_listener

resource "aws_alb_listener" "default" {
  default_action {
    target_group_arn = aws_alb_target_group.default.arn
    type             = "forward"
  }

  load_balancer_arn = aws_alb.default.arn
  port              = 80
  protocol          = "HTTP"
}

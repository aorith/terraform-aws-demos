resource "aws_lb" "default" {
  name               = local.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = local.default_tags
}

resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.default.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }

  tags = local.default_tags
}

resource "aws_lb_target_group" "default" {
  name        = local.container_name
  port        = local.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    matcher  = "200-499"
    path     = "/"
    port     = local.container_port
    interval = 30
  }

  stickiness {
    type = "lb_cookie"
  }

  depends_on = [aws_lb.default]

  tags = local.default_tags
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.listener_http.arn
  priority     = 99
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  tags = local.default_tags
}

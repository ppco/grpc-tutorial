#load balancer controller を利用するため、こちらは不使用

# resource "aws_lb" "sample_alb" {
#   name               = "sample-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.sample_alb_security_group.id]
#   subnets            = [aws_subnet.sample_public_subnet1.id, aws_subnet.sample_public_subnet2.id]
#   tags = {
#     Name      = "${local.project}-alb"
#     terraform = true
#   }
# }

# # ALBリスナー(HTTP1 rest)
# resource "aws_lb_listener" "sample_http_alb_listener" {
#   load_balancer_arn = aws_lb.sample_alb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.sample_http_alb_target_group.arn
#   }
#   tags = {
#     Name      = "${local.project}-http-alb-listener"
#     terraform = true
#   }
# }

# # ALBターゲットグループ(HTTP1 rest)
# resource "aws_lb_target_group" "sample_http_alb_target_group" {
#   name = "sample-http-alb-target-group"

#   protocol         = "HTTP"
#   protocol_version = "HTTP1"
#   port             = 8888

#   vpc_id      = aws_vpc.sample_vpc.id
#   target_type = "ip"

#   lifecycle {
#     create_before_destroy = true
#   }
#   tags = {
#     Name      = "${local.project}-http-alb-target-group"
#     terraform = true
#   }
# }

# resource "aws_security_group" "sample_alb_security_group" {
#   name   = "sample-alb-security-group"
#   vpc_id = aws_vpc.sample_vpc.id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["131.147.64.0/19"] #nuroのcidr
#   }
#   tags = {
#     Name      = "${local.project}-alb-sg"
#     terraform = true
#   }
# }
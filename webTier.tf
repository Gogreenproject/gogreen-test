# Subnet for web layer
module "subnet-pub-1a" {
  source      = "./modules/subnet"
  vpc_id      = module.my_vpc.my_vpc_id
  cidr_subnet = var.cidr_subnet_1
  az_subnet   = var.az_subnet_1
  public      = var.public_1
  tags_subnet = var.tags_subnet_1
}
module "subnet-pub-1b" {
  source      = "./modules/subnet"
  vpc_id      = module.my_vpc.my_vpc_id
  cidr_subnet = var.cidr_subnet_2
  az_subnet   = var.az_subnet_2
  public      = var.public_2
  tags_subnet = var.tags_subnet_2
}
# Route table association
module "rt_ass_pub_1a" {
  source         = "./modules/rt_association"
  subnet_id      = module.subnet-pub-1a.subnet_id
  route_table_id = module.public_rt.rt_id
}
module "rt_ass_pub_1b" {
  source         = "./modules/rt_association"
  subnet_id      = module.subnet-pub-1b.subnet_id
  route_table_id = module.public_rt.rt_id
}
# Security Group
module "sg_alb_web" {
  source         = "./modules/security_group"
  ingress_rules  = var.ingress_rules_web
  vpc_id         = module.my_vpc.my_vpc_id
  sg_name        = var.sg_name_web
  sg_description = var.sg_description_web
  egress_rules   = var.egress_rules_web
  #security_groups = var.security_groups_web
  tags_sg = var.tags_sg_web
}
# Application load balancer 
module "web-alb" {
  source = "./modules/application_load_balancer"
  name   = "tf-webtier-alb"
  #internal           = false
  #load_balancer_type = "application"
  security_groups = [module.sg_alb_web.sg_id]
  subnets         = [module.subnet-pub-1a.subnet_id, module.subnet-pub-1b.subnet_id]

  #enable_deletion_protection = false

  tags_alb = var.tags_alb_web
}
# Target group
module "webTier-tg" {
  source   = "./modules/target_group"
  name     = "tf-webTier-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.my_vpc.my_vpc_id
  tags_tg  = var.tags_web_tg
}
# Listener group
module "http_listener_web" {
  source   = "./modules/listener_group"
  lb_arn   = module.web-alb.alb_arn
  port     = "80"
  protocol = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  tg_arn = module.webTier-tg.tg_arn
}
# Autoscaling
module "web_asg1" {
  source              = "./modules/autoscaling_group"
  vpc_zone_identifier = [module.subnet-pub-1a.subnet_id]
  #  availability_zones = ["us-west-2a"]
  desired_capacity  = 1
  max_size          = 6
  min_size          = 1
  target_group_arns = [module.webTier-tg.tg_arn]
  launch_template   = module.webtier_lt.lt_id

}
module "web_asg2" {
  source              = "./modules/autoscaling_group"
  vpc_zone_identifier = [module.subnet-pub-1b.subnet_id]
  #  availability_zones = ["us-west-2b"]
  desired_capacity  = 1
  max_size          = 6
  min_size          = 1
  target_group_arns = [module.webTier-tg.tg_arn]
  launch_template   = module.webtier_lt.lt_id

}
# Security group for webserver
module "sg_web_server" {
  source = "./modules/security_group"
  ingress_rules = [
    {
      description     = "allow on 443"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      cidr_blocks     = null
      security_groups = [module.sg_alb_web.sg_id]
    },
    {
      description     = "allow on 80"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = null
      security_groups = [module.sg_alb_web.sg_id]
    },
      {
      description     = "allow on 22 through Bastion"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = [join("", [aws_instance.bastion.private_ip, "/32"])]
      security_groups = [module.bastion_host_sg.sg_id]
    }
  ] #var.ingress_rules_web_server
  vpc_id         = module.my_vpc.my_vpc_id
  sg_name        = var.sg_name_web_server
  sg_description = var.sg_description_web_server
  egress_rules   = var.egress_rules_web_server
  #security_groups = var.security_groups_web_server
  tags_sg = var.tags_sg_web_server
}
# AWS Key Pair
resource "aws_key_pair" "key01" {
  key_name   = "tf-keypair-web"
  public_key = file("~/.ssh/id_ed25519.pub")
}
# Launch template
module "webtier_lt" {
  source                 = "./modules/launch_template"
  name_prefix            = "tf-webserver-"
  image_id               = "ami-01450e8988a4e7f44"
  instance_type          = "t2.micro"
  key_name               = "tf-keypair-web"
  user_data              = filebase64("${path.module}/web.sh")
  vpc_security_group_ids = [module.sg_web_server.sg_id]
  tags_lt = {
    Name = "tf-webtier_lt",
    Kind = "practice"
  }
}
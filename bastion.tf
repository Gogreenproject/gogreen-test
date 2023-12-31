#Bastion host instance

resource "aws_instance" "bastion" {
  ami             = "ami-01450e8988a4e7f44"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.bastion-key.id
  subnet_id       = module.subnet-pub-1b.subnet_id
  security_groups = [module.bastion_host_sg.sg_id]
  tags = {
    Name = "bastion_host"
  }
}

# Key pair
resource "aws_key_pair" "bastion-key" {
  key_name   = "tf-keypair"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# Security Group
module "bastion_host_sg" {
  source         = "./modules/security_group"
  ingress_rules  = var.ingress_rules_bh
  vpc_id         = module.my_vpc.my_vpc_id
  sg_name        = var.sg_name_bh
  sg_description = var.sg_description_bh
  egress_rules   = var.egress_rules_bh
  #security_groups = var.security_groups_web
  tags_sg = var.tags_sg_bh
}
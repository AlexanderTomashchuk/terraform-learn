output "ec2-public-ip" {
  value = module.myapp-webserver.webserver.public_ip
}

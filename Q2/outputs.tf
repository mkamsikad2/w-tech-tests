output "instance_id" {
  value = aws_instance.webserver.id
}

output "public_ip" {
  value = aws_instance.webserver.public_ip
}

output "public_dns" {
  value = aws_instance.webserver.public_dns
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.webserver.public_ip}"
}

output "web_url" {
  value = "http://${aws_instance.webserver.public_ip}"
}
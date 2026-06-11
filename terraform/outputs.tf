output "public_ip" {
  description = "Elastic IP of the Minecraft server"
  value       = aws_eip.minecraft.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.minecraft.id
}

output "nmap_command" {
  description = "Command to verify Minecraft port"
  value       = "nmap -sV -Pn -p T:25565 ${aws_eip.minecraft.public_ip}"
}

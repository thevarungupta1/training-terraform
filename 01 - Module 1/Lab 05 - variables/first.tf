variable "username" {
  
}

output "printblock" {
  value = "hello, ${ var.username }"
}
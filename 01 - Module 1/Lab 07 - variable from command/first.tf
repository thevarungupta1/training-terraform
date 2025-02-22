output "printname" {
  value = "Hello, ${ var.username }"
}


# terraform plan -var "username=John"
variable "username" {
  type = string
}

output "printname" {
  value = "Hello, ${ var.username }"
}

# export TF_VAR_username=mark
# echo $TF_VAR_username
# terraform plan
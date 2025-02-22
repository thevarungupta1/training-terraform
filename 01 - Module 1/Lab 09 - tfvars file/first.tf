variable "name" {
    type = string  
}

variable "age" {
  type = number
}

output "printblock" {
  value = "Hello, ${ var.name }, your age is ${ var.age }"
}
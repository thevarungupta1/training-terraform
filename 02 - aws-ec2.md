### main.tf
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

provider "aws" {
  region = var.region
}


resource "aws_instance" "myserver" {
  ami           = "ami-0c0e147c706360bd7"
  instance_type = "t3.nano"

  tags = {
    Name = "SampleServer"
  }
}
```

### outputs.tf
```
output "aws_instance_public_ip" {
  value = aws_instance.myserver.public_ip
}
```

### variables.tf
```
variable "region" {
  description = "Value of region"
  type        = string
  default     = "eu-north-1"
}
```
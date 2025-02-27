### index.html
```
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="styles.css">
    <title>Document</title>
</head>

<body>
    <h1>Hi, I am deployed using Terraform</h1>
</body>

</html>
```

### styles.css
```
/* styles.css */
body {
    /* Set a gradient background from purple to teal */
    background: linear-gradient(to right, #6a3093, #a044ff, #5f2c82, #49a09d);
    font-family: Arial, sans-serif;
    /* Sets a clean, modern font for the body text */
    color: white;
    /* Sets the text color to white for better contrast */
    margin: 0;
    /* Removes default margin */
    padding: 0;
    /* Removes default padding */
    display: flex;
    /* Enables flexbox layout */
    justify-content: center;
    /* Centers content horizontally */
    align-items: center;
    /* Centers content vertically */
    height: 100vh;
    /* Makes the body take the full height of the viewport */
}

h1 {
    font-size: 2em;
    /* Sets the size of the header text */
    text-align: center;
    /* Centers the header text */
}
```

### main.tf
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "random_id" "rand_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "mywebapp-bucket" {
  bucket = "mywebapp-bucket-${random_id.rand_id.hex}"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mywebapp-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "mywebapp" {
  bucket = aws_s3_bucket.mywebapp-bucket.id
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Sid       = "PublicReadGetObject",
          Effect    = "Allow",
          Principal = "*",
          Action    = "s3:GetObject",
          Resource  = "${aws_s3_bucket.mywebapp-bucket.arn}/*"
        }
      ]
    }
  )
}

resource "aws_s3_bucket_website_configuration" "mywebapp" {
  bucket = aws_s3_bucket.mywebapp-bucket.id

  index_document {
    suffix = "index.html"
  }
}


resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.mywebapp-bucket.bucket
  source       = "./index.html"
  key          = "index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "styles_css" {
  bucket       = aws_s3_bucket.mywebapp-bucket.bucket
  source       = "./styles.css"
  key          = "styles.css"
  content_type = "text/css"
}

output "name" {
  value = aws_s3_bucket_website_configuration.mywebapp.website_endpoint
}
```

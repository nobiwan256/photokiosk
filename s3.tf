variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

resource "aws_s3_bucket" "wordpress_bucket" {
  bucket = var.s3_bucket_name
}

##############################
# S3 Bucket for WordPress Files
##############################

resource "aws_s3_bucket" "wordpress_bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"

  tags = {
    Name        = "${var.project_name}-wordpress-bucket"
    Environment = var.env
  }
}

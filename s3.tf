/*
# S3 Bucket for WordPress
# Commenting out completely to avoid permission issues

resource "aws_s3_bucket" "wordpress_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "${var.project_name}-bucket"
    Environment = var.env
  }
}
*/

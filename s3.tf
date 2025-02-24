##############################
# S3 Bucket for WordPress Files
##############################

resource "aws_s3_bucket" "wordpress_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "${var.project_name}-wordpress-bucket"
    Environment = var.env
  }

  lifecycle {
    ignore_changes = [
      object_lock_configuration,
    ]
  }
}

resource "aws_s3_bucket_acl" "wordpress_bucket_acl" {
  bucket = aws_s3_bucket.wordpress_bucket.id
  acl    = "private"
}

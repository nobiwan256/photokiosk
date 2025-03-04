resource "aws_s3_bucket" "wordpress_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "${var.project_name}-bucket"
    Environment = var.env
  }
}

resource "aws_s3_bucket_public_access_block" "wordpress_bucket_public_access" {
  bucket                  = aws_s3_bucket.wordpress_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

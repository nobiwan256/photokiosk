# Basic S3 Bucket with minimal permissions
resource "aws_s3_bucket" "wordpress_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "${var.project_name}-bucket"
    Environment = var.env
  }
}

# Set basic bucket settings
resource "aws_s3_bucket_ownership_controls" "wordpress_bucket_ownership" {
  bucket = aws_s3_bucket.wordpress_bucket.id
  
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Set public access block
resource "aws_s3_bucket_public_access_block" "wordpress_bucket_public_access" {
  bucket                  = aws_s3_bucket.wordpress_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Set versioning
resource "aws_s3_bucket_versioning" "wordpress_bucket_versioning" {
  bucket = aws_s3_bucket.wordpress_bucket.id
  
  versioning_configuration {
    status = "Disabled"  # Set to Enabled if you need versioning
  }
}

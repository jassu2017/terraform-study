resource "aws_s3_bucket" "example-s3" {
  bucket = var.bucket_name
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.example-s3.bucket
  key    = "${var.s3_bucket_key_name}.jpg"
  source = "rose.jpg"


}

resource "aws_s3_bucket_public_access_block" "example-public-acl" {
  bucket = aws_s3_bucket.example-s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

data "aws_s3_object" "demo-s3-datasrc" {
  bucket = aws_s3_bucket.example-s3.bucket
  key    = aws_s3_object.object.key
}


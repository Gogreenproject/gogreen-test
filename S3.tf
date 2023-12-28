resource "aws_s3_bucket" "Go-Bucket" {
  bucket = "gogreen123456"

  tags = {
    Name        = "Go-Bucket"
    Environment = "Dev"
  }
}
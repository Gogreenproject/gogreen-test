resource "aws_s3_bucket" "Go-Bucket" {
  bucket = "go-green-bucket-12345"

  tags = {
    Name        = "Go-Bucket"
    Environment = "Dev"
  }
}
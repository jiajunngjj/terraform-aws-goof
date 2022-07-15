resource "aws_s3_bucket" "allowed" {
  bucket = "my-test-s3-terraform-bucket"
  tags {
    owner = "snyk"
  }
}

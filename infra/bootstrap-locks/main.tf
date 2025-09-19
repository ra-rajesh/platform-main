provider "aws" {
  region = var.region
}

resource "aws_dynamodb_table" "locks" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "lock_table_name" {
  value = aws_dynamodb_table.locks.name
}

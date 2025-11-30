env_name    = "db-test"
region      = "us-east-1"
repositories         = {}
image_tag_mutability = "MUTABLE"
scan_on_push         = true
encryption_type      = "AES256"

# Publish to SSM for convenience
ssm_prefix = "/platform-main"

tags = {
  Project     = "platform-main"
  Environment = "db-test"
}

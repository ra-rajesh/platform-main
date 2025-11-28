env_name    = "{{env.name}}"
region      = "{{aws.region}}"
repositories         = {}
image_tag_mutability = "MUTABLE"
scan_on_push         = true
encryption_type      = "AES256"

# Publish to SSM for convenience
ssm_prefix = "/platform-main"

tags = {
  Project     = "platform-main"
  Environment = "{{env.name}}"
}

env_name = "stage"
region   = "ap-south-1"

repositories    = ["idlms-app", "vitalreg-app"]
prefix_with_env = true
scan_on_push    = true
force_delete    = true

tags = {
  Environment = "stage"
  Project     = "IDLMS"
}

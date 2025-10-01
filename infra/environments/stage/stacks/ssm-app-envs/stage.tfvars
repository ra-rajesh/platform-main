region     = "ap-south-1"
env_name   = "stage"
param_root = "/idlms"
kms_key_id = null # or "alias/idlms-ssm-params"
build_tag  = null # or set a default tag for all apps

shared_defaults = {
  HEALTH_PATH = "/health"
}
apps = [
  {
    name = "idlms-app"
    port = 4000
    env = {
      JWT_SECRET = "replace_me"
      IMAGE_REPO = "592776312448.dkr.ecr.ap-south-1.amazonaws.com/stage-idlms-api"
    }
  },
  {
    name = "vitalreg-app"
    port = 4010
    env = {
      JWT_SECRET = "replace_me_2"
      IMAGE_REPO = "592776312448.dkr.ecr.ap-south-1.amazonaws.com/stage-vitalreg-api"
    }
  }
  # {
  #   name = "new-service"
  #   port = 4002
  #   env  = {
  #     JWT_SECRET = "replace_me_3"
  #     IMAGE_REPO = "592776312448.dkr.ecr.ap-south-1.amazonaws.com/stage-new-service"
  #   }
  # }
]

common_tags = {
  Environment = "stage"
  Project     = "IDLMS"
}

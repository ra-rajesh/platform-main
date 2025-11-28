env_name    = "{{env.name}}"
region      = "{{aws.region}}"

cwagent_ssm_param_path = "/{{env.name}}/platform_main/cloudwatch/agent-config"

# Add as many apps as you want here
apps = []

retention_in_days = 14

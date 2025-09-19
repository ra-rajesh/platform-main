# Get each TG ARN from EC2 > Target groups (region ap-south-1, acct 881490099206)

import {
  to = module.nlb.aws_lb_target_group.multi["4000"]
  id = "arn:aws:elasticloadbalancing:ap-south-1:881490099206:targetgroup/stage-idlms-nlb-4000/49c49051f03f5f54"
}
import {
  to = module.nlb.aws_lb_target_group.multi["4001"]
  id = "arn:aws:elasticloadbalancing:ap-south-1:881490099206:targetgroup/stage-idlms-nlb-4001/822f15c67f5a202d"
}
import {
  to = module.nlb.aws_lb_target_group.multi["4002"]
  id = "arn:aws:elasticloadbalancing:ap-south-1:881490099206:targetgroup/stage-idlms-nlb-4002/5f12b4046006aeec"
}
import {
  to = module.nlb.aws_lb_target_group.multi["4010"]
  id = "arn:aws:elasticloadbalancing:ap-south-1:881490099206:targetgroup/stage-idlms-nlb-4010/ce38616156d2b09b"
}

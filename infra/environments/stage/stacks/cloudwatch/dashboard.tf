locals {
  tg_widgets = [
    for port, sfx in local.tg_suffixes : {
      "type" : "metric",
      "width" : 12,
      "height" : 6,
      "properties" : {
        "title" : "TG ${port} health",
        "view" : "timeSeries",
        "region" : var.region,
        "stacked" : false,
        "legend" : { "position" : "bottom" },
        "metrics" : [
          ["AWS/NetworkELB", "HealthyHostCount", "TargetGroup", sfx, "LoadBalancer", local.lb_suffix],
          [".", "UnHealthyHostCount", "TargetGroup", ".", "LoadBalancer", "."]
        ],
        "yAxis" : { "left" : { "min" : 0 } }
      }
    }
  ]

  lb_widgets = [
    {
      "type" : "metric",
      "width" : 24,
      "height" : 6,
      "properties" : {
        "title" : "NLB Connections / Flows / Bytes",
        "view" : "timeSeries",
        "region" : var.region,
        "stacked" : false,
        "legend" : { "position" : "bottom" },
        "metrics" : [
          ["AWS/NetworkELB", "ActiveFlowCount", "LoadBalancer", local.lb_suffix],
          [".", "NewFlowCount", "LoadBalancer", "."],
          [".", "ProcessedBytes", "LoadBalancer", ".", { "stat" : "Sum" }]
        ]
      }
    }
  ]
}

resource "aws_cloudwatch_dashboard" "nlb" {
  dashboard_name = "${var.env_name}-idlms-nlb"
  dashboard_body = jsonencode({ widgets = concat(local.lb_widgets, local.tg_widgets) })
}

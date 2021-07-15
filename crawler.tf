resource "aws_glue_crawler" "ec2_compute_optimizer" {
  database_name = var.athena_database
  name          = "ec2_compute_optimizer${var.env}"
  role          = aws_iam_role.compute_optimizer_role.arn
  schedule      = "cron(07 10 * * ? *)"

  s3_target {
    path = "s3://${aws_s3_bucket.s3_bucket.id}/Compute_Optimizer/Compute_Optimizer_ec2_instance"
  }

  configuration = <<EOF
    {"Version":1.0,"CrawlerOutput":{"Partitions":{"AddOrUpdateBehavior":"InheritFromTable"}}}
EOF


  tags = {
    Team = "FinOps"
  }
}

resource "aws_glue_crawler" "auto_compute_optimizer" {
  database_name = var.athena_database
  name          = "auto_compute_optimizer${var.env}"
  role          = aws_iam_role.compute_optimizer_role.arn
  schedule      = "cron(07 10 * * ? *)"

  s3_target {
    path = "s3://${aws_s3_bucket.s3_bucket.id}/Compute_Optimizer/Compute_Optimizer_auto_scale"
  }

  configuration = <<EOF
    {"Version":1.0,"CrawlerOutput":{"Partitions":{"AddOrUpdateBehavior":"InheritFromTable"}}}
EOF


  tags = {
    Team = "FinOps"
  }
}

resource "aws_glue_crawler" "lambda_optimizer" {
  database_name = var.athena_database
  name          = "lambda_optimizer${var.env}"
  role          = aws_iam_role.compute_optimizer_role.arn
  schedule      = "cron(07 10 * * ? *)"

  s3_target {
    path = "s3://${aws_s3_bucket.s3_bucket.id}/Compute_Optimizer/Compute_Optimizer_lambda"
  }

  configuration = <<EOF
    {"Version":1.0,"CrawlerOutput":{"Partitions":{"AddOrUpdateBehavior":"InheritFromTable"}}}
EOF


  tags = {
    Team = "FinOps"
  }
}

resource "aws_glue_crawler" "ebs_volumes_optimizer" {
  database_name = var.athena_database
  name          = "ebs_volumes_optimizer${var.env}"
  role          = aws_iam_role.compute_optimizer_role.arn
  schedule      = "cron(07 10 * * ? *)"

  s3_target {
    path = "s3://${aws_s3_bucket.s3_bucket.id}/Compute_Optimizer/Compute_Optimizer_ebs_volume"
  }

  configuration = <<EOF
    {"Version":1.0,"CrawlerOutput":{"Partitions":{"AddOrUpdateBehavior":"InheritFromTable"}}}
EOF


  tags = {
    Team = "FinOps"
  }
}

resource "aws_iam_role_policy" "compute_optimizer_role_policy" {
  name = "compute_optimizer_collector_Role_Policy${var.env}"
  role = aws_iam_role.compute_optimizer_role.id

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Action": [
"glue:*",
"s3:GetBucketLocation",
"s3:ListBucket",
"s3:ListAllMyBuckets",
"s3:GetBucketAcl",
"ec2:DescribeVpcEndpoints",
"ec2:DescribeRouteTables",
"ec2:CreateNetworkInterface",
"ec2:DeleteNetworkInterface",
"ec2:DescribeNetworkInterfaces",
"ec2:DescribeSecurityGroups",
"ec2:DescribeSubnets",
"ec2:DescribeVpcAttribute",
"iam:ListRolePolicies",
"iam:GetRole",
"iam:GetRolePolicy",
"cloudwatch:PutMetricData"
],
"Resource": [
"*"
]
},
{
"Effect": "Allow",
"Action": [
"s3:CreateBucket"
],
"Resource": [
"arn:aws:s3:::aws-glue-*"
]
},
{
"Effect": "Allow",
"Action": [
"s3:GetObject",
"s3:PutObject",
"s3:DeleteObject"
],
"Resource": [
"arn:aws:s3:::aws-glue-*/*",
"arn:aws:s3:::*/*aws-glue-*/*"
]
},
{
"Effect": "Allow",
"Action": [
"s3:GetObject"
],
"Resource": [
"arn:aws:s3:::crawler-public*",
"arn:aws:s3:::aws-glue-*"
]
},
{
"Effect": "Allow",
"Action": [
"logs:CreateLogGroup",
"logs:CreateLogStream",
"logs:PutLogEvents"
],
"Resource": [
"arn:aws:logs:*:*:/aws-glue/*"
]
},
{
"Effect": "Allow",
"Action": [
"ec2:CreateTags",
"ec2:DeleteTags"
],
"Condition": {
"ForAllValues:StringEquals": {
"aws:TagKeys": [
"aws-glue-service-resource"
]
}
},
"Resource": [
"arn:aws:ec2:*:*:network-interface/*",
"arn:aws:ec2:*:*:security-group/*",
"arn:aws:ec2:*:*:instance/*"
]
},
{
"Effect": "Allow",
"Action": [
"s3:GetObject",
"s3:PutObject"
],
"Resource": [
"arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}*"
]
}
]
}
EOF

}

resource "aws_iam_role" "compute_optimizer_role" {
  name = "compute_optimizer_collector_Role${var.env}"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Principal": {
"Service": "glue.amazonaws.com"
},
"Action": "sts:AssumeRole"
}
]
}
EOF


  tags = {
    Team = "FinOps"
  }
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.compute_optimizer_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.bucket_name}-${data.aws_caller_identity.current.account_id}"
  region = var.region

  versioning {
    enabled = true
  }
}


resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.s3_bucket.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "compute-optimizer.amazonaws.com"
          },
          "Action" : "s3:GetBucketAcl",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}"
        },
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "compute-optimizer.amazonaws.com"
          },
          "Action" : "s3:GetBucketPolicyStatus",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}"
        },
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "compute-optimizer.amazonaws.com"
          },
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}/*",
          "Condition" : {
            "StringEquals" : {
              "s3:x-amz-acl" : "bucket-owner-full-control"
            }
          }
        }
      ]
    }

  )
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.start_crawler.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
    filter_prefix       = "Compute_Optimizer/Compute_Optimizer_ebs_volume/"
  }
}

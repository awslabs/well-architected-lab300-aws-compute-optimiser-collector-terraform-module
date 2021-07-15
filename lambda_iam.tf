resource "aws_iam_role" "iam_role_for_accounts" {
  name               = "org_accounts${var.env}"
  assume_role_policy = file("${path.module}/policies/LambdaAssume.pol")
}

resource "aws_iam_role_policy" "iam_role_policy_for_athena" {
  name   = "org_accounts${var.env}"
  role   = aws_iam_role.iam_role_for_accounts.id
  policy = file("${path.module}/policies/LambdaAthena.pol")
}


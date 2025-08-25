
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
data "aws_iam_policy_document" "gha_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals { type = "Federated" identifiers = [aws_iam_openid_connect_provider.github.arn] }
    condition { test = "StringLike" variable = "token.actions.githubusercontent.com:sub" values = ["repo:${var.github_repo}:*"] }
    condition { test = "StringEquals" variable = "token.actions.githubusercontent.com:aud" values = ["sts.amazonaws.com"] }
  }
}
resource "aws_iam_role" "gha_role" { name = "${var.project_name}-gha-oidc" assume_role_policy = data.aws_iam_policy_document.gha_assume.json }
data "aws_iam_policy_document" "gha_policy" {
  statement { effect = "Allow" actions = ["ecr:*","ec2:*","iam:PassRole","ssm:*","cloudwatch:*","logs:*"] resources = ["*"] }
}
resource "aws_iam_policy" "gha_policy" { name = "${var.project_name}-gha-policy" policy = data.aws_iam_policy_document.gha_policy.json }
resource "aws_iam_role_policy_attachment" "gha_attach" { role = aws_iam_role.gha_role.name policy_arn = aws_iam_policy.gha_policy.arn }
output "gha_role_arn" { value = aws_iam_role.gha_role.arn }

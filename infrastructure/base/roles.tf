resource "aws_iam_policy" "sm-policy" {
  name        = "sm-policy-for-eks"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Effect   = "Allow"
        Resource = [
          aws_secretsmanager_secret.parrot_db_secret.arn
        ]
      },
      {
        "Effect": "Allow",
        "Action": "secretsmanager:ListSecrets",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sm-eks-role-attach" {
  role       = module.eks.worker_iam_role_name
  policy_arn = aws_iam_policy.sm-policy.arn
}

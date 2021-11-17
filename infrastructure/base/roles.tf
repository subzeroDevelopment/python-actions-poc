// resource "aws_iam_role" "ecs_task_role" {
//   name = "ecs_task_role"

//   assume_role_policy = jsonencode({
//     Version = "2012-10-17"
//     Statement = [
//       {
//         Action = "sts:AssumeRole"
//         Effect = "Allow"
//         Sid    = ""
//         Principal = {
//           Service = "ecs-tasks.amazonaws.com"
//         }
//       },
//     ]
//   })
// }

// data "aws_kms_alias" "sm_key" {
//   name = "alias/aws/secretsmanager"
// }

// resource "aws_iam_policy" "sm-policy" {
//   name        = "sm-kms-policy-for-ecs"
//   path        = "/"

//   policy = jsonencode({
//     Version = "2012-10-17"
//     Statement = [
//       {
//         Action = [
//           "secretsmanager:GetSecretValue",
//           "kms:Decrypt"
//         ]
//         Effect   = "Allow"
//         Resource = [
//           data.aws_kms_alias.sm_key.target_key_arn,
//           aws_secretsmanager_secret.parrot_db_secret.arn
//         ]
//       },
//     ]
//   })
// }

// resource "aws_iam_role_policy_attachment" "sm-ecs-role-attach" {
//   role       = aws_iam_role.ecs_task_role.name
//   policy_arn = aws_iam_policy.sm-policy.arn
// }

// resource "aws_iam_role_policy_attachment" "ecs-task-role-attach" {
//   role       = aws_iam_role.ecs_task_role.name
//   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
// }
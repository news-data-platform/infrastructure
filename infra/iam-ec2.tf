resource "aws_iam_role" "ec2_etl_instance" {
  name = "${var.project_name}-ec2-etl-instance-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_etl_instance" {
  name = "${var.project_name}-ec2-etl-instance-iam-instance-profile"
  role = aws_iam_role.ec2_etl_instance.name
}

resource "aws_iam_role_policy" "ec2_etl_instance_s3_access" {
  name = "${var.project_name}-ec2-etl-instance-s3-access-iam-policy"
  role = aws_iam_role.ec2_etl_instance.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Sid      = ""
        Resource = "${aws_s3_bucket.data_lake.arn}/*"
      },
      {
        Action   = "s3:PutObject"
        Effect   = "Allow"
        Sid      = ""
        Resource = "${aws_s3_bucket.data_lake.arn}/*"
      },
      {
        Action   = "s3:DeleteObject"
        Effect   = "Allow"
        Sid      = ""
        Resource = "${aws_s3_bucket.data_lake.arn}/*"
      },
      {
        Action   = "s3:ListBucket"
        Effect   = "Allow"
        Sid      = ""
        Resource = "${aws_s3_bucket.data_lake.arn}"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_etl_instance_basic_logs" {
  role       = aws_iam_role.ec2_etl_instance.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

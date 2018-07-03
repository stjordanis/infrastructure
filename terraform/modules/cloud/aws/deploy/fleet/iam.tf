resource "aws_iam_role" "epoch" {
  name = "${data.aws_region.current.name}-${var.env}-epoch"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "epoch" {
  name = "${data.aws_region.current.name}-${var.env}-epoch"
  role = "${aws_iam_role.epoch.name}"
}

resource "aws_iam_role_policy" "epoch_policy" {
  name = "${data.aws_region.current.name}-${var.env}-epoch"
  role = "${aws_iam_role.epoch.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

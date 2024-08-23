resource "aws_sagemaker_domain" "domain" {
  domain_name = "${local.prefix}-domain"
  auth_mode   = "IAM"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets

  default_user_settings {
    execution_role    = aws_iam_role.role.arn
    studio_web_portal = "ENABLED"
  }

  default_space_settings {
    execution_role = aws_iam_role.role.arn
  }
}

resource "aws_sagemaker_space" "space" {
  domain_id  = aws_sagemaker_domain.domain.id
  space_name = "${local.prefix}-learning"

  space_sharing_settings {
    sharing_type = "Shared"
  }
  ownership_settings {
    owner_user_profile_name = aws_sagemaker_user_profile.default.user_profile_name
  }
}

resource "aws_iam_role" "role" {
  name               = "${local.prefix}-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "admin_policy" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_sagemaker_user_profile" "default" {
  domain_id         = aws_sagemaker_domain.domain.id
  user_profile_name = "${local.prefix}-profile"
}

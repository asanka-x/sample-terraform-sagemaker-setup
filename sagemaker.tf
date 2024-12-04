resource "aws_sagemaker_domain" "domain" {
  domain_name = "${local.prefix}-domain"
  auth_mode   = "IAM"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets

  default_user_settings {
    execution_role    = aws_iam_role.role.arn
    studio_web_portal = "ENABLED"

    canvas_app_settings {
      direct_deploy_settings {
        status = "ENABLED"
      }
    }
  }

  default_space_settings {
    execution_role  = aws_iam_role.role.arn
    security_groups = [module.vpc.default_security_group_id]
  }
}

resource "aws_sagemaker_space" "space" {
  domain_id  = aws_sagemaker_domain.domain.id
  space_name = "${local.prefix}-learning"

  space_sharing_settings {
    sharing_type = "Private"
  }
  ownership_settings {
    owner_user_profile_name = aws_sagemaker_user_profile.default.user_profile_name
  }

  space_settings {
    app_type = "JupyterLab"

    jupyter_lab_app_settings {
      default_resource_spec {
        instance_type                 = "ml.t3.medium"
        sagemaker_image_version_alias = "1.10.0"
      }
    }

    space_storage_settings {
      ebs_storage_settings {
        ebs_volume_size_in_gb = 50
      }
    }
  }

  lifecycle {
    ignore_changes = [space_settings]
  }
}

# resource "aws_sagemaker_space" "space_jarib" {
#   domain_id  = aws_sagemaker_domain.domain.id
#   space_name = "${local.prefix}-jarib"

#   space_sharing_settings {
#     sharing_type = "Private"
#   }
#   ownership_settings {
#     owner_user_profile_name = aws_sagemaker_user_profile.default.user_profile_name
#   }

#   space_settings {
#     app_type = "JupyterLab"

#     jupyter_lab_app_settings {
#       default_resource_spec {
#         instance_type                 = "ml.t3.medium"
#         sagemaker_image_version_alias = "1.10.0"
#       }
#     }

#     space_storage_settings {
#       ebs_storage_settings {
#         ebs_volume_size_in_gb = 50
#       }
#     }
#   }

#   lifecycle {
#     ignore_changes = [space_settings]
#   }
# }

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

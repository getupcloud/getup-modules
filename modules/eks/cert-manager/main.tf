locals {
  name_prefix = "cert-manager-"
}

data "aws_iam_policy_document" "cert_manager" {
  statement {
    effect = "Allow"

    actions = [
      "route53:GetChange"
    ]

    resources = [
      "arn:aws:route53:::change/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZonesByName"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets"
    ]

    resources = [
      "arn:aws:route53:::hostedzone/*"
    ]
  }
}

resource "aws_iam_policy" "cert_manager" {
  name_prefix = local.name_prefix
  description = "Cert-Manager policy"
  policy      = data.aws_iam_policy_document.cert_manager.json

  tags = merge(var.cert_manager_tags, {
    "managed-by" : "terraform"
  })
}


module "cert_manager_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.34.0"

  create_role                   = true
  role_name_prefix              = local.name_prefix
  provider_url                  = var.cert_manager_cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.cert_manager.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:cert-manager:cert-manager"] #TODO: parametrize

  tags = merge(var.cert_manager_tags, {
    "managed-by" : "terraform"
  })
}


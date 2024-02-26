output "${name_}_iam_role_arn" {
  description = "${DISPLAY_NAME} role ARN."
  value       = module.${name_}_irsa.iam_role_arn
}

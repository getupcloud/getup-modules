# File auto-generated from ./bin/vars2tfvars

# aws_region - AWS Region.
# Type: ${string}
# Required
#aws_region = <REQUIRED-VALUE>

# cluster_name - EKS cluster name.
# Type: ${string}
# Required
#cluster_name = <REQUIRED-VALUE>

# cluster_endpoint - Endpoint for your Kubernetes API server.
# Type: ${string}
# Required
#cluster_endpoint = <REQUIRED-VALUE>

# cluster_certificate_authority_data - Base64 encoded certificate data required to communicate with the cluster.
# Type: ${string}
# Required
#cluster_certificate_authority_data = <REQUIRED-VALUE>

# flux_github_token - GitHub OAuth / Personal Access Token. Can also by provided via the GITHUB_TOKEN environment variable.
# Type: ${string}
# Default: ""
#flux_github_token = ""

# flux_github_org - GitHub organization or individual user account to manage.
# Type: ${string}
# Default: ""
#flux_github_org = ""

# flux_github_repository - Name of the GitHub repository.
# Type: ${string}
# Default: ""
#flux_github_repository = ""

# flux_path - Path relative to the repository root, when specified the cluster sync will be scoped to this path. Defaults to \"clusters/$${var.aws_region}/$${var.cluster_name}\".
# Type: ${string}
# Default: ""
#flux_path = ""

TERRAFORM            ?= tflocal
TERRAFORM_APPLY_ARGS ?=

test: fmt init validate plan

fmt:
	$(TERRAFORM) fmt

check-tools:
	@type localstack || { echo -e "$$(tput setaf 9)Please install localstack (https://github.com/localstack/localstack)$$(tput sgr0)"; exit 1; }
	@type tflocal || { echo -e "$$(tput setaf 9)Please install tflocal (https://docs.localstack.cloud/user-guide/integrations/terraform/)$$(tput sgr0)"; exit 1; }
	@type awslocal || { echo -e "$$(tput setaf 9)Please install awslocal (https://github.com/localstack/awscli-local) or use $$(tput bold)aws --endpoint-url=http://localhost:4566$$(tput sgr0)"; exit 1; }

start-localstack: check-tools
	localstack start -d

init: start-localstack
	$(TERRAFORM) init $(TERRAFORM_ARGS) $(TERRAFORM_INIT_ARGS)

validate:
	$(TERRAFORM) validate $(TERRAFORM_ARGS) $(TERRAFORM_VALIDATE_ARGS)

plan:
	$(TERRAFORM) apply $(TERRAFORM_ARGS) $(TERRAFORM_APPLY_ARGS) -target=aws_vpc.fake -target=aws_route_table.fake
	$(TERRAFORM) plan $(TERRAFORM_ARGS) $(TERRAFORM_PLAN_ARGS)
	$(TERRAFORM) destroy $(TERRAFORM_ARGS) $(TERRAFORM_PLAN_ARGS) -target=aws_vpc.fake -target=aws_route_table.fake

clean:
	rm -rf .terraform .terraform.lock.hcl terraform.log

###

validate-vars:
	@if [ -z "$(CLUSTER_NAME)" ]; then
		echo "Missing required var: CLUSTER_NAME"
		exit 1
	fi

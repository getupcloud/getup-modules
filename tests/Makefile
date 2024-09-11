TERRAFORM ?= terraform

test: fmt init validate plan

fmt:
	$(TERRAFORM) fmt

init:
	$(TERRAFORM) init $(TERRAFORM_ARGS) $(TERRAFORM_INIT_ARGS)

validate:
	$(TERRAFORM) validate $(TERRAFORM_ARGS) $(TERRAFORM_VALIDATE_ARGS)

plan:
	$(TERRAFORM) plan $(TERRAFORM_ARGS) $(TERRAFORM_PLAN_ARGS)

clean:
	rm -rf .terraform .terraform.lock.hcl terraform.log

###

validate-vars:
	@if [ -z "$(CLUSTER_NAME)" ]; then
		echo "Missing required var: CLUSTER_NAME"
		exit 1
	fi

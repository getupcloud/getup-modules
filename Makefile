VERSION_TXT    := version.txt
FILE_VERSION   := $(shell cat $(VERSION_TXT))
VERSION        ?= $(FILE_VERSION)
RELEASE        := v$(VERSION)
TEMPLATES      := $(notdir $(wildcard templates/*))
SEMVER_REGEX   := ^([0-9]+)\.([0-9]+)\.([0-9]+)(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?(\+[0-9A-Za-z-]+)?$
FLAVORS        := eks doks
MODULES        := eks/argocd \
                  eks/aws-external-secrets-operator \
                  eks/cert-manager \
                  eks/ecr-credentials-sync \
                  eks/eks \
                  eks/flux \
                  eks/istio \
                  eks/loki \
                  eks/opencost \
                  eks/rds \
                  eks/tempo \
                  eks/velero \
                  eks/vpc_peering \
                  doks/doks \
                  doks/flux
COMMON_TARGETS := init validate
TERRAFORM      ?= terraform

.ONESHELL:

.PHONY: examples tests $(COMMON_TARGETS) $(TFVARS)

$(COMMON_TARGETS):
	@for dir in $(addprefix modules/,$(MODULES)) $(addprefix examples/,$(MODULES)); do
		$(MAKE) -C $$dir $@ || exit 1
	done

clean:
	@for dir in tests $(addprefix modules/,$(MODULES)) $(addprefix examples/,$(MODULES)); do
		$(MAKE) -C $$dir $@ || exit 1
	done

test tests:
	$(MAKE) -C tests fmt init validate plan

lint:
	@echo Linting modules:
	pushd modules && tflint --recursive
	popd
	echo
	echo Linting examples:
	pushd examples && tflint --recursive

fmt:
	$(TERRAFORM) fmt -recursive modules examples

examples: MODULE_SOURCE_URL ?= git@github.com:getupcloud/getup-modules//modules/{cluster_flavor}/{module_name}?ref={tag}
examples:
	@for module in $(MODULES); do
		cluster_flavor=$${module%%/*}
		module_name=$${module#*/}
		source_module_dir=modules/$$module
		example_module_dir=examples/$$module
		echo Generating $$example_module_dir
		mkdir -p $$example_module_dir
		if [ -e $$source_module_dir/variables.tf ]; then
			cat $$source_module_dir/variables.tf | ./bin/make-example-main $$cluster_flavor $$module_name $(RELEASE) > $$example_module_dir/main-$$module_name.tf || exit 1
			cat $$source_module_dir/variables.tf | ./bin/make-example-vars $$cluster_flavor module_name=$$module_name tag=$(RELEASE) > $$example_module_dir/variables-$$module_name.tf || exit 1
			cat $$source_module_dir/variables.tf | ./bin/make-example-tfvars > $$example_module_dir/terraform-$$module_name.auto.tfvars.example || exit 1
		fi
		if [ -e $$source_module_dir/outputs.tf ]; then
			cat $$source_module_dir/outputs.tf | ./bin/outputs $$module_name > $$example_module_dir/outputs-$$module_name.tf
		fi
		ln -fs ../../Makefile.example $$example_module_dir/Makefile
	done
	for cluster_flavor in $(FLAVORS); do
		versions_tf=examples/$$cluster_flavor/versions.tf
		echo Generating $$versions_tf
		find modules/$$cluster_flavor -name versions.tf | xargs bin/make-versions $$cluster_flavor > $$versions_tf
	done
	$(MAKE) fmt

release: fmt update-version
	$(MAKE) build-release

update-version:
	@if git status --porcelain | grep '^[^?]' | grep -vq $(VERSION_TXT); then
		git status
		echo -e "\n>>> Tree is not clean. Please commit and try again <<<\n"
		exit 1
	fi
	[ -n "$$BUILD_VERSION" ] || read -e -i "$(FILE_VERSION)" -p "New version: " BUILD_VERSION
	echo $$BUILD_VERSION > $(VERSION_TXT)

build-release: examples
	git pull --tags
	git commit -m "Auto-generated examples $(RELEASE)" examples
	git commit -m "Built release $(RELEASE)" $(VERSION_TXT)
	git tag $(RELEASE)
	git push
	git push --tags

template:
	@select source in $(TEMPLATES); do
		break
	done
	while true; do
		read -e -p "Name of new module: " NAME
		if [ -d modules/$$NAME ]; then
			echo Already exists: modules/$$NAME
		else
			read -e -p "Display Name of new module: " DISPLAY_NAME
			export NAME DISPLAY_NAME name=$${NAME,,} name_=$${NAME//-/_}
			mkdir -p modules/$$NAME
			for i in templates/$$source/*; do
				envsubst < $$i >> modules/$$NAME/$${i##*/}
			done
			ln -s ../Makefile.common modules/$$NAME/Makefile
			ls -la modules/$$NAME/
			break
		fi
	done

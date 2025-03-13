VERSION_TXT    := version.txt
FILE_VERSION   := $(shell cat $(VERSION_TXT))
VERSION        ?= $(FILE_VERSION)
RELEASE        := v$(VERSION)
TEMPLATES      := $(notdir $(wildcard templates/*))
SEMVER_REGEX   := ^([0-9]+)\.([0-9]+)\.([0-9]+)(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?(\+[0-9A-Za-z-]+)?$
MODULES        := argocd \
                  aws-external-secrets-operator \
                  cert-manager \
                  ecr-credentials-sync \
                  eks \
                  flux \
                  istio \
                  loki \
                  opencost \
                  rds \
                  tempo \
                  velero \
                  vpc_peering
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

examples: MODULE_SOURCE_URL ?= git@github.com:getupcloud/getup-modules//modules/{module_name}?ref={tag}
examples:
	@for dir in $(addprefix modules/,$(MODULES)); do
		name=$${dir##*/}
		echo Generating examples/$$name
		mkdir -p examples/$$name
		if [ -e $$dir/variables.tf ]; then
			cat $$dir/variables.tf | ./bin/make-example-main $$name $(RELEASE) > examples/$$name/main-$$name.tf || exit 1
			cat $$dir/variables.tf | ./bin/make-example-vars > examples/$$name/variables-$$name.tf || exit 1
			cat $$dir/variables.tf | ./bin/make-example-tfvars > examples/$$name/terraform-$$name.auto.tfvars.example || exit 1
		fi
		if [ -e $$dir/outputs.tf  ]; then
			cat $$dir/outputs.tf | ./bin/outputs $$name > examples/$$name/outputs-$$name.tf
		fi
		ln -fs ../Makefile.example examples/$$name/Makefile
	done
	./bin/make-versions $(wildcard $(addsuffix /versions.tf,$(addprefix modules/,$(MODULES)))) > examples/versions.tf
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

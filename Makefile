VERSION_TXT    := version.txt
FILE_VERSION   := $(shell cat $(VERSION_TXT))
VERSION        ?= $(FILE_VERSION)
RELEASE        := v$(VERSION)
TEMPLATES      := $(notdir $(wildcard templates/*))
SEMVER_REGEX   := ^([0-9]+)\.([0-9]+)\.([0-9]+)(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?(\+[0-9A-Za-z-]+)?$
FLAVORS        := eks doks
MODULES        := eks/argocd \
                  eks/cert-manager \
                  eks/ecr-credentials-sync \
                  eks/eks \
                  eks/external-dns \
                  eks/external-secrets-operator \
                  eks/flux \
                  eks/istio \
                  eks/loki \
                  eks/opencost \
                  eks/rds \
                  eks/tempo \
                  eks/velero \
                  eks/vpc_peering \
                  doks/doks \
                  doks/flux \
                  doks/velero \
                  doks/loki \
                  doks/tempo
COMMON_TARGETS := init validate
TERRAFORM      ?= terraform

.ONESHELL:

.PHONY: examples $(COMMON_TARGETS) $(TFVARS)

all help:
	@echo Available targets
	echo
	echo "  examples        Build each ./examples/[FLAVOR] from ./modules/[FLAVOR]"
	echo "  release         Build a new version release, commit and push to git repo"
	echo "  fmt             Executes 'terraform fmt'"
	echo "  lint            Executes 'tflint'"
	echo "  test            Test all modules"
	echo "  test-[FLAVOR]   Test modules ./test/[FLAVOR] only"
	echo "  clean           Remove test files"
	echo "  template        Creates new module based on ./templates/"
	echo

$(COMMON_TARGETS):
	@for dir in $(addprefix modules/,$(MODULES)) $(addprefix examples/,$(MODULES)); do
		$(MAKE) -C $$dir $@ || exit 1
	done

clean:
	@for dir in tests/* $(addprefix modules/,$(MODULES)) $(addprefix examples/,$(MODULES)); do
		$(MAKE) -C $$dir $@ || exit 1
	done

test: test-eks test-doks

test-%:
	$(MAKE) -C tests/$* test MODULES="$(MODULES)"

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
	@echo Generating examples/common
	for i in examples/common/variables-*.tf; do
		n=$${i%.tf}
		n=$${n#*/variables-}
		cat $$i | bin/make-example tfvars all common $(RELEASE) | terraform fmt - > examples/common/terraform-$${n}.auto.tfvars.example
	done
	for module in $(MODULES); do
		cluster_flavor=$${module%%/*}
		module_name=$${module#*/}
		source_module_dir=modules/$$module
		example_module_dir=examples/$$module
		echo Generating $$example_module_dir
		mkdir -p $$example_module_dir
		if [ -e $$source_module_dir/variables.tf ]; then
			cat $$source_module_dir/variables.tf | ./bin/make-example main $$cluster_flavor $$module_name $(RELEASE)   | terraform fmt - > $$example_module_dir/main-$$module_name.tf|| exit 1
			cat $$source_module_dir/variables.tf | ./bin/make-example vars $$cluster_flavor $$module_name $(RELEASE)   | terraform fmt - > $$example_module_dir/variables-$$module_name.tf || exit 1
			cat $$source_module_dir/variables.tf | ./bin/make-example tfvars $$cluster_flavor $$module_name $(RELEASE) | terraform fmt - > $$example_module_dir/terraform-$$module_name.auto.tfvars.example || exit 1
		fi
		if [ -e $$source_module_dir/outputs.tf ]; then
			cat $$source_module_dir/outputs.tf | ./bin/outputs $$module_name > $$example_module_dir/outputs-$$module_name.tf
		fi
		ln -fs ../../Makefile.example $$example_module_dir/Makefile
		ln -fs ../Makefile.conf $$example_module_dir/Makefile.conf
	done
	\
	for cluster_flavor in $(FLAVORS); do
		versions_tf=examples/$$cluster_flavor/versions.tf.example
		echo Generating $$versions_tf
		find modules/$$cluster_flavor -name versions.tf | xargs bin/make-example versions $$cluster_flavor all $(RELEASE) | terraform fmt - > $$versions_tf || exit 1
		modules_yaml=examples/$$cluster_flavor/modules.yaml
		\
		echo Generating $$modules_yaml
		modules_yaml=examples/$$cluster_flavor/modules.yaml
		echo 'modules:' > $$modules_yaml
		printf "%s\n" $(MODULES) | grep ^$$cluster_flavor/ | cut -f2 -d/ | sort | sed -e 's/^/- /' >> $$modules_yaml
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
		PS3='Cluster flavor: '; select FLAVOR in $(FLAVORS); do break; done
		read -e -p "Name of new module: " NAME
		if [ -d modules/$$FLAVOR/$$NAME ]; then
			echo Already exists: modules/$$NAME
		else
			read -e -p "Display Name of new module: " DISPLAY_NAME
			export NAME DISPLAY_NAME name=$${NAME,,} name_=$${NAME//-/_}
			mkdir -p modules/$$FLAVOR/$$NAME
			for i in templates/$$source/*; do
				envsubst < $$i >> modules/$$FLAVOR/$$NAME/$${i##*/}
			done
			ln -s ../../Makefile.common modules/$$FLAVOR/$$NAME/Makefile
			ls -la modules/$$FLAVOR/$$NAME/
			break
		fi
	done

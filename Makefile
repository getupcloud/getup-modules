VERSION_TXT    := version.txt
FILE_VERSION   := $(shell cat $(VERSION_TXT))
VERSION        ?= $(FILE_VERSION)
RELEASE        := v$(VERSION)
SEMVER_REGEX   := ^([0-9]+)\.([0-9]+)\.([0-9]+)(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?(\+[0-9A-Za-z-]+)?$
MODULES        := modules/eks modules/flux modules/istio modules/argocd modules/loki
EXAMPLES       := examples/eks examples/flux examples/istio examples/argocd
COMMON_TARGETS := fmt lint init validate clean
TEST_TARGETS   := test

.ONESHELL:

.PHONY: examples $(COMMON_TARGETS) $(TFVARS)

$(COMMON_TARGETS):
	@for dir in $(MODULES) $(EXAMPLES); do
		$(MAKE) -C $$dir $@ || exit 1
	done

$(TEST_TARGETS):
	@for dir in $(EXAMPLES); do
		$(MAKE) -C $$dir $@ || exit 1
	done

examples:
	@source examples/config
	for dir in $(MODULES); do
		name=$${dir##*/}
		echo Generating files: examples/$$name
		mkdir -p examples/$$name
		if [ -e $$dir/variables.tf ]; then
			cat $$dir/variables.tf | ./bin/vars2tf $$name $(RELEASE) > examples/$$name/main-$$name.tf || exit 1
			cat $$dir/variables.tf | ./bin/filter-vars > examples/$$name/variables-$$name.tf || exit 1
			cat $$dir/variables.tf | ./bin/vars2tfvars > examples/$$name/terraform-$$name.auto.tfvars.example || exit 1
		fi
		if [ -e $$dir/versions.tf  ]; then
			cp -f $$dir/versions.tf examples/$$name/versions-$$name.tf
		fi
		ln -fs ../Makefile.example examples/$$name/Makefile
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

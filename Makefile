EPOCH_VERSION =? 0.16.0
SITE_PACKAGES := $(shell python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
VIRTUAL_ENV_ERR = Python Virtual environment is not active. Run `virtualenv -p python3 .venv/py3 && source .venv/py3/bin/activate`
.DEFAULT_GOAL := lint

images:
	packer build packer/epoch.json

setup-infrastructure: check-deploy-env
	cd ansible && ansible-playbook -e 'ansible_python_interpreter="/usr/bin/env python3"' \
		--tags "$(DEPLOY_ENV)" environments.yml
	cd terraform && terraform init && terraform apply -var "epoch_version=$(EPOCH_VERSION)" --auto-approve

setup-infrastructure-aws: ansible/roles check-deploy-env
	cd terraform && terraform init && terraform apply -var "epoch_version=$(EPOCH_VERSION)" --auto-approve

setup-node: check-deploy-env
	cd ansible && ansible-playbook --limit="tag_env_$(DEPLOY_ENV):&tag_role_epoch" setup.yml

setup-monitoring: check-deploy-env
	cd ansible && ansible-playbook --limit="tag_env_$(DEPLOY_ENV):&tag_role_epoch" monitoring.yml

setup: setup-infrastructure setup-node setup-monitoring

manage-node: check-deploy-env
ifndef CMD
	$(error CMD is undefined, supported commands: start, stop, restart, ping)
endif
	cd ansible && ansible-playbook --limit="tag_env_$(DEPLOY_ENV):&tag_role_epoch" \
		--extra-vars="cmd=$(CMD)" manage-node.yml

reset-net: check-deploy-env
	cd ansible && ansible-playbook --limit="tag_env_$(DEPLOY_ENV):&tag_role_epoch" reset-net.yml

test-openstack:
	openstack stack create test -e openstack/test/create.yml \
		-t openstack/ae-environment.yml --enable-rollback --wait --dry-run

test-setup-environments:
	cd ansible && ansible-playbook -e 'ansible_python_interpreter="/usr/bin/env python3"' \
		--check -i localhost, environments.yml


test-setup-environments-terraform: pip
	cd terraform && terraform init && terraform plan -var "epoch_version=$(EPOCH_VERSION)"
lint:
	ansible-lint ansible/setup.yml
	ansible-lint ansible/monitoring.yml --exclude ~/.ansible/roles
	ansible-lint ansible/manage-node.yml
	ansible-lint ansible/reset-net.yml
	packer validate packer/epoch.json

lint-terraform:
	cd terraform && terraform init
	cd terraform && terraform validate -var "epoch_version=$(EPOCH_VERSION)"
	cd terraform && terraform fmt -check=true -diff=true

check-deploy-env:
ifndef DEPLOY_ENV
	$(error DEPLOY_ENV is undefined)
endif

.PHONY: \
	images setup-infrastructure setup-node setup-monitoring setup \
	manage-node reset-net lint test-openstack test-setup-environments \
	check-deploy-env

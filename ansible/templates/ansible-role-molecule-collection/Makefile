# last_verified: 2026-09-16 · ansible n/a
# Canonical pipeline targets: Terraform provisions, Ansible configures.
# TF_OUTPUTS points at a `terraform output -json` artifact from the provision stage.
TF_OUTPUTS ?= /tmp/tf-outputs.json
HANDOFF_VARS := ansible/group_vars/all/terraform_outputs.yml

.PHONY: plan apply configure deploy destroy check drift

plan:
	terraform -chdir=terraform plan

apply:
	terraform -chdir=terraform apply

configure:
	mkdir -p ansible/group_vars/all
	python3 scripts/tf_outputs_to_vars.py "$(TF_OUTPUTS)" "$(HANDOFF_VARS)"
	ansible-playbook ansible/site.yml

deploy: apply configure

check:
	ansible-playbook ansible/site.yml --check --diff

drift:
	terraform -chdir=terraform plan -refresh-only

destroy:
	terraform -chdir=terraform destroy

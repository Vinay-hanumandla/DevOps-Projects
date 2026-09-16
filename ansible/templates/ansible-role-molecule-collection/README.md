---
last_verified: 2026-09-16
tool_version: n/a
sources:
  - https://www.ansiblebyexample.com/articles/ansible-terraform-enterprise-infrastructure-as-code-pipeline
  - https://github.com/ansible/terraform-provider-ansible
  - https://scalr.com/learning-center/ultimate-guide-to-using-terraform-with-ansible
---

# Ansible role scaffold with Molecule and collection layout

## Purpose

A starting layout for an Ansible role that is tested with Molecule and shipped
inside a collection, with a CI workflow that runs the tests on every push.
Use it when a playbook has grown past inline tasks and needs its own tests
and versioning. The layout also follows the decoupled Terraform-to-Ansible
handoff: Terraform owns provisioning, Ansible owns configuration, and the two
meet through a generated variables file rather than inline provisioners.

## When to use

- The role configures one service (here: a demo app) and needs `defaults`,
  `tasks`, `handlers`, and `meta` separated the standard way.
- The team wants `molecule test` to gate merges via GitHub Actions.
- Terraform provisions the hosts; this repo only reads `terraform output -json`
  (via the `group_vars/all/terraform_outputs.yml` artifact) or discovers hosts
  with the cloud inventory plugin filtering on Terraform-applied tags such as
  `ManagedBy: terraform`, `Environment`, and `Role`.
- The pipeline guide this scaffold follows pins its CI example with
  `hashicorp/setup-terraform@v3` and `actions/checkout@v4`; this scaffold's
  own CI only needs the checkout step, so that is the one pinned action here.

## Prerequisites

- Ansible and Molecule installed in the environment that runs the tests
  (deliberately unpinned here — pin versions in your own lockfile, not in a
  scaffold, so the template never cites a version it did not verify).
- Docker available if the Molecule driver creates containers.
- For the Terraform handoff: a Terraform root module whose outputs include the
  connection details the role needs. The supported Terraform-side bridge is
  `terraform-provider-ansible` with the inventory plugin in the
  `cloud.terraform` collection; the older `local-exec` + `null_resource`
  pattern still works but the provider is the more robust handoff.

## Steps

1. Copy this directory as the root of the new role/collection repo.
2. Rename the `app_example` role and the collection namespace/name in
   `galaxy.yml` to the real ones.
3. Fill in `roles/app_example/defaults/main.yml` with the service settings.
4. Add tasks to `roles/app_example/tasks/main.yml`; notify handlers on change.
5. Provision infrastructure with Terraform, then generate the handoff file:

   ```bash
   terraform output -json > /tmp/tf-outputs.json
   make configure TF_OUTPUTS=/tmp/tf-outputs.json
   ```

   This writes `ansible/group_vars/all/terraform_outputs.yml` carrying
   `vpc_id`, `db_endpoint`, `redis_endpoint`, `s3_bucket`, and `lb_dns`
   placeholders. Alternatively, skip the file and let
   `ansible/inventory/aws_ec2.yml` discover hosts by tag.
6. Check SSH readiness before configuring (delegated gate):

   ```yaml
   - ansible.builtin.wait_for:
       port: 22
       delay: 30
       timeout: 300
     delegate_to: localhost
   ```

   The full play is in `ansible/site.yml`.
7. Run drift checks before applying changes: `terraform plan -refresh-only`
   for infrastructure drift and
   `ansible-playbook ansible/site.yml --check --diff` for configuration drift.
8. Run the test loop locally, then push — CI runs the same command:

   ```bash
   molecule test
   ```

## Verify

- `molecule test` passes: create, converge, verify, destroy.
- `ansible-playbook ansible/site.yml --check --diff` reports no unexpected changes on
  a second run (idempotence).
- `ansible-galaxy collection build` succeeds from the repo root.

## References

- [Ansible + Terraform enterprise pipeline guide](https://www.ansiblebyexample.com/articles/ansible-terraform-enterprise-infrastructure-as-code-pipeline)
- [terraform-provider-ansible](https://github.com/ansible/terraform-provider-ansible)

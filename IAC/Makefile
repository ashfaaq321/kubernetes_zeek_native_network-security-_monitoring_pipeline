# SPDX-FileCopyrightText: 2023 Aravinth Manivannan <realaravinth@batsense.net>
#
# SPDX-License-Identifier: AGPL-3.0-or-later


define configure_ping
	ansible-playbook -i ./ansible/inventory/hosts.ini -f 10 ./ansible/ping.yml
endef

define configure_base
	ansible-playbook -i ./ansible/inventory/hosts.ini -f 10 ./ansible/playbook.yml
endef

define configure_loadbalance
	ansible-playbook -i ./ansible/inventory/hosts.ini -f 10 ./ansible/loadbalance.yml
endef

define configure_libreddit
	ansible-playbook -i ./ansible/inventory/hosts.ini -f 10 ./ansible/libreddit.yml
endef

define test_base
	. ./venv/bin/activate &&  \
		cd tests/ && \
		py.test --hosts='ansible://all' \
		-n 10 \
		--verbose \
		--ansible-inventory='../ansible/inventory/hosts.ini' \
		test_basic.py

endef

define test_libreddit
	. ./venv/bin/activate &&  \
		cd tests/ && \
		py.test --hosts='ansible://bullseye_libreddit' \
		-n 10 \
		--verbose \
		--ansible-inventory='../ansible/inventory/hosts.ini' \
		test_libreddit.py
endef



define test_loadbalance
	. ./venv/bin/activate &&  \
		cd tests/ && \
		py.test --hosts='ansible://bullseye_loadbalance' \
		-n 10 \
		--verbose \
		--ansible-inventory='../ansible/inventory/hosts.ini' \
		test_loadbalance.py
endef


configure: ## Configure whole deployment 
	$(call configure_ping)
	$(call configure_base)
	$(call configure_libreddit)
	$(call configure_loadbalance)

configure.ping: ## Ping all VMs
	$(call configure_ping)

configure.base: ## Configure all VMs to base production configuration
	$(call configure_ping)
	$(call configure_base)

configure.libreddit: ## Configure libreddit
	$(call configure_ping)
	$(call configure_libreddit)

configure.loadbalance: ## Configure loadbalancer
	$(call configure_ping)
	$(call configure_loadbalance)


lint: ## Lint source code
	terraform fmt
	ansible-lint --write ./ansible/playbook.yml
	ansible-lint --write ./ansible/shutdown.yml
	ansible-lint --write ./ansible/loadbalance.yml
	ansible-lint --write ./ansible/libreddit.yml
	. ./venv/bin/activate && black tests/

on: ## Boot VMs
	./scripts/on.sh
	virsh list

shutdown: ## Shutdown VMs
	ansible-playbook -i ./ansible/inventory/hosts.ini -f 10 ./ansible/shutdown.yml

test: ## Run all tests
	$(call test_base)
	$(call test_loadbalance)
	$(call test_libreddit)

test.base: ## Test base configuration on all VMs
	$(call test_base)

test.loadbalance: ## Test loadbalancer installation
	$(call test_loadbalance)

test.libreddit: ## Test libreddit installation
	$(call test_libreddit)


help: ## Prints help for targets with comments
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-].+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# This make file aim to interact with the Grafana's API
# At some point, commands tested here should be integrated to
# the ansible of the project.

# https://grafana.com/docs/reference/http_api/
# https://grafana.com/docs/tutorials/api_org_token_howto/

SHELL := /bin/bash
GRAFANA_ENV := -tst
ENVFILE := .grafana$(GRAFANA_ENV)

.PHONY: check-env
check-env:
ifeq ($(wildcard $(ENVFILE)),)
	@echo "Please create your $(ENVFILE) file first, from $(ENVFILE).sample"
	@exit 1
else
include $(ENVFILE)
API_URL ?= 'https://grafana-tst.idev-fsd.ml'
BA_USER ?= 'admin'
BA_PASS ?= 'admin_password'
API_USER ?= 'apikeycurl'
API_KEY ?= 'noapikey'
endif

.PHONY : check
check: check-curl check-jq check-env
ifeq ($(API_KEY),'noapikey')
	@echo "Please set your API_KEY first, in $(ENVFILE)"
	@exit 1
endif
	@echo '===================================================================='
	@echo "API_URL:    $(API_URL)"
	@echo "BA_USER:    $(BA_USER)"
	@echo "BA_PASS:    $(BA_PASS)"
	@echo "API_USER:   $(API_USER)"
	@echo "API_KEY:    $(API_KEY)"
	@echo "ORG_NAME:   $(ORG_NAME)"
	@echo '===================================================================='

.PHONY: check-curl
check-curl:
	@type curl > /dev/null 2>&1 || { echo >&2 "Please install curl. Aborting."; exit 1; }

.PHONY: check-jq
check-jq:
	@type jq > /dev/null 2>&1 || { echo >&2 "Please install jq. Aborting."; exit 1; }


# https://grafana.com/docs/http_api/org/#get-current-organization
.PHONY: get-org
get-org: check
	@echo "$@: $(API_URL)"
	@curl --silent -X GET \
		-H "Authorization: Bearer $(API_KEY)" \
		-H "Content-Type: application/json" \
		-H "Accept: application/json" \
		$(API_URL)/api/org | jq

# https://grafana.com/docs/http_api/org/#get-all-users-within-the-current-organization
.PHONY: get-users
get-users: check
	@echo "$@"
	@curl --silent -X GET \
		-H "Authorization: Bearer $(API_KEY)" \
		-H "Content-Type: application/json" \
		-H "Accept: application/json" \
	$(API_URL)/api/org/users | jq

# https://grafana.com/docs/http_api/org/#get-organization-by-name
# Only works with Basic Authentication (username and password)
.PHONY: set-org-name
set-org-name:
	@echo "$@"
	curl -X PUT --user $(BA_USER):$(BA_PASS) \
		-H "Content-Type: application/json" \
		-H "Accept: application/json" \
		-d '{"name":"$(ORG_NAME)"}' \
		$(API_URL)/api/orgs/1 | jq

# https://grafana.com/docs/http_api/admin/#global-users
# Only works with Basic Authentication (username and password)
.PHONY: create-user
create-user: check
	@echo "$@"
	PASSWORD := $(shell pwgen 20 -n1) \
	echo $(PASSWORD) \
	curl -X POST --user $(BA_USER):$(BA_PASS) \
		-H "Content-Type: application/json" \
		-H "Accept: application/json" \
		-d '{"email":"ponsfrilus@gmail.com","name":"ponsfrilus","login":"ponsfrilus","theme":"dark","password":}' \
		$(API_URL)/api/admin/users | jq

.PHONY: make-user-admin
make-user-admin: check
	@echo "$@"
	curl -X PATCH \
		-H "Authorization: Bearer $(API_KEY)" \
		-H "Content-Type: application/json" \
		-H "Accept: application/json" \
		-d '{"role":"Admin"}' \
		$(API_URL)/api/org/users/7 | jq

# https://grafana.com/docs/http_api/org/#add-a-new-user-to-the-current-organization
.PHONY: add-org-user
add-org-user: check
	@echo "$@"
	curl -X PUT \
		-H "Authorization: Bearer $(API_KEY)" \
		-H "Content-Type: application/json" \
		-H "Accept: application/json" \
		-d '{"role":"Admin","loginOrEmail":"ponsfrilus"}' \
	$(API_URL)/api/org/users | jq

# API Token
.PHONY: new-token
new-token: check
	curl -X POST -H "Content-Type: application/json" -d '{"name":"apikeycurl", "role": "Admin"}' --user $(BA_USER):$(BA_PASS) $(API_URL)/api/auth/keys | jq

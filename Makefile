#!/usr/bin/make -f

SHELL = /bin/bash

.PHONY: examples
examples: tf-examples/basic

.PHONY: tf-examples/%
tf-examples/%:
	@terraform -chdir=examples/$* init
	@terraform -chdir=examples/$* validate
	@terraform -chdir=examples/$* plan

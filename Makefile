#!/usr/bin/make -f

SHELL = /bin/bash
EXAMPLES = $(shell find ./examples/* -maxdepth 1 -type d -not -path '*/\.*')
.PHONY: examples
examples: $(addprefix example/,$(EXAMPLES))

.PHONY: example/%
example/%:
	@echo "Processing example: $(notdir $*)"
	@terraform -chdir=$* init
	@terraform -chdir=$* validate
	@terraform -chdir=$* plan


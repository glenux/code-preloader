
all: build

build:
	shards build --error-trace

spec: test
test:
	crystal spec --error-trace

.PHONY: spec test build all

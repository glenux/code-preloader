
PREFIX=/usr

all: build

prepare:
	shards install

build:
	shards build --error-trace

spec: test
test:
	crystal spec --error-trace

install:
	install \
		-m 755 \
		-o root \
		bin/code-preloader \
		$(PREFIX)/bin

.PHONY: spec test build all prepare install

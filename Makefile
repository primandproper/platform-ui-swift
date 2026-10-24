.PHONY: build
build:
	./scripts/xcodebuild.sh build

.PHONY: format
format:
	./scripts/format.sh

.PHONY: lint
lint:
	./scripts/lint.sh

.PHONY: test
test:
	./scripts/xcodebuild.sh test

#
#  Makefile
#

export SHELL ?= /bin/bash
include make.cfg

IMAGE := ${REGISTRY_URL}/${OWNER}/${PROJECT_NAME}
DK_VERSION = $(shell git describe --always --tags --dirty | sed 's/^v//' | sed 's/-g/-/')
DK_PLATFORMS ?= linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64

export DOCKER_CLI_EXPERIMENTAL = enabled

DOCKER ?= docker

default: build

.PHONY: help
help:
	@echo 'Management commands for $(PROJECT_NAME):'
	@grep -Eh '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	 awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build the image
	@echo "building ${DK_VERSION}"
	${DOCKER} info
	${DOCKER} build --build-arg BASE_IMAGE=alpine:3.19 --pull -t ${IMAGE}:${DK_VERSION}-alpine .
	${DOCKER} build --build-arg BASE_IMAGE=busybox:1.36 --pull -t ${IMAGE}:${DK_VERSION}-busybox .
	${DOCKER} build --pull -t ${IMAGE}:${DK_VERSION} -t ${IMAGE}:${DK_VERSION}-scratch .

.PHONY: release
release: ## Tag and release the image
	@echo "release ${DK_VERSION}"
	${DOCKER} push ${IMAGE}:${DK_VERSION}

	@echo "tag and release latest"
	${DOCKER} pull ${IMAGE}:${DK_VERSION}
	${DOCKER} tag ${IMAGE}:${DK_VERSION} ${IMAGE}:latest
	${DOCKER} push ${IMAGE}:latest

# build manifest for git describe
# manifest version is "1.2.3-23ab3df"
# image version is "1.2.3-23ab3df-amd64"

.PHONY: release-multiarch
release-multiarch:
	@echo "building multi-arch docker images ${DK_VERSION}"
	${DOCKER} context create build
	${DOCKER} buildx create --driver docker-container --use build
	${DOCKER} buildx inspect --bootstrap
	${DOCKER} buildx ls
	${DOCKER} buildx build --build-arg BASE_IMAGE=alpine:3.19 --platform ${DK_PLATFORMS} --pull -t ${IMAGE}:${DK_VERSION}-alpine -t ${IMAGE}:alpine --push .
	${DOCKER} buildx build --build-arg BASE_IMAGE=busybox:1.36 --platform ${DK_PLATFORMS} --pull -t ${IMAGE}:${DK_VERSION}-busybox -t ${IMAGE}:busybox --push .
	${DOCKER} buildx build --platform ${DK_PLATFORMS} --pull -t ${IMAGE}:${DK_VERSION} -t ${IMAGE}:${DK_VERSION}-scratch -t ${IMAGE}:scratch -t ${IMAGE}:latest --push .
	${DOCKER} context rm build

VERSION := ${shell cat ./VERSION}
IMPORT_PATH := github.com/hms-dbmi/secret-getter
IGNORED_PACKAGES := /vendor/ # space separated patterns

Q := $(if $V,,@)
V := 1 # print commands and build progress by default

.PHONY: all
all: test build

.PHONY: hello
build: .GOPATH/.ok
	$Q go install $(if $V,-v) -ldflags='-w -s -X "main.Version=$(VERSION)"' -a -installsuffix cgo $(IMPORT_PATH)/cmd/secret_getter

.PHONY: clean
clean:
	$Q rm -rf .GOPATH/.ok .GOPATH bin/secret_getter bin secret-getter

.PHONY: mock
mock:
	cd client && mockery -all

.PHONY: deps
deps:
	$Q cd $(GOPATH)/src/$(IMPORT_PATH) && dep ensure

.PHONY: test test-race
# issue with golang & alpine (alpine uses musl library, not glibc)
# race calls built on glibc libraries -Andre
test-race: ARGS=-race
test test-race: .GOPATH/.ok
	$Q go vet $(allpackages)
	$Q go test $(ARGS) $(allpackages)

.PHONY: list
list: .GOPATH/.ok
	@echo $(allpackages)

lint: format
	$Q go vet $(allpackages)

format: .GOPATH/.ok
	$Q echo $(_allpackages)
	$Q find .GOPATH/src/$(IMPORT_PATH)/ -iname \*.go | grep -v -e "^$$" $(addprefix -e ,$(IGNORED_PACKAGES)) | xargs goimports -w

# cd into the GOPATH to workaround ./... not following symlinks
_allpackages = $(shell ( cd "$(CURDIR)"/.GOPATH/src/$(IMPORT_PATH) && \
							 GOPATH="$(CURDIR)"/.GOPATH go list ./... 2>&1 1>&3 | \
							 grep -v -e "^$$" $(addprefix -e ,$(IGNORED_PACKAGES)) 1>&2 ) 3>&1 | \
							 grep -v -e "^$$" $(addprefix -e ,$(IGNORED_PACKAGES)))

# memoize allpackages, so that it's executed only once and only if used
allpackages = $(if $(__allpackages),,$(eval __allpackages := $$(_allpackages)))$(__allpackages)

SYS_GOPATH = $(shell echo $$GOPATH)

.GOPATH/.ok:
	$Q ln -s "$(SYS_GOPATH)" .GOPATH
	$Q mkdir -p "$(dir .GOPATH/src/$(IMPORT_PATH))"
	$Q ln -s "$(CURDIR)" ".GOPATH/src/$(IMPORT_PATH)"
	$Q ln -s .GOPATH/bin bin
	$Q touch $@

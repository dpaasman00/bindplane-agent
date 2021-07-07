VERSION := $(shell cat VERSION)

# All source code and documents, used when checking for misspellings
ALLDOC := $(shell find . \( -name "*.md" -o -name "*.yaml" \) \
                                -type f | sort)

GOPATH := $(shell go env GOPATH)
GOOS := $(shell go env GOOS)
GOARCH := $(shell go env GOARCH)

ifeq ($(GOOS), windows)
EXT=.exe
else
EXT=
endif

OUTDIR=./build
MODNAME=github.com/observIQ/observIQ-otel-collector

LINT=$(GOPATH)/bin/golangci-lint
IMPI=$(GOPATH)/bin/impi
MISSPELL=$(GOPATH)/bin/misspell

LDFLAGS=
GOBUILD=go build
GOINSTALL=go install
GOTEST=go test
GOTOOL=go tool
GOFORMAT=gofmt

.PHONY: observiqcol
observiqcol:
	$(GOBUILD) $(LDFLAGS) -o $(OUTDIR)/$(GOOS)/observiqcol_$(GOARCH)$(EXT) ./cmd/observiqcol

.PHONY: install-tools
install-tools:
	$(GOINSTALL) github.com/pavius/impi/cmd/impi
	$(GOINSTALL) github.com/golangci/golangci-lint/cmd/golangci-lint@v1.40.1
	$(GOINSTALL) github.com/client9/misspell/cmd/misspell

.PHONY: lint
lint:
	$(LINT) run

.PHONY: impi
impi:
	$(IMPI) --local $(MODNAME) --scheme stdLocalThirdParty ./...

.PHONY: misspell
misspell:
	$(MISSPELL) $(ALLDOC)

.PHONY: misspell-fix
misspell-fix:
	$(MISSPELL) -w $(ALLDOC)

.PHONY: test
test:
	$(GOTEST) -vet off -race ./...

.PHONY: test-with-cover
test-with-cover:
	$(GOTEST) -vet off -cover cover.out ./...
	$(GOTOOL) cover -html=cover.out -o cover.html

.PHONY: check-fmt
check-fmt:
	@GOFMTOUT=`$(GOFORMAT) -s -d .`; \
		if [ "$$GOFMTOUT" ]; then \
			echo "$(GOFORMAT) SUGGESTED CHANGES:"; \
			echo "$$GOFMTOUT\n"; \
			exit 1; \
		else \
			echo "$(GOFORMAT) completed successfully"; \
		fi

.PHONY: fmt
fmt:
	$(GOFORMAT) -w -s .

.PHONY: ci-checks
ci-checks: check-fmt misspell lint impi test

.PHONY: clean
clean:
	rm -rf $(OUTDIR)

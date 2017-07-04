
# target only .proto files
only_proto = grep ".proto$$"

# files to be considered for proto compilation
PROTO_FILES ?= $(ALL_FILES) | $(only_proto)

# resulting files
PROTO_TARGETS ?= $(patsubst %.proto,%.pb.go,$(shell $(PROTO_FILES)))

PROTOC ?= protoc

# The go path to compile the protos to.
# By default this is the last entry in the GOPATH
GOLAST ?= $(lastword $(subst :, ,$(GOPATH)))

# set this to add extra includes
PROTOC_EXTRA_INCLUDES ?=

# these are the default includes
PROTOC_INCLUDES ?= -I/usr/local/include \
	-I$(subst :, -I,$(GOPATH)) \
	-I`dirname $(PWD)` \
	$(PROTOC_EXTRA_INCLUDES)

# default protobuf flags
PROTOC_FLAGS ?= $(PROTOC_INCLUDES) \
	--gofast_out=plugins=grpc:$(GOLAST) \
	--proto_path=$(GOLAST)/src/ \
	--grpc-gateway_out=:$(GOLAST)

# build all proto files
protos: $(PROTO_TARGETS)

# build a proto file
%.pb.go: %.proto
	@$(log) "compiling proto file $<"
	@$(PROTOC) $(PROTOC_FLAGS) $(PWD)/$<

# remove compiled proto files
protos-clean:
	rm -f $(PROTO_TARGETS)

# fetch deps for protos
protos-deps:
	@$(log) "fetching proto tools"
	@command -v protoc-gen-gofast > /dev/null || go get "github.com/gogo/protobuf/protoc-gen-gofast"
	@command -v protoc-gen-grpc-gateway > /dev/null || go get "github.com/gogo/protobuf/protoc-gen-grpc-gateway"

# alias commands
proto: protos
proto-clean: protos-clean
proto-deps: protos-deps

# vim: ft=make

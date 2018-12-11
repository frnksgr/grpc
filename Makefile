CERT_OUT := cert/server.key cert/server.crt cert/server.csr
SERVER_OUT := bin/server
CLIENT_OUT := bin/client
API_OUT := api/api.pb.go
API_REST_OUT := api/api.pb.gw.go
API_SWAG_OUT := api/api.swagger.json
PKG := github.com/frnksgr/grpc
SERVER_PKG_BUILD := ${PKG}/server
CLIENT_PKG_BUILD := ${PKG}/client
PKG_LIST := $(shell go list ${PKG}/api/... ${PKG}/client/... ${PKG}/server/... | grep -v /vendor/)

.PHONY: all api server client cert

all: server client

api/api.pb.go: api/api.proto
	@protoc -I api/ \
		-I vendor/ \
		-I${GOPATH}/src \
		-I${GOPATH}/src/<c \
		--go_out=plugins=grpc:api \
		api/api.proto

api/api.pb.gw.go: api/api.proto
	@protoc -I api/ \
		-I vendor/ \
		-I${GOPATH}/src \
		-I${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
		--grpc-gateway_out=logtostderr=true:api \
		api/api.proto

api/api.swagger.json: api/api.proto
	@protoc -I api/ \
		-I vendor/ \
		-I${GOPATH}/src \
		-I${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
		--swagger_out=logtostderr=true:api \
		api/api.proto

api: api/api.pb.go api/api.pb.gw.go api/api.swagger.json ## Auto-generate grpc go sources

dep: ## Get the dependencies
	@go get -v -d -u ./api ./client ./server

server: dep api cert ## Build the binary file for server
	@go build -i -v -o $(SERVER_OUT) $(SERVER_PKG_BUILD)

client: dep api cert ## Build the binary file for client
	@go build -i -v -o $(CLIENT_OUT) $(CLIENT_PKG_BUILD)

cert/server.key:
	@openssl genrsa -out cert/server.key 2048

cert/server.csr: cert/server.key
	@openssl req -new -sha256 -key cert/server.key -out cert/server.csr \
		-subj "/C=EU/ST=Bayern/L=Muenchen/O=ACME/CN=localhost"

cert/server.crt: cert/server.key cert/server.csr
	@openssl x509 -req -sha256 -in cert/server.csr \
		-signkey cert/server.key -out cert/server.crt -days 3650

cert: $(CERT_OUT) ## Create certificates

clean: ## Remove previous builds
	@rm -f $(CERT_OUT) $(SERVER_OUT) $(CLIENT_OUT) $(API_OUT) $(API_REST_OUT) $(API_SWAG_OUT)

help: ## Display this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

package api

import (
	"log"
	"strings"

	"golang.org/x/net/context"
)

// Server represents the gRPC server
type Server struct {
}

// Ping generates response to a Ping request
func (s *Server) Ping(ctx context.Context, in *PingRequest) (*PingResponse, error) {
	log.Printf("Receive message: %s", in.Message)
	response := "Hello world!"
	if strings.Contains(in.Message, "captain") {
		response = "I said wot"
	}
	return &PingResponse{Message: response}, nil
}

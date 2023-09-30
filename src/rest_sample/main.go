package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/rest", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello, World!")
	})

	port := ":8888"
	fmt.Printf("Starting server on %s...\n", port)
	if err := http.ListenAndServe(port, nil); err != nil {
		log.Fatalf("Server error: %v\n", err)
	}
}

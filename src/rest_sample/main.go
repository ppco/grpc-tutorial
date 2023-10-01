package main

import (
	"fmt"
	"log"
	"net/http"
	"time"
)

func main() {
	http.HandleFunc("/rest", func(w http.ResponseWriter, r *http.Request) {
		now := time.Now().Format("2006-01-02 15:04:05")
		log.Println("access!!")
		fmt.Fprintf(w, "hello world! time:"+now)
	})

	port := ":8888"
	fmt.Printf("Starting server on %s...\n", port)
	if err := http.ListenAndServe(port, nil); err != nil {
		log.Fatalf("Server error: %v\n", err)
	}
}

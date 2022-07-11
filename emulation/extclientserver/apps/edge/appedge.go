package main

import (
	"fmt"
	"log"
	"net"
	"net/http"
	"strconv"
	// "github.com/kavehmz/prime"
)

func main() {
	fmt.Println("Appedge pod starts!")
	conn, err := net.Dial("udp", "8.8.8.8:80")
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()
	fmt.Println("Received new request!")
	fmt.Println(conn.LocalAddr().(*net.UDPAddr).IP)
	http.HandleFunc("/prime", func(w http.ResponseWriter, r *http.Request) {

		numStr := r.Header["Num"][0]
		reqNum, err := strconv.ParseUint(numStr, 10, 64)
		if err != nil {
			fmt.Println("failed to convert " + numStr)
			fmt.Fprintf(w, "failed to convert")
			return
		}
		// p := prime.SieveOfEratosthenes(reqNum)
		fmt.Println("Plus one = ", reqNum+1)
		fmt.Fprintf(w, "RSP Plus one = %d", reqNum+1)
	})
	http.ListenAndServe(":10021", nil)
}

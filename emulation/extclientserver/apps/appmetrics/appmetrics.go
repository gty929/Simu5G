package main

import (
	"fmt"
	"net/http"
	"time"
)

func main() {
	testCycle := 500
	succeedCycle := 0
	var totalTime int64
	totalTime = 0
	client := &http.Client{Timeout: 5 * time.Second}
	req, err := http.NewRequest("GET", "http://192.168.2.100/prime", nil)
	if err != nil {
		fmt.Println("error creating request", err)
		return
	}

	req.Header.Add("Num", "1")
	for i := 0; i < testCycle; i++ {
		start := time.Now()
		resp, err := client.Do(req)
		timeElapsed := time.Since(start).Microseconds()
		if err != nil {
			fmt.Println("error sending http request", err)
			continue
		}
		if resp.StatusCode != 200 {
			fmt.Println("error sending http request", resp.StatusCode)
			continue
		}
		succeedCycle++
		fmt.Printf("%d,", timeElapsed/1000)
		totalTime += timeElapsed
		time.Sleep(1 * time.Second)
	}
	successRate := float32(succeedCycle) / float32(testCycle)
	fmt.Printf("Success Rate = %f %%\n", successRate*100)
	if succeedCycle != 0 {

		averageLatency := totalTime / int64(succeedCycle)
		fmt.Printf("Average Latency = %d ms\n", averageLatency/1000)
	}

}

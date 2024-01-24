#!/bin/bash

log_file=$1
output_json_file=$2

cat <<EOF > convert_to_json.go
package main

import (
	"encoding/json"
	"fmt"
	"os"
	"runtime"
	"sync"
)

type LogEntry struct {
	Content string \`json:"content"\`
}

func processLine(line string, wg *sync.WaitGroup, jsonCh chan<- string) {
	defer wg.Done()
	entry := LogEntry{Content: line}
	jsonData, _ := json.Marshal(entry)
	jsonCh <- string(jsonData)
}

func main() {
	if len(os.Args) < 3 {
		fmt.Println("Usage: convert_to_json <input_log_file> <output_json_file>")
		return
	}
	inputFile := os.Args[1]
	outputFile := os.Args[2]

	file, err := os.Open(inputFile)
	if err != nil {
		fmt.Printf("Error opening input file: %s\n", err)
		return
	}
	defer file.Close()

	outFile, err := os.Create(outputFile)
	if err != nil {
		fmt.Printf("Error creating output file: %s\n", err)
		return
	}
	defer outFile.Close()

	var wg sync.WaitGroup
	concurrency := runtime.NumCPU()
	jsonCh := make(chan string, concurrency)

	go func() {
		for jsonData := range jsonCh {
			fmt.Fprintln(outFile, jsonData)
		}
	}()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		wg.Add(1)
		go processLine(scanner.Text(), &wg, jsonCh)
	}

	wg.Wait()
	close(jsonCh)
}
EOF

go build -o convert_to_json convert_to_json.go

./convert_to_json "$log_file" "$output_json_file"

rm convert_to_json.go
rm convert_to_json
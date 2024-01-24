#!/bin/bash

log_file=$1

function is_program_installed() {
    command -v $1 &> /dev/null
}

function get_cpu_cores() {
    nproc --all
}

if ! is_program_installed "go"; then
    echo "Installing Go..."
    wget -q https://golang.org/dl/go1.20.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
fi

cpu_cores=$(get_cpu_cores)

cat <<EOF > send_to_database.go
package main

import (
	"bufio"
	"fmt"
	"os"
	"runtime"
	"sync"
)

func parseLogLine(line string) string {
	// Implement log line parsing logic here
	return line
}

func insertLogToDB(logEntry string) {
	// Implement your database insertion logic here
}

func processLog(logFile string, wg *sync.WaitGroup) {
	defer wg.Done()

	file, err := os.Open(logFile)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		logEntry := parseLogLine(line)
		insertLogToDB(logEntry)
	}
}

func main() {
	logFile := os.Args[1]

	var wg sync.WaitGroup
	numCPU := runtime.NumCPU()
	runtime.GOMAXPROCS(numCPU)

	for i := 0; i < numCPU; i++ {
		wg.Add(1)
		go processLog(logFile, &wg)
	}

	wg.Wait()
}
EOF

echo "Compiling send_to_database.go..."
go build send_to_database.go

echo "Running send_to_database..."
./send_to_database "$log_file"

rm send_to_database.go send_to_database
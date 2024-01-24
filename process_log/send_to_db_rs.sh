#!/bin/bash

log_file=$1

function is_program_installed() {
    command -v $1 &> /dev/null
}

function get_cpu_cores() {
    nproc --all
}

if ! is_program_installed "rustc"; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
fi

cpu_cores=$(get_cpu_cores)

cat <<EOF > send_to_database.rs
use std::fs::File;
use std::io::{self, BufRead};
use std::thread;

fn parse_log_line(line: &str) -> String {
    // Implement your log line parsing logic here
    // This is a placeholder function that needs to be adapted based on your log format
    line.to_owned()
}

fn insert_log_to_db(log_entry: String) {
    // Implement your database insertion logic here
    // This is a placeholder function that needs to be adapted based on your database setup
}

fn process_log(log_file: &str) {
    if let Ok(file) = File::open(log_file) {
        let reader = io::BufReader::new(file);

        for line in reader.lines() {
            if let Ok(line) = line {
                let log_entry = parse_log_line(&line);
                insert_log_to_db(log_entry);
            }
        }
    }
}

fn main() {
    let log_file = std::env::args().nth(1).expect("Usage: send_to_database <log_file>");

    let handles: Vec<_> = (0..$cpu_cores).map(|_| {
        let log_file = log_file.clone();
        thread::spawn(move || {
            process_log(&log_file);
        })
    }).collect();

    for handle in handles {
        handle.join().expect("Thread panicked");
    }
}
EOF

echo "Compiling send_to_database.rs..."
rustc -O send_to_database.rs -o send_to_database

echo "Running send_to_database..."
./send_to_database "$log_file"

rm send_to_database.rs send_to_database

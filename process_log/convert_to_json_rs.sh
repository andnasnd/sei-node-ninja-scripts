#!/bin/bash

log_file=$1
output_json_file=$2

cat <<EOF > convert_to_json.rs
use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader, Write};
use std::thread;

#[derive(Debug, serde::Serialize)]
struct LogEntry {
    content: String,
}

fn process_line(line: String, json_tx: std::sync::mpsc::Sender<String>) {
    let entry = LogEntry { content: line };
    if let Ok(json_data) = serde_json::to_string(&entry) {
        if let Err(_) = json_tx.send(json_data) {
            eprintln!("Error sending JSON data.");
        }
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} <input_log_file> <output_json_file>", &args[0]);
        return;
    }

    let input_file = &args[1];
    let output_file = &args[2];

    let file = match File::open(input_file) {
        Ok(file) => file,
        Err(err) => {
            eprintln!("Error opening input file: {}", err);
            return;
        }
    };

    let json_tx = {
        let (tx, rx) = std::sync::mpsc::channel();
        thread::spawn(move || {
            let mut output_file = match File::create(output_file) {
                Ok(file) => file,
                Err(err) => {
                    eprintln!("Error creating output file: {}", err);
                    return;
                }
            };

            for json_data in rx {
                if let Err(err) = writeln!(output_file, "{}", json_data) {
                    eprintln!("Error writing to output file: {}", err);
                    return;
                }
            }
        });
        tx
    };

    let lines = BufReader::new(file).lines();
    for line in lines {
        if let Ok(line) = line {
            let json_tx = json_tx.clone();
            thread::spawn(move || {
                process_line(line, json_tx);
            });
        }
    }
}
EOF

rustc convert_to_json.rs

./convert_to_json "$log_file" "$output_json_file"

rm convert_to_json.rs
rm convert_to_json
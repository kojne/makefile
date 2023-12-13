#!/bin/bash

if [ $# -eq 0 ]; then
    echo "ERROR"
    exit 1
fi

awk '{
    if (length($0) > 0) {
        total_count = length($0);
        gc_count = gsub(/[GC]/, "");
        gc_content = gc_count / total_count;
        printf "%.2f\n", gc_content;
    }
}' "$1"

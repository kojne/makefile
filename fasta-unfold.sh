#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "No arguments given"
    exit 1
fi

awk '/^>/{if(seq)print seq; print;seq=""} !/^>/{seq=seq" "$0} END{if(seq)print seq}' "$1"

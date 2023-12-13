#!/bin/sh

cat $@ | tr 'a-z' 'A-Z' | grep -v '^>' | grep -o -E "ATG([A-Z][A-Z][A-Z]){10,}(TAA|TAG|TGA)"


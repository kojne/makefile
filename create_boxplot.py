#!/usr/bin/env python3
import matplotlib.pyplot as plt
import sys
import os

def read_fsa_file(filename):
    gc_counts = []
    with open(filename, 'r') as file:
        for line in file:
            line = line.strip()
            if not line:
                continue  
            try:
                value = float(line)
                if 0 <= value <= 1:
                    gc_counts.append(value)
            except ValueError as e:
                print(f"Error converting line to float: {line} in file {filename}. Error: {e}")
    return gc_counts

def create_boxplot(data, output_filename):
    if not data:
        print(f"No data to plot for {output_filename}.")
        return
    plt.boxplot(data)
    plt.title("GC Content Boxplot")
    plt.ylabel("GC Content")
    plt.savefig(output_filename)
    #plt.show()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        file_path = sys.argv[1]
        base_filename = os.path.basename(file_path)
        if base_filename.lower().endswith('.fsa'):
            base_filename = base_filename[:-4]  # Remove .fsa
        output_file = os.path.join("images", base_filename + "_boxplot.png")
        gc_content = read_fsa_file(file_path)
        if not gc_content:
            print(f"No valid GC content data found in file {file_path}.")
        else:
            create_boxplot(gc_content, output_file)
    else:
        print("Please provide a file path")



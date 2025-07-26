#!/bin/bash

# This script recursively finds all files (not directories) in the current
# directory and all its subdirectories. For each file found, it prints the
# file's name, displays its content, and then prints a separator line.

# Use 'find' to locate all items in the current directory ('.') that are
# of type 'f' (regular files). The '-print0' argument is important; it
# separates filenames with a null character. This makes the script safe
# for filenames that contain spaces or other special characters.
find . -type f -print0 | while IFS= read -r -d '' file; do
    # Print the name of the file being processed.
    # The './' at the beginning is stripped for cleaner output.
    echo "--- START: ${file#./} ---"

    # Use 'cat' to display the contents of the file.
    cat "$file"

    # Print a separator to clearly mark the end of the file's content.
    echo "--- END: ${file#./} ---"

    # Add a blank line for better readability between files.
    echo ""
done



#!/bin/bash
file="$ZED_FILE"
exe="${file%.*}"
input="input.txt"
output="output.txt"
status_file="status.txt"

# Ensure files exist
touch "$input" "$output" "$status_file"

# Compile the C++ code
g++ "$file" -std=c++20 -O2 -o "$exe" || { echo -e "\e[31mCompile Failed\e[0m"; echo "Failed" > "$status_file"; exit; }

# Show input
echo "Input"
echo "==============="
cat "$input"
echo

# Run the program
"$exe" < "$input" > tmp_out.txt

# Show output
echo "Output"
echo "==============="
cat tmp_out.txt
echo

# Compare ignoring whitespace (-w)
if diff -w "$output" tmp_out.txt > /dev/null; then
  echo  "\e[32m(Passed)\e[0m"
  echo "Passed" > "$status_file"
else
  echo  "\e[31m(Failed)\e[0m"
  echo "Failed" > "$status_file"
fi

rm tmp_out.txt

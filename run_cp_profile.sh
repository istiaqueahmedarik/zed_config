#!/bin/bash
file="$ZED_FILE"
exe="${file%.*}"
input="input.txt"
output="output.txt"
status_file="status.txt"

# Ensure files exist
touch "$input" "$output" "$status_file"

# Compile
g++ "$file" -std=c++20 -O2 -o "$exe" 2> compile_err.txt
if [ $? -ne 0 ]; then
  echo "Input
===============
$(cat "$input")

Output
===============
<compile error>"

  echo -e "\n\e[31m(Failed)\e[0m"
  echo "Output:
$(cat compile_err.txt)
Failed" > "$status_file"
  rm compile_err.txt
  exit
fi
rm compile_err.txt

# Read input
input_data=$(cat "$input")

# Run program, capturing both stdout and stderr together
"$exe" < "$input" > tmp_out.txt 2> tmp_err.txt
err_output=$(cat tmp_err.txt)
program_output=$(cat tmp_out.txt)

# Show sections
echo "Input
===============
$input_data

Output
===============
$program_output"

# Show stderr if any
if [ -n "$err_output" ]; then
  echo "
Errors
===============
$err_output"
fi

echo

# Compare ignoring whitespace
if diff -w "$output" tmp_out.txt > /dev/null; then
  echo -e "\e[32m(Passed)\e[0m"
  {
    echo "Output:
$program_output"
    [ -n "$err_output" ] && { echo "Errors:"; echo "$err_output"; }
    echo "Passed"
  } > "$status_file"
else
  echo -e "\e[31m(Failed)\e[0m"
  {
    echo "Output:
$program_output"
    [ -n "$err_output" ] && { echo "Errors:"; echo "$err_output"; }
    echo "Failed"
  } > "$status_file"
fi

rm tmp_out.txt tmp_err.txt


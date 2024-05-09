#!/bin/bash

# Parse index.html to find the highest ID
INDEX_HTML="./index.html"
HIGHEST_ID=$(grep -oP '\d+(?=:)' "$INDEX_HTML" | sort -n | tail -1)

# Print the highest ID
echo "Highest ID in index.html: $HIGHEST_ID"

# Directory to scan
DIRECTORY="/home/carey/Downloads"

# Pattern to match files
PATTERN="Fitronics_ Lightning Strikes!\(([0-9]+-[0-9]+)\).xlsx"

# Initialize variables to track the largest second number and the corresponding file name
LARGEST_SECOND_NUMBER=0
LARGEST_FILE=""

# Loop through files matching the pattern in the directory
for FILE_PATH in "$DIRECTORY"/Fitronics_*; do
    if [[ -f "$FILE_PATH" && "$FILE_PATH" =~ $PATTERN ]]; then
        # Extract the second number from the file name
        SECOND_NUMBER=$(echo "${BASH_REMATCH[1]}" | cut -d'-' -f2)

        # Check if the current second number is greater than the largest one found so far
        if (( SECOND_NUMBER > LARGEST_SECOND_NUMBER )); then
            LARGEST_SECOND_NUMBER=$SECOND_NUMBER
            LARGEST_FILE="$FILE_PATH"
        fi
    fi
done

# Print the name of the file with the largest second number
echo "Most recent file: $LARGEST_FILE"

# Convert the most recent Excel file to CSV format using unoconv
CSV_FILE="${LARGEST_FILE%.xlsx}.csv"
unoconv -f csv "$LARGEST_FILE" > /dev/null 2>&1
# Get the current date
CURRENT_DATE=$(date +"%Y-%m-%d")
# Define the output file name
OUTPUT_FILE="LightningStrikes-$CURRENT_DATE.csv"


# Extract specific columns from the CSV file (A, F, G, H, I) only if column A is greater than $HIGHEST_ID
awk -v highest_id="$HIGHEST_ID" -F ',' '$1 > highest_id {print $1 "," $6 "," $7 "," $8 "," $9}' "$CSV_FILE" > "$OUTPUT_FILE"

# Print the name of the extracted CSV file
echo "Extracted columns saved to: $OUTPUT_FILE"


awk -v highest_id="$HIGHEST_ID" -F ',' '$1 > highest_id {print "<div>" $1 ": " $7 "</div>"}' "$CSV_FILE" | tail -n +2


# Count the number of rows (excluding the header) in the CSV file
NUM_ROWS=$(awk 'NR > 1 {count++} END {print count}' "$OUTPUT_FILE")
echo "Number of entries: $NUM_ROWS"

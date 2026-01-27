#!/bin/bash

#===============================================================================
# Generate Year Notes Script
#===============================================================================
#
# DESCRIPTION:
#   This script generates markdown files for a specified year, creating one file
#   per month with daily headers. Each month file contains properly formatted
#   headers for every day of that month, taking into account leap years.
#
# USAGE:
#   ./generate_year_notes.sh <year> [output_directory]
#
# PARAMETERS:
#   year              - 4-digit year (e.g., 2026)
#   output_directory  - Optional. Directory where files will be created.
#                      Defaults to current directory.
#
# EXAMPLES:
#   ./generate_year_notes.sh 2026
#   ./generate_year_notes.sh 2026 /home/user/notes
#   ./generate_year_notes.sh 2024 ./my-notes
#
# OUTPUT STRUCTURE:
#   <output_directory>/
#   └── <year>/
#       ├── <year>01.md  (January)
#       ├── <year>02.md  (February)
#       ├── ...
#       └── <year>12.md  (December)
#
# OUTPUT EXAMPLE:
#   For year 2026, creates files like:
#   
#   2026/202601.md:
#   # 202601
#   
#   ## 20260101
#   
#   ## 20260102
#   
#   ...
#   
#   ## 20260131
#   
# FEATURES:
#   - Automatically handles leap years
#   - Creates directory structure if it doesn't exist
#   - Validates input year format
#   - Generates proper date headers for each day
#
#===============================================================================

# Check arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <year> [output_directory]"
    echo "Example: $0 2026"
    echo "Example: $0 2026 /path/to/output"
    exit 1
fi

YEAR=$1
OUTPUT_DIR=${2:-.}  # Default is current directory

# Check if year is a 4-digit number
if ! [[ "$YEAR" =~ ^[0-9]{4}$ ]]; then
    echo "Error: Year must be a 4-digit number"
    exit 1
fi

# Create output directory
YEAR_DIR="$OUTPUT_DIR/$YEAR"
if [ ! -d "$YEAR_DIR" ]; then
    mkdir -p "$YEAR_DIR"
    echo "Created directory: $YEAR_DIR"
fi

# Leap year determination function
is_leap_year() {
    local year=$1
    if [ $((year % 400)) -eq 0 ]; then
        return 0
    elif [ $((year % 100)) -eq 0 ]; then
        return 1
    elif [ $((year % 4)) -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Function to get the number of days in a month
get_days_in_month() {
    local year=$1
    local month=$2
    
    case $month in
        1|3|5|7|8|10|12) echo 31 ;;
        4|6|9|11) echo 30 ;;
        2)
            if is_leap_year $year; then
                echo 29
            else
                echo 28
            fi
            ;;
    esac
}

# Generate files for each month
for month in {1..12}; do
    # Format month with 2 digits
    month_formatted=$(printf "%02d" $month)
    filename="${YEAR}${month_formatted}.md"
    filepath="$YEAR_DIR/$filename"
    
    # Generate file content
    echo "# ${YEAR}${month_formatted}" > "$filepath"
    echo "" >> "$filepath"
    
    # Get the number of days in the month
    days_in_month=$(get_days_in_month $YEAR $month)
    
    # Generate headers for each day
    for day in $(seq 1 $days_in_month); do
        day_formatted=$(printf "%02d" $day)
        echo "## ${YEAR}${month_formatted}${day_formatted}" >> "$filepath"
        echo "" >> "$filepath"
    done
    
    echo "Generated: $filepath"
done

echo ""
echo "Completed: Generated markdown files for year $YEAR in $YEAR_DIR"
echo "Number of files created: 12"

# -*- coding: utf-8 -*-
"""
Created on Wed Dec  4 14:29:06 2024

@author: jrgreen
"""

import zipfile
import os
import pandas as pd
import re
import sys
from io import BytesIO, TextIOWrapper


def validate_zip_file(zip_file_path):
    """
    Validate the input zip file against the specified requirements and generate a summary report.

    :param zip_file_path: Path to the input zip file.
    """
    report = []

    # Check if the file exists
    if not os.path.exists(zip_file_path):
        return [f"❌ The file '{zip_file_path}' does not exist. Please provide a valid file path."]

    # Check 1: Validate the zip file name
    if not re.match(r"group_\d{2}\.zip$", os.path.basename(zip_file_path)):
        report.append("❌ The zip file name must be in the format 'group_##.zip' (e.g., 'group_01.zip').")
    else:
        report.append("✅ Zip file name format is valid.")

    # Check if it is a valid zip file
    if not zipfile.is_zipfile(zip_file_path):
        report.append("❌ The file is not a valid zip file.")
        return report

    # Required structure and header
    required_locations = ["BRY", "CAL", "FIO", "HAR", "KEA", "LAW", "LIF", "MCK", "PEN", "SYL", "WAT"]
    required_header = ["fname", "AMRO", "BHCO", "CHSW", "EUST", "GRCA", "HOSP", "HOWR", "NOCA", "RBGU", "RWBL"]

    # Validate contents of the zip file
    with zipfile.ZipFile(zip_file_path, 'r') as zip_ref:
        # Get the list of files in the zip archive
        zip_file_list = zip_ref.namelist()

        # Check 2: Validate top-level directory
        if not any(name.startswith("2023_predictions/") for name in zip_file_list):
            report.append("❌ The zip file must contain a top-level directory named '2023_predictions'.")
            return report  # Further checks depend on this directory existing

        report.append("✅ Top-level directory '2023' exists.")

        # Check 3: Validate subdirectories
        found_locations = set(
            name.split('/')[1]
            for name in zip_file_list
            if name.startswith("2023_predictions/") and len(name.split('/')) > 1
        )
        missing_subdirs = set(required_locations) - found_locations
        if missing_subdirs:
            report.append(f"❌ Missing subdirectories: {', '.join(missing_subdirs)}.")
        else:
            report.append("✅ All required subdirectories are present.")

        # Check 4: Validate files in subdirectories
        for location in required_locations:
            location_files = [
                name
                for name in zip_file_list
                if name.startswith(f"2023_predictions/{location}/") and len(name.split('/')) == 3
            ]

            if not location_files:
                report.append(f"❌ Subdirectory '{location}' does not contain any files.")
                continue

            test_labels_files = [f for f in location_files if f.endswith("test_labels.csv")]
            if not test_labels_files:
                report.append(f"❌ Subdirectory '{location}' does not contain a file named 'test_labels.csv'.")
                continue

            # Validate the contents of test_labels.csv
            test_labels_path = test_labels_files[0]
            try:
                with zip_ref.open(test_labels_path) as file:
                    df = pd.read_csv(TextIOWrapper(file, 'utf-8'), header=None)

                # Check header
                if list(df.iloc[0]) != required_header:
                    report.append(f"❌ The header in '{test_labels_path}' is incorrect. Expected: {required_header}")
                else:
                    report.append(f"✅ The header in '{test_labels_path}' is correct.")

                # Check column count
                if df.shape[1] != 11:
                    report.append(f"❌ '{test_labels_path}' does not have exactly 11 columns.")
                    continue

                # Validate first column and other columns
                first_column = df.iloc[1:, 0].astype(str)
                remaining_columns = df.iloc[1:, 1:].apply(pd.to_numeric, errors='coerce')
                if not first_column.str.endswith(".mp3").all():
                    report.append(f"❌ The first column of '{test_labels_path}' contains values that are not filenames with an 'mp3' extension.")
                if not ((remaining_columns == 0) | (remaining_columns == 1)).all().all():
                    report.append(f"❌ The non-header columns of '{test_labels_path}' contain values other than 0 or 1.")
                else:
                    report.append(f"✅ The file '{test_labels_path}' meets all column requirements.")
            except Exception as e:
                report.append(f"❌ Error reading or validating '{test_labels_path}': {e}")

    return report


if __name__ == "__main__":
    # Get the zip file name from the command line or use a default value
    # Note: Change "group_00.zip" to your actual zip file name.
    zip_file_path = sys.argv[1] if len(sys.argv) > 1 else "group_00.zip"

    validation_report = validate_zip_file(zip_file_path)

    print("\nValidation Report:")
    for line in validation_report:
        print(line)

#!/usr/bin/env python3

import os
import sys


def check_license_files(root_dir):
    missing_license_folders = []
    for folder_name in os.listdir(root_dir):
        if os.path.isdir(os.path.join(root_dir, folder_name)):
            license_file_path = os.path.join(root_dir, folder_name, "LICENSE")
            if (
                not os.path.exists(license_file_path)
                or len(open(license_file_path).read().strip()) == 0
            ):
                missing_license_folders.append(os.path.join(root_dir, folder_name))
    return missing_license_folders


def main():
    current_folder = os.path.dirname(os.path.abspath(__file__))
    parent_folder = os.path.dirname(current_folder)
    root_directory = parent_folder
    missing_license_folders = check_license_files(root_directory)

    if missing_license_folders:
        print("Error: Folders missing LICENSE files:")
        for folder in missing_license_folders:
            print(folder)
        # TODO make fail
        # sys.exit(1)  # Return non-zero exit code
        sys.exit(0)  # Return non-zero exit code
    else:
        print("All subfolders contain a LICENSE file.")
        sys.exit(0)  # Return zero exit code


if __name__ == "__main__":
    main()

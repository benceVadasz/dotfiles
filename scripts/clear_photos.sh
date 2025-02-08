#!/bin/bash

# Path to the parent folder
parent_folder="/Users/bencevadasz/Desktop/kvalifik/ev-remarketing/backend/public/storage"

# Function to get and print the size of a folder
get_folder_size() {
  folder_name="$1"
  folder_path="$parent_folder/$folder_name"
  if [ -d "$folder_path" ]; then
    folder_size=$(du -sh "$folder_path" | awk '{print $1}')
    echo "Size of $folder_name before removing: $folder_size"
  else
    echo "$folder_name does not exist."
  fi
}

# Get and print the size of the photos and documents folders
get_folder_size "photos"
get_folder_size "documents"

# Remove the existing photos and documents folders and their content
rm -rf "$parent_folder/photos"
rm -rf "$parent_folder/documents"

# Recreate the photos and documents folders
mkdir "$parent_folder/photos"
mkdir "$parent_folder/documents"

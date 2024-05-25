#! /bin/bash

# Function to create a directory
create_directory () {
	DIR_NAME=$1

	# If the directory does not already exist, create it
	if [ ! -d "${DIR_NAME}" ]
	then
		mkdir -p ${DIR_NAME}
	fi
}

# Create output directories if they don't exist already
create_directory public_keys
create_directory private_keys
create_directory client_keys
create_directory conf

exit 0

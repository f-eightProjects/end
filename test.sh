#!/bin/bash

# Ask for the GitHub username
read -p "Enter GitHub username: " username

# GitHub API endpoint to fetch repos for the given username
repos_url="https://api.github.com/users/$username/repos?per_page=100"

# Fetch repository details from GitHub API
repos=$(curl -s "$repos_url")

# Debugging: Print the raw API response
echo "Raw API response:"
echo "$repos" | jq .

# Check if the user exists and has repos
if [[ $(echo "$repos" | grep -c "Not Found") -gt 0 ]]; then
    echo "User not found or has no repositories."
    exit 1
fi

# Fetch the avatar URL from the first repository owner
avatar_url=$(echo "$repos" | jq -r '.[0].owner.avatar_url')

# Debugging: Check the avatar URL
echo "Avatar URL: $avatar_url"

# Check if avatar URL is not empty
if [ -z "$avatar_url" ]; then
    echo "Failed to retrieve avatar."
    exit 1
fi

# Display the avatar using chafa
echo "Displaying avatar..."
curl -s "$avatar_url" | chafa

# Loop through the repos and display name and stars
echo -e "\nRepositories for $username:"
echo "$repos" | jq -r '.[] | "\(.name) - \(.stargazers_count) stars"'

#!/bin/bash

# Path to the JSON file
JSON_FILE="public/data/container.json"

# Check if the JSON file exists
if [ ! -f "$JSON_FILE" ]; then
    echo "Error: JSON file not found at expected loacation '$JSON_FILE'."
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' command not found."
    exit 1
fi

# Extract and build the FQIN (Fully Qualified Image Name) from the JSON file
REGISTRY=$(jq -r '.image.registry // empty' $JSON_FILE)
NAMESPACE=$(jq -r '.image.namespace // empty' $JSON_FILE)
REPOSITORY=$(jq -r '.image.repository // empty' $JSON_FILE)
TAG=$(jq -r '.image.tag // empty' $JSON_FILE)

# Check if REPOSITORY or TAG is missing
if [[ -z "$REPOSITORY" || -z "$TAG" ]]; then
  echo "Error: Image 'repository' or 'tag' is missing in the JSON file."
  exit 1
fi

# Combine the repository and tag to form the image name
FQRN="${REGISTRY:+${REGISTRY}/}${NAMESPACE:+${NAMESPACE}/}${REPOSITORY}"
FQIN="${FQRN}:${TAG}"

# Build a multi-architecture Docker image using the extracted image name
docker buildx build --platform linux/amd64,linux/arm64 -t $FQIN .

# If the build is successful...
if [ $? -eq 0 ]; then

  # Add the 'latest' tag to the image
  docker tag $FQIN $FQRN:latest

  # Ask if the user wants to push the image to the registry
  read -p "Do you want to push the image '${FQIN}'? (y/N): " Q
  Q=$(echo "$Q" | tr '[:upper:]' '[:lower:]')
  if [[ "$Q" == "y" || "$Q" == "yes" ]]; then
    docker push $FQIN && docker push $FQRN:latest
  fi

  # Ask if the user wants to run the container
  read -p "Do you want to run the container now? (y/N): " Q
  Q=$(echo "$Q" | tr '[:upper:]' '[:lower:]')
  if [[ "$Q" == "y" || "$Q" == "yes" ]]; then
    docker run --rm -p 80:80 --name $REPOSITORY $FQIN
  fi

fi

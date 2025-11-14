#!/bin/bash
# Script to clean up ECR repository before stack deletion

REPO_NAME="cprx-idp-pattern2stack-lrm676l9iv6h-ecrrepository-2efwyr0xxfld"
REGION="us-east-1"
PROFILE="nblythe-dev"  # Change to your AWS profile name

echo "Cleaning up ECR repository: $REPO_NAME"
echo "Using AWS profile: $PROFILE"

# Get all image digests
echo "Fetching image list..."
IMAGE_DIGESTS=$(aws ecr list-images \
    --repository-name "$REPO_NAME" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'imageIds[*]' \
    --output json)

if [ "$IMAGE_DIGESTS" != "[]" ] && [ -n "$IMAGE_DIGESTS" ]; then
    echo "Found images. Deleting all images from repository..."
    aws ecr batch-delete-image \
        --repository-name "$REPO_NAME" \
        --region "$REGION" \
        --profile "$PROFILE" \
        --image-ids "$IMAGE_DIGESTS"
    echo "✓ Images deleted successfully"
else
    echo "No images found in repository (or repository doesn't exist)"
fi

echo ""
echo "You can now delete the CloudFormation stack with:"
echo "aws cloudformation delete-stack --stack-name <your-stack-name> --region $REGION --profile $PROFILE"

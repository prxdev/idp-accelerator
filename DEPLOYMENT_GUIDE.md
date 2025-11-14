# Deployment Fix Guide

## Current Issues

Your CloudFormation deployment is failing because:

1. **Missing build artifacts** - The nested stacks need `.aws-sam/packaged.yaml` files
2. **CodeBuild failure** - Docker image build is failing
3. **ECR cleanup issue** - Repository has images preventing deletion

## Step-by-Step Fix

### 1. Clean Up Failed Stack

First, manually delete ECR images:

```bash
# Update these values for your environment
REPO_NAME="cprx-idp-pattern2stack-lrm676l9iv6h-ecrrepository-2efwyr0xxfld"
REGION="us-east-1"  # Change to your actual region
ACCOUNT_ID="354856904650"

# Delete all images
aws ecr batch-delete-image \
    --repository-name "$REPO_NAME" \
    --region "$REGION" \
    --image-ids "$(aws ecr list-images --repository-name "$REPO_NAME" --region "$REGION" --query 'imageIds[*]' --output json)" \
    || echo "Repository may already be empty or deleted"
```

Then delete the CloudFormation stack:

```bash
aws cloudformation delete-stack --stack-name <your-stack-name> --region $REGION
```

### 2. Build the Project Properly

This repo requires running the build script before deployment:

```bash
# Install dependencies
pip install boto3 pyyaml rich

# Run the build script
python3 publish.py <bucket-name> <prefix> <region>

# Example:
# python3 publish.py my-artifacts-bucket genai-idp us-east-1
```

The `publish.py` script will:
- Build all Lambda functions
- Package SAM templates
- Create `.aws-sam/packaged.yaml` files
- Upload artifacts to S3
- Generate the final CloudFormation template

### 3. Deploy Using the Generated Template

After the build completes, deploy using:

```bash
# The script outputs a CloudFormation template URL
# Use that URL to create your stack

aws cloudformation create-stack \
    --stack-name IDP \
    --template-url <S3-URL-from-publish-output> \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --region $REGION
```

## Alternative: Use Pre-Built Public Templates

If you don't want to build from source, use the pre-built templates:

```bash
# For us-west-2
TEMPLATE_URL="https://s3.us-west-2.amazonaws.com/aws-ml-blog-us-west-2/artifacts/genai-idp/idp-main.yaml"

# For us-east-1
TEMPLATE_URL="https://s3.us-east-1.amazonaws.com/aws-ml-blog-us-east-1/artifacts/genai-idp/idp-main.yaml"

# For eu-central-1
TEMPLATE_URL="https://s3.eu-central-1.amazonaws.com/aws-ml-blog-eu-central-1/artifacts/genai-idp/idp-main.yaml"

aws cloudformation create-stack \
    --stack-name IDP \
    --template-url $TEMPLATE_URL \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --region us-east-1
```

## Common Build Issues

### Issue: "No module named 'boto3'"
**Fix:** Install dependencies: `pip install boto3 pyyaml rich`

### Issue: "SAM CLI not found"
**Fix:** Install SAM CLI: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html

### Issue: "Docker not running"
**Fix:** Start Docker Desktop or Docker daemon

### Issue: Build fails with Python version errors
**Fix:** Ensure Python 3.12 or 3.13 is installed

## Verification

After successful deployment, verify:

1. Check CloudFormation stack status is `CREATE_COMPLETE`
2. Verify nested stacks (PATTERN2STACK, DOCUMENTKB) are also complete
3. Check ECR repository has images
4. Test with a sample document upload

## Need More Help?

- Check the main README.md for detailed documentation
- Review docs/deployment.md for comprehensive deployment guide
- Check docs/troubleshooting.md for common issues

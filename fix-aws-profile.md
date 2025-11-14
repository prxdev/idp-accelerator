# Fix AWS Profile Issue

## Problem
You're using AWS SSO (IAM Identity Center) which requires an active login session.

## Solution

### Step 1: Login to AWS SSO

```bash
aws sso login --profile nblythe-dev
```

This will:
1. Open your browser
2. Ask you to authenticate via your SSO portal
3. Cache temporary credentials

### Step 2: Verify the login worked

```bash
aws sts get-caller-identity --profile nblythe-dev
```

You should see output like:
```json
{
    "UserId": "...",
    "Account": "354856904650",
    "Arn": "arn:aws:sts::354856904650:assumed-role/..."
}
```

### Step 3: Clean up ECR repository

Now run the cleanup script:

```bash
chmod +x cleanup-ecr.sh
./cleanup-ecr.sh
```

Or manually:

```bash
# List images first
aws ecr list-images \
    --repository-name "cprx-idp-pattern2stack-lrm676l9iv6h-ecrrepository-2efwyr0xxfld" \
    --region us-east-1 \
    --profile nblythe-dev

# Delete all images
aws ecr batch-delete-image \
    --repository-name "cprx-idp-pattern2stack-lrm676l9iv6h-ecrrepository-2efwyr0xxfld" \
    --region us-east-1 \
    --profile nblythe-dev \
    --image-ids "$(aws ecr list-images --repository-name "cprx-idp-pattern2stack-lrm676l9iv6h-ecrrepository-2efwyr0xxfld" --region us-east-1 --profile nblythe-dev --query 'imageIds[*]' --output json)"
```

### Step 4: Delete the CloudFormation stack

```bash
aws cloudformation delete-stack \
    --stack-name <your-stack-name> \
    --region us-east-1 \
    --profile nblythe-dev
```

## Alternative: Use AWS Console

If CLI continues to have issues, you can clean up via the AWS Console:

1. **ECR Cleanup:**
   - Go to: https://console.aws.amazon.com/ecr/repositories
   - Find repository: `cprx-idp-pattern2stack-lrm676l9iv6h-ecrrepository-2efwyr0xxfld`
   - Select all images → Delete

2. **Stack Deletion:**
   - Go to: https://console.aws.amazon.com/cloudformation
   - Select your stack
   - Click "Delete"
   - If it fails on ECR, manually delete the repository after cleaning images

## SSO Session Expiration

SSO sessions expire (usually after 8-12 hours). If you get credential errors later, just run:

```bash
aws sso login --profile nblythe-dev
```

## Set Default Profile (Optional)

To avoid typing `--profile` every time:

```bash
export AWS_PROFILE=nblythe-dev
```

Then you can run commands without `--profile`:

```bash
aws sts get-caller-identity
aws ecr list-images --repository-name "..." --region us-east-1
```

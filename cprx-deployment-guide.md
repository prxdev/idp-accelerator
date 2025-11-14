# CPRX GenAI IDP Deployment Guide

## Recommended Naming Convention

### Bucket Name
```bash
BUCKET_NAME="cprx-genai-idp-artifacts-us-east-1"
```

**Naming rationale:**
- `cprx` - Your company identifier
- `genai-idp` - Project name (clear purpose)
- `artifacts` - Indicates it stores build artifacts
- `us-east-1` - Region (helps if you deploy to multiple regions)

**Alternative options:**
- `cprx-idp-deployments`
- `cprx-ml-artifacts`
- `cprx-genai-artifacts-prod` (if you have multiple environments)

### Prefix
```bash
PREFIX="genai-idp"
```

**Naming rationale:**
- Simple and descriptive
- Organizes artifacts within the bucket
- Allows sharing the bucket with other projects

**Alternative options:**
- `idp/v1` - If you want versioning
- `genai-idp/prod` - If you have multiple environments
- `projects/genai-idp` - If you organize by project

## Full Deployment Command

```bash
# Set variables
BUCKET_NAME="cprx-genai-idp-artifacts-us-east-1"
PREFIX="genai-idp"
REGION="us-east-1"
PROFILE="nblythe-dev"

# Create the bucket (if it doesn't exist)
aws s3 mb s3://$BUCKET_NAME --region $REGION --profile $PROFILE

# Enable versioning (recommended for production)
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled \
    --profile $PROFILE

# Run the build and publish
python3 publish.py $BUCKET_NAME $PREFIX $REGION --profile $PROFILE
```

## S3 Bucket Structure

After running `publish.py`, your bucket will look like:

```
s3://cprx-genai-idp-artifacts-us-east-1/
└── genai-idp/
    ├── 0.3.19/                          # Version number
    │   ├── idp-main.yaml                # Main CloudFormation template
    │   ├── patterns/
    │   │   ├── pattern-1/
    │   │   │   ├── packaged.yaml
    │   │   │   └── pattern1-source-abc123.zip
    │   │   ├── pattern-2/
    │   │   │   ├── packaged.yaml
    │   │   │   └── pattern2-source-def456.zip
    │   │   └── pattern-3/
    │   │       ├── packaged.yaml
    │   │       └── pattern3-source-ghi789.zip
    │   ├── options/
    │   │   └── bedrockkb/
    │   │       └── packaged.yaml
    │   └── webui/
    │       └── webui-jkl012.zip
    └── latest/                          # Symlink to latest version
        └── idp-main.yaml
```

## Environment-Specific Naming

If you plan to have multiple environments:

### Development
```bash
BUCKET_NAME="cprx-genai-idp-artifacts-dev-us-east-1"
PREFIX="genai-idp/dev"
STACK_NAME="cprx-idp-dev"
```

### Staging
```bash
BUCKET_NAME="cprx-genai-idp-artifacts-staging-us-east-1"
PREFIX="genai-idp/staging"
STACK_NAME="cprx-idp-staging"
```

### Production
```bash
BUCKET_NAME="cprx-genai-idp-artifacts-prod-us-east-1"
PREFIX="genai-idp/prod"
STACK_NAME="cprx-idp-prod"
```

## Complete Deployment Steps

### 1. Create the artifacts bucket

```bash
aws s3 mb s3://cprx-genai-idp-artifacts-us-east-1 \
    --region us-east-1 \
    --profile nblythe-dev
```

### 2. (Optional) Enable encryption

```bash
aws s3api put-bucket-encryption \
    --bucket cprx-genai-idp-artifacts-us-east-1 \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }' \
    --profile nblythe-dev
```

### 3. (Optional) Block public access

```bash
aws s3api put-public-access-block \
    --bucket cprx-genai-idp-artifacts-us-east-1 \
    --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
    --profile nblythe-dev
```

### 4. Build and publish

```bash
# Make sure you're logged in
aws sso login --profile nblythe-dev

# Run the build
python3 publish.py \
    cprx-genai-idp-artifacts-us-east-1 \
    genai-idp \
    us-east-1
```

**Note:** The `publish.py` script will automatically use your AWS profile from the environment.

### 5. Deploy the stack

After `publish.py` completes, it will output a CloudFormation template URL. Use it to deploy:

```bash
# The script will output something like:
# Template URL: https://s3.us-east-1.amazonaws.com/cprx-genai-idp-artifacts-us-east-1/genai-idp/0.3.19/idp-main.yaml

aws cloudformation create-stack \
    --stack-name cprx-idp \
    --template-url "https://s3.us-east-1.amazonaws.com/cprx-genai-idp-artifacts-us-east-1/genai-idp/0.3.19/idp-main.yaml" \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --region us-east-1 \
    --profile nblythe-dev \
    --parameters \
        ParameterKey=Pattern,ParameterValue=Pattern-2 \
        ParameterKey=Pattern2Configuration,ParameterValue=rvl-cdip
```

## Bucket Lifecycle Policy (Optional)

To automatically clean up old versions after 90 days:

```bash
aws s3api put-bucket-lifecycle-configuration \
    --bucket cprx-genai-idp-artifacts-us-east-1 \
    --lifecycle-configuration file://lifecycle-policy.json \
    --profile nblythe-dev
```

Create `lifecycle-policy.json`:
```json
{
  "Rules": [
    {
      "Id": "DeleteOldVersions",
      "Status": "Enabled",
      "Prefix": "genai-idp/",
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 90
      }
    }
  ]
}
```

## Troubleshooting

### Issue: Bucket name already taken
S3 bucket names are globally unique. If taken, try:
- `cprx-genai-idp-artifacts-354856904650` (add account ID)
- `cprx-idp-ml-artifacts-us-east-1`
- `carepathrx-genai-idp-artifacts-us-east-1` (full company name)

### Issue: Permission denied creating bucket
Make sure your SSO role has S3 permissions:
```bash
aws sts get-caller-identity --profile nblythe-dev
```

Your Administrator role should have full access.

### Issue: publish.py fails
Check prerequisites:
```bash
# Python version
python3 --version  # Should be 3.12 or 3.13

# SAM CLI
sam --version

# Docker
docker --version
docker ps  # Should not error
```

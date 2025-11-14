# Deploy GenAI IDP Stack via AWS CLI

## Prerequisites

1. ✅ Build completed successfully (publish.py finished)
2. ✅ AWS SSO logged in
3. ✅ Template uploaded to S3

## Quick Deploy - Use the Script

```bash
chmod +x deploy-stack.sh
./deploy-stack.sh
```

## Manual Deploy - Step by Step

### Step 1: Set Variables

```bash
export AWS_PROFILE=nblythe-dev
STACK_NAME="cprx-idp"
REGION="us-east-1"
TEMPLATE_URL="https://s3.us-east-1.amazonaws.com/cprx-idp-20251113-us-east-1-us-east-1/idp/0.4.2/idp-main.yaml"
```

### Step 2: Login to AWS

```bash
aws sso login --profile $AWS_PROFILE
```

### Step 3: Create the Stack

```bash
aws cloudformation create-stack \
    --stack-name "$STACK_NAME" \
    --template-url "$TEMPLATE_URL" \
    --region "$REGION" \
    --profile "$AWS_PROFILE" \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --parameters \
        ParameterKey=AdminEmail,ParameterValue=your-email@carepathrx.com \
        ParameterKey=AllowedSignUpEmailDomain,ParameterValue=carepathrx.com \
        ParameterKey=Pattern,ParameterValue=Pattern-2 \
        ParameterKey=Pattern2Configuration,ParameterValue=rvl-cdip \
    --tags \
        Key=Project,Value=GenAI-IDP \
        Key=Environment,Value=Production
```

**Important:** Replace `your-email@carepathrx.com` with your actual email address. You'll receive a temporary password at this email.

### Step 4: Monitor Deployment

**Check stack status:**
```bash
aws cloudformation describe-stacks \
    --stack-name cprx-idp \
    --region us-east-1 \
    --profile nblythe-dev \
    --query 'Stacks[0].StackStatus'
```

**Watch events in real-time:**
```bash
aws cloudformation describe-stack-events \
    --stack-name cprx-idp \
    --region us-east-1 \
    --profile nblythe-dev \
    --max-items 10
```

**Wait for completion:**
```bash
aws cloudformation wait stack-create-complete \
    --stack-name cprx-idp \
    --region us-east-1 \
    --profile nblythe-dev

echo "Stack creation complete!"
```

### Step 5: Get Stack Outputs

```bash
aws cloudformation describe-stacks \
    --stack-name cprx-idp \
    --region us-east-1 \
    --profile nblythe-dev \
    --query 'Stacks[0].Outputs'
```

Important outputs:
- **ApplicationWebURL** - Web UI URL
- **S3InputBucketName** - Upload documents here
- **S3OutputBucketName** - Results appear here
- **StateMachineArn** - Step Functions workflow

## Common Parameters

### Required Parameters
```bash
--parameters \
    ParameterKey=AdminEmail,ParameterValue=your-email@carepathrx.com \
    ParameterKey=Pattern,ParameterValue=Pattern-2 \
    ParameterKey=Pattern2Configuration,ParameterValue=rvl-cdip
```

**AdminEmail** - Email address that will receive the temporary password for first login to the Web UI.

### Optional Parameters

**Allow self-signup for specific email domains:**
```bash
ParameterKey=AllowedSignUpEmailDomain,ParameterValue=carepathrx.com
# Or multiple domains:
ParameterKey=AllowedSignUpEmailDomain,ParameterValue="carepathrx.com,example.com"
# Or disable self-signup (users must be created in Cognito):
ParameterKey=AllowedSignUpEmailDomain,ParameterValue=""
```

**Enable HITL (Human-in-the-Loop):**
```bash
ParameterKey=EnableHITL,ParameterValue=true
```

**Custom stack name:**
```bash
--stack-name cprx-idp-dev  # or cprx-idp-prod
```

**Enable X-Ray tracing:**
```bash
ParameterKey=EnableXRayTracing,ParameterValue=true
```

**Custom log retention:**
```bash
ParameterKey=LogRetentionDays,ParameterValue=30
```

**Use existing workteam (for multiple HITL stacks):**
```bash
ParameterKey=ExistingPrivateWorkforceArn,ParameterValue=arn:aws:sagemaker:us-east-1:123456789012:workteam/private-crowd/my-team
```

## Full Example with All Options

```bash
aws cloudformation create-stack \
    --stack-name cprx-idp-prod \
    --template-url "https://s3.us-east-1.amazonaws.com/cprx-idp-20251113-us-east-1-us-east-1/idp/0.4.2/idp-main.yaml" \
    --region us-east-1 \
    --profile nblythe-dev \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --parameters \
        ParameterKey=AdminEmail,ParameterValue=admin@carepathrx.com \
        ParameterKey=AllowedSignUpEmailDomain,ParameterValue=carepathrx.com \
        ParameterKey=Pattern,ParameterValue=Pattern-2 \
        ParameterKey=Pattern2Configuration,ParameterValue=rvl-cdip \
        ParameterKey=EnableHITL,ParameterValue=false \
        ParameterKey=EnableXRayTracing,ParameterValue=true \
        ParameterKey=LogRetentionDays,ParameterValue=30 \
        ParameterKey=EnableECRImageScanning,ParameterValue=true \
    --tags \
        Key=Project,Value=GenAI-IDP \
        Key=Environment,Value=Production \
        Key=Owner,Value=CPRX \
        Key=CostCenter,Value=ML-Team
```

## Update an Existing Stack

```bash
aws cloudformation update-stack \
    --stack-name cprx-idp \
    --template-url "https://s3.us-east-1.amazonaws.com/cprx-idp-20251113-us-east-1-us-east-1/idp/0.4.2/idp-main.yaml" \
    --region us-east-1 \
    --profile nblythe-dev \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --parameters \
        ParameterKey=Pattern,UsePreviousValue=true \
        ParameterKey=Pattern2Configuration,UsePreviousValue=true
```

## Delete the Stack

```bash
# Delete the stack
aws cloudformation delete-stack \
    --stack-name cprx-idp \
    --region us-east-1 \
    --profile nblythe-dev

# Wait for deletion to complete
aws cloudformation wait stack-delete-complete \
    --stack-name cprx-idp \
    --region us-east-1 \
    --profile nblythe-dev
```

## Troubleshooting

### Check why stack creation failed:
```bash
aws cloudformation describe-stack-events \
    --stack-name cprx-idp \
    --region us-east-1 \
    --profile nblythe-dev \
    --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]'
```

### View nested stack failures:
```bash
# List all nested stacks
aws cloudformation list-stacks \
    --stack-status-filter CREATE_FAILED \
    --region us-east-1 \
    --profile nblythe-dev

# Get specific nested stack events
aws cloudformation describe-stack-events \
    --stack-name <nested-stack-name> \
    --region us-east-1 \
    --profile nblythe-dev
```

### Check CodeBuild logs (for Pattern 2):
```bash
# Get the build project name from stack resources
aws cloudformation describe-stack-resources \
    --stack-name cprx-idp \
    --region us-east-1 \
    --profile nblythe-dev \
    --query 'StackResources[?ResourceType==`AWS::CodeBuild::Project`]'

# View build logs in CloudWatch
aws logs tail /aws/codebuild/<project-name> \
    --follow \
    --region us-east-1 \
    --profile nblythe-dev
```

## Deployment Timeline

Typical deployment takes **20-30 minutes**:
- Main stack: 5-10 minutes
- Pattern 2 nested stack: 10-15 minutes
  - CodeBuild (Docker images): 5-10 minutes
  - Lambda functions: 2-5 minutes
- DOCUMENTKB (if enabled): 5-10 minutes
- UI deployment: 2-5 minutes

## After Deployment

### Get the Web UI URL:
```bash
aws cloudformation describe-stacks \
    --stack-name cprx-idp \
    --region us-east-1 \
    --profile nblythe-dev \
    --query 'Stacks[0].Outputs[?OutputKey==`ApplicationWebURL`].OutputValue' \
    --output text
```

### Get the input bucket:
```bash
aws cloudformation describe-stacks \
    --stack-name cprx-idp \
    --region us-east-1 \
    --profile nblythe-dev \
    --query 'Stacks[0].Outputs[?OutputKey==`S3InputBucketName`].OutputValue' \
    --output text
```

### Test with a sample document:
```bash
INPUT_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name cprx-idp \
    --region us-east-1 \
    --profile nblythe-dev \
    --query 'Stacks[0].Outputs[?OutputKey==`S3InputBucketName`].OutputValue' \
    --output text)

aws s3 cp samples/lending_package.pdf s3://$INPUT_BUCKET/ \
    --region us-east-1 \
    --profile nblythe-dev
```

## Using IDP CLI

After deployment, you can use the IDP CLI for batch processing:

```bash
# Install CLI
cd idp_cli
pip install -e .

# Process documents
idp-cli run-inference \
    --stack-name cprx-idp \
    --dir ./samples/ \
    --monitor

# Download results
idp-cli download-results \
    --stack-name cprx-idp \
    --batch-id <batch-id> \
    --output-dir ./results/
```

See [idp_cli/README.md](../idp_cli/README.md) for full CLI documentation.

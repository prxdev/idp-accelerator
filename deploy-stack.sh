#!/bin/bash
# Deploy CPRX GenAI IDP Stack via AWS CLI

# Configuration
export AWS_PROFILE=nblythe-dev
STACK_NAME="cprx-idp"
REGION="us-east-1"
TEMPLATE_URL="https://s3.us-east-1.amazonaws.com/cprx-idp-20251113-us-east-1-us-east-1/idp/idp-main.yaml"

# Pattern Configuration
IDP_PATTERN="Pattern2 - Packet processing with Textract and Bedrock"
PATTERN2_CONFIG="rvl-cdip-package-sample"  # Must match AllowedValues in template

# Admin Email - REQUIRED
# This email will receive the temporary password for first login
ADMIN_EMAIL="nathan.blythe@carepathrx.com"  # CHANGE THIS!

# Optional: Allow signup for specific email domains
# Leave empty to disable self-signup (users must be created in Cognito)
ALLOWED_SIGNUP_DOMAIN="carepathrx.com"  # or "" to disable

echo "🚀 Deploying CPRX GenAI IDP Stack"
echo "=================================="
echo "Stack Name: $STACK_NAME"
echo "Region: $REGION"
echo "Pattern: $IDP_PATTERN"
echo "Configuration: $PATTERN2_CONFIG"
echo "Admin Email: $ADMIN_EMAIL"
echo ""

# Validate admin email is set
if [ "$ADMIN_EMAIL" == "your-email@carepathrx.com" ]; then
    echo "❌ ERROR: Please set ADMIN_EMAIL in the script before running!"
    echo "   Edit deploy-stack.sh and change ADMIN_EMAIL to your email address."
    exit 1
fi

# Login to AWS SSO
echo "Logging in to AWS SSO..."
aws sso login --profile $AWS_PROFILE

# Verify credentials
echo "Verifying AWS credentials..."
aws sts get-caller-identity --profile $AWS_PROFILE

echo ""
echo "Creating CloudFormation stack..."
echo ""

# Create the stack
aws cloudformation create-stack \
    --stack-name "$STACK_NAME" \
    --template-url "$TEMPLATE_URL" \
    --region "$REGION" \
    --profile "$AWS_PROFILE" \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --parameters \
        ParameterKey=AdminEmail,ParameterValue="$ADMIN_EMAIL" \
        ParameterKey=AllowedSignUpEmailDomain,ParameterValue="$ALLOWED_SIGNUP_DOMAIN" \
        ParameterKey=IDPPattern,ParameterValue="$IDP_PATTERN" \
        ParameterKey=Pattern2Configuration,ParameterValue="$PATTERN2_CONFIG" \
    --tags \
        Key=Project,Value=GenAI-IDP \
        Key=Environment,Value=Production \
        Key=ManagedBy,Value=CloudFormation

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Stack creation initiated successfully!"
    echo ""
    echo "Monitor progress with:"
    echo "  aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --profile $AWS_PROFILE"
    echo ""
    echo "Or watch events in real-time:"
    echo "  aws cloudformation describe-stack-events --stack-name $STACK_NAME --region $REGION --profile $AWS_PROFILE"
    echo ""
    echo "View in AWS Console:"
    echo "  https://console.aws.amazon.com/cloudformation/home?region=$REGION#/stacks/stackinfo?stackId=$STACK_NAME"
else
    echo ""
    echo "❌ Stack creation failed!"
    exit 1
fi

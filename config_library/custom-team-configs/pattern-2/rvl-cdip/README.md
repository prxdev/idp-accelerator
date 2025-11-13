# Medical Records Document Processing Configuration

## Overview

This configuration is designed for processing healthcare and medical records documents using Pattern 2 architecture with Amazon Bedrock models. Optimized for extracting payer information, clinical data, and administrative details from various medical document types.

## Pattern

**Pattern 2**: Uses Amazon Bedrock with Nova and Claude models for both page classification/grouping and information extraction.

## Configuration Details

### OCR
- **Backend**: Amazon Textract
- **Model**: Claude 3.7 Sonnet
- **Features**: Layout, Tables, Signatures
- **DPI**: 150

### Classification
- **Model**: Amazon Nova Pro v1.0
- **Method**: Text-based holistic classification
- **Temperature**: 0.0 (deterministic)

### Extraction
- **Model**: Amazon Nova Pro v1.0
- **Temperature**: 0.0 (deterministic)
- **Max Tokens**: 10,000

### Assessment
- **Model**: Amazon Nova Lite v1.0
- **Granular Assessment**: Enabled
- **Confidence Threshold**: 0.8

### Summarization
- **Model**: Claude 3.7 Sonnet
- **Enabled**: Yes
- **Style**: Balanced with citations

## Document Classes

This configuration includes comprehensive schemas for the following medical document types:

1. **lab_results** - Laboratory test results with specimen info, test values, reference ranges, and abnormal flags
2. **history_and_physical** - Comprehensive H&P documents with patient history, physical exam findings, assessment, and plan
3. **facesheet** - Hospital admission facesheets with patient demographics, admission details, and insurance information
4. **referral_order** - Healthcare referral orders/packets for specialist referrals with insurance and clinical details
5. **prior_authorization** - Insurance prior authorization documents for medications, procedures, or services
6. **prescriber_order** - Prescriber orders including prescriptions, home infusion therapy, enteral nutrition, and DME orders

### Healthcare-Specific Features

- **Payer Information Extraction**: Specialized rules for extracting and standardizing insurance information
- **Phone Number Normalization**: Automatically formats phone numbers to 10-digit standard
- **Address Standardization**: Converts state abbreviations to full names
- **Insurance Rank Normalization**: Standardizes to "Primary", "Secondary", "Tertiary"
- **Clinical Data Extraction**: Optimized for medical terminology and healthcare document layouts

## Usage

Upload this configuration through the IDP Accelerator UI or reference it in your deployment.

## Validation Status

**Status**: In Development

## Notes

- Configuration includes detailed attribute descriptions for each document class
- Uses prompt caching for improved performance
- Includes comprehensive pricing information for cost tracking
- Error analysis agent configured for troubleshooting

## Customization

To customize this configuration:
1. Modify document classes in the `classes` section
2. Adjust model parameters (temperature, top_p, top_k)
3. Update prompts for classification, extraction, or summarization
4. Add or remove document types as needed

## Sample Documents

Add sample documents to the `samples/` directory for testing and validation.

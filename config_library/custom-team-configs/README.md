# Custom Team Configurations

This directory contains custom configurations developed by your team for specific use cases and document processing needs.

## Directory Structure

```
custom-team-configs/
├── README.md                    # This file
├── pattern-1/                   # Pattern 1 custom configs
├── pattern-2/                   # Pattern 2 custom configs
│   └── rvl-cdip/               # RVL-CDIP document classification
│       ├── config.yaml         # Main configuration
│       ├── README.md           # Documentation
│       └── samples/            # Sample documents
└── pattern-3/                   # Pattern 3 custom configs
```

## Purpose

This section is separate from the example configurations in `config_library/pattern-X/` to:
- Keep team-specific configurations organized
- Avoid conflicts with upstream repository updates
- Make it easy to share configurations within the team
- Maintain clear separation between examples and production configs

## Adding New Configurations

1. Create a directory under the appropriate pattern (pattern-1, pattern-2, or pattern-3)
2. Use descriptive names for your use case
3. Include a config.yaml file with your configuration
4. Add a README.md documenting the configuration
5. Include sample documents in a samples/ directory

## Git Strategy

You can choose to:
- **Commit these configs** to your fork for team collaboration
- **Add to .gitignore** if configurations contain sensitive information
- **Use a separate branch** for custom configs to keep main branch clean

## Notes

- These configurations are specific to your team's needs
- Document any custom classes, prompts, or model selections
- Include validation results and performance metrics in READMEs

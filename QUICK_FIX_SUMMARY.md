# Build Failure - Node.js Version Issue

## Current Problem
**Node.js version is too old!**
- Current: Node.js 18.20.8
- Required: Node.js 20.19+ or 22.12+
- Error: Vite 7 requires newer Node.js

## Quick Fix - Upgrade Node.js

You're using nvm, so upgrading is easy:

```bash
# Install Node.js 22 (LTS)
nvm install 22

# Set as default
nvm alias default 22

# Use it now
nvm use 22

# Verify
node --version  # Should show v22.x.x
```

Or run the script I created:
```bash
chmod +x upgrade-node.sh
./upgrade-node.sh
```

## After Upgrading Node.js

Re-run the publish script:
```bash
export AWS_PROFILE=nblythe-dev
python3 publish.py cprx-idp-20251113-us-east-1 idp us-east-1
```

## What Happened

1. ✅ First issue (Prettier formatting) - FIXED
2. ❌ Second issue (Node.js version) - NEEDS FIX

The UI build uses Vite 7, which dropped support for Node.js 18. You need Node.js 20 or 22.

## Alternative: Skip UI Build (Not Recommended)

If you can't upgrade Node.js right now, you could deploy without the UI:
- Use AWS Console to upload documents
- Use CLI for batch processing
- Deploy UI later after upgrading Node.js

But upgrading Node.js is the proper solution.

# Local Development Guide

This guide covers how to setup the Bluerage iOS app for local development.

## Environment Variables Reference
<details>
<summary>Expand to see</summary>

### Required

#### Convex

- `CONVEX_DEPLOYMENT_URL`: Your Convex deployment URL (automatically generated when you
  create a deployment, found in Convex dashboard)

**How to obtain**:
1. Create a new project at [Convex Dashboard](https://dashboard.convex.dev/)
2. Copy your deployment URL to the `CONVEX_DEPLOYMENT_URL` environment variable

#### Clerk

- `CLERK_FRONTEND_URL`: Your Clerk frontend API URL (found in Clerk dashboard under API Keys)
- `CLERK_PUBLISHABLE_KEY`: Your Clerk publishable key for client-side authentication (found in Clerk dashboard under API Keys)

**How to obtain**:
1. Create an account at [Clerk](https://clerk.com/)
2. Create a new application in your Clerk dashboard
3. Copy your Frontend API URL to `CLERK_FRONTEND_URL`
4. Copy your Publishable Key to `CLERK_PUBLISHABLE_KEY`

### Optional

#### PostHog

- `POSTHOG_API_KEY`: Your PostHog project API key (sign up at
  https://posthog.com/)
- `POSTHOG_HOST`: PostHog instance URL (usually `https://app.posthog.com` or
  `https://us.i.posthog.com`)

**How to obtain**:
1. Sign up at [PostHog](https://posthog.com/)
2. Create a new project and copy your API key to `POSTHOG_API_KEY`
3. Set the appropriate host URL for your region in `POSTHOG_HOST` (usually `https://app.posthog.com` or `https://us.i.posthog.com`)

#### Sentry

- `SENTRY_DSN`: Your Sentry Data Source Name for error tracking (obtained from Sentry project settings after creating a project at https://sentry.io/)

**How to obtain**:
1. Sign up at [Sentry](https://sentry.io/)
2. Create a new project and copy your DSN to `SENTRY_DSN`

</details>

## Requirements

- **Xcode**: 15.0+
- **iOS SDK**: 17.0+
- **Tuist**: 4.0+
- **SwiftLint**: 0.61.0+

## Setup Instructions

### 1. Setup Environment Variables

Bluerage uses xconfigs for managing environment variables.
Project contains [example config](../xcconfigs/Config.example.xcconfig).
Create Release and Debug xcconfigs and fill them:
```bash
cp xcconfigs/Config.example.xcconfig xcconfigs/Release.xcconfig
cp xcconfigs/Config.example.xcconfig xcconfigs/Debug.xcconfig
```

### 2. Run setup scripts

This will setup git hooks, check SwiftLint, install dependencies and create a project. Provide `TUIST_BUNDLE_ID` (your app's bundle identifier) and `TUIST_SENTRY_ORG` (your Sentry org) as env params

```bash
TUIST_BUNDLE_ID={your_bundle_id} TUIST_SENTRY_ORG={your_sentry_org} make setup
```

### 3. Open the project and run

You are good to go!

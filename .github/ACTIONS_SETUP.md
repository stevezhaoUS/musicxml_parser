# GitHub Actions Setup Guide

This document explains how to configure the GitHub Actions for the `musicxml_parser` project.

## Overview

The project includes several GitHub Actions workflows for:
- **CI/CD**: Continuous integration across multiple Dart versions and platforms
- **Code Quality**: Static analysis, documentation coverage, and package health checks
- **Dependencies**: Automated dependency updates via Dependabot

## Required Setup

### 1. Repository Settings

#### Branch Protection
Set up branch protection rules for the `main` branch:
1. Go to Settings → Branches
2. Add rule for `main` branch
3. Enable:
   - Require status checks to pass before merging
   - Require branches to be up to date before merging
   - Required status checks: CI tests, Code Quality checks

#### GitHub Pages (Optional)
If you want to publish documentation:
1. Go to Settings → Pages
2. Set source to "GitHub Actions"

### 2. Dependabot Configuration

Update the usernames in `.github/dependabot.yml`:
- Replace `"stevezhaoUS"` with your actual GitHub username (already updated)
- Adjust review/assignment settings as needed

## Workflow Details

### CI Workflow (`ci.yml`)
- **Triggers**: Push/PR to main/develop branches
- **Tests**: Multiple Dart versions (3.0.0, stable, beta) across platforms
- **Coverage**: Generates test coverage reports and uploads to Codecov

#### Setup Requirements:
- No additional setup needed
- Optionally set up Codecov account for coverage reports

### Code Quality Workflow (`code-quality.yml`)
- **Triggers**: Push/PR to main/develop branches
- **Checks**: Package health, documentation, lint analysis, dependency checks
- **Tools**: pana, dartdoc, dart_code_metrics

#### Setup Requirements:
- No additional setup needed

### Dependabot (`dependabot.yml`)
- **Schedule**: Weekly updates on Mondays
- **Scope**: Dart dependencies, example dependencies, GitHub Actions
- **Configuration**: Auto-assigns PRs, adds labels

#### Setup Requirements:
- Update usernames in configuration file

## Usage

### Monitoring

- Check the "Actions" tab in your repository for workflow status
- Set up notifications for failed builds
- Review Dependabot PRs weekly

## Troubleshooting

### Common Issues

1. **Tests fail on specific platforms**: Review platform-specific dependencies
2. **Coverage reports not uploading**: Verify Codecov configuration
3. **Dependabot PRs failing**: Check for breaking changes in dependencies

### Getting Help

- Review GitHub Actions logs for detailed error messages
- Check the official documentation for each action used

## Customization

Feel free to modify these workflows based on your specific needs:
- Adjust Dart version matrix in CI
- Modify code quality tools
- Change branch protection rules

Remember to test workflow changes in a feature branch before merging to main.

## Next Steps

1. ✅ Update `stevezhaoUS` in `dependabot.yml` with your actual GitHub username (completed)
2. Configure branch protection rules in repository settings
3. Optional: Set up Codecov account for coverage reports

These GitHub Actions will provide a complete CI/CD pipeline for your project, ensuring code quality and automated testing.

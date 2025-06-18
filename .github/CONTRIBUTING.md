# Contributing to musicxml_parser

Thank you for your interest in contributing to `musicxml_parser`! This document provides guidelines for contributing to the project.

## Code of Conduct

Please be respectful and professional in all interactions. We're here to build something great together.

## How to Contribute

### Reporting Issues

Before creating an issue, please:
1. Check if the issue already exists
2. Provide a clear description of the problem
3. Include a minimal MusicXML sample that demonstrates the issue
4. Specify your environment (Dart version, platform, etc.)

### Suggesting Features

For new features:
1. Check the [Feature Support List](docs/feature-support.md) to see current status
2. Describe the use case and why the feature is needed
3. Reference the relevant MusicXML specification if applicable
4. Provide example MusicXML that would benefit from this feature

### Pull Requests

1. **Fork** the repository
2. **Create a branch** for your feature: `git checkout -b feature/my-feature`
3. **Follow our coding standards**:
   - Use `dart format` for code formatting
   - Ensure `dart analyze` passes with no issues
   - Write comprehensive tests for new functionality
   - Add dartdoc comments for all public APIs
4. **Test your changes**:
   - All existing tests must pass
   - New functionality must have >90% test coverage
   - Test on multiple MusicXML samples if applicable
5. **Update documentation**:
   - Update README.md if needed
   - Update feature support list in `docs/feature-support.md`
   - Add examples for new functionality
6. **Commit with clear messages**: Follow conventional commit format
7. **Submit the pull request**

## Development Guidelines

### Project Structure
- `lib/src/models/` - Data model classes
- `lib/src/parser/` - Parsing logic
- `lib/src/utils/` - Utility functions
- `lib/src/exceptions/` - Custom exceptions
- `test/` - All test files (mirror lib structure)

### Coding Standards
- Use `@immutable` for model classes where appropriate
- Prefer composition over inheritance
- Use meaningful variable and function names
- Handle errors gracefully with informative messages
- Follow Dart's official style guide

### Testing Requirements
- Every public method must have tests
- Test both happy path and error cases
- Use descriptive test names
- Group related tests logically
- Mock external dependencies appropriately

### Music Theory Accuracy
When implementing music-related features:
- Validate against music theory rules
- Ensure MIDI note ranges are correct (0-127)
- Follow standard notation conventions
- Reference authoritative music theory sources

### Documentation
- Use dartdoc format for all public APIs
- Include examples in documentation
- Explain music theory concepts when relevant
- Update relevant documentation files

## Questions?

If you have questions about contributing, feel free to:
- Open a discussion on GitHub
- Ask in an issue with the "question" label
- Check existing documentation in the `docs/` folder

Thank you for contributing to `musicxml_parser`! 🎵

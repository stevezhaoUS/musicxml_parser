# Test Coverage Guidelines

## Progressive Coverage Targets

This project follows a progressive approach to test coverage, allowing for steady improvement as the codebase matures.

### Current Thresholds

| Project Stage | Minimum Coverage | Target Coverage | Notes |
|---------------|------------------|-----------------|-------|
| **Initial** (v0.1.x) | 40% | 50% | Focus on core functionality |
| **Growing** (v0.2.x) | 50% | 65% | Expand test coverage systematically |
| **Maturing** (v0.3.x+) | 65% | 80% | Comprehensive testing |
| **Production** (v1.0+) | 80% | 90%+ | High reliability standards |

### Current Status

- **CI Threshold**: 40% (will fail CI if below)
- **Current Coverage**: Run `make coverage` to see latest
- **Next Target**: 50%

## Coverage Strategy

### Phase 1: Core Coverage (40-50%)
Focus on testing the most critical paths:
- ✅ Public API methods
- ✅ Main parsing logic
- ✅ Basic error handling
- ⏳ Core model classes

### Phase 2: Comprehensive Coverage (50-65%)
Expand to cover more scenarios:
- ⏳ Edge cases and error conditions
- ⏳ Complex parsing scenarios
- ⏳ Integration tests
- ⏳ Utility functions

### Phase 3: Rigorous Coverage (65-80%)
Ensure robustness:
- ⏳ All public methods tested
- ⏳ Error handling paths
- ⏳ Performance edge cases
- ⏳ Documentation examples

### Phase 4: Excellence (80%+)
Production-ready quality:
- ⏳ Complete test suite
- ⏳ Stress testing
- ⏳ Compatibility testing
- ⏳ Security validation

## How to Improve Coverage

### 1. Check Current Coverage
```bash
make coverage
open coverage/html/index.html
```

### 2. Identify Gaps
Look for:
- Red lines (uncovered code)
- Missing test files
- Untested edge cases

### 3. Add Tests Systematically
```bash
# Create test file for new model
touch test/models/new_model_test.dart

# Run tests to verify
dart test
```

### 4. Verify Improvement
```bash
make coverage
# Check if coverage increased
```

## Coverage Quality Guidelines

### Good Coverage Includes:
- ✅ **Happy path**: Normal operation scenarios
- ✅ **Edge cases**: Boundary conditions
- ✅ **Error cases**: Invalid input handling
- ✅ **Integration**: Component interaction

### Avoid:
- ❌ **Coverage for coverage's sake**: Don't test trivial getters/setters
- ❌ **Flaky tests**: Tests that pass/fail inconsistently
- ❌ **Slow tests**: Optimize for fast feedback

## Tools and Commands

### Local Development
```bash
# Quick coverage check
make coverage

# Run specific test file
dart test test/models/pitch_test.dart

# Watch mode (if available)
dart test --watch
```

### CI Integration
- Coverage is checked automatically on every push
- Failed coverage checks will block merges
- Coverage reports are uploaded as artifacts

### Coverage Reports
- **HTML Report**: `coverage/html/index.html`
- **LCOV Report**: `coverage/lcov.info`
- **CI Artifacts**: Available for download from GitHub Actions

## Raising the Bar

As the project grows, consider:

1. **Update CI threshold** in `.github/workflows/ci.yml`
2. **Update documentation** in this file
3. **Communicate changes** to contributors
4. **Provide migration time** for existing code

### Example: Raising from 40% to 50%

```yaml
# In .github/workflows/ci.yml
if (( $(echo "$COVERAGE < 50" | bc -l) )); then
  echo "❌ Coverage ${COVERAGE}% is below minimum threshold of 50%"
```

## Best Practices

1. **Write tests first** when adding new features
2. **Test behavior, not implementation**
3. **Keep tests simple and focused**
4. **Use descriptive test names**
5. **Group related tests logically**

## Resources

- [Dart Testing Guide](https://dart.dev/guides/testing)
- [Test Coverage Tools](https://pub.dev/packages/coverage)
- [Project Contributing Guidelines](../.github/CONTRIBUTING.md)

---

*Last updated: June 18, 2025*

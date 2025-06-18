#!/bin/bash

# Quick coverage check script

echo "🧪 Running tests and generating coverage..."

# Run tests with coverage
dart test --coverage=coverage/ || exit 1

# Generate coverage report
dart pub global activate coverage
dart pub global run coverage:format_coverage \
    --lcov \
    --in=coverage/ \
    --out=coverage/lcov.info \
    --packages=.dart_tool/package_config.json \
    --report-on=lib

# Check if lcov is available for HTML reports
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html/ --quiet
    echo "📊 HTML Coverage report: coverage/html/index.html"
    
    # Try to open in browser (macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open coverage/html/index.html
    fi
fi

# Display quick summary
if command -v lcov &> /dev/null; then
    echo ""
    echo "📈 Coverage Summary:"
    lcov --summary coverage/lcov.info
else
    echo ""
    echo "💡 Install lcov for detailed coverage reports:"
    echo "   macOS: brew install lcov"
    echo "   Ubuntu: sudo apt-get install lcov"
fi

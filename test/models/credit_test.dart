import 'package:musicxml_parser/src/models/credit.dart'; // Adjust import as needed
import 'package:collection/collection.dart'; // For DeepCollectionEquality
import 'package:test/test.dart';

void main() {
  group('Credit Model', () {
    group('constructor and properties', () {
      test('creates instance with all properties', () {
        const credit = Credit(
          page: 1,
          creditType: 'composer',
          creditWords: ['John Doe'],
        );
        expect(credit.page, 1);
        expect(credit.creditType, 'composer');
        expect(credit.creditWords, equals(['John Doe']));
      });

      test('properties can be null (except creditWords which defaults to empty)', () {
        const credit = Credit();
        expect(credit.page, isNull);
        expect(credit.creditType, isNull);
        expect(credit.creditWords, isEmpty);
      });

      test('creditWords defaults to empty list', () {
        const credit = Credit(creditType: 'title');
        expect(credit.creditWords, isEmpty);
      });
    });

    group('equality and hashCode', () {
      const c1 = Credit(page: 1, creditType: 'title', creditWords: ['My Score']);
      const c2 = Credit(page: 1, creditType: 'title', creditWords: ['My Score']);
      const c3 = Credit(page: 2, creditType: 'title', creditWords: ['My Score']); // diff page
      const c4 = Credit(page: 1, creditType: 'subtitle', creditWords: ['My Score']); // diff type
      const c5 = Credit(page: 1, creditType: 'title', creditWords: ['Another Score']); // diff words
      const c6 = Credit(page: 1, creditType: 'title', creditWords: ['My', 'Score']); // diff words list structure
      const c7 = Credit(); // all optional null, words empty

      test('instances with same values are equal and have same hashCode', () {
        expect(c1, equals(c2));
        expect(c1.hashCode, equals(c2.hashCode));
      });

      test('instances with default/empty values are equal', () {
        const credit_empty1 = Credit();
        const credit_empty2 = Credit();
        expect(credit_empty1, equals(credit_empty2));
        expect(credit_empty1.hashCode, equals(credit_empty2.hashCode));
      });

      test('instances with different page are not equal', () {
        expect(c1, isNot(equals(c3)));
      });

      test('instances with different creditType are not equal', () {
        expect(c1, isNot(equals(c4)));
      });

      test('instances with different creditWords are not equal', () {
        expect(c1, isNot(equals(c5)));
        expect(c1, isNot(equals(c6))); // c1 has ['My Score'], c6 has ['My', 'Score']
      });

      test('instance with values vs all default/empty is not equal', () {
        expect(c1, isNot(equals(c7)));
      });
       test('instances with different numbers of creditWords are not equal', () {
        const credit_multi_words = Credit(creditWords: ['Word1', 'Word2']);
        const credit_single_word = Credit(creditWords: ['Word1']);
        expect(credit_multi_words, isNot(equals(credit_single_word)));
      });
    });

    group('toString representation', () {
      test('includes all fields when present', () {
        const credit = Credit(page: 1, creditType: 'arranger', creditWords: ['Arr. By Me']);
        // Based on Credit model's toString: Credit{page: 1, creditType: "arranger", creditWords: "Arr. By Me"}
        expect(credit.toString(), equals('Credit{page: 1, creditType: "arranger", creditWords: "Arr. By Me"}'));
      });

      test('handles multiple creditWords', () {
        const credit = Credit(creditType: 'title', creditWords: ['Main Title', 'Subtitle']);
        expect(credit.toString(), equals('Credit{creditType: "title", creditWords: "Main Title", "Subtitle"}'));
      });

      test('omits fields when null/empty', () {
        const credit = Credit(creditType: 'dedication'); // page null, creditWords empty
        expect(credit.toString(), equals('Credit{creditType: "dedication"}'));
      });

      test('empty when all fields null/empty', () {
        const credit = Credit();
        expect(credit.toString(), equals('Credit{}'));
      });
    });
  });
}

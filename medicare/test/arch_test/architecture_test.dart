import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Architecture Compliance', () {
    final libDir = Directory('lib');
    final files = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    // Helper: Get imports from file
    List<String> getImports(File file) {
      return file
          .readAsLinesSync()
          .where((line) => line.trim().startsWith('import '))
          .map((line) {
            // Extract content between quotes
            final match =
                RegExp(r"[']([^']+)[']").firstMatch(line) ??
                RegExp(r'["]([^"]+)["]').firstMatch(line);
            return match?.group(1) ?? '';
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }

    test('Rule 1: Domain Isolation (No Infra/Presentation in Domain)', () {
      final violations = <String>[];

      for (final file in files) {
        // Normalize path
        final path = p.split(file.path).join('/');

        // Identify if file is in domain
        if (path.contains('/domain/')) {
          final imports = getImports(file);

          for (final importInfo in imports) {
            // Check forbidden layers
            if (importInfo.contains('/infra/') ||
                importInfo.contains('/presentation/') ||
                importInfo.contains('/ui/')) {
              violations.add(
                'File $path imports $importInfo (Domain cannot import Infra/UI)',
              );
            }
          }
        }
      }

      if (violations.isNotEmpty) {
        fail('Domain Isolation Violations Found:\n${violations.join('\n')}');
      }
    });

    test('Rule 2: Framework Independence (No Flutter in Domain)', () {
      final violations = <String>[];

      for (final file in files) {
        final path = p.split(file.path).join('/');

        if (path.contains('/domain/')) {
          final imports = getImports(file);
          for (final importInfo in imports) {
            if (importInfo.startsWith('package:flutter/')) {
              violations.add(
                'File $path imports $importInfo (Domain cannot import Flutter)',
              );
            }
          }
        }
      }

      if (violations.isNotEmpty) {
        fail(
          'Framework Independence Violations Found:\n${violations.join('\n')}',
        );
      }
    });

    test('Rule 3: Presentation Layer (No Infra in Presentation)', () {
      final violations = <String>[];

      for (final file in files) {
        final path = p.split(file.path).join('/');

        if (path.contains('/presentation/') || path.contains('/ui/')) {
          final imports = getImports(file);
          for (final importInfo in imports) {
            if (importInfo.contains('/infra/') ||
                importInfo.startsWith('package:parse_server_sdk')) {
              // Also checking for explicit SDK usage which is infra
              violations.add(
                'File $path imports $importInfo (Presentation cannot import Infra)',
              );
            }
          }
        }
      }

      if (violations.isNotEmpty) {
        fail('Presentation Layer Violations Found:\n${violations.join('\n')}');
      }
    });

    test('Rule 4: Naming (UseCases should end with UseCase)', () {
      final violations = <String>[];

      for (final file in files) {
        final path = p.split(file.path).join('/');

        if (path.contains('/domain/usecases/')) {
          // Read file content to find class name?
          // Or just check filename as a proxy?
          // Valid pattern: "create_care_plan_usecase.dart" -> CreateCarePlanUseCase
          // Let's check class names inside.

          final content = file.readAsStringSync();
          final classRegex = RegExp(r'class\s+(\w+)');
          final matches = classRegex.allMatches(content);

          for (final match in matches) {
            final className = match.group(1)!;
            if (!className.endsWith('UseCase') &&
                !className.endsWith('Params')) {
              // UseCase often has Params classes
              // Simple heuristic: if it's the main class (usually matches filename roughly)
              // Strict rule says "Classes inside usecases".
              // Let's allow "Params" suffix or "Failure" if defined there?
              // The rule said "Classes within usecases... suffix UseCase".
              // Let's flag it.
              if (!className.endsWith('UseCase')) {
                violations.add(
                  'File $path contains class $className (Should end with UseCase)',
                );
              }
            }
          }
        }
      }

      if (violations.isNotEmpty) {
        fail('Naming Violations Found:\n${violations.join('\n')}');
      }
    });
  });
}

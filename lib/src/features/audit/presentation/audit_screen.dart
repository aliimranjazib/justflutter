import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// State provider for the audit input text
final auditInputProvider = StateProvider<String>(
  (ref) => '''
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // Potential Memory Leak: Controller not disposed
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
  
  // Missing dispose() method
}
''',
);

// Provider for handled analysis results
final auditResultsProvider = StateProvider<String?>((ref) => null);

class WidgetDoctorEngine {
  static String analyze(String code) {
    List<String> memoryLeaks = [];
    List<String> logicIssues = [];

    // 1. Check for Memory Leaks (Detect controllers without dispose)
    final disposables = {
      'TextEditingController': '.dispose()',
      'AnimationController': '.dispose()',
      'ScrollController': '.dispose()',
      'TabController': '.dispose()',
      'PageController': '.dispose()',
      'StreamController': '.close()',
      'StreamSubscription': '.cancel()',
      'Timer': '.cancel()',
      'FocusNode': '.dispose()',
      'ChangeNotifier': '.dispose()',
      'ValueNotifier': '.dispose()',
    };

    disposables.forEach((type, disposeMethod) {
      if (code.contains(type)) {
        final hasDisposeMethod = code.contains('void dispose()');

        if (!hasDisposeMethod) {
          memoryLeaks.add(
            '**$type** used but `dispose()` override is missing.',
          );
        } else {
          // Check if the specific dispose method (e.g., .cancel() or .dispose()) is called
          if (!code.contains(disposeMethod)) {
            memoryLeaks.add(
              '**$type** detected, but `$disposeMethod` call not found in the file.',
            );
          }
        }
      }
    });

    // Specific check for StreamSubscription cancel in dispose
    if (code.contains('StreamSubscription') && !code.contains('.cancel()')) {
      memoryLeaks.add(
        '**StreamSubscription** found but might not be cancelled. Ensure you call `.cancel()` in `dispose()`.',
      );
    }

    // Specific check for Timer cancel in dispose
    if (code.contains('Timer') && !code.contains('.cancel()')) {
      memoryLeaks.add(
        '**Timer** found but might not be cancelled. This will continue running even after widget destruction.',
      );
    }

    // 2. Check for Logic Issues
    if (code.contains('setState(') && code.contains('Widget build')) {
      // Heuristic: setState inside build methods is bad
      final lines = code.split('\n');
      bool insideBuild = false;
      for (var line in lines) {
        if (line.contains('Widget build')) insideBuild = true;
        if (insideBuild && line.contains('setState(')) {
          logicIssues.add(
            'Potential **setState() called during build**. This will cause infinite loops.',
          );
          break;
        }
        if (line.contains('}')) {
          /* could be end of build, but hard to tell without AST */
        }
      }
    }

    if (!code.contains('super.dispose()') && code.contains('void dispose()')) {
      logicIssues.add(
        'Missing **super.dispose()**. This can prevent cleanup in the base class.',
      );
    }

    // 3. Construct the response
    StringBuffer report = StringBuffer();
    report.writeln('### 🏥 The Flutter Widget Doctor - Analysis Report\n');

    if (memoryLeaks.isEmpty && logicIssues.isEmpty) {
      report.writeln('✅ **No obvious issues found.** Clean bill of health!');
    } else {
      if (memoryLeaks.isNotEmpty) {
        report.writeln('#### 🧠 Memory Leak Analysis');
        for (var issue in memoryLeaks) {
          report.writeln('- $issue');
        }
        report.writeln();
      }

      if (logicIssues.isNotEmpty) {
        report.writeln('#### 📉 Logic & Performance Issues');
        for (var issue in logicIssues) {
          report.writeln('- $issue');
        }
        report.writeln();
      }

      // Try to generate a basic refactored version if it's a StatefulWidget
      if (code.contains('State<') && memoryLeaks.isNotEmpty) {
        report.writeln('#### 🛠️ Suggested Refactored Code (Cleanup Added)');

        String generatedDispose = '\\n  @override\\n  void dispose() {\\n';

        // Find variables that look like they need disposing
        final varRegex = RegExp(
          r'(?:final|late)\s+(?:[\w<>]+\s+)?_?([a-zA-Z0-9]+)\s*=\s*([a-zA-Z0-9]+)\(',
        );
        final matches = varRegex.allMatches(code);

        List<String> toDispose = [];
        for (var match in matches) {
          final varName = match.group(1);
          final typeName = match.group(2);

          if (varName != null && typeName != null) {
            if (disposables.containsKey(typeName) ||
                typeName == 'StreamSubscription' ||
                typeName == 'Timer') {
              String action = '.dispose();';
              if (typeName == 'StreamController') {
                action = '.close();';
              }
              if (typeName == 'StreamSubscription' || typeName == 'Timer') {
                action = '.cancel();';
              }

              // For private variables that match the pattern, try to keep the prefix
              final fullVarName = code.contains('_$varName')
                  ? '_$varName'
                  : varName;
              toDispose.add('    $fullVarName$action');
            }
          }
        }

        // Add specific fallback heuristics if regex misses them due to complex init
        disposables.forEach((type, action) {
          if (code.contains(type)) {
            // Very rough guess at variable names based on type if regex failed
            // E.g., TextEditingController -> _controller mapping is too hard,
            // so we just add a placeholder if we know the type exists but couldn't parse the var name.
          }
        });

        if (toDispose.isNotEmpty) {
          for (var d in toDispose.toSet()) {
            generatedDispose += '$d\\n';
          }
          generatedDispose += '    super.dispose();\\n  }\\n';

          report.writeln('```dart');
          if (code.contains('void dispose()')) {
            report.writeln(
              '// ⚠️ WARNING: Your code already has a dispose() method.',
            );
            report.writeln('// Ensure it looks like this:');
          } else {
            report.writeln('// ✅ Added missing dispose() method');
          }
          report.writeln(generatedDispose.trim());
          report.writeln('```\n');
        } else {
          report.writeln(
            '> ℹ️ *Could not auto-generate the exact `dispose()` method. Ensure you call the appropriate cleanup method for your controllers.*',
          );
        }
      }
    }

    if (memoryLeaks.isEmpty &&
        logicIssues.isEmpty &&
        code.contains('StatefulWidget') &&
        !code.contains('setState')) {
      report.writeln(
        '\n> **Tip:** Consider converting this to a `StatelessWidget` if you are not managing any local state.',
      );
    }

    return report.toString();
  }
}

class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(auditInputProvider);
    final results = ref.watch(auditResultsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      appBar: AppBar(
        title: Text(
          'INTERNAL AUDIT SYSTEM',
          style: GoogleFonts.orbitron(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00FFD1),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF00FFD1),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _buildDiagnoseButton(ref),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildEditorSection(context, ref, input),
                ),
                VerticalDivider(
                  color: const Color(0xFF00FFD1).withValues(alpha: 0.1),
                  width: 1,
                ),
                Expanded(flex: 1, child: _buildResultsSection(results)),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 400,
                    child: _buildEditorSection(context, ref, input),
                  ),
                  const Divider(color: Color(0xFF00FFD1), height: 1),
                  _buildResultsSection(results),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEditorSection(
    BuildContext context,
    WidgetRef ref,
    String input,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.code_rounded,
                color: Color(0xFF00FFD1),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'SOURCE CODE',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  color: const Color(0xFF00FFD1).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00FFD1).withValues(alpha: 0.2),
                ),
              ),
              child: TextField(
                maxLines: null,
                expands: true,
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: input,
                    selection: TextSelection.fromPosition(
                      TextPosition(offset: input.length),
                    ),
                  ),
                ),
                onChanged: (value) =>
                    ref.read(auditInputProvider.notifier).state = value,
                style: GoogleFonts.firaCode(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(20),
                  border: InputBorder.none,
                  hintText: 'Paste Flutter code for analysis...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(String? results) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.health_and_safety_rounded,
                color: Color(0xFF00FFD1),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'INTERNAL DIAGNOSIS',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  color: const Color(0xFF00FFD1).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF00FFD1).withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00FFD1).withValues(alpha: 0.1),
                ),
              ),
              child: results == null
                  ? Center(
                      child: Text(
                        'READY FOR INTERNAL SCAN...',
                        style: GoogleFonts.orbitron(
                          color: Colors.white24,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: MarkdownBody(
                        data: results,
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.inter(color: Colors.white70),
                          h3: GoogleFonts.orbitron(
                            color: const Color(0xFF00FFD1),
                            fontSize: 18,
                          ),
                          h4: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 14,
                            height: 2,
                          ),
                          blockquote: GoogleFonts.inter(
                            color: const Color(0xFF00FFD1),
                            fontStyle: FontStyle.italic,
                          ),
                          blockquoteDecoration: BoxDecoration(
                            border: const Border(
                              left: BorderSide(
                                color: Color(0xFF00FFD1),
                                width: 4,
                              ),
                            ),
                            color: const Color(
                              0xFF00FFD1,
                            ).withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnoseButton(WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () {
        final input = ref.read(auditInputProvider);
        final report = WidgetDoctorEngine.analyze(input);
        ref.read(auditResultsProvider.notifier).state = report;
      },
      icon: const Icon(Icons.biotech_rounded, size: 18),
      label: Text(
        'RUN INTERNAL DIAGNOSIS',
        style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00FFD1),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

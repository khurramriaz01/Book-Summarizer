import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Summary Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
          background: Colors.grey[100],
          primary: Colors.black,
          secondary: Colors.grey[800]!,
          surface: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto Mono',
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          color: Colors.white.withOpacity(0.8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[800]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const BookSummaryPage(),
    );
  }
}

class BookSummaryPage extends StatefulWidget {
  const BookSummaryPage({super.key});

  @override
  State<BookSummaryPage> createState() => _BookSummaryPageState();
}

class _BookSummaryPageState extends State<BookSummaryPage> {
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  String _summary = '';
  bool _isLoading = false;

  Future<void> _generateSummary() async {
    if (_bookNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the book name'),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _summary = '';
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: GEMINI_API_KEY,
      );

      final prompt = _authorController.text.isEmpty
          ? 'Generate a detailed summary of the book "${_bookNameController.text}". Format the response in markdown with appropriate headings, bullet points, and sections for plot, characters, themes, and key takeaways.'
          : 'Generate a detailed summary of the book "${_bookNameController.text}" by ${_authorController.text}. Format the response in markdown with appropriate headings, bullet points, and sections for plot, characters, themes, and key takeaways.';
      
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _summary = response.text ?? 'No summary generated';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Summary Generator',
          style: TextStyle(
            fontFamily: 'Roboto Mono',
            fontWeight: FontWeight.w500,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Enter Book Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _bookNameController,
                      decoration: const InputDecoration(
                        labelText: 'Book Name',
                        hintText: 'Enter the book name',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Roboto Mono',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _authorController,
                      decoration: const InputDecoration(
                        labelText: 'Author (Optional)',
                        hintText: 'Enter the author name (optional)',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Roboto Mono',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _generateSummary,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Generate Summary',
                              style: TextStyle(
                                fontFamily: 'Roboto Mono',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            if (_summary.isNotEmpty) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Generated Summary',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      MarkdownBody(
                        data: _summary,
                        styleSheet: MarkdownStyleSheet(
                          h1: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Roboto Mono',
                            letterSpacing: -0.5,
                            height: 1.6,
                          ),
                          h2: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto Mono',
                            letterSpacing: -0.5,
                            height: 1.6,
                          ),
                          h3: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto Mono',
                            letterSpacing: -0.5,
                            height: 1.6,
                          ),
                          p: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            fontFamily: 'Roboto Mono',
                          ),
                          listBullet: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            fontFamily: 'Roboto Mono',
                          ),
                          strong: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Roboto Mono',
                          ),
                          em: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[800],
                            fontFamily: 'Roboto Mono',
                          ),
                          blockquote: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                            fontFamily: 'Roboto Mono',
                          ),
                          code: TextStyle(
                            fontSize: 14,
                            backgroundColor: Colors.grey[100],
                            fontFamily: 'Roboto Mono',
                          ),
                          codeblockPadding: const EdgeInsets.all(8),
                          codeblockDecoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          horizontalRuleDecoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bookNameController.dispose();
    _authorController.dispose();
    super.dispose();
  }
}

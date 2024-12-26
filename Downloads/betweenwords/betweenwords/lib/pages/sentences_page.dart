import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Sentence {
  final String number;
  final String english;
  final String chinese;
  final String grammar;
  final List<String> words;
  final Map<String, List<String>> topics;

  Sentence({
    required this.number,
    required this.english,
    required this.chinese,
    required this.grammar,
    required this.words,
    required this.topics,
  });
}

class SentencesPage extends StatefulWidget {
  const SentencesPage({super.key});

  @override
  State<SentencesPage> createState() => _SentencesPageState();
}

class _SentencesPageState extends State<SentencesPage> {
  List<Sentence> _sentences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSentences();
  }

  Future<void> _loadSentences() async {
    try {
      final String content = await rootBundle.loadString('assets/100sentences.md');
      final List<Sentence> sentences = [];
      
      // 按句子分割内容
      final RegExp sentencePattern = RegExp(r'# Sentence (\d+) {[^}]+}\n\n::: hui\n(.*?)\n\n(.*?)\n:::\n\n.*?(?=# Sentence|\Z)', dotAll: true);
      
      final matches = sentencePattern.allMatches(content);
      
      for (final match in matches) {
        final number = match.group(1) ?? '';
        final english = (match.group(2) ?? '').trim();
        final chinese = (match.group(3) ?? '').trim();
        final fullContent = match.group(0) ?? '';
        
        // 提取语法笔记
        final grammarMatch = RegExp(r'## 语法笔记[^#]*?\n\n(.*?)\n\n', dotAll: true).firstMatch(fullContent);
        final grammar = (grammarMatch?.group(1) ?? '').trim();
        
        // 提取核心词表
        final wordsMatch = RegExp(r'## 核心词表.*?\n\n(.*?)(?=## 主题归纳|\Z)', dotAll: true).firstMatch(fullContent);
        final wordsText = (wordsMatch?.group(1) ?? '').trim();
        final words = wordsText.split('\n\n').where((w) => w.isNotEmpty).toList();
        
        // 提取主题归纳
        final topics = <String, List<String>>{};
        
        // 使用简单的字符串分割来提取主题归纳部分
        if (fullContent.contains('## 主题归纳')) {
          final topicsContent = fullContent.split('## 主题归纳').last;
          final topicSections = topicsContent.split('### ').where((s) => s.isNotEmpty);
          
          for (final section in topicSections) {
            final lines = section.split('\n\n');
            if (lines.isNotEmpty) {
              final titleLine = lines.first;
              final title = titleLine.split('{').first.trim();
              
              final words = lines.skip(1)
                  .where((w) => w.isNotEmpty && !w.contains(':::') && !w.contains('!['))
                  .map((w) => w.replaceAll(RegExp(r'\[\[.*?\]\]'), '')) // 移除音标标记
                  .map((w) => w.replaceAll(RegExp(r'\{.*?\}'), '')) // 移除样式标记
                  .map((w) => w.replaceAll(RegExp(r'\*.*?\*'), '')) // 移除斜体标记
                  .toList();
              
              if (words.isNotEmpty) {
                topics[title] = words;
              }
            }
          }
        }
        
        sentences.add(Sentence(
          number: number,
          english: english,
          chinese: chinese,
          grammar: grammar,
          words: words,
          topics: topics,
        ));
      }

      setState(() {
        _sentences = sentences;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading sentences: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('100句记单词'),
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue.shade50,
        foregroundColor: isDark ? Colors.white : Colors.blue.shade900,
      ),
      body: Container(
        color: isDark ? Colors.black : Colors.grey.shade50,
        child: PageView.builder(
          itemCount: _sentences.length,
          itemBuilder: (context, index) {
            final sentence = _sentences[index];
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                color: isDark ? Colors.grey[850] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sentence ${sentence.number}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isDark ? Colors.blue[200] : Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        sentence.english,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sentence.chinese,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '语法笔记',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.blue[200] : Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sentence.grammar,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '核心词表',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.blue[200] : Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...sentence.words.map((word) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          word,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      )).toList(),
                      const SizedBox(height: 24),
                      ...sentence.topics.entries.map((topic) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.key,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isDark ? Colors.blue[200] : Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...topic.value.map((word) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              word,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          )).toList(),
                          const SizedBox(height: 16),
                        ],
                      )).toList(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 
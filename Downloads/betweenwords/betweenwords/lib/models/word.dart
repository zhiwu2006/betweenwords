class Word {
  final String word;
  final String phonetic;
  final String type;
  final String meaning;
  final String unit;
  final String category;
  final String subcategory;
  final String example;
  bool isLearned;
  bool isExpanded = false;

  Word({
    required this.word,
    required this.phonetic, 
    required this.type,
    required this.meaning,
    required this.unit,
    required this.category,
    required this.subcategory,
    this.example = '',
    this.isLearned = false,
  });

  String generateExample() {
    // 这里是一些预设的例句模板，可以根据需要扩充
    final templates = [
      "The professor delivered an insightful lecture on how to WORD in academic writing.",
      "Recent research has shown that WORD plays a crucial role in sustainable development.",
      "Students are encouraged to WORD their ideas clearly in the dissertation.",
      "The symposium focused on various ways to WORD in contemporary society.",
      "Many scholars argue that we must WORD to address global challenges.",
      "The study reveals a significant correlation between WORD and academic success.",
      "It is essential to WORD when conducting scientific research.",
      "The article examines how WORD affects modern educational practices.",
      "Experts emphasize the importance of WORD in professional development.",
      "The conference highlighted new approaches to WORD in the digital age."
    ];
    
    // 根据单词选择合适的模板
    var template = templates[word.length % templates.length];
    
    // 根据词性调整单词在句子中的形式
    var wordInSentence = word;
    if (type.contains('v.')) {
      // 如果是动词，直接使用原形
      wordInSentence = word;
    } else if (type.contains('n.')) {
      // 如果是名词，可能需要加冠词
      wordInSentence = "the " + word;
    } else if (type.contains('adj.')) {
      // 如果是形容词，可能需要调整句子结构
      template = "The results were particularly WORD in their implications.";
    }
    
    return template.replaceAll('WORD', wordInSentence);
  }

  factory Word.fromJson(String str, String unit, String category, String subcategory) {
    try {
      // 处理特殊字符，跳过类别标识符（如①、②等）
      if (str.startsWith('①') || str.startsWith('②') || str.startsWith('③')) {
        return Word(
          word: '',
          phonetic: '',
          type: '',
          meaning: str,
          unit: unit,
          category: category,
          subcategory: subcategory,
          example: '',
        );
      }

      // 解析形如 "word 【phonetic】 type meaning" 的字符串
      final regex = RegExp(r'(.*?)\s+【(.*?)】\s+(.*?)\s+(.*)');
      final match = regex.firstMatch(str);
    
      if (match == null) {
        // 如果不匹配标准格式，将整个字符串作为meaning
        return Word(
          word: '',
          phonetic: '',
          type: '',
          meaning: str,
          unit: unit,
          category: category,
          subcategory: subcategory,
          example: '',
        );
      }

      final word = match.group(1)?.trim() ?? '';
      final phonetic = match.group(2)?.trim() ?? '';
      final type = match.group(3)?.trim() ?? '';
      final meaning = match.group(4)?.trim() ?? '';

      final wordObj = Word(
        word: word,
        phonetic: phonetic,
        type: type,
        meaning: meaning,
        unit: unit,
        category: category,
        subcategory: subcategory,
        example: '',  // 例句将在构造函数中生成
      );

      return wordObj;
    } catch (e) {
      print('解析单词时出错: $str');
      print('错误: $e');
      return Word(
        word: '',
        phonetic: '',
        type: '',
        meaning: str,
        unit: unit,
        category: category,
        subcategory: subcategory,
        example: '',
      );
    }
  }
} 
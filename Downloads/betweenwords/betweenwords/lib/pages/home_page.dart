import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import '../models/word.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Word> words = [];
  
  @override
  void initState() {
    super.initState();
    loadWords();
  }

  Future<void> loadWords() async {
    try {
      print('开始加载words.json');
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/words.json');
      print('成功读取JSON文件，内容长度: ${jsonString.length}');
      print('JSON内容预览: ${jsonString.substring(0, min(200, jsonString.length))}');
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      print('成功解析JSON数据，包含 ${jsonData.length} 个单元');
      
      // 解析JSON数据
      List<Word> loadedWords = [];
      jsonData.forEach((unit, content) {
        print('正在处理单元: $unit');
        if (content is Map) {
          content.forEach((category, sections) {
            print('  处理类别: $category');
            if (sections is Map) {
              sections.forEach((subcategory, wordList) {
                print('    处理子类别: $subcategory');
                if (wordList is List) {
                  try {
                    final newWords = wordList.map((w) => Word.fromJson(
                      w.toString(),
                      unit,
                      category,
                      subcategory,
                    )).toList();
                    print('    成功解析 ${newWords.length} 个单词');
                    loadedWords.addAll(newWords);
                  } catch (e) {
                    print('    解析单词列表时出错: $e');
                    print('    问题数据: $wordList');
                  }
                } else {
                  print('    警告: wordList不是List类型，而是 ${wordList.runtimeType}');
                }
              });
            } else if (sections is List) {
              try {
                final newWords = sections.map((w) => Word.fromJson(
                  w.toString(),
                  unit,
                  category,
                  '',
                )).toList();
                print('  直接解析单词列表，成功解析 ${newWords.length} 个单词');
                loadedWords.addAll(newWords);
              } catch (e) {
                print('  解析单词列表时出错: $e');
                print('  问题数据: $sections');
              }
            } else {
              print('  警告: sections既不是Map也不是List，而是 ${sections.runtimeType}');
            }
          });
        } else {
          print('警告: content不是Map类型，而是 ${content.runtimeType}');
        }
      });

      print('总共加载了 ${loadedWords.length} 个单词');
      setState(() {
        words = loadedWords;
      });
      
      if (words.isNotEmpty) {
        print('第一个单词示例: ${words[0].word} ${words[0].phonetic} ${words[0].type} ${words[0].meaning}');
      } else {
        print('警告: 没有加载到任何单词');
      }
    } catch (e, stackTrace) {
      print('加载单词时发生错误: $e');
      print('错误堆栈: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('单词列表'),
      ),
      body: ListView.builder(
        itemCount: words.length,
        itemBuilder: (context, index) {
          final word = words[index];
          return ListTile(
            title: Text(word.word),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${word.phonetic} ${word.type}'),
                Text(word.meaning),
                Text('${word.unit} - ${word.category} - ${word.subcategory}'),
              ],
            ),
          );
        },
      ),
    );
  }
} 
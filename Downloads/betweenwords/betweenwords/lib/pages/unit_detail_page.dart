import 'package:flutter/material.dart';
import '../models/word.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import '../providers/study_state_provider.dart';
import '../utils/app_theme.dart';
import 'unfamiliar_words_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class UnitDetailPage extends StatefulWidget {
  final String unitName;
  final Map<String, dynamic> unitData;

  UnitDetailPage({
    required this.unitName,
    required this.unitData,
  });

  @override
  _UnitDetailPageState createState() => _UnitDetailPageState();
}

class CategoryData {
  final String name;
  final Map<String, List<Word>> subcategories;
  
  CategoryData(this.name, this.subcategories);
}

enum TtsState { playing, stopped }

class _UnitDetailPageState extends State<UnitDetailPage> {
  List<CategoryData> categories = [];
  late FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;
  String? _currentWord;
  bool isLoading = true;
  
  get isPlaying => ttsState == TtsState.playing;

  @override
  void initState() {
    super.initState();
    initTts();
    _processUnitData();
  }

  initTts() async {
    flutterTts = FlutterTts();

    if (Platform.isAndroid) {
      // 强制使用 Google TTS
      var engines = await flutterTts.getEngines;
      print('Available TTS engines: $engines');
      
      if (engines.contains('com.google.android.tts')) {
        await flutterTts.setEngine('com.google.android.tts');
        // 设置美式英语声音
        var voices = await flutterTts.getVoices;
        print('Android voices: $voices');
        
        // 查找最佳的美式英语声音
        for (var voice in voices) {
          String name = (voice['name'] ?? '').toString();
          
          // 尝试找到 Google 的高质量美式英语声音
          if (name.contains('en-us-x-sfg')) {
            print('Selected high quality US voice: $name');
            await flutterTts.setVoice({"name": name, "locale": "en-US"});
            break;
          }
        }
      }
    } else if (Platform.isIOS) {
      await flutterTts.setSharedInstance(true);
      var voices = await flutterTts.getVoices;
      print('iOS voices: $voices');
      
      // 在 iOS 上使用 Samantha 声音
      await flutterTts.setVoice({
        "name": "Samantha",
        "locale": "en-US"
      });
    }

    // 基本设置
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);  // 标准音高
    await flutterTts.setVolume(1.0); // 最大音量
    await flutterTts.setSpeechRate(0.35);  // 稍慢一点，更清晰
    await flutterTts.setQueueMode(1);  // 队列模式
    
    // 打印当前设置
    print('Current voice: ${await flutterTts.getVoices}');
    print('Current language: ${await flutterTts.getLanguages}');
    
    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
        _currentWord = null;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("Error: $msg");
        ttsState = TtsState.stopped;
        _currentWord = null;
      });
    });
  }

  Future<void> _speak(String text) async {
    if (_currentWord == text && isPlaying) {
      await _stop();
      return;
    }

    if (isPlaying) {
      await _stop();
    }

    setState(() {
      _currentWord = text;
    });

    try {
      // 在单词前后添加空格，确保清晰的发音
      var result = await flutterTts.speak("  $text  ");
      print("Speaking word: $text, result: $result");
      
      if (result != 1) {
        print('TTS Error: Failed to speak');
        setState(() {
          ttsState = TtsState.stopped;
          _currentWord = null;
        });
      }
    } catch (e) {
      print('TTS Error: $e');
      setState(() {
        ttsState = TtsState.stopped;
        _currentWord = null;
      });
    }
  }

  Future<void> _stop() async {
    var result = await flutterTts.stop();
    setState(() {
      ttsState = TtsState.stopped;
      _currentWord = null;
    });
  }

  void _processUnitData() {
    setState(() => isLoading = true);
    List<CategoryData> tempCategories = [];
    
    widget.unitData.forEach((category, sections) {
      if (sections is Map) {
        Map<String, List<Word>> subcategories = {};
        
        sections.forEach((subcategory, wordList) {
          if (wordList is List) {
            List<Word> words = wordList.map((w) => Word.fromJson(
              w.toString(),
              widget.unitName,
              category,
              subcategory,
            )).toList();
            
            if (words.isNotEmpty) {
              subcategories[subcategory] = words;
            }
          }
        });
        
        if (subcategories.isNotEmpty) {
          tempCategories.add(CategoryData(category, subcategories));
        }
      }
    });

    setState(() {
      categories = tempCategories;
      isLoading = false;
    });
  }

  Widget _buildLoadingShimmer() {
    return AnimationLimiter(
      child: ListView.builder(
        itemCount: 5,
        padding: EdgeInsets.all(16.w),
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studyState = Provider.of<StudyStateProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(MdiIcons.chevronLeft),
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      widget.unitName,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(MdiIcons.bookshelf),
                    onPressed: () => Get.to(() => UnfamiliarWordsPage()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                ? _buildLoadingShimmer()
                : AnimationLimiter(
                    child: ListView.builder(
                      itemCount: categories.length,
                      padding: EdgeInsets.all(16.w),
                      itemBuilder: (context, categoryIndex) {
                        final category = categories[categoryIndex];
                        
                        return AnimationConfiguration.staggeredList(
                          position: categoryIndex,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 16.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    initiallyExpanded: category.name == studyState.currentState?.categoryName,
                                    onExpansionChanged: (expanded) {
                                      if (expanded) {
                                        studyState.updateState(
                                          unitName: widget.unitName,
                                          categoryName: category.name,
                                          subcategoryName: '',
                                        );
                                      }
                                    },
                                    leading: Icon(
                                      MdiIcons.sprout,
                                      color: Colors.blue[700],
                                    ),
                                    title: Container(
                                      padding: EdgeInsets.symmetric(vertical: 8.h),
                                      child: Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ),
                                    trailing: Icon(
                                      studyState.currentState?.categoryName == category.name
                                          ? MdiIcons.chevronUp
                                          : MdiIcons.chevronDown,
                                      color: Colors.blue[700],
                                    ),
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: category.subcategories.length,
                                        itemBuilder: (context, subcategoryIndex) {
                                          final subcategoryName = category.subcategories.keys.elementAt(subcategoryIndex);
                                          final words = category.subcategories[subcategoryName]!;
                                          
                                          return Container(
                                            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.circular(12.r),
                                            ),
                                            child: Theme(
                                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                              child: ExpansionTile(
                                                initiallyExpanded: subcategoryName == studyState.currentState?.subcategoryName &&
                                                                 category.name == studyState.currentState?.categoryName,
                                                onExpansionChanged: (expanded) {
                                                  if (expanded) {
                                                    studyState.updateState(
                                                      unitName: widget.unitName,
                                                      categoryName: category.name,
                                                      subcategoryName: subcategoryName,
                                                    );
                                                  }
                                                },
                                                leading: Icon(
                                                  MdiIcons.formatListText,
                                                  color: Colors.blue[600],
                                                ),
                                                title: Text(
                                                  subcategoryName,
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: Colors.blue[600],
                                                  ),
                                                ),
                                                trailing: Icon(
                                                  studyState.currentState?.subcategoryName == subcategoryName &&
                                                  studyState.currentState?.categoryName == category.name
                                                      ? MdiIcons.chevronUp
                                                      : MdiIcons.chevronDown,
                                                  color: Colors.blue[600],
                                                ),
                                                children: [
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    physics: NeverScrollableScrollPhysics(),
                                                    itemCount: words.length,
                                                    itemBuilder: (context, wordIndex) {
                                                      final word = words[wordIndex];
                                                      if (word.word.isEmpty || studyState.isWordDeleted(word.word)) {
                                                        return SizedBox.shrink();
                                                      }
                                                      
                                                      final isCurrentlyPlaying = _currentWord == word.word;
                                                      
                                                      return Dismissible(
                                                        key: Key('${word.word}_${word.unit}_${word.category}_${word.subcategory}'),
                                                        direction: DismissDirection.startToEnd,
                                                        background: Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.blue[100],
                                                            borderRadius: BorderRadius.circular(8.r),
                                                          ),
                                                          alignment: Alignment.centerLeft,
                                                          padding: EdgeInsets.only(left: 20.w),
                                                          child: Icon(MdiIcons.bookPlus, color: Colors.blue),
                                                        ),
                                                        confirmDismiss: (direction) async {
                                                          await studyState.toggleReviewWord(word.word);
                                                          Get.snackbar(
                                                            '提示',
                                                            '已添加到不熟悉单词列表',
                                                            snackPosition: SnackPosition.BOTTOM,
                                                          );
                                                          return false; // 不真正移除组件
                                                        },
                                                        child: Container(
                                                          margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(8.r),
                                                            border: Border.all(
                                                              color: Colors.blue.withOpacity(0.2),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Theme(
                                                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                                            child: ExpansionTile(
                                                              initiallyExpanded: false,
                                                              onExpansionChanged: (expanded) {
                                                                setState(() {
                                                                  word.isExpanded = expanded;
                                                                });
                                                              },
                                                              trailing: Icon(
                                                                word.isExpanded
                                                                    ? MdiIcons.chevronUp
                                                                    : MdiIcons.chevronDown,
                                                                color: Colors.grey[600],
                                                              ),
                                                              title: GestureDetector(
                                                                onTap: () => _speak(word.word),
                                                                onDoubleTap: () => studyState.toggleReviewWord(word.word),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      MdiIcons.volumeHigh,
                                                                      color: isCurrentlyPlaying ? Colors.blue : Colors.grey,
                                                                      size: 20.w,
                                                                    ),
                                                                    SizedBox(width: 8.w),
                                                                    Flexible(
                                                                      child: Text(
                                                                        word.word,
                                                                        style: TextStyle(
                                                                          fontSize: 16.sp,
                                                                          color: isCurrentlyPlaying ? Colors.blue : Colors.black87,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets.all(16.w),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        '音标: [${word.phonetic}]',
                                                                        style: TextStyle(
                                                                          fontSize: 14.sp,
                                                                          color: Colors.grey[700],
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 8.h),
                                                                      Text(
                                                                        '词性: ${word.type}',
                                                                        style: TextStyle(
                                                                          fontSize: 14.sp,
                                                                          color: Colors.grey[700],
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 8.h),
                                                                      Text(
                                                                        '释义: ${word.meaning}',
                                                                        style: TextStyle(
                                                                          fontSize: 14.sp,
                                                                          color: Colors.grey[700],
                                                                        ),
                                                                      ),
                                                                      if (word.example.isNotEmpty) ...[
                                                                        SizedBox(height: 8.h),
                                                                        Container(
                                                                          padding: EdgeInsets.all(12.w),
                                                                          decoration: BoxDecoration(
                                                                            color: Colors.grey[50],
                                                                            borderRadius: BorderRadius.circular(8.r),
                                                                          ),
                                                                          child: Text(
                                                                            '例句: ${word.example}',
                                                                            style: TextStyle(
                                                                              fontSize: 14.sp,
                                                                              color: Colors.grey[700],
                                                                              fontStyle: FontStyle.italic,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
} 
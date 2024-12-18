import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_state_provider.dart';
import '../utils/app_theme.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class UnfamiliarWordsPage extends StatefulWidget {
  @override
  _UnfamiliarWordsPageState createState() => _UnfamiliarWordsPageState();
}

class _UnfamiliarWordsPageState extends State<UnfamiliarWordsPage> {
  late FlutterTts flutterTts;
  String? _currentWord;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    initTts();
  }

  initTts() async {
    flutterTts = FlutterTts();
    if (Platform.isAndroid) {
      var engines = await flutterTts.getEngines;
      if (engines.contains('com.google.android.tts')) {
        await flutterTts.setEngine('com.google.android.tts');
        var voices = await flutterTts.getVoices;
        for (var voice in voices) {
          String name = (voice['name'] ?? '').toString();
          if (name.contains('en-us-x-sfg')) {
            await flutterTts.setVoice({"name": name, "locale": "en-US"});
            break;
          }
        }
      }
    } else if (Platform.isIOS) {
      await flutterTts.setSharedInstance(true);
      await flutterTts.setVoice({"name": "Samantha", "locale": "en-US"});
    }

    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.setQueueMode(1);
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
      isPlaying = true;
    });

    try {
      var result = await flutterTts.speak("  $text  ");
      if (result != 1) {
        setState(() {
          isPlaying = false;
          _currentWord = null;
        });
      }
    } catch (e) {
      setState(() {
        isPlaying = false;
        _currentWord = null;
      });
    }
  }

  Future<void> _stop() async {
    await flutterTts.stop();
    setState(() {
      isPlaying = false;
      _currentWord = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      '不熟悉的单词',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<StudyStateProvider>(
                builder: (context, studyState, child) {
                  final reviewWords = studyState.reviewWords;
                  
                  if (reviewWords.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            MdiIcons.bookshelf,
                            size: 64.w,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            '还没有添加不熟悉的单词',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return AnimationLimiter(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: reviewWords.length,
                      itemBuilder: (context, index) {
                        final word = reviewWords.elementAt(index);
                        final isCurrentlyPlaying = _currentWord == word;

                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16.w),
                                  leading: GestureDetector(
                                    onTap: () => _speak(word),
                                    child: Container(
                                      width: 40.w,
                                      height: 40.w,
                                      decoration: BoxDecoration(
                                        color: isCurrentlyPlaying ? Colors.blue : Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        MdiIcons.volumeHigh,
                                        color: isCurrentlyPlaying ? Colors.white : Colors.grey,
                                        size: 20.w,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    word,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: isCurrentlyPlaying ? Colors.blue : Colors.black87,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      MdiIcons.minusCircleOutline,
                                      color: Colors.red[300],
                                    ),
                                    onPressed: () {
                                      studyState.toggleReviewWord(word);
                                      Get.snackbar(
                                        '提示',
                                        '已从不熟悉单词列表中移除',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
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
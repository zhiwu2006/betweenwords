import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'unit_detail_page.dart';

class UnitListPage extends StatefulWidget {
  @override
  _UnitListPageState createState() => _UnitListPageState();
}

class _UnitListPageState extends State<UnitListPage> {
  Map<String, dynamic> units = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUnits();
  }

  Future<void> loadUnits() async {
    try {
      setState(() => isLoading = true);
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/words.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      setState(() {
        units = jsonData;
        isLoading = false;
      });
    } catch (e) {
      print('加载单元列表时出错: $e');
      setState(() => isLoading = false);
      Get.snackbar(
        '错误',
        '加载单元列表失败',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Widget _buildLoadingShimmer() {
    return AnimationLimiter(
      child: ListView.builder(
        itemCount: 10,
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
                    height: 80.h,
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '单词学习',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(MdiIcons.refresh),
                    onPressed: loadUnits,
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                ? _buildLoadingShimmer()
                : RefreshIndicator(
                    onRefresh: loadUnits,
                    child: AnimationLimiter(
                      child: ListView.builder(
                        itemCount: units.length,
                        padding: EdgeInsets.all(16.w),
                        itemBuilder: (context, index) {
                          final unitName = units.keys.elementAt(index);
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 16.h),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade400,
                                        Colors.blue.shade600,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Get.to(
                                          () => UnitDetailPage(
                                            unitName: unitName,
                                            unitData: units[unitName],
                                          ),
                                          transition: Transition.rightToLeft,
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Container(
                                        padding: EdgeInsets.all(20.w),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40.w,
                                              height: 40.w,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12.r),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  unitName.substring(5, 7),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 16.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    unitName,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    '${(units[unitName] as Map).length} 个分类',
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.8),
                                                      fontSize: 14.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              MdiIcons.chevronRight,
                                              color: Colors.white,
                                              size: 20.w,
                                            ),
                                          ],
                                        ),
                                      ),
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
            ),
          ],
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/custom_widgets/custom_module.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/provider/module_provider/subject_provider.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:geography_geyser/views/modules/select_time.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ModuleHomeScreen extends StatefulWidget {
  final bool hideback;
  const ModuleHomeScreen({super.key, this.hideback = false});

  @override
  State<ModuleHomeScreen> createState() => _ModuleHomeScreenState();
}

class _ModuleHomeScreenState extends State<ModuleHomeScreen> {
  int? selectedIndex;
  bool _hasInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        leading: widget.hideback
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePageScreen(),
                    ),
                    (route) => false,
                  );
                },
              )
            : null,
        title: Text(
          AppStrings.selectModuleTitle,
          style: FontManager.boldHeading(color: AppColors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<SubjectProvider>(
          builder: (context, provider, _) {
            final isLoading = provider.isLoading;
            final subjects = provider.subjects;
            final errorMessage = provider.errorMessage;

            // ✅ Initialize only once
            if (!_hasInitialized &&
                subjects.isEmpty &&
                !isLoading &&
                errorMessage == null) {
              _hasInitialized = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  provider.fetchSubjects().catchError((error) {
                    AppLogger.error('Failed to load modules', error);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLogger.getSafeErrorMessage(error.toString()),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  });
                }
              });
            }

            // Loading state
            if (isLoading && subjects.isEmpty) {
              return _buildShimmerLoading();
            }

            // Error state
            if (errorMessage != null && subjects.isEmpty && !isLoading) {
              return _buildErrorState(errorMessage, provider);
            }

            // Empty list state (no error, just no data)
            if (subjects.isEmpty && !isLoading) {
              return _buildEmptyState(provider);
            }

            // Final UI: Use ListView.builder for better performance
            // Add synoptic as first item when data is loaded
            final hasData = subjects.isNotEmpty && !isLoading;
            final totalItems = hasData ? subjects.length + 1 : subjects.length;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: totalItems,
              // ✅ Add cacheExtent for better scrolling performance
              cacheExtent: 500,
              itemBuilder: (context, index) {
                // Show synoptic as last item when data is loaded
                if (hasData && index == totalItems - 1) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: CustomModule(
                      key: const ValueKey('synoptic'),
                      text: 'Synoptic'.toUpperCase(),
                      isSelected: selectedIndex == index,
                      textStyle: FontManager.headerSubtitleText(
                        fontSize: 20,
                        color:
                            AppColors.buttonColor, // Custom color for synoptic
                      ),
                      onPressed: () {
                        selectedIndex = index;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SelectTime_screen(moduleId: 'synoptic'),
                          ),
                        );
                      },
                    ),
                  );
                }

                // Subjects are shown before synoptic (no index adjustment needed)
                final subject = subjects[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: CustomModule(
                    key: ValueKey(subject.id),
                    text: subject.moduleName,
                    isSelected: selectedIndex == index,
                    onPressed: () {
                      // ✅ Don't call setState if navigating immediately
                      selectedIndex = index;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SelectTime_screen(moduleId: subject.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Initial shimmer loading
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: _buildShimmerItem(),
        );
      },
    );
  }

  /// Shimmer item design
  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Error state widget
  Widget _buildErrorState(String errorMessage, SubjectProvider provider) {
    final isNoInternet =
        errorMessage.toLowerCase().contains('internet') ||
        errorMessage.toLowerCase().contains('connection');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isNoInternet ? Icons.wifi_off : Icons.error_outline,
              size: 64,
              color: Colors.grey[400]!,
            ),
            AppSpacing.h16,
            Text(
              "No modules available for now",
              textAlign: TextAlign.center,
              style: FontManager.headerSubtitleText(
                fontSize: 16,
                color: Colors.grey[600]!,
              ),
            ),
            AppSpacing.h24,
            CustomLoginButton(
              text: 'Retry',
              onPressed: () => provider.refreshSubjects(),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state widget (no data from server)
  Widget _buildEmptyState(SubjectProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]!),
            AppSpacing.h16,
            Text(
              'No modules available',
              textAlign: TextAlign.center,
              style: FontManager.headerSubtitleText(
                fontSize: 18,
                color: Colors.grey[600]!,
              ),
            ),
            AppSpacing.h8,
            Text(
              'Please check back later',
              textAlign: TextAlign.center,
              style: FontManager.bodyText(color: Colors.grey[500]!),
            ),
            AppSpacing.h24,
            CustomLoginButton(
              text: 'Refresh',
              onPressed: () => provider.refreshSubjects(),
            ),
          ],
        ),
      ),
    );
  }
}

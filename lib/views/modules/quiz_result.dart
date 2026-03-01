import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/custom_widgets/custom_module.dart';
import 'package:geography_geyser/provider/module_provider/quiz_finish_provider.dart';
import 'package:geography_geyser/provider/module_provider/quiz_provider.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:geography_geyser/views/modules/module_home.dart';
import 'package:geography_geyser/views/modules/select_time.dart';
import 'package:provider/provider.dart';

class QuizResult_Screen extends StatefulWidget {
  const QuizResult_Screen({super.key});

  @override
  State<QuizResult_Screen> createState() => _QuizResult_ScreenState();
}

class _QuizResult_ScreenState extends State<QuizResult_Screen> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeQuizData();
  }

  Future<void> _initializeQuizData() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final quizFinishProvider = Provider.of<QuizFinishProvider>(
        context,
        listen: false,
      );
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);

      // If quiz finish data is not available and not currently loading, try to fetch it
      // This is a fallback in case finishQuiz wasn't called before navigation
      if (quizFinishProvider.quizFinishData == null &&
          !quizFinishProvider.isLoading) {
        // Get quiz data from QuizProvider
        final quizId = quizProvider.quizData?.quizId;
        final questions = quizProvider.quizData?.questions ?? [];

        if (quizId != null && quizId.isNotEmpty && questions.isNotEmpty) {
          // Calculate attempted from questions length
          // Note: This is a fallback - correct answers will be 0 since we don't have that data
          // In normal flow, finishQuiz should be called before navigation
          final attempted = questions.length;
          final correctAnswers = 0; // Default fallback value

          await quizFinishProvider.finishQuiz(
            quizId,
            correctAnswers,
            attempted,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Consumer<QuizFinishProvider>(
          builder: (context, provider, child) {
            // Loading state
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: AppColors.red,
                    ),
                    AppSpacing.h16,
                    Text(
                      AppLogger.getSafeErrorMessage(provider.errorMessage!),
                      style: FontManager.bodyText(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Get quiz finish data
            final quizData = provider.quizFinishData;

            // If no data, show default/fallback UI
            if (quizData == null) {
              return _buildFallbackUI(context);
            }

            // Calculate values from API data
            // Use attempted questions from provider instead of totalQuestions from API
            final attempted =
                provider.attemptedQuestions ?? quizData.totalQuestions;
            final correctAnswers = quizData.correctAnswers;
            final totalQuestions = attempted; // Use attempted as totalQuestions
            final incorrectAnswers = totalQuestions - correctAnswers;
            final score = quizData.score;
            final grade = quizData.grade;
            final xpGained = quizData.xpGained;
            final attendAnotherQuiz = quizData.attendAnotherQuiz;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Title
                  Text(
                    AppStrings.quizCompleteTitle,
                    style: FontManager.bigTitle(
                      fontSize: 28,
                      color: AppColors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.h24,

                  // Result Summary Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        buildResultRow(
                          icon: Icons.check_circle,
                          iconColor: AppColors.green,
                          label: AppStrings.correctLabel,
                          value: correctAnswers.toString(),
                          valueColor: AppColors.green,
                        ),
                        buildResultRow(
                          icon: Icons.cancel,
                          iconColor: AppColors.red,
                          label: AppStrings.incorrectLabel,
                          value: incorrectAnswers.toString(),
                          valueColor: AppColors.red,
                        ),
                        buildResultRow(
                          icon: Icons.emoji_events,
                          iconColor: AppColors.yellow,
                          label: AppStrings.scoreLabel,
                          value: '$score',
                          valueColor: AppColors.yellow,
                        ),
                        buildResultRow(
                          icon: Icons.star,
                          iconColor: AppColors.yellow,
                          label: AppStrings.gradeLabel,
                          value: grade,
                          valueColor: AppColors.yellow,
                        ),
                        AppSpacing.h8,
                        buildXPGainedRow(
                          labelText: AppStrings.xpGainedLabel,
                          valueText: '+$xpGained XP',
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h32,

                  // Attend another Quiz section
                  if (attendAnotherQuiz.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppStrings.attendAnotherQuizInstruction,
                        style: FontManager.boldHeading(
                          fontSize: 18,
                          color: AppColors.grey4B,
                        ),
                      ),
                    ),
                    AppSpacing.h16,

                    // Dynamic quiz topic options from API
                    ...attendAnotherQuiz.asMap().entries.map((entry) {
                      final index = entry.key;
                      final quiz = entry.value;
                      final isLast = index == attendAnotherQuiz.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.blueTransparent,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomModule(
                            text: quiz.moduleName,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SelectTime_screen(moduleId: quiz.id),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                    AppSpacing.h32,
                  ],

                  // Bottom action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ModuleHomeScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            AppStrings.retryQuizButton,
                            style: FontManager.buttonText().copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.w16,
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePageScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            AppStrings.returnMenuButton,
                            style: FontManager.buttonText().copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFallbackUI(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Text(
            AppStrings.quizCompleteTitle,
            style: FontManager.bigTitle(fontSize: 28, color: AppColors.blue),
            textAlign: TextAlign.center,
          ),
          AppSpacing.h24,
          Text('No quiz data available', style: FontManager.bodyText()),
          AppSpacing.h32,
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModuleHomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    AppStrings.retryQuizButton,
                    style: FontManager.buttonText().copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              AppSpacing.w16,
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePageScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    AppStrings.returnMenuButton,
                    style: FontManager.buttonText().copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildResultRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.white, size: 20.sp),
            ),
            AppSpacing.w16,
            Expanded(
              child: Text(
                label,
                style: FontManager.generalText(
                  fontSize: 20,
                ).copyWith(color: iconColor, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              value,
              style: FontManager.boldHeading(fontSize: 18, color: valueColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildXPGainedRow({
    required String labelText,
    required String valueText,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.flash_on, color: AppColors.white, size: 20.sp),
          ),
          AppSpacing.w16,
          Expanded(
            child: Text(
              labelText,
              // AppStrings.xpGainedLabel,
              style: FontManager.generalText(
                fontSize: 16,
              ).copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            valueText,
            // AppStrings.xpGainedValue,
            style: FontManager.boldHeading(
              fontSize: 18,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget CustomQuizTopicOption(String topic) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Text(
        topic,
        style: FontManager.bodyText().copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

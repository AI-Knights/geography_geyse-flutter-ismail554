import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/core/sound_helper.dart';
import 'package:geography_geyser/models/quiz_model.dart';
import 'package:geography_geyser/provider/module_provider/quiz_provider.dart';
import 'package:geography_geyser/provider/module_provider/quiz_finish_provider.dart';
import 'package:geography_geyser/provider/module_provider/delete_xp_provider.dart';
import 'package:geography_geyser/views/modules/quiz_result.dart';
import 'package:geography_geyser/views/modules/time_out_dialog.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {
  final int? totalQuestions;
  final int? timeInMinutes;
  final String? moduleId;

  const QuizScreen({
    super.key,
    this.totalQuestions,
    this.timeInMinutes,
    this.moduleId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Quiz state variables
  int currentQuestionIndex = 0;
  late int totalQuestions;
  late int timeRemaining;
  int? selectedAnswerIndex;
  Timer? _timer;
  bool showAnswerFeedback = false;
  bool isCorrectAnswer = false;
  int correctAnswersCount = 0; // Track total correct answers
  bool _isSoundEnabled = true; // Sound state

  @override
  void initState() {
    super.initState();
    // Initialize sound state from SoundHelper
    _isSoundEnabled = SoundHelper.isSoundEnabled;
    // Initialize total questions and time based on selected options
    _initializeQuizSettings();

    // Fetch quiz data from API
    if (widget.moduleId != null && widget.moduleId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final quizProvider = Provider.of<QuizProvider>(context, listen: false);

        // Use synoptic API if moduleId is 'synoptic'
        final future = widget.moduleId == 'synoptic'
            ? quizProvider.fetchSynopticQuiz()
            : quizProvider.fetchQuiz(widget.moduleId!);

        future.then((_) {
          // Start timer only after quiz is loaded
          if (mounted) {
            startTimer();
          }
        });
      });
    } else {
      // If no moduleId, start timer anyway (fallback)
      startTimer();
    }
  }

  void _initializeQuizSettings() {
    // Set total questions from passed value
    totalQuestions = widget.totalQuestions ?? 10; // Default value

    // Set time from passed value (convert minutes to seconds)
    final minutes = widget.timeInMinutes ?? 5; // Default 5 minutes
    timeRemaining = minutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        timer.cancel();
        // Handle time up - show timeout dialog
        if (mounted) {
          TimeoutDialog.show(
            context,
            onOkPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Finish quiz with current correct answers count before navigating
              _finishQuizAndNavigate();
            },
          );
        }
      }
    });
  }

  String get formattedTime {
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _finishQuizAndNavigate() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final quizFinishProvider = Provider.of<QuizFinishProvider>(
      context,
      listen: false,
    );

    // Get quiz_id from quiz data
    final quizId = quizProvider.quizData?.quizId;

    if (quizId != null && quizId.isNotEmpty) {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );
      }

      // Calculate attempted questions (currentQuestionIndex is 0-based, so add 1)
      final attemptedQuestions = currentQuestionIndex + 1;

      // Call finish quiz API
      await quizFinishProvider.finishQuiz(
        quizId,
        correctAnswersCount,
        attemptedQuestions,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to result screen regardless of API success/failure
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => QuizResult_Screen()),
          (route) => false,
        );
      }
    } else {
      // If no quiz_id, navigate directly to result screen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => QuizResult_Screen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _deleteXpAndNavigate() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final deleteXpProvider = Provider.of<DeleteXpProvider>(
      context,
      listen: false,
    );
    final quizFinishProvider = Provider.of<QuizFinishProvider>(
      context,
      listen: false,
    );

    // Get quiz_id from quiz data
    final quizId = quizProvider.quizData?.quizId;

    if (quizId != null && quizId.isNotEmpty) {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );
      }

      // Call delete XP API
      await deleteXpProvider.deleteXp(quizId);

      // Calculate attempted questions (currentQuestionIndex is 0-based, so add 1)
      final attemptedQuestions = currentQuestionIndex + 1;

      // Call finish quiz API to get quiz result data
      await quizFinishProvider.finishQuiz(
        quizId,
        correctAnswersCount,
        attemptedQuestions,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to result screen regardless of API success/failure
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => QuizResult_Screen()),
          (route) => false,
        );
      }
    } else {
      // If no quiz_id, navigate directly to result screen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => QuizResult_Screen()),
          (route) => false,
        );
      }
    }
  }

  void handleAnswerSelection(int selectedIndex, QuestionModel question) {
    if (showAnswerFeedback) return; // Prevent multiple selections

    final isCorrect = selectedIndex == question.correctAnswerIndex;
    if (isCorrect) {
      SoundHelper.playCorrect();
    } else {
      SoundHelper.playWrong();
    }

    setState(() {
      selectedAnswerIndex = selectedIndex;
      showAnswerFeedback = true;
      isCorrectAnswer = isCorrect;

      // Increment correct answers count if answer is correct
      if (isCorrect) {
        correctAnswersCount++;
      }
    });

    // Auto-progress after 2 seconds
    Timer(Duration(seconds: 2), () {
      if (mounted) {
        final provider = Provider.of<QuizProvider>(context, listen: false);
        final questions = provider.quizData?.questions ?? [];
        final actualTotalQuestions = questions.length;

        if (currentQuestionIndex < actualTotalQuestions - 1) {
          setState(() {
            currentQuestionIndex++;
            selectedAnswerIndex = null;
            showAnswerFeedback = false;
            isCorrectAnswer = false;
          });
        } else {
          // Quiz completed, finish quiz and navigate to results
          _finishQuizAndNavigate();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the Scaffold in a PopScope to intercept back navigation
    return PopScope(
      canPop: false, // 1. Prevents the screen from closing automatically
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
          return;
        }
        // 2. Trigger your existing "Quit Quiz" dialog
        showCancelQuizDialog(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: SafeArea(
          child: Consumer<QuizProvider>(
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
                      AppSpacing.h24,
                      ElevatedButton(
                        onPressed: () {
                          if (widget.moduleId != null) {
                            // Use synoptic API if moduleId is 'synoptic'
                            if (widget.moduleId == 'synoptic') {
                              provider.fetchSynopticQuiz();
                            } else {
                              provider.fetchQuiz(widget.moduleId!);
                            }
                          }
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // No quiz data
              if (provider.quizData == null ||
                  provider.quizData!.questions.isEmpty) {
                return const Center(child: Text('No quiz data available'));
              }

              final questions = provider.quizData!.questions;
              final actualTotalQuestions = questions.length;

              // Check if current question index is valid
              if (currentQuestionIndex >= actualTotalQuestions) {
                // Quiz completed
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _finishQuizAndNavigate();
                });
                return const Center(child: CircularProgressIndicator());
              }

              final currentQuestion = questions[currentQuestionIndex];

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top section (close button + quiz info)
                          IconButton(
                            icon: Icon(Icons.close, color: AppColors.black),
                            onPressed: () {
                              showCancelQuizDialog(context);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  AppStrings.quizTitleMigrations,
                                  style: FontManager.buttonTextRegular()
                                      .copyWith(
                                        color: AppColors.white,
                                        fontSize: 14.sp,
                                      ),
                                ),
                              ),
                              //Sound on/off button
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isSoundEnabled = !_isSoundEnabled;
                                    SoundHelper.setSoundEnabled(
                                      _isSoundEnabled,
                                    );
                                  });
                                },
                                icon: Icon(
                                  _isSoundEnabled
                                      ? Icons.volume_up_outlined
                                      : Icons.volume_off_outlined,
                                  color: _isSoundEnabled
                                      ? AppColors.black
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.h12,

                          // Question info row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Question no: ${currentQuestionIndex + 1}',
                                style: FontManager.bodyText(),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: AppColors.red,
                                    size: 18.sp,
                                  ),
                                  AppSpacing.w4,
                                  Text(
                                    formattedTime,
                                    style: FontManager.bodyText().copyWith(
                                      color: AppColors.red,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  AppSpacing.w16,
                                ],
                              ),
                            ],
                          ),

                          AppSpacing.h20,

                          // Question text
                          Text(
                            currentQuestion.questionText,
                            style: FontManager.boldHeading(
                              fontSize: 20,
                              color: AppColors.black,
                            ),
                          ),
                          AppSpacing.h24,

                          // Options
                          ...List.generate(currentQuestion.optionsList.length, (
                            index,
                          ) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: customQchoice(
                                currentQuestion.optionsList[index],
                                AppColors.white,
                                index,
                                currentQuestion,
                              ),
                            );
                          }),
                          AppSpacing.h20,
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void showCancelQuizDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            title: Text(
              AppStrings.cancelQuizConfirmationTitle,
              textAlign: TextAlign.center,
              style: FontManager.boldHeading(
                fontSize: 18,
                color: AppColors.black,
              ),
            ),
            content: Text(
              AppStrings.cancelQuizDeductionMessage,
              textAlign: TextAlign.center,
              style: FontManager.bodyText().copyWith(color: AppColors.grey4B),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: AppColors.black,
                        side: BorderSide(color: AppColors.blue),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        AppStrings.cancelButton,
                        style: FontManager.buttonText(),
                      ),
                    ),
                  ),
                  AppSpacing.w12,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        // Delete XP and navigate when user quits quiz
                        _deleteXpAndNavigate();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        AppStrings.quitButton,
                        textAlign: TextAlign.center,
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
    );
  }

  Widget customQchoice(
    String text,
    Color backgroundColor,
    int optionIndex,
    QuestionModel question,
  ) {
    final isSelected = selectedAnswerIndex == optionIndex;
    final isCorrectAnswer = optionIndex == question.correctAnswerIndex;

    Color getAnswerColor() {
      if (!showAnswerFeedback) {
        return isSelected ? const Color(0xFFE8F4FF) : backgroundColor;
      }

      if (isCorrectAnswer) {
        return Colors.green.withValues(alpha: 0.2); // Light green for correct
      } else if (isSelected) {
        return Colors.red.withValues(alpha: 0.2); // Light red for incorrect
      }
      return backgroundColor;
    }

    Color getBorderColor() {
      if (!showAnswerFeedback) {
        return isSelected ? Colors.blueAccent : AppColors.borderColor;
      }

      if (isCorrectAnswer) {
        return Colors.green; // Green border for correct
      } else if (isSelected) {
        return Colors.red; // Red border for incorrect
      }
      return AppColors.borderColor;
    }

    return InkWell(
      onTap: () {
        handleAnswerSelection(optionIndex, question);
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: getAnswerColor(),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: getBorderColor(),
            width: showAnswerFeedback ? 2 : (isSelected ? 2 : 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: FontManager.bodyText().copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ),
            if (showAnswerFeedback && isCorrectAnswer)
              Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
            if (showAnswerFeedback && isSelected && !isCorrectAnswer)
              Icon(Icons.cancel, color: Colors.red, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

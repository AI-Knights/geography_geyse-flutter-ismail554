import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/views/profile/settings/app_info.dart';
import 'package:provider/provider.dart';

// Core imports
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';

// Models
import 'package:geography_geyser/models/home_model.dart';
import 'package:geography_geyser/models/userstats_model.dart';
import 'package:geography_geyser/models/user_performance_model.dart';

// Providers
import 'package:geography_geyser/provider/auth_provider/login_provider.dart';
import 'package:geography_geyser/provider/home_provider.dart';
import 'package:geography_geyser/provider/userstats_provider.dart';
import 'package:geography_geyser/provider/user_performance_provider.dart';
import 'package:geography_geyser/provider/settings_provider/optional_module_provider.dart';

// Services
import 'package:geography_geyser/services/api_service.dart';

// Views
import 'package:geography_geyser/views/auth/login/login.dart';
import 'package:geography_geyser/views/home/op_mod_settings.dart';
import 'package:geography_geyser/views/profile/account_delete.dart';
import 'package:geography_geyser/views/profile/settings/general_settings.dart';
import 'package:geography_geyser/views/profile/settings/privacy_settings.dart';

class ProfileScreen extends StatelessWidget {
  final bool hideSettingsCard;

  const ProfileScreen({super.key, this.hideSettingsCard = false});

  static bool _isInitialized = false;

  /// Reset initialization flag (useful after logout)
  static void resetInitialization() {
    _isInitialized = false;
  }

  /// Initialize data by loading from storage first, then fetching from API if needed
  void _initializeData(BuildContext context) {
    if (_isInitialized) return;
    _isInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;

      await _loadUserData(context);
      if (!context.mounted) return;
      await _loadStatsData(context);
      if (!context.mounted) return;
      await _loadPerformanceData(context);
    });
  }

  /// Load user data from storage, then API if needed
  Future<void> _loadUserData(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserDataFromStorage();

    if (context.mounted &&
        userProvider.userModel == null &&
        !userProvider.isLoading) {
      await userProvider.fetchUserData();
    }
  }

  /// Load stats data from storage, then API if needed
  Future<void> _loadStatsData(BuildContext context) async {
    final statsProvider = Provider.of<UserStatsProvider>(
      context,
      listen: false,
    );
    await statsProvider.loadUserStatsFromStorage();

    if (context.mounted &&
        statsProvider.userStats == null &&
        !statsProvider.isLoading) {
      await statsProvider.fetchUserStats();
    }
  }

  /// Load performance data from storage, then API if needed
  Future<void> _loadPerformanceData(BuildContext context) async {
    final performanceProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    await performanceProvider.loadProfileFromStorage();

    if (context.mounted &&
        performanceProvider.profileData == null &&
        !performanceProvider.isLoading) {
      await performanceProvider.fetchProfile();
    }
  }

  /// Refresh all data from API
  Future<void> _refreshAllData(
    UserProvider userProvider,
    UserStatsProvider statsProvider,
    ProfileProvider performanceProvider,
  ) async {
    await Future.wait([
      userProvider.fetchUserData(),
      statsProvider.fetchUserStats(),
      performanceProvider.fetchProfile(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    _initializeData(context);
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Consumer3<UserProvider, UserStatsProvider, ProfileProvider>(
          builder: (context, userProvider, statsProvider, performanceProvider, child) {
            final user = userProvider.userModel;
            final stats = statsProvider.userStats;
            final performance = performanceProvider.profileData;

            // Only show loading if we have no data AND we're currently loading
            final isLoading =
                userProvider.isLoading ||
                statsProvider.isLoading ||
                performanceProvider.isLoading;
            final hasNoData = user == null || stats == null;

            if (isLoading && hasNoData) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () => _refreshAllData(
                userProvider,
                statsProvider,
                performanceProvider,
              ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button (only show when navigated to as a pushed screen)
                    if (hideSettingsCard) ...[
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back, color: AppColors.black),
                            AppSpacing.w8,
                            Text(
                              AppStrings.backButton,
                              style: FontManager.bodyText(
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.h24,
                    ],

                    // Profile Header
                    buildProfileHeader(user, stats, performance),

                    AppSpacing.h24,

                    // Progress Section
                    buildProgressSection(stats, performance),

                    AppSpacing.h24,

                    // Subject Performance Section
                    buildSubjectPerformanceSection(performance),

                    AppSpacing.h40,
                    // Settings Card (conditionally shown)
                    if (!hideSettingsCard) ...[
                      buildSettingsCard(context),
                      AppSpacing.h24,
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build profile header with avatar, name, and XP
  Widget buildProfileHeader(
    HomeModel? user,
    UserStatsModel? stats,
    ProfileModel? performance,
  ) {
    // Prefer performance data, fallback to user/stats
    final profilePic = performance?.profilePic ?? user?.profilePic;
    final fullName =
        performance?.fullName ?? user?.fullName ?? AppStrings.userName;
    final totalXp = performance?.totalXp ?? stats?.totalXp;

    return Center(
      child: Column(
        children: [
          _buildProfileAvatar(profilePic),
          AppSpacing.h16,
          Text(fullName, style: FontManager.bigTitle(fontSize: 18)),
          AppSpacing.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: Colors.orange,
                size: 20.sp,
              ),
              AppSpacing.w8,
              Text(
                "XP: ${totalXp ?? '--'}",
                style: FontManager.bodyText(color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build profile avatar with network image fallback
  Widget _buildProfileAvatar(String? profilePicUrl) {
    if (profilePicUrl != null && profilePicUrl.isNotEmpty) {
      final imageUrl = _buildImageUrl(profilePicUrl);

      return CircleAvatar(
        radius: 50.r,
        backgroundColor: Colors.grey[300],
        child: ClipOval(
          child: Image.network(
            imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/man.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 50.r,
        backgroundImage: AssetImage('assets/images/man.png'),
      );
    }
  }

  /// Build full image URL from relative or absolute URL
  String _buildImageUrl(String profilePicUrl) {
    if (profilePicUrl.startsWith('http://') ||
        profilePicUrl.startsWith('https://')) {
      return profilePicUrl;
    }

    // Handle relative URLs by prepending base URL
    final cleanUrl = profilePicUrl.startsWith('/')
        ? profilePicUrl.substring(1)
        : profilePicUrl;
    return '${ApiService.baseUrl}/$cleanUrl';
  }

  /// SETTINGS CARD
  Widget buildSettingsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // General settings
          buildSettingRow(
            icon: Icons.settings_outlined,
            text: AppStrings.generalSetting,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GeneralSettings_Screen(),
                ),
              );
            },
          ),
          Divider(height: 1, color: Colors.grey[300]),
          //Privacy settings
          buildSettingRow(
            icon: Icons.lock_outline,
            text: AppStrings.privacySetting,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacySettings_Screen(),
                ),
              );
            },
          ),

          Divider(height: 1, color: Colors.grey[300]),
          // Module Settings Row
          buildSettingRow(
            icon: Icons.settings_outlined,
            text: AppStrings.moduleSettingOption,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OptionalModuleSettings(),
                ),
              );
            },
          ),
          // Account Deletion
          Divider(height: 1, color: Colors.grey[300]),
          buildSettingRow(
            icon: Icons.delete_sweep_sharp,
            text: AppStrings.accountdelection,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountDelete()),
              );
            },
          ),

          Divider(height: 1, color: Colors.grey[300]),
          //About App
          buildSettingRow(
            icon: Icons.info_outline,
            text: "About App",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutAppScreen()),
              );
            },
          ),
          Divider(height: 1, color: Colors.grey[300]),
          // Logout Row
          buildSettingRow(
            icon: Icons.logout_outlined,
            text: AppStrings.logOutOption,
            textColor: AppColors.red, // ✅ Themed logout color
            iconColor: AppColors.red,
            onTap: () => showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  /// Build a settings row with icon, text, and navigation arrow
  Widget buildSettingRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Colors.black, size: 24.sp),
            AppSpacing.w16,
            Expanded(
              child: Text(
                text,
                style: FontManager.bodyText(color: textColor ?? Colors.black),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16.sp),
          ],
        ),
      ),
    );
  }

  /// Build progress section with quiz stats
  Widget buildProgressSection(
    UserStatsModel? stats,
    ProfileModel? performance,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.progressTitle, style: FontManager.bigTitle()),
        AppSpacing.h16,
        Column(
          children: [
            buildProgressCard(
              label: AppStrings.quizAttemptedLabel,
              value: _getQuizAttemptedValue(stats, performance),
            ),
            AppSpacing.h12,
            buildProgressCard(
              label: AppStrings.averageScoreLabel,
              value: _getAverageScoreValue(stats, performance),
            ),
            AppSpacing.h12,
            buildProgressCard(
              label: AppStrings.subjectCoveredLabel,
              value: _getSubjectCoveredValue(performance),
            ),
          ],
        ),
      ],
    );
  }

  /// Get quiz attempted value with fallback
  String _getQuizAttemptedValue(
    UserStatsModel? stats,
    ProfileModel? performance,
  ) {
    if (performance != null) return '${performance.quizAttempted}';
    if (stats != null) return '${stats.totalAttemptedQuizzes}';
    return AppStrings.quizAttemptedValue;
  }

  /// Get average score value with fallback
  String _getAverageScoreValue(
    UserStatsModel? stats,
    ProfileModel? performance,
  ) {
    if (performance != null) {
      return '${performance.averageScore.toStringAsFixed(1)}%';
    }
    if (stats != null) {
      return '${stats.averageScore.toStringAsFixed(1)}%';
    }
    return AppStrings.averageScoreValue;
  }

  /// Get subject covered value with fallback
  String _getSubjectCoveredValue(ProfileModel? performance) {
    if (performance != null) return '${performance.subjectCovered}';
    return AppStrings.subjectCoveredValue;
  }

  /// Build a progress card with label and value
  Widget buildProgressCard({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.r, horizontal: 16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: FontManager.subtitleText()),
          AppSpacing.h8,
          Text(
            value,
            style: FontManager.bigTitle(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build subject performance section with list of subjects
  Widget buildSubjectPerformanceSection(ProfileModel? performance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.subjectPerformanceTitle, style: FontManager.bigTitle()),
        AppSpacing.h16,
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: _buildCardDecoration(),
          child: _buildSubjectList(performance),
        ),
      ],
    );
  }

  /// Build card decoration
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Build subject list or empty state
  Widget _buildSubjectList(ProfileModel? performance) {
    if (performance == null || performance.subjects.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: performance.subjects.length,
      itemBuilder: (context, index) {
        final subject = performance.subjects[index];

        return Column(
          children: [
            if (index > 0) AppSpacing.h12,
            buildSubjectProgress(subject.moduleName, subject.progress),
          ],
        );
      },
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Text(
          'No subject data available',
          style: FontManager.bodyText(color: Colors.grey),
        ),
      ),
    );
  }

  /// Build individual subject progress bar
  Widget buildSubjectProgress(String subject, double progress) {
    // Calculate actual percentage for display
    final progressPercentage = (progress).toInt();

    // Calculate widthFactor: use 2/100 if progress is 0, otherwise use actual progress
    final widthFactor = progress == 0 ? 2 / 100 : progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(subject, style: FontManager.generalText(color: Colors.black)),
            Text(
              '$progressPercentage%',
              style: FontManager.bodyText(color: Colors.black),
            ),
          ],
        ),
        AppSpacing.h8,
        Container(
          height: 8.h,
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: Colors.grey[200],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widthFactor / 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: AppColors.buttonColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// LOGOUT DIALOG
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            AppStrings.areYouSureTitle,
            style: FontManager.bigTitle(),
            textAlign: TextAlign.center,
          ),
          content: Text(
            AppStrings.logoutConfirmationMessage,
            style: FontManager.bodyText(),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      AppStrings.cancelButton,
                      style: FontManager.buttonText().copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                AppSpacing.w12,

                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();

                      final userProvider = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      );
                      final statsProvider = Provider.of<UserStatsProvider>(
                        context,
                        listen: false,
                      );
                      final profileProvider = Provider.of<ProfileProvider>(
                        context,
                        listen: false,
                      );
                      final optionalModuleProvider =
                          Provider.of<OptionalModuleProvider>(
                            context,
                            listen: false,
                          );

                      await Future.wait([
                        userProvider.clearUserData(),
                        statsProvider.clearUserStats(),
                        profileProvider.clearProfileData(),
                      ]);

                      optionalModuleProvider.clearModulePairs();

                      ProfileScreen.resetInitialization();

                      await LoginProvider.logout();

                      if (!context.mounted) return;

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      AppStrings.logOutButton,
                      style: FontManager.buttonText().copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

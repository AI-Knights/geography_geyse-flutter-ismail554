import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB), // Light grey background
      appBar: AppBar(
        title: Text('App Information', style: FontManager.titleText()),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_outlined, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Header Section
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 80.w,
                      height: 65.w,
                    ),
                    // AppSpacing.h16,
                    Text(
                      'Geography Geyser',
                      style: FontManager.bigTitle(fontSize: 20.sp),
                    ),
                    AppSpacing.h4,
                    Text(
                      'Your Pocket Guide to the World',
                      style: FontManager.bodyText(color: Colors.grey),
                    ),
                    AppSpacing.h12,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.h32,

              // Key Features
              _buildSectionHeader('Key Features'),
              AppSpacing.h10,
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      icon: Icons.public,
                      color: Colors.orange.shade100,
                      iconColor: Colors.orange,
                      title: 'Interactive Quizzes',
                      subtitle:
                          'Test your knowledge with engaging geography quizzes.',
                    ),
                    _buildDivider(),
                    _buildFeatureItem(
                      icon: Icons.map_outlined,
                      color: Colors.blue.shade100,
                      iconColor: Colors.blue,
                      title: 'Global Coverage',
                      subtitle:
                          'Explore detailed maps and data from around the world.',
                    ),
                    _buildDivider(),
                    _buildFeatureItem(
                      icon: Icons.school_outlined,
                      color: Colors.green.shade100,
                      iconColor: Colors.green,
                      title: 'Educational Resources',
                      subtitle:
                          'Access curated content to boost your learning.',
                    ),
                  ],
                ),
              ),
              AppSpacing.h24,

              // About
              _buildSectionHeader('About'),
              AppSpacing.h10,
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: _cardDecoration(),
                child: Text(
                  "Geography Geyser helps you learn subjects in a fun and easy way. Whether you’re a student, teacher, or just curious about the world, this app makes exploring our planet simple and enjoyable.",
                  style: TextStyle(
                    fontFamily: GoogleFonts.roboto().fontFamily,
                    fontSize: 14.sp,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              AppSpacing.h24,

              // Technical Information
              _buildSectionHeader('Technical Information'),
              AppSpacing.h14,
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildInfoRow('Version', '1.0.0'),
                    // AppSpacing.h12,
                    // _buildInfoRow('Build Number', '100'),
                    AppSpacing.h12,
                    _buildInfoRow('Platform', 'iOS & Android'),
                  ],
                ),
              ),
              AppSpacing.h28,

              // Contact & Support
              _buildSectionHeader('Contact & Support'),
              AppSpacing.h10,
              Container(
                decoration: _cardDecoration(),
                child: InkWell(
                  onTap: () async {
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'simonA@standsureeducation.co.uk',
                    );
                    try {
                      await launchUrl(emailLaunchUri);
                    } catch (e) {
                      debugPrint('Could not launch email: $e');
                      if (context.mounted) {
                        CustomSnackBar.show(
                          context,
                          message:
                              'Could not launch email app. Please copy the email manually.',
                          isError: true,
                        );
                      }
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Title with better visual hierarchy
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Email Support',
                              style: FontManager.headerSubtitleText(
                                color: Colors.black87,
                              ),
                            ),
                            Icon(
                              Icons.mail_outline,
                              size: 20.r,
                              color: Colors.orange,
                            ),
                          ],
                        ),

                        SizedBox(height: 16.r),

                        // Email with better alignment and handling
                        Container(
                          width: double.maxFinite,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.r,
                            vertical: 8.r,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'simonA@standsureeducation.co.uk',
                            style: FontManager.bodyText(
                              fontSize: 16.sp,
                              color: Colors.orange,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,

                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppSpacing.h48,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: FontManager.headerSubtitleText(fontSize: 16.sp));
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FontManager.headerSubtitleText(fontSize: 14.sp),
                ),
                AppSpacing.h4,
                Text(subtitle, style: FontManager.bodyText(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100);
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: FontManager.bodyText(
            fontSize: 16.sp,
            color: Colors.grey.shade600,
          ),
        ),
        Text(value, style: FontManager.headerSubtitleText(fontSize: 14.sp)),
      ],
    );
  }
}

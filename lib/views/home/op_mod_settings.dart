import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/provider/settings_provider/optional_module_provider.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/custom_toggle_button.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:provider/provider.dart';

class OptionalModuleSettings extends StatefulWidget {
  final bool isFirstLogin;

  const OptionalModuleSettings({super.key, this.isFirstLogin = false});

  @override
  State<OptionalModuleSettings> createState() => _OptionalModuleSettingsState();
}

class _OptionalModuleSettingsState extends State<OptionalModuleSettings> {
  @override
  void initState() {
    super.initState();
    // Fetch modules when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<OptionalModuleProvider>(
          context,
          listen: false,
        );
        provider.fetchOptionalModules();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        automaticallyImplyLeading: widget.isFirstLogin ? false : true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isFirstLogin
              ? AppStrings.altModSettOption
              : AppStrings.moduleSettingTitle,
          style: FontManager.titleText(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.h20,

                    // Show first login message only when coming from login
                    if (widget.isFirstLogin) ...[
                      Text(
                        AppStrings.firstLoginModule,
                        style: FontManager.bodyText(),
                      ),
                      AppSpacing.h16,
                    ],

                    Text(
                      AppStrings.selectOptionalModuleInstruction,
                      style: FontManager.bigTitle(),
                    ),
                    AppSpacing.h32,

                    // Module Selection from API
                    Consumer<OptionalModuleProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (provider.errorMessage != null) {
                          return Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppLogger.getSafeErrorMessage(
                                      provider.errorMessage!,
                                    ),
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, size: 18),
                                  color: Colors.red,
                                  onPressed: () {
                                    provider.clearError();
                                    provider.fetchOptionalModules();
                                  },
                                ),
                              ],
                            ),
                          );
                        }

                        if (provider.modulePairs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Text(
                                'No optional modules available',
                                style: FontManager.bodyText(),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            ...provider.modulePairs.map((pair) {
                              if (pair.modules.length < 2) {
                                return SizedBox.shrink();
                              }

                              final module1 = pair.modules[0];
                              final module2 = pair.modules[1];

                              // Determine initial selection based on selected_module
                              String? initialSelection;
                              final selectedModuleId = pair.selectedModule
                                  ?.trim();
                              if (selectedModuleId != null &&
                                  selectedModuleId.isNotEmpty) {
                                // Check which module matches the selected_module ID
                                if (selectedModuleId == module1.id.trim()) {
                                  initialSelection = module1.moduleName;
                                } else if (selectedModuleId ==
                                    module2.id.trim()) {
                                  initialSelection = module2.moduleName;
                                }
                              }

                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: CustomToggleButton(
                                  option1: module1.moduleName,
                                  option2: module2.moduleName,
                                  initialSelection: initialSelection,
                                  onChanged: (selectedModuleName) {
                                    // Find the module ID for the selected name
                                    String? selectedModuleId;
                                    if (selectedModuleName ==
                                        module1.moduleName) {
                                      selectedModuleId = module1.id;
                                    } else if (selectedModuleName ==
                                        module2.moduleName) {
                                      selectedModuleId = module2.id;
                                    }

                                    AppLogger.debug(
                                      'Module selected: $selectedModuleName (ID: $selectedModuleId) for pair ${pair.pairNumber}',
                                    );

                                    // Update selection in provider
                                    if (selectedModuleId != null &&
                                        selectedModuleId.isNotEmpty) {
                                      provider.updateSelectedModule(
                                        pair.pairNumber,
                                        selectedModuleId,
                                      );
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Save and Go to Home Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Consumer<OptionalModuleProvider>(
                builder: (context, provider, child) {
                  return CustomLoginButton(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            // Update selections via PATCH request
                            final success = await provider
                                .updateModuleSelections();

                            if (context.mounted) {
                              if (success) {
                                CustomSnackBar.show(
                                  context,
                                  message:
                                      'Module selections saved successfully!',
                                );

                                // Navigate to home after successful save
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const HomePageScreen(),
                                  ),
                                );
                              } else {
                                // Error message is already shown in provider
                                if (provider.errorMessage != null) {
                                  CustomSnackBar.show(
                                    context,
                                    message: AppLogger.getSafeErrorMessage(
                                      provider.errorMessage!,
                                    ),
                                    isError: true,
                                  );
                                }
                              }
                            }
                          },
                    text: provider.isLoading ? 'Saving...' : AppStrings.goHome,
                  );
                },
              ),
            ),
            AppSpacing.h16,
          ],
        ),
      ),
    );
  }
}

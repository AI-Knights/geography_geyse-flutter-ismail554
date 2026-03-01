import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/provider/home_provider.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

class GeneralSettings_Screen extends StatefulWidget {
  const GeneralSettings_Screen({super.key});

  @override
  State<GeneralSettings_Screen> createState() => _GeneralSettings_ScreenState();
}

class _GeneralSettings_ScreenState extends State<GeneralSettings_Screen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (_isInitialized) return;
    _isInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Load from storage first
      await userProvider.loadUserDataFromStorage();

      // If no data in storage, fetch from API
      if (mounted &&
          userProvider.userModel == null &&
          !userProvider.isLoading) {
        await userProvider.fetchUserData();
      }

      // Populate fields with user data
      if (context.mounted) {
        _populateFields(userProvider.userModel);
      }
    });
  }

  void _populateFields(userModel) {
    if (userModel != null) {
      _nameController.text = userModel.fullName ?? '';
      _emailController.text = userModel.email ?? '';
    }
  }

  String _buildImageUrl(String? profilePicUrl) {
    if (profilePicUrl == null || profilePicUrl.isEmpty) {
      return '';
    }

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

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('${source.name} error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to access ${source.name}. Please check permissions.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (context.mounted)
        setState(() {
          _imageFile =
              null; // Ensuring build check compliance, though not strictly required
        });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await SecureStorageHelper.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Token not found! Please login again.");
      }

      final url = Uri.parse(ApiService.updateProfile);
      var request = http.MultipartRequest('PATCH', url);

      //Add Bearer token
      request.headers['Authorization'] = 'Bearer $token';

      // Add text field
      if (_nameController.text.isNotEmpty) {
        request.fields['full_name'] = _nameController.text.trim();
      }

      // Add image file if selected
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_pic', _imageFile!.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!context.mounted) return;
        try {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Profile updated!'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          // If 200 but not valid JSON (unexpected), just show success with default message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }

        // Refresh user data after successful update
        if (context.mounted) {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          await userProvider.fetchUserData();

          // Update fields with new data
          _populateFields(userProvider.userModel);
        }
      } else {
        // Try to parse error message, fallback to status text
        String errorMsg = 'Update failed (${response.statusCode})';
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null)
            errorMsg = data['message'];
          else if (data['error'] != null)
            errorMsg = data['error'];
        } catch (_) {
          // Body is not JSON (likely HTML)
          if (response.body.contains('<!DOCTYPE html>')) {
            errorMsg =
                'Server Error (${response.statusCode}). Please contact support.';
          } else if (response.body.isNotEmpty) {
            // Take first 100 chars if plain text
            errorMsg = response.body.length > 100
                ? response.body.substring(0, 100)
                : response.body;
          }
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint("Profile update error: $e");
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        msg = msg.substring(11); // Remove "Exception: " prefix
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {
      if (context.mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        title: Text(AppStrings.generalSetting, style: FontManager.titleText()),
      ),
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final userModel = userProvider.userModel;
            final profilePicUrl = userModel?.profilePic;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (profilePicUrl != null &&
                                            profilePicUrl.isNotEmpty
                                        ? NetworkImage(
                                            _buildImageUrl(profilePicUrl),
                                          )
                                        : const AssetImage(
                                            "assets/images/man.png",
                                          ))
                                    as ImageProvider,
                          onBackgroundImageError: (exception, stackTrace) {
                            // Handle network image error
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: CircleAvatar(
                              radius: 16.r,
                              backgroundColor: AppColors.buttonColor,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.h8,
                    Text(
                      AppStrings.choosePhoto,
                      style: FontManager.titleText(color: AppColors.blue),
                    ),
                    AppSpacing.h40,

                    // 🧍 Name field
                    BuildTextField(
                      controller: _nameController,
                      label: AppStrings.nameLabel,
                      hint: AppStrings.nameFieldValue,
                    ),
                    AppSpacing.h12,

                    // ✉️ Email field (read-only)
                    BuildTextField(
                      controller: _emailController,
                      isReadOnly: true,

                      label: AppStrings.emailLabel,
                      hint: AppStrings.emailFieldValue,
                    ),

                    AppSpacing.h32,

                    // 💾 Save Changes Button
                    CustomLoginButton(
                      text: _isLoading
                          ? "Saving..."
                          : AppStrings.saveChangesButton,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _updateProfile,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common_widget/auth_bottom_sheet.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker picker = ImagePicker();
  XFile? image;
  String? profileImageUrl;

  TextEditingController txtFirstName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // If not logged in, show auth sheet first
    if (!Globs.udValueBool(Globs.userLogin)) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final loggedIn = await AuthBottomSheet.show(context);
        if (!loggedIn && mounted) {
          Navigator.pop(context);
          return;
        }
        if (mounted) _fetchProfile();
      });
    } else {
      _fetchProfile();
    }
  }

  void _fetchProfile() async {
    setState(() {
      isLoading = true;
    });

    await ServiceCall.get(
      SVKey.svProfile,
      isToken: true,
      withSuccess: (responseObj) async {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });

        if (responseObj['status'] == 'success' && responseObj['data'] != null) {
          final data = responseObj['data'] as Map<String, dynamic>;
          txtFirstName.text = data['first_name']?.toString() ?? '';
          txtLastName.text = data['last_name']?.toString() ?? '';
          txtEmail.text = data['email']?.toString() ?? '';
          txtMobile.text = data['phone']?.toString() ?? '';
          profileImageUrl = data['profile_image_url']?.toString();
          
          // Cache profile locally
          Globs.udSet(data, Globs.userProfile);
          setState(() {});
        }
      },
      failure: (err) async {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err.toString()),
            backgroundColor: TColor.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  void _updateProfile() async {
    // Validate inputs
    if (txtFirstName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("First name is required"),
          backgroundColor: TColor.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Globs.showHUD();
    
    final payload = {
      "first_name": txtFirstName.text.trim(),
      "last_name": txtLastName.text.trim(),
      "email": txtEmail.text.trim(),
      "phone": txtMobile.text.trim(),
      "profile_image_url": profileImageUrl ?? "",
    };

    await ServiceCall.put(
      SVKey.svProfile,
      body: payload,
      isToken: true,
      withSuccess: (responseObj) async {
        Globs.hideHUD();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text("Profile updated successfully"),
              ],
            ),
            backgroundColor: TColor.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      failure: (err) async {
        Globs.hideHUD();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err.toString()),
            backgroundColor: TColor.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  Widget _buildProfileImage() {
    if (image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.file(
          File(image!.path),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    } else if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: CachedNetworkImage(
          imageUrl: profileImageUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(
            color: TColor.primary,
            strokeWidth: 2.5,
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.person_rounded,
            size: 50,
            color: TColor.primary.withOpacity(0.5),
          ),
        ),
      );
    } else {
      return Icon(
        Icons.person_rounded,
        size: 50,
        color: TColor.primary.withOpacity(0.5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.plusJakartaSans(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: TColor.primary,
                strokeWidth: 2.5,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Profile header card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: TColor.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: TColor.primaryLight,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          alignment: Alignment.center,
                          child: _buildProfileImage(),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () async {
                            image = await picker.pickImage(
                                source: ImageSource.gallery);
                            setState(() {});
                          },
                          icon: Icon(Icons.camera_alt_rounded,
                              color: TColor.primary, size: 16),
                          label: Text(
                            "Change Photo",
                            style: GoogleFonts.plusJakartaSans(
                              color: TColor.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          txtFirstName.text.isNotEmpty
                              ? "Hi there ${txtFirstName.text}!"
                              : "Hi there!",
                          style: GoogleFonts.plusJakartaSans(
                            color: TColor.primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Text('Sign Out',
                                    style: GoogleFonts.plusJakartaSans(
                                        color: TColor.primaryText,
                                        fontWeight: FontWeight.w700)),
                                content: Text(
                                    'Are you sure you want to sign out?',
                                    style: GoogleFonts.plusJakartaSans()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('Cancel',
                                        style: TextStyle(
                                            color: TColor.secondaryText)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      ServiceCall.logout();
                                    },
                                    child: Text('Sign Out',
                                        style: TextStyle(
                                            color: TColor.primary)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text(
                            "Sign Out",
                            style: GoogleFonts.plusJakartaSans(
                              color: TColor.secondaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Form card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: TColor.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Personal Information",
                          style: GoogleFonts.plusJakartaSans(
                            color: TColor.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        RoundTitleTextfield(
                          title: "First Name",
                          hintText: "Enter First Name",
                          controller: txtFirstName,
                        ),
                        const SizedBox(height: 12),
                        RoundTitleTextfield(
                          title: "Last Name",
                          hintText: "Enter Last Name",
                          controller: txtLastName,
                        ),
                        const SizedBox(height: 12),
                        RoundTitleTextfield(
                          title: "Email",
                          hintText: "Enter Email",
                          keyboardType: TextInputType.emailAddress,
                          controller: txtEmail,
                        ),
                        const SizedBox(height: 12),
                        RoundTitleTextfield(
                          title: "Mobile No",
                          hintText: "Enter Mobile No",
                          controller: txtMobile,
                          keyboardType: TextInputType.phone,
                          readOnly: true,
                        ),
                        const SizedBox(height: 24),
                        RoundButton(title: "Save", onPressed: _updateProfile),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}

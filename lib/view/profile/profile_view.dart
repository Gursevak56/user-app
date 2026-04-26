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
    setState(() => isLoading = true);

    await ServiceCall.get(
      SVKey.svProfile,
      isToken: true,
      withSuccess: (responseObj) async {
        if (!mounted) return;
        setState(() => isLoading = false);

        if (responseObj['status'] == 'success' && responseObj['data'] != null) {
          final data = responseObj['data'] as Map<String, dynamic>;
          txtFirstName.text = data['first_name']?.toString() ?? '';
          txtLastName.text = data['last_name']?.toString() ?? '';
          txtEmail.text = data['email']?.toString() ?? '';
          txtMobile.text = data['phone']?.toString() ?? '';
          profileImageUrl = data['profile_image_url']?.toString();
          Globs.udSet(data, Globs.userProfile);
          setState(() {});
        }
      },
      failure: (err) async {
        if (!mounted) return;
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err.toString()),
            backgroundColor: TColor.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  void _updateProfile() async {
    if (txtFirstName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("First name is required"),
          backgroundColor: TColor.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      );
    } else {
      return Icon(
        Icons.person_rounded,
        size: 50,
        color: Colors.white.withOpacity(0.7),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: TColor.background,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: TColor.primary,
                strokeWidth: 2.5,
              ),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── Premium Profile Header ───
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [TColor.primary, TColor.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: 20),
                                ),
                                Expanded(
                                  child: Text(
                                    "My Profile",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 48),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Profile avatar
                          Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 3),
                                ),
                                alignment: Alignment.center,
                                child: _buildProfileImage(),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () async {
                                    image = await picker.pickImage(
                                        source: ImageSource.gallery);
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_rounded,
                                      size: 16,
                                      color: TColor.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            txtFirstName.text.isNotEmpty
                                ? "${txtFirstName.text} ${txtLastName.text}".trim()
                                : "Your Name",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (txtEmail.text.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              txtEmail.text,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── Form Card ───
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: TColor.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: TColor.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                color: TColor.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Personal Information",
                              style: GoogleFonts.plusJakartaSans(
                                color: TColor.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        RoundTitleTextfield(
                          title: "First Name",
                          hintText: "Enter First Name",
                          controller: txtFirstName,
                        ),
                        const SizedBox(height: 14),
                        RoundTitleTextfield(
                          title: "Last Name",
                          hintText: "Enter Last Name",
                          controller: txtLastName,
                        ),
                        const SizedBox(height: 14),
                        RoundTitleTextfield(
                          title: "Email",
                          hintText: "Enter Email",
                          keyboardType: TextInputType.emailAddress,
                          controller: txtEmail,
                        ),
                        const SizedBox(height: 14),
                        RoundTitleTextfield(
                          title: "Mobile No",
                          hintText: "Enter Mobile No",
                          controller: txtMobile,
                          keyboardType: TextInputType.phone,
                          readOnly: true,
                        ),
                        const SizedBox(height: 28),
                        RoundButton(title: "Save Changes", onPressed: _updateProfile),
                      ],
                    ),
                  ),
                ),

                // ─── Sign Out ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                    child: Material(
                      color: TColor.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              title: Text('Sign Out',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18)),
                              content: Text(
                                  'Are you sure you want to sign out?',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: TColor.secondaryText,
                                      fontSize: 14)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text('Cancel',
                                      style: GoogleFonts.plusJakartaSans(
                                          color: TColor.secondaryText,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: TColor.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      ServiceCall.logout();
                                    },
                                    child: Text('Sign Out',
                                        style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_rounded,
                                  size: 20, color: TColor.primary),
                              const SizedBox(width: 10),
                              Text(
                                "Sign Out",
                                style: GoogleFonts.plusJakartaSans(
                                  color: TColor.primary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common_widget/auth_bottom_sheet.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/common/globs.dart';
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
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  void _updateProfile() async {
    // Validate inputs
    if (txtFirstName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("First name is required"), backgroundColor: Colors.red),
      );
      return;
    }

    Globs.showHUD();
    
    final payload = {
      "first_name": txtFirstName.text.trim(),
      "last_name": txtLastName.text.trim(),
      "email": txtEmail.text.trim(),
      "phone": txtMobile.text.trim(),
      // Retain existing image url if no new one is uploaded (image uploading not implemented yet in this snippet)
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
          const SnackBar(
            content: Text("Profile updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
      },
      failure: (err) async {
        Globs.hideHUD();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err.toString()),
            backgroundColor: Colors.red,
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
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(
            Icons.person,
            size: 65,
            color: TColor.secondaryText,
          ),
        ),
      );
    } else {
      return Icon(
        Icons.person,
        size: 65,
        color: TColor.secondaryText,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: TColor.placeholder,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      alignment: Alignment.center,
                      child: _buildProfileImage(),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        image = await picker.pickImage(source: ImageSource.gallery);
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.edit,
                        color: TColor.primary,
                        size: 12,
                      ),
                      label: Text(
                        "Edit Profile Image",
                        style: TextStyle(color: TColor.secondary, fontSize: 12),
                      ),
                    ),
                    Text(
                      txtFirstName.text.isNotEmpty ? "Hi there ${txtFirstName.text}!" : "Hi there!",
                      style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text('Sign Out',
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontWeight: FontWeight.w700)),
                            content: const Text(
                                'Are you sure you want to sign out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('Cancel',
                                    style:
                                        TextStyle(color: TColor.secondaryText)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  ServiceCall.logout();
                                },
                                child: const Text('Sign Out',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        "Sign Out",
                        style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: RoundTitleTextfield(
                        title: "First Name",
                        hintText: "Enter First Name",
                        controller: txtFirstName,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: RoundTitleTextfield(
                        title: "Last Name",
                        hintText: "Enter Last Name",
                        controller: txtLastName,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: RoundTitleTextfield(
                        title: "Email",
                        hintText: "Enter Email",
                        keyboardType: TextInputType.emailAddress,
                        controller: txtEmail,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: RoundTitleTextfield(
                        title: "Mobile No",
                        hintText: "Enter Mobile No",
                        controller: txtMobile,
                        keyboardType: TextInputType.phone,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RoundButton(title: "Save", onPressed: _updateProfile),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}

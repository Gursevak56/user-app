import 'package:flutter/material.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';

class ChangeAddressView extends StatefulWidget {
  const ChangeAddressView({super.key});

  @override
  State<ChangeAddressView> createState() => _ChangeAddressViewState();
}

class _ChangeAddressViewState extends State<ChangeAddressView> {
  List<Map<String, dynamic>> addresses = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  void _fetchAddresses() async {
    setState(() => isLoading = true);

    await ServiceCall.get(
      SVKey.svAddresses,
      isToken: true,
      withSuccess: (responseObj) async {
        if (!mounted) return;
        setState(() => isLoading = false);
        if (responseObj['status'] == 'success' && responseObj['data'] != null) {
          addresses = List<Map<String, dynamic>>.from(responseObj['data']);
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

  IconData _getLabelIcon(String? label) {
    switch (label?.toLowerCase()) {
      case 'work':
      case 'office':
        return Icons.business_rounded;
      case 'other':
        return Icons.place_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  void _showAddAddressDialog() {
    final txtLabel = TextEditingController(text: "Home");
    final txtStreet = TextEditingController();
    final txtCity = TextEditingController();
    final txtZipCode = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Add New Address",
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RoundTitleTextfield(
                    title: "Label",
                    hintText: "Home/Work/Etc",
                    controller: txtLabel),
                const SizedBox(height: 10),
                RoundTitleTextfield(
                    title: "Street",
                    hintText: "123 Main St",
                    controller: txtStreet),
                const SizedBox(height: 10),
                RoundTitleTextfield(
                    title: "City",
                    hintText: "City Name",
                    controller: txtCity),
                const SizedBox(height: 10),
                RoundTitleTextfield(
                    title: "Zip Code",
                    hintText: "Postal Code",
                    controller: txtZipCode),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel",
                  style: GoogleFonts.plusJakartaSans(
                      color: TColor.secondaryText,
                      fontWeight: FontWeight.w600)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: TColor.foodTabGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  if (txtStreet.text.trim().isEmpty ||
                      txtCity.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text("Street and City are required"),
                      backgroundColor: TColor.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                    return;
                  }

                  final payload = {
                    "label": txtLabel.text.trim(),
                    "street": txtStreet.text.trim(),
                    "city": txtCity.text.trim(),
                    "zipCode": txtZipCode.text.trim(),
                    "latitude": 0.0,
                    "longitude": 0.0,
                    "is_default": addresses.isEmpty,
                  };

                  Globs.showHUD();
                  await ServiceCall.post(
                    payload,
                    SVKey.svAddresses,
                    isToken: true,
                    withSuccess: (res) async {
                      Globs.hideHUD();
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      _fetchAddresses();
                    },
                    failure: (err) async {
                      Globs.hideHUD();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(err.toString()),
                          backgroundColor: TColor.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  );
                },
                child: Text("Add",
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
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
          "My Addresses",
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
                  color: TColor.primary, strokeWidth: 2.5))
          : addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: TColor.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.location_off_rounded,
                            size: 48, color: TColor.primary),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "No saved addresses",
                        style: GoogleFonts.plusJakartaSans(
                          color: TColor.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Add your delivery address",
                        style: GoogleFonts.plusJakartaSans(
                          color: TColor.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: addresses.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    final isDefault = addr['is_default'] == true;
                    return Material(
                      color: TColor.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, addr);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: isDefault
                                ? Border.all(
                                    color: TColor.primary.withOpacity(0.3),
                                    width: 1.5)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isDefault
                                      ? TColor.primary.withOpacity(0.1)
                                      : TColor.textfield,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getLabelIcon(addr['label']?.toString()),
                                  color: isDefault
                                      ? TColor.primary
                                      : TColor.secondaryText,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          addr['label']?.toString() ??
                                              'Address',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: TColor.primaryText,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (isDefault) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: TColor.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              "Default",
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                color: TColor.primary,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${addr['street'] ?? ''}, ${addr['city'] ?? ''} - ${addr['zipCode'] ?? ''}",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: TColor.secondaryText,
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 14, color: TColor.placeholder),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAddressDialog,
        backgroundColor: TColor.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text("Add Address",
            style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
      ),
    );
  }
}

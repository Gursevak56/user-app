import 'package:flutter/material.dart';
import 'package:food_delivery/view/more/about_us_view.dart';
import 'package:food_delivery/view/more/inbox_view.dart';
import 'package:food_delivery/view/more/my_order_view.dart';
import 'package:food_delivery/view/more/notification_view.dart';
import 'package:food_delivery/view/more/payment_details_view.dart';
import 'package:food_delivery/view/profile/profile_view.dart';
import 'package:food_delivery/view/order/order_history_view.dart';
import 'package:food_delivery/view/more/favorite_view.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common/color_extension.dart';
import '../../common/service_call.dart';

class MoreView extends StatefulWidget {
  const MoreView({super.key});

  @override
  State<MoreView> createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  final List<Map<String, dynamic>> moreArr = [
    {"index": "1", "name": "Payment Details", "icon": Icons.payment_rounded, "color": Color(0xFF5C6BC0)},
    {"index": "2", "name": "Profile", "icon": Icons.person_outline_rounded, "color": Color(0xFF26A69A)},
    {"index": "3", "name": "Notifications", "icon": Icons.notifications_outlined, "color": Color(0xFFFF7043)},
    {"index": "4", "name": "Inbox", "icon": Icons.chat_bubble_outline_rounded, "color": Color(0xFF42A5F5)},
    {"index": "5", "name": "About Us", "icon": Icons.info_outline_rounded, "color": Color(0xFF7E57C2)},
    {"index": "7", "name": "Order History", "icon": Icons.history_rounded, "color": Color(0xFF66BB6A)},
    {"index": "8", "name": "My Favorites", "icon": Icons.favorite_border_rounded, "color": Color(0xFFEC407A)},
    {"index": "6", "name": "Logout", "icon": Icons.logout_rounded, "color": Color(0xFFEF5350)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "More",
          style: GoogleFonts.plusJakartaSans(
            color: TColor.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOrderView()),
                );
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TColor.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 22,
                  color: TColor.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            children: [
              ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: moreArr.length,
                itemBuilder: (context, index) {
                  var mObj = moreArr[index];
                  final isLogout = mObj["index"] == "6";
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: TColor.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () => _handleTap(mObj["index"].toString()),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: (mObj["color"] as Color)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  mObj["icon"] as IconData,
                                  size: 22,
                                  color: mObj["color"] as Color,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  mObj["name"].toString(),
                                  style: GoogleFonts.plusJakartaSans(
                                    color: isLogout
                                        ? TColor.primary
                                        : TColor.primaryText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (!isLogout)
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: TColor.placeholder,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(String index) {
    switch (index) {
      case "1":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PaymentDetailsView()));
        break;
      case "2":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ProfileView()));
        break;
      case "3":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const NotificationsView()));
        break;
      case "4":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const InboxView()));
        break;
      case "5":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AboutUsView()));
        break;
      case "7":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const OrderHistoryView()));
        break;
      case "8":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const FavoriteView()));
        break;
      case "6":
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Sign Out',
                style: GoogleFonts.plusJakartaSans(
                    color: TColor.primaryText, fontWeight: FontWeight.w700)),
            content: Text('Are you sure you want to sign out?',
                style: GoogleFonts.plusJakartaSans()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel',
                    style: TextStyle(color: TColor.secondaryText)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ServiceCall.logout();
                },
                child:
                    Text('Sign Out', style: TextStyle(color: TColor.primary)),
              ),
            ],
          ),
        );
        break;
    }
  }
}

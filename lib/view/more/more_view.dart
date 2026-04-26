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
import '../../common/globs.dart';

class MoreView extends StatefulWidget {
  const MoreView({super.key});

  @override
  State<MoreView> createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  final List<Map<String, dynamic>> moreArr = [
    {"index": "1", "name": "Payment Details", "icon": Icons.account_balance_wallet_rounded, "color": const Color(0xFF5C6BC0)},
    {"index": "2", "name": "Profile", "icon": Icons.person_rounded, "color": const Color(0xFF26A69A)},
    {"index": "3", "name": "Notifications", "icon": Icons.notifications_rounded, "color": const Color(0xFFFF7043)},
    {"index": "4", "name": "Inbox", "icon": Icons.chat_rounded, "color": const Color(0xFF42A5F5)},
    {"index": "5", "name": "About Us", "icon": Icons.info_rounded, "color": const Color(0xFF7E57C2)},
    {"index": "7", "name": "Order History", "icon": Icons.receipt_long_rounded, "color": const Color(0xFF66BB6A)},
    {"index": "8", "name": "My Favorites", "icon": Icons.favorite_rounded, "color": const Color(0xFFEC407A)},
    {"index": "6", "name": "Sign Out", "icon": Icons.logout_rounded, "color": const Color(0xFFEF5350)},
  ];

  @override
  Widget build(BuildContext context) {
    final userName = Globs.udValueString("user_name");
    final userEmail = Globs.udValueString("user_email");
    final isLoggedIn = Globs.udValueBool(Globs.userLogin);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: TColor.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Premium Profile Header ───
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [TColor.primary, TColor.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLoggedIn && userName.isNotEmpty
                                  ? userName
                                  : "Welcome!",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (isLoggedIn && userEmail.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                userEmail,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyOrderView()),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Menu Items ───
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var mObj = moreArr[index];
                  final isLogout = mObj["index"] == "6";
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < moreArr.length - 1 ? 8 : 0,
                      top: isLogout ? 8 : 0,
                    ),
                    child: Material(
                      color: isLogout ? TColor.primaryLight : TColor.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => _handleTap(mObj["index"].toString()),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
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
                                  size: 15,
                                  color: TColor.placeholder,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: moreArr.length,
              ),
            ),
          ),
        ],
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
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Sign Out',
                style: GoogleFonts.plusJakartaSans(
                    color: TColor.primaryText,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
            content: Text(
              'Are you sure you want to sign out?',
              style: GoogleFonts.plusJakartaSans(
                color: TColor.secondaryText,
                fontSize: 14,
              ),
            ),
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
        break;
    }
  }
}

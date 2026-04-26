import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List notificationArr = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    await ServiceCall.get(
      "${SVKey.restaurantBaseUrl}/notifications/history",
      isToken: true,
      withSuccess: (responseObj) async {
        if (!mounted) return;
        if (responseObj['status'] == 'success' &&
            responseObj['data'] != null) {
          setState(() {
            notificationArr = responseObj['data'] as List? ?? [];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      },
      failure: (err) async {
        if (!mounted) return;
        setState(() => isLoading = false);
      },
    );
  }

  IconData _iconForNotification(String? type) {
    switch (type?.toLowerCase()) {
      case 'order':
        return Icons.receipt_long_rounded;
      case 'promo':
        return Icons.local_offer_rounded;
      case 'delivery':
        return Icons.delivery_dining_rounded;
      default:
        return Icons.notifications_rounded;
    }
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
          "Notifications",
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
          : notificationArr.isEmpty
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
                        child: Icon(Icons.notifications_off_rounded,
                            size: 44, color: TColor.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No notifications yet",
                        style: GoogleFonts.plusJakartaSans(
                          color: TColor.primaryText,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "We'll notify you when something arrives",
                        style: GoogleFonts.plusJakartaSans(
                          color: TColor.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  physics: const BouncingScrollPhysics(),
                  itemCount: notificationArr.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    var cObj = notificationArr[index] as Map? ?? {};
                    var title = cObj["title"]?.toString() ??
                        cObj["body"]?.toString() ??
                        "Notification";
                    var body = cObj["body"]?.toString() ?? "";
                    var type = cObj["type"]?.toString();
                    var timeStr = cObj["created_at"]?.toString() ?? "";
                    var formattedTime = "";

                    if (timeStr.isNotEmpty) {
                      try {
                        final dt = DateTime.parse(timeStr).toLocal();
                        formattedTime =
                            DateFormat('dd MMM yyyy, h:mm a').format(dt);
                      } catch (_) {
                        formattedTime = timeStr;
                      }
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: TColor.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: TColor.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _iconForNotification(type),
                              color: TColor.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: TColor.primaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (body.isNotEmpty &&
                                    body != title) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    body,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: TColor.secondaryText,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (formattedTime.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    formattedTime,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: TColor.placeholder,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

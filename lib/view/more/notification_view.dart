import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/service_call.dart';
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
      isToken: true, // Assuming this endpoint needs auth
      withSuccess: (responseObj) async {
        if (!mounted) return;
        if (responseObj['status'] == 'success' && responseObj['data'] != null) {
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
          "Notifications",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationArr.isEmpty
              ? Center(
                  child: Text(
                    "No notifications yet",
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: notificationArr.length,
                          separatorBuilder: ((context, index) => Divider(
                                indent: 25,
                                endIndent: 25,
                                color: TColor.secondaryText.withOpacity(0.4),
                                height: 1,
                              )),
                          itemBuilder: ((context, index) {
                            var cObj = notificationArr[index] as Map? ?? {};
                            var title = cObj["title"]?.toString() ??
                                cObj["body"]?.toString() ??
                                "Notification";
                            var timeStr = cObj["created_at"]?.toString() ?? "";
                            var formattedTime = timeStr;
                            if (timeStr.isNotEmpty) {
                              try {
                                final dt = DateTime.parse(timeStr).toLocal();
                                formattedTime =
                                    DateFormat('dd MMM yyyy, h:mm a').format(dt);
                              } catch (_) {}
                            }

                            return Container(
                              decoration: BoxDecoration(
                                  color: index % 2 == 0
                                      ? TColor.white
                                      : TColor.textfield),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 25),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                        color: TColor.primary,
                                        borderRadius:
                                            BorderRadius.circular(4)),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                              color: TColor.primaryText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          formattedTime,
                                          style: TextStyle(
                                              color: TColor.secondaryText,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

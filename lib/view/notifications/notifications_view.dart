import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List notifications = [];
  bool isLoading = true;
  String errorMessage = "";
  int currentPage = 1;
  int totalItems = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });
    NotificationService.fetchNotifications(currentPage, (items, total) {
      if (mounted) {
        setState(() {
          if (currentPage == 1) {
            notifications = items;
          } else {
            notifications.addAll(items);
          }
          totalItems = total;
          isLoading = false;
        });
      }
    }, (error) {
      if (mounted) {
        setState(() {
          errorMessage = error;
          isLoading = false;
        });
      }
    });
  }

  void _markAsRead(String id, int index) {
    NotificationService.markAsRead(id, () {
      if (mounted) {
        setState(() {
          notifications[index]["is_read"] = true;
        });
      }
    }, (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    });
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading && currentPage == 1
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty && notifications.isEmpty
              ? Center(child: Text(errorMessage))
              : notifications.isEmpty
                  ? const Center(child: Text("No notifications yet."))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length + (notifications.length < totalItems ? 1 : 0),
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        if (index == notifications.length) {
                          return Center(
                            child: TextButton(
                              onPressed: () {
                                currentPage++;
                                _fetchData();
                              },
                              child: const Text("Load More"),
                            ),
                          );
                        }

                        var notm = notifications[index] as Map? ?? {};
                        bool isRead = notm["is_read"] as bool? ?? false;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            notm["title"]?.toString() ?? "",
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                notm["body"]?.toString() ?? "",
                                style: TextStyle(
                                  color: TColor.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(notm["created_at"]?.toString() ?? ""),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: isRead
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                  onPressed: () {
                                    _markAsRead(notm["id"]?.toString() ?? "", index);
                                  },
                                ),
                        );
                      },
                    ),
    );
  }
}

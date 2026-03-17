# Quick Setup Guide

## Step 1: Add Provider Setup

In your `main.dart` or wherever you initialize providers:

```dart
import 'package:provider/provider.dart';
import 'package:food_delivery/common/home_provider.dart';
import 'package:food_delivery/common/restaurant_provider.dart';
import 'package:food_delivery/common/menu_provider.dart';
import 'package:food_delivery/common/order_provider.dart';
import 'package:food_delivery/common/foodshare_payment_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => FoodShareProvider()),
      ],
      child: MaterialApp(
        home: Home(),
        // ... rest of config
      ),
    );
  }
}
```

## Step 2: Integrate into Existing Views

### In Home Tab (currently main_tabview.dart)

```dart
import 'package:food_delivery/common/home_provider.dart';
import 'package:food_delivery/models/restaurant.dart';

class HomeTab extends StatefulWidget {
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  
  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() {
    final lat = Globs.udValueDouble('user_lat');
    final lng = Globs.udValueDouble('user_lng');
    
    return context.read<HomeProvider>().fetchHomeData(
      lat: lat > 0 ? lat : null,
      lng: lng > 0 ? lng : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        if (homeProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (homeProvider.errorMessage != null) {
          return ErrorScreen(
            message: homeProvider.errorMessage ?? '',
            onRetry: _loadHomeData,
          );
        }

        final homeData = homeProvider.homeData;
        if (homeData == null) {
          return SizedBox.shrink();
        }

        return ListView(
          children: [
            // Your existing banners code, now use homeData.banners
            if (homeData.banners.isNotEmpty)
              BannerCarousel(banners: homeData.banners),
            
            // Your existing categories, now use homeData.categories
            if (homeData.categories.isNotEmpty)
              CategorySection(categories: homeData.categories),
            
            // Your existing restaurants, now use homeData.recommendedRestaurants
            if (homeData.recommendedRestaurants.isNotEmpty)
              RestaurantSection(restaurants: homeData.recommendedRestaurants),
          ],
        );
      },
    );
  }
}
```

### In Search/Browse Restaurants

```dart
import 'package:food_delivery/common/restaurant_provider.dart';

class RestaurantSearchView extends StatefulWidget {
  final String? initialCategory;
  
  @override
  State<RestaurantSearchView> createState() => _RestaurantSearchViewState();
}

class _RestaurantSearchViewState extends State<RestaurantSearchView> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search([bool reset = true]) {
    if (reset) _currentPage = 1;
    
    final lat = Globs.udValueDouble('user_lat');
    final lng = Globs.udValueDouble('user_lng');
    
    return context.read<RestaurantProvider>().browseRestaurants(
      query: _searchController.text.isEmpty ? null : _searchController.text,
      category: widget.initialCategory,
      page: _currentPage,
      lat: lat > 0 ? lat : null,
      lng: lng > 0 ? lng : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, restaurantProvider, _) {
        final restaurants = restaurantProvider.restaurants;
        
        return Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(hintText: 'Search restaurants...'),
              onChanged: (_) => _search(),
            ),
            Expanded(
              child: restaurantProvider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : restaurantProvider.errorMessage != null
                      ? Center(child: Text(restaurantProvider.errorMessage!))
                      : restaurants?.items.isEmpty ?? true
                          ? Center(child: Text('No restaurants found'))
                          : ListView.builder(
                              itemCount: restaurants!.items.length +
                                  (restaurants.meta.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == restaurants.items.length) {
                                  return Padding(
                                    padding: EdgeInsets.all(8),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _currentPage++;
                                        _search(false);
                                      },
                                      child: Text('Load More'),
                                    ),
                                  );
                                }
                                final restaurant = restaurants.items[index];
                                return RestaurantCard(
                                  restaurant: restaurant,
                                  onTap: () {
                                    // Navigate to menu
                                    Navigator.pushNamed(
                                      context,
                                      '/menu',
                                      arguments: restaurant.id,
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

### In Order History

```dart
import 'package:food_delivery/common/order_provider.dart';

class MyOrdersView extends StatefulWidget {
  @override
  State<MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<MyOrdersView> {
  @override
  void initState() {
    super.initState();
    context.read<OrderProvider>().fetchOrderHistory(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        return orderProvider.isLoading
            ? Center(child: CircularProgressIndicator())
            : orderProvider.errorMessage != null
                ? Center(child: Text('Error: ${orderProvider.errorMessage}'))
                : orderProvider.orderHistory?.orders.isEmpty ?? true
                    ? Center(child: Text('No orders yet'))
                    : ListView.builder(
                        itemCount: orderProvider.orderHistory!.orders.length,
                        itemBuilder: (context, index) {
                          final order =
                              orderProvider.orderHistory!.orders[index];
                          return OrderHistoryCard(
                            order: order,
                            onTap: () {
                              // Navigate to order details
                              Navigator.pushNamed(
                                context,
                                '/order-detail',
                                arguments: order.orderId,
                              );
                            },
                          );
                        },
                      );
      },
    );
  }
}
```

### In Order Detail with Live Tracking

```dart
import 'package:food_delivery/common/order_provider.dart';
import 'package:food_delivery/common/restaurant_api_service.dart';

class OrderDetailView extends StatefulWidget {
  final String orderId;

  OrderDetailView({required this.orderId});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  Map<String, dynamic>? _liveUpdate;
  late StreamSubscription _liveStream;

  @override
  void initState() {
    super.initState();
    context.read<OrderProvider>().fetchOrderDetail(widget.orderId);
    _startLiveTracking();
  }

  void _startLiveTracking() {
    _liveStream = RestaurantApiService.liveOrderTracking(
      orderId: widget.orderId,
    ).listen(
      (event) {
        if (mounted) {
          setState(() => _liveUpdate = event);
        }
      },
      onError: (error) => print('Tracking error: $error'),
    );
  }

  @override
  void dispose() {
    _liveStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        if (orderProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: Text('Order Detail')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final order = orderProvider.currentOrder;
        if (order == null) {
          return Scaffold(
            body: Center(child: Text('Order not found')),
          );
        }

        final currentStatus = _liveUpdate?['status'] ?? order.status;

        return Scaffold(
          appBar: AppBar(title: Text(order.orderId)),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Status
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(label: Text(currentStatus)),
                      SizedBox(height: 8),
                      Text('Est. Delivery: ${order.estimatedDeliveryTime}'),
                    ],
                  ),
                ),
              ),
              // Your existing order detail UI using order object
            ],
          ),
        );
      },
    );
  }
}
```

## Step 3: Update Route Navigation

In your route configuration, add:

```dart
routes: {
  '/menu': (context) {
    final restaurantId = settings.arguments as int;
    return Scaffold(
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (menuProvider.menuData == null) {
              menuProvider.fetchMenu(restaurantId);
            }
          });
          return YourMenuScreen(); // Use menuProvider.menuData
        },
      ),
    );
  },
  '/order-detail': (context) {
    final orderId = settings.arguments as String;
    return OrderDetailView(orderId: orderId);
  },
}
```

## Step 4: Usage Summary

### Fetch Data
```dart
// In any screen
await context.read<HomeProvider>().fetchHomeData();
await context.read<OrderProvider>().fetchOrderHistory();
// etc.
```

### Display with Loading/Error
```dart
Consumer<HomeProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) return LoadingWidget();
    if (provider.errorMessage != null) return ErrorWidget(provider.errorMessage);
    return ContentWidget(provider.homeData);
  },
)
```

### Live Updates (for tracking)
```dart
RestaurantApiService.liveOrderTracking(orderId: 'ORD-123')
  .listen((event) => setState(() => _liveUpdate = event));
```

## API Endpoints Reference

All endpoints are in `RestaurantApiService`:

```
✅ getHomeData()                    → HomeProvider
✅ browseRestaurants()              → RestaurantProvider  
✅ getRestaurantMenu()              → MenuProvider
✅ getOrderHistory()                → OrderProvider
✅ getOrderDetail()                 → OrderProvider
✅ liveOrderTracking()              → Stream (direct consumption)
✅ getPaymentMethods()              → PaymentProvider
✅ createFoodShareSession()         → FoodShareProvider
✅ getActiveFoodShareSessions()     → FoodShareProvider
```

## Common Patterns

### Refresh Data
```dart
Future<void> _refresh() async {
  await context.read<HomeProvider>().fetchHomeData();
}
```

### Error Handling with Toast
```dart
onFailure: (error) async {
  Globs.showHUD('Error: $error');
  // or
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $error')),
  );
}
```

### Pagination
```dart
if (restaurants.meta.hasMore) {
  _page++;
  await provider.browseRestaurants(page: _page);
}
```

---

**You're all set!** 🚀 All APIs are integrated and ready to use.

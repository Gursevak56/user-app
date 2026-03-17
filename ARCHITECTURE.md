# Integration Architecture & Implementation Checklist

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Flutter UI Screens                          │
│  (HomeView, RestaurantList, Menu, OrderHistory, OrderDetail, etc)   │
└────────────────┬─────────────────────────────────────────────────────┘
                 │ Consumer<Provider>
                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                    State Management Layer (Provider)                  │
├─────────────────────────────────────────────────────────────────────┤
│  · HomeProvider         (HomeData)                                    │
│  · RestaurantProvider   (RestaurantListResponse)                      │
│  · MenuProvider         (MenuData)                                    │
│  · OrderProvider        (OrderHistory, OrderDetail)                   │
│  · PaymentProvider      (List<PaymentMethod>)                         │
│  · FoodShareProvider    (FoodShareSession, active sessions)           │
└────────────────┬─────────────────────────────────────────────────────┘
                 │ await provider.fetch*()
                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                      API Service Layer                               │
│          RestaurantApiService (9 endpoints)                          │
├─────────────────────────────────────────────────────────────────────┤
│  · getHomeData()                                                      │
│  · browseRestaurants()                                                │
│  · getRestaurantMenu()                                                │
│  · getOrderHistory()                                                  │
│  · getOrderDetail()                                                   │
│  · liveOrderTracking() [SSE Stream]                                   │
│  · getPaymentMethods()                                                │
│  · createFoodShareSession()                                           │
│  · getActiveFoodShareSessions()                                       │
└────────────────┬─────────────────────────────────────────────────────┘
                 │ HTTP + Bearer Token
                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                  Data Model Layer (Type-Safe)                        │
├─────────────────────────────────────────────────────────────────────┤
│  · HomeData             (Banners, Categories, Restaurants)           │
│  · Restaurant           (Details, ratings, delivery time)            │
│  · MenuData             (Restaurant + MenuCategories + Items)        │
│  · OrderHistoryResponse (List<OrderHistoryItem> + Pagination)        │
│  · OrderDetail          (Full order breakdown + items)               │
│  · PaymentMethod        (Card / UPI methods)                         │
│  · FoodShareSession     (Host, participants, expiry)                 │
└────────────────┬─────────────────────────────────────────────────────┘
                 │ fromJson() parsing
                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                     HTTP Client & Auth Layer                         │
│            (Automatic Bearer token injection via Globs)              │
├─────────────────────────────────────────────────────────────────────┤
│  · Authorization: Bearer {{TOKEN}}                                   │
│  · Token source: SharedPreferences (user_payload)                    │
│  · Debug logging: All requests/responses logged                      │
│  · Error handling: Callback pattern (onSuccess/onFailure)           │
└────────────────┬─────────────────────────────────────────────────────┘
                 │ HTTP calls
                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                    Backend API Endpoints                             │
│        https://restaurant-prod.mangaale.com/api                      │
├─────────────────────────────────────────────────────────────────────┤
│  GET  /home                                                           │
│  GET  /restaurants                                                    │
│  GET  /restaurants/:id/menu                                          │
│  GET  /orders/history                                                │
│  GET  /orders/:orderId                                               │
│  GET  /orders/:orderId/live [SSE]                                    │
│  GET  /users/payment-methods                                         │
│  POST /foodshare                                                      │
│  GET  /foodshare/active                                              │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Example: Home Screen

```
User Opens App
    ↓
initState() in HomeTab
    ↓
context.read<HomeProvider>().fetchHomeData(lat, lng)
    ↓
Provider state: _isLoading = true, notify listeners
    ↓
Consumer<HomeProvider> rebuilds with loading indicator
    ↓
RestaurantApiService.getHomeData(
  lat: lat,
  lng: lng,
  onSuccess: (data) {
    _homeData = data
    _isLoading = false
    notifyListeners()
  },
  onFailure: (error) {
    _errorMessage = error
    _isLoading = false
    notifyListeners()
  }
)
    ↓
HTTP GET /api/home?lat=12.97&lng=77.59
    ↓ [with Authorization: Bearer {{TOKEN}}]
    ↓
Response received → JSON parsed → HomeData.fromJson()
    ↓
if (success) onSuccess(homeData)
    ↓
Provider notifies listeners
    ↓
Consumer<HomeProvider> rebuilds with data
    ↓
Banners, categories, restaurants displayed
```

---

## File Organization

```
lib/
├── common/
│   ├── restaurant_api_service.dart     ← All 9 endpoints
│   ├── home_provider.dart              ← HomeData state
│   ├── restaurant_provider.dart        ← Browse restaurants state
│   ├── menu_provider.dart              ← Menu/details state
│   ├── order_provider.dart             ← Orders state
│   ├── foodshare_payment_provider.dart ← Payment & FoodShare state
│   ├── globs.dart                      ← Token management
│   ├── service_call.dart               ← HTTP client (existing)
│   └── [other existing services]
│
├── models/
│   ├── api_response.dart               ← Envelope + Pagination
│   ├── restaurant.dart                 ← Restaurant models
│   ├── menu.dart                       ← Menu models
│   ├── order.dart                      ← Order models
│   └── payment_and_foodshare.dart      ← Payment & FoodShare models
│
├── view/
│   ├── main_tabview/
│   │   └── main_tabview.dart           ← Update with HomeProvider
│   ├── restaurants/
│   │   └── restaurants.dart            ← Use RestaurantProvider
│   ├── menu/
│   │   └── menu.dart                   ← Use MenuProvider
│   ├── orders/
│   │   ├── order_history.dart          ← Use OrderProvider
│   │   └── order_detail.dart           ← Use OrderProvider + SSE
│   └── [other screens]
│
├── main.dart                           ← Add MultiProvider setup
│
└── root/
    ├── API_INTEGRATION_GUIDE.md        ← Complete API reference
    ├── API_INTEGRATION_EXAMPLES.md     ← 8 screen examples
    ├── QUICK_SETUP_GUIDE.md            ← Integration instructions
    ├── INTEGRATION_SUMMARY.md          ← Overview
    └── ARCHITECTURE.md                 ← This file
```

---

## Implementation Checklist

### Phase 1: Setup (1-2 hours)

- [ ] **Review Architecture**
  - [ ] Read `INTEGRATION_SUMMARY.md`
  - [ ] Read `API_INTEGRATION_GUIDE.md` 
  - [ ] Review this file

- [ ] **Add Model Files**
  - [ ] Copy/verify `lib/models/api_response.dart`
  - [ ] Copy/verify `lib/models/restaurant.dart`
  - [ ] Copy/verify `lib/models/menu.dart`
  - [ ] Copy/verify `lib/models/order.dart`
  - [ ] Copy/verify `lib/models/payment_and_foodshare.dart`

- [ ] **Add Service Files**
  - [ ] Copy/verify `lib/common/restaurant_api_service.dart`
  - [ ] Verify API base URL (should be `https://restaurant-prod.mangaale.com/api`)
  - [ ] Test imports compile without errors

- [ ] **Add Provider Files**
  - [ ] Copy/verify `lib/common/home_provider.dart`
  - [ ] Copy/verify `lib/common/restaurant_provider.dart`
  - [ ] Copy/verify `lib/common/menu_provider.dart`
  - [ ] Copy/verify `lib/common/order_provider.dart`
  - [ ] Copy/verify `lib/common/foodshare_payment_provider.dart`

- [ ] **Main.dart Setup**
  - [ ] Add `MultiProvider` with all 6 providers
  - [ ] Verify app compiles successfully

### Phase 2: Home Screen (1-2 hours)

- [ ] **Integrate Home Data**
  - [ ] Import `HomeProvider` in home view
  - [ ] Call `fetchHomeData()` in `initState()`
  - [ ] Update UI to use `homeProvider.homeData`
  - [ ] Show loading indicator during fetch
  - [ ] Show error message on failure
  - [ ] Test with mock location (lat/lng)

- [ ] **Test Endpoints**
  - [ ] Verify API token is available
  - [ ] Check network logs in debug console
  - [ ] Verify banners display
  - [ ] Verify categories display
  - [ ] Verify recommended restaurants display

### Phase 3: Restaurant Browsing (2-3 hours)

- [ ] **Integrate Restaurant Listing**
  - [ ] Import `RestaurantProvider`
  - [ ] Implement search with query parameter
  - [ ] Implement category filter
  - [ ] Implement sorting (recommended/rating/distance)
  - [ ] Show loading state
  - [ ] Handle errors gracefully

- [ ] **Pagination**
  - [ ] Implement infinite scroll
  - [ ] Load more on scroll to bottom
  - [ ] Check `meta.hasMore` flag
  - [ ] Show loading indicator during page load

- [ ] **Test**
  - [ ] Search by restaurant name
  - [ ] Filter by category
  - [ ] Sort by different options
  - [ ] Verify pagination works
  - [ ] Test error scenarios

### Phase 4: Menu & Restaurant Details (2-3 hours)

- [ ] **Integrate Menu**
  - [ ] Import `MenuProvider`
  - [ ] Call `fetchMenu()` when restaurant selected
  - [ ] Display restaurant info (rating, cuisine, delivery time)
  - [ ] Display menu categories
  - [ ] Display menu items in categories
  - [ ] Show preparation time
  - [ ] Show availability status

- [ ] **Navigation**
  - [ ] Add route for menu screen
  - [ ] Pass restaurant ID as argument
  - [ ] Navigate from restaurant list to menu

- [ ] **Test**
  - [ ] Load menu for multiple restaurants
  - [ ] Verify all items display
  - [ ] Check availability filtering (only available items shown)
  - [ ] Verify ratings and reviews display

### Phase 5: Orders (2-3 hours)

- [ ] **Order History**
  - [ ] Import `OrderProvider`
  - [ ] Call `fetchOrderHistory()` on order screen
  - [ ] Display list of past orders
  - [ ] Show pagination controls if needed
  - [ ] Add pull-to-refresh functionality

- [ ] **Order Details**
  - [ ] Call `fetchOrderDetail()` when order selected
  - [ ] Display full order breakdown
  - [ ] Show all line items
  - [ ] Display payment info (method, status)
  - [ ] Show delivery address

- [ ] **Live Tracking**
  - [ ] Connect to SSE stream using `liveOrderTracking()`
  - [ ] Listen for "snapshot" event
  - [ ] Listen for "status:update" event
  - [ ] Update UI with live status
  - [ ] Handle stream disconnection
  - [ ] Auto-reconnect if needed

- [ ] **Test**
  - [ ] Verify order history loads
  - [ ] Test pagination if applicable
  - [ ] Click into order detail
  - [ ] Verify all order data displays
  - [ ] Test live tracking with active order

### Phase 6: Payment & FoodShare (1-2 hours)

- [ ] **Payment Methods**
  - [ ] Import `PaymentProvider`
  - [ ] Call `fetchPaymentMethods()` on payment screen
  - [ ] Display CARD type methods (last4, brand, expiry)
  - [ ] Display UPI type methods (UPI ID)
  - [ ] Show default method indicator

- [ ] **FoodShare Sessions**
  - [ ] Import `FoodShareProvider`
  - [ ] Create session: `createFoodShareSession()`
  - [ ] Display session creation form
  - [ ] Validate inputs (2-100 participants)
  - [ ] Show success with invite link

- [ ] **Browse FoodShare**
  - [ ] Fetch active sessions: `getActiveFoodShareSessions()`
  - [ ] Display nearby joinable sessions
  - [ ] Show host info, restaurant, participants, expiry
  - [ ] Allow joining sessions

- [ ] **Test**
  - [ ] Verify payment methods display correctly
  - [ ] Create new FoodShare session
  - [ ] Verify invite link generated
  - [ ] Browse active sessions nearby
  - [ ] Test without location (should show all)

### Phase 7: Testing & Polish (2-3 hours)

- [ ] **Comprehensive Testing**
  - [ ] Test all endpoints with real data
  - [ ] Test error scenarios (network, auth, validation)
  - [ ] Test loading states across all screens
  - [ ] Test empty states (no data)
  - [ ] Test pagination at boundaries

- [ ] **Auth Testing**
  - [ ] Verify token injection in all requests
  - [ ] Test 401 error handling
  - [ ] Test token refresh flow
  - [ ] Verify "Authorization: Bearer" header format

- [ ] **Error Handling**
  - [ ] Show user-friendly error messages
  - [ ] Implement retry buttons
  - [ ] Handle network connection errors
  - [ ] Handle timeout errors
  - [ ] Handle validation errors from API

- [ ] **Performance**
  - [ ] Check loading times
  - [ ] Verify no unnecessary rebuilds
  - [ ] Test on slow network
  - [ ] Monitor memory usage

- [ ] **UI/UX Polish**
  - [ ] Add proper loading skeletons
  - [ ] Add pull-to-refresh
  - [ ] Add error retry buttons
  - [ ] Add empty state illustrations
  - [ ] Smooth animations during loading

---

## Common Issues & Solutions

### Issue: "Invalid token" error on all requests

**Solutions:**
1. Verify token is stored in SharedPreferences under `user_payload` key
2. Check `Globs.getToken()` returns non-empty string
3. Verify token format (should include "Bearer " prefix verification only on backend)
4. Check token expiration
5. Verify authorization header format in requests

### Issue: "Missing authorization header" error

**Solution:**
- Ensure all API calls pass `isToken: true` (default)
- Check there's no typo in header name: `Authorization` (capital A)
- Verify Bearer token value is not empty

### Issue: Models not parsing correctly

**Solutions:**
1. Check field names match API response (snake_case vs camelCase)
2. Verify null-safety handling in fromJson()
3. Check numeric fields are converted with `.toDouble()` or `.toInt()`
4. Verify lists parsing with `List<T>.from()`

### Issue: Loading never completes

**Solutions:**
1. Verify `notifyListeners()` called in both onSuccess and onFailure
2. Check for exceptions not being caught
3. Verify isLoading flag is set to false
4. Check network timeout (may need retry logic)

### Issue: Live tracking stream not receiving events

**Solutions:**
1. Verify order is in a live-trackable state
2. Check stream is being listened to
3. Verify no stream cancellation before events arrive
4. Check for SSE event parsing issues

---

## Testing Curl Commands

Test endpoints manually before integrating:

```bash
# Home Data
curl -X GET "https://restaurant-prod.mangaale.com/api/home?lat=12.9716&lng=77.5946" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Browse Restaurants
curl -X GET "https://restaurant-prod.mangaale.com/api/restaurants?page=1&limit=20" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Restaurant Menu
curl -X GET "https://restaurant-prod.mangaale.com/api/restaurants/123/menu" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Order History
curl -X GET "https://restaurant-prod.mangaale.com/api/orders/history?page=1&limit=10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Payment Methods
curl -X GET "https://restaurant-prod.mangaale.com/api/users/payment-methods" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Create FoodShare
curl -X POST "https://restaurant-prod.mangaale.com/api/foodshare" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "restaurantId": 1,
    "groupName": "Office Lunch",
    "maxParticipants": 5,
    "splitType": "INDIVIDUAL"
  }'
```

---

## Success Criteria

✅ All 9 endpoints integrated and working
✅ Proper loading/error states on all screens
✅ Auth errors handled correctly
✅ Data models type-safe and properly validated
✅ Live tracking receiving updates
✅ Pagination working correctly
✅ No memory leaks
✅ User experience smooth and responsive

---

## Support Documents

| Document | Purpose |
|----------|---------|
| `API_INTEGRATION_GUIDE.md` | Complete API reference (share with backend team) |
| `API_INTEGRATION_EXAMPLES.md` | 8 working screen examples + signatures |
| `QUICK_SETUP_GUIDE.md` | Step-by-step integration instructions |
| `INTEGRATION_SUMMARY.md` | Overview of all changes |
| `ARCHITECTURE.md` | This file - system design & checklist |

---

**Ready to build! 🚀**

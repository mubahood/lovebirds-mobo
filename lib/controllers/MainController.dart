// ignore: file_names
// ignore: file_names
import 'package:get/get.dart';
import 'package:lovebirds_app/models/LoggedInUserModel.dart';
import 'package:lovebirds_app/models/ManifestModel.dart'; // <-- Import ManifestModel
import 'package:lovebirds_app/models/ManifestService.dart'; // <-- Import ManifestService
import 'package:lovebirds_app/models/MovieModel.dart';

import '../models/MyRole.dart';
import '../models/SeriesModel.dart';
import '../screens/shop/models/CartItem.dart';
import '../screens/shop/models/Product.dart';
import '../screens/shop/models/ProductCategory.dart';
import '../utils/Utilities.dart';

class MainController extends GetxController {
  // --- Existing State Variables ---

  LoggedInUserModel loggedInUser = LoggedInUserModel();
  LoggedInUserModel userModel = LoggedInUserModel();

  List<MovieModel> movies = []; // Keep for potential separate movie listings
  List<SeriesModel> series = []; // Keep for potential separate series listings

  RxList<dynamic> categories = <ProductCategory>[].obs;
  RxList<dynamic> products = <Product>[].obs;

  RxList<dynamic> cartItems = <CartItem>[].obs;
  RxList<dynamic> watchedMovies = <MovieModel>[].obs;
  RxList<dynamic> myProducts = <Product>[].obs;

  // --- New Manifest State ---
  final ManifestService _manifestService =
      ManifestService(); // Instance of the service
  Rx<ManifestModel?> manifestModel = Rx<ManifestModel?>(
    null,
  ); // Observable for manifest data
  RxBool isManifestLoading = false.obs; // Observable loading state for manifest

  /// Initializes essential data for the controller.
  /// Loads the manifest first, then other relevant data.
  init() async {
    // Load the manifest data initially
    await loadManifest();

    return; // Explicit return
  }

  Future<void> removeFromCart(String id) async {
    await CartItem.deleteAt("product_id = '$id'");
    await getCartItems();
    update();
  }

  Future<void> getMyProducts() async {
    if (userModel.id < 1) {
      await getLoggedInUser();
    }
    if (userModel.id < 1) {
      myProducts.clear();
      return;
    }
    myProducts.clear();
    for (var element in (await Product.getItems(
      where: 'user = ${userModel.id}',
    ))) {
      myProducts.add(element);
    }
    myProducts.sort((a, b) => b.id.compareTo(a.id));
    update();
    return;
  }

  Future<void> getCategories() async {
    categories.value = await ProductCategory.getItems();
    update();
  }

  /// Fetches and updates the manifest data from the service.
  Future<void> loadManifest() async {
    isManifestLoading.value = true;
    try {
      final data = await _manifestService.getManifest();
      manifestModel.value = ManifestModel.fromJson(data);
      // Optional: You could potentially populate 'movies' or other lists
      // here if the manifest is the primary source, e.g.:
      // _populateDataFromManifest();
    } catch (e) {
      print("Error loading manifest: $e");
      manifestModel.value = null; // Set to null on error
      // Optionally show a user-facing error message via Get.snackbar
    } finally {
      isManifestLoading.value = false;
      update(); // Notify listeners
    }
  }

  // --- Existing Methods (potentially refactor based on manifest) ---

  Future<void> getWatchedMovies() async {
    // This likely remains independent of the manifest
    watchedMovies.value = await MovieModel.get_items(
      where: "watched_movie = 'Yes'",
    );
    update();
  }

  getOrders() async {
    update();
  }

  Future<void> getProducts() async {
    products.value = await Product.getItems();
    //shuffle products.value
    products.shuffle();
    products.shuffle();
    update();
    return;
  }

  Future<void> addToCart(
    Product pro, {
    String color = "",
    String size = "",
  }) async {
    await getCartItems();
    for (var element in cartItems) {
      if (element.product_id == pro.id.toString()) {
        Utils.toast("Item already in cart.");
        return;
      }
    }

    //await CartItem.deleteAll();
    CartItem c = CartItem();
    c.id = pro.id;
    c.product_id = pro.id.toString();
    c.product_name = pro.name;
    c.product_price_1 = pro.price_1;
    c.product_quantity = '1';
    c.product_feature_photo = pro.feature_photo;
    c.color = color;
    c.size = size;
    await c.save();
    await getCartItems();
  }

  List<String> cartItemsIDs = [];
  var count = 0.obs; // Consider renaming for clarity (e.g., cartItemCount)
  double tot = 0;

  Future<void> getCartItems() async {
    cartItems.clear();
    cartItemsIDs.clear();
    tot = 0;
    cartItemsIDs.clear();
    for (var element in (await CartItem.getItems())) {
      cartItems.add(element);
      cartItemsIDs.add(element.id.toString());
      if (element.pro.id < 1) {
        await element.getPro();
      }
      if (element.pro.id > 0) {
        if (element.pro.p_type == 'Yes') {
          element.pro.getPrices();
          int qty = Utils.int_parse(element.product_quantity);
          for (var price in element.pro.pricesList) {
            if (qty >= price.min_qty && qty <= price.max_qty) {
              element.product_price_1 = price.price;
              break;
            }
          }
        } else {
          element.product_price_1 = element.pro.price_1;
        }
        tot +=
            Utils.double_parse(element.product_quantity) *
            Utils.double_parse(element.product_price_1);
      } else {
        Utils.toast("Product ${element.product_name} not found.");
      }
      update();
    }
  }

  List<MyRole> roles = [];
  bool canManageFarmers = false;
  bool canAnswerQuestions = false;

  String myRole = "";

  Future<void> getLoggedInUser() async {
    loggedInUser = await LoggedInUserModel.getLoggedInUser();

    userModel = loggedInUser; // Update userModel as well
    update(); // Notify listeners of user data change
    return;
  }

  var raw; // Consider giving 'raw' a more specific type if possible (Map<String, dynamic>?)

  getWeather(String lati, String long) async {
    // Basic validation for latitude and longitude
    if (lati.isEmpty || long.isEmpty) {
      print("Error: Latitude or Longitude is empty.");
      return;
    }
  }
}

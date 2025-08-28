// ignore: file_names
// ignore: file_names
import 'package:get/get.dart';
import 'package:lovebirds_app/models/LoggedInUserModel.dart';
import 'package:lovebirds_app/models/MovieModel.dart';

import '../../../utils/Utilities.dart';
import '../models/CartItem.dart';
import '../models/ChatHead.dart';
import '../models/OrderOnline.dart';
import '../models/Product.dart';

class MainController extends GetxController {
  var count = 0.obs;
  var tot = 0.obs;

  RxList<dynamic> chatHeads = <ChatHead>[].obs;
  RxList<dynamic> myProducts = <Product>[].obs;
  RxList<dynamic> products = <Product>[].obs;
  RxList<dynamic> cartItems = <CartItem>[].obs;
  RxList<dynamic> myOrders = <OrderOnline>[].obs;
  RxList<dynamic> watchedMovies = <MovieModel>[].obs;

  List<String> cartItemsIDs = [];
  LoggedInUserModel userModel = LoggedInUserModel();

  @override
  void onInit() {
    super.onInit();
    init();
  }

  init() async {
    await getLoggedInUser();
    return;
    getCartItems();
    getProducts();
    getMyProducts();
    getChatHeads();
    /* await getMyClasses();
    await getMySubjects();
    await getMyStudents();*/
  }

  Future<void> getLoggedInUser() async {
    userModel = await LoggedInUserModel.getLoggedInUser();
    return;
  }

  Future<void> addToCart(Product pro) async {
    if (cartItemsIDs.contains(pro.id.toString())) {
      return;
    }
    await CartItem.deleteAll();
    CartItem c = CartItem();
    c.id = pro.id;
    c.product_id = pro.id.toString();
    c.product_name = pro.name;
    c.product_price_1 = pro.price_1;
    c.product_quantity = '1';
    c.product_feature_photo = pro.feature_photo;
    await c.save();
    await getCartItems();
  }

  Future<void> getProducts() async {
    products.value = await Product.getItems();
    update();
    return;
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
    for (var element
        in (await Product.getItems(where: 'user = ${userModel.id}'))) {
      myProducts.add(element);
    }
    update();
    return;
  }

  bool listenersStarted = false;

  Future<void> getChatHeads() async {
    if (userModel.id < 1) {
      await getLoggedInUser();
    }
    if (userModel.id < 1) {
      chatHeads.clear();
      return;
    }
    chatHeads.clear();
    for (var element in (await ChatHead.get_items(userModel))) {
      element.myUnread(userModel);
      chatHeads.add(element);
    }
    update();
    return;
  }

  Future<void> getWatchedMovies() async {
    watchedMovies.value = await MovieModel.get_items(
      where: "watched_movie = 'Yes'",
    );
    update();
  }

  getCartItems() async {
    cartItems.clear();
    cartItemsIDs.clear();
    tot.value = 0;
    for (var element in (await CartItem.getItems())) {
      cartItems.add(element);
      cartItemsIDs.add(element.id.toString());
      tot.value += Utils.int_parse(element.product_quantity) *
          Utils.int_parse(element.product_price_1);
    }
    update();
  }

  getOrders() async {
    myOrders.value = await OrderOnline.getItems();
    update();
  }

  increment() => count++;

  decrement() => count--;
}

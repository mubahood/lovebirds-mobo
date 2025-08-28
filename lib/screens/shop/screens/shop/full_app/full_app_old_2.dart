// import 'package:flutter/material.dart';
// import 'package:flutx/flutx.dart';
//
// import '../../../../../theme/custom_theme.dart';
// import '../../../models/Product.dart';
// import '../widgets.dart';
//
// class FullApp2 extends StatefulWidget {
//   const FullApp2({Key? key}) : super(key: key);
//
//   @override
//   _FullApp2State createState() => _FullApp2State();
// }
//
// class _FullApp2State extends State<FullApp2>
//     with SingleTickerProviderStateMixin {
//   late ThemeData theme;
//
//   @override
//   void initState() {
//     super.initState();
//
//     doRefresh();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: CustomTheme.primary,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         titleSpacing: 0,
//         title: FxText.titleLarge(
//           "Products",
//           color :Colors.white,
//           maxLines: 2,
//         ),
//       ),
//       body: SafeArea(
//         child: FutureBuilder(
//             future: futureInit,
//             builder: (context, snapshot) {
//               switch (snapshot.connectionState) {
//                 case ConnectionState.waiting:
//                   return const Center(
//                     child: Text("⌛ Loading..."),
//                   );
//                 default:
//                   return mainWidget();
//               }
//             }),
//       ),
//     );
//   }
//
//   Widget mainWidget() {
//     return Container(
//       padding: const EdgeInsets.only(left: 5, right: 5),
//       child: RefreshIndicator(
//         backgroundColor: Colors.white,
//         onRefresh: doRefresh,
//         child: CustomScrollView(
//           slivers: [
//             SliverList(
//               delegate: SliverChildBuilderDelegate(
//                     (BuildContext context, int index) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(
//                         height: 25,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(
//                             left: 15, right: 15, bottom: 15),
//                         child: FxText.bodyLarge(
//                           "Recently posted ${items.length} products",
//                           height: 1,
//                           fontWeight : 800,
//                         ),
//                       ),
//                       const Divider(),
//                       const SizedBox(
//                         height: 15,
//                       ),
//                     ],
//                   );
//                 },
//                 childCount: 1, // 1000 list items
//               ),
//             ),
//             SliverList(
//               delegate: SliverChildBuilderDelegate(
//                     (BuildContext context, int index) {
//                   Product m = items[index];
//                   return productWidget(m);
//                 },
//                 childCount: items.length, // 1000 list items
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   late Future<dynamic> futureInit;
//
//   Future<dynamic> doRefresh() async {
//     futureInit = myInit();
//     setState(() {});
//   }
//
//   List<Product> items = [];
//
//   Future<dynamic> myInit() async {
//     items = await Product.getItems();
//     return "Done";
//   }
//
//   menuItemWidget(String title, String subTitle, Function screen) {
//     return InkWell(
//       onTap: () => {screen()},
//       child: Container(
//         padding: const EdgeInsets.only(left: 0, bottom: 5, top: 20),
//         decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(color: CustomTheme.primary, width: 2),
//             )),
//         child: Flex(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           direction: Axis.horizontal,
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   FxText.titleLarge(
//                     title,
//                     color :Colors.black,
//                     fontWeight : 900,
//                   ),
//                   FxText.bodyLarge(
//                     subTitle,
//                     height: 1,
//                     fontWeight : 600,
//                     color :Colors.grey.shade700,
//                   ),
//                   const SizedBox(
//                     height: 15,
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(
//               Icons.chevron_right,
//               size: 35,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

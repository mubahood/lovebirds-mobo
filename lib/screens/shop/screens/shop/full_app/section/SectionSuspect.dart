// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_feather_icons/flutter_feather_icons.dart';
// import 'package:flutx/flutx.dart';
//
// import '../../../../../../utils/CustomTheme.dart';
// import '../../../../../../utils/Utilities.dart';
// import '../../../../../../widget/widgets.dart';
// class SectionSuspect extends StatefulWidget {
//   const SectionSuspect({Key? key}) : super(key: key);
//
//   @override
//   _SectionSuspectState createState() => _SectionSuspectState();
// }
//
// class _SectionSuspectState extends State<SectionSuspect> {
//   late Future<dynamic> futureInit;
//
//   Future<dynamic> do_refresh() async {
//     futureInit = init();
//     setState(() {});
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     do_refresh();
//   }
//
//   Random random = Random();
//
//   Future<dynamic> init() async {
//     return "Done";
//   }
//
//
//   Future<dynamic> doRefresh() async {
//     futureInit = init();
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         systemOverlayStyle: Utils.overlay(),
//         elevation: .5,
//         title: Row(
//           children: [
//             FxContainer(
//               width: 10,
//               height: 20,
//               color :CustomTheme.primary,
//               borderRadiusAll: 2,
//             ),
//             FxSpacing.width(8),
//             FxText.titleLarge(
//               "Finance",
//               fontWeight : 900,
//             ),
//             const Spacer(),
//             FxContainer(
//               color :CustomTheme.primary.withAlpha(20),
//               padding:
//               const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
//               child: Row(
//                 children: [
//                   FxText(
//                     "Sort",
//                     fontWeight : 700,
//                     color :CustomTheme.primaryDark,
//                     fontSize: 16,
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Icon(
//                     FeatherIcons.filter,
//                     size: 20,
//                     color :CustomTheme.primaryDark,
//                   )
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: FutureBuilder(
//             future: futureInit,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return myListLoaderWidget();
//               }
//             /*  if (items.isEmpty) {
//                 return noItemWidget( () {
//                   do_refresh();
//                 });
//               }*/
//
//               return Container(
//                 padding: const EdgeInsets.only(left: 5, right: 5),
//                 child: RefreshIndicator(
//                   backgroundColor: Colors.white,
//                   onRefresh: doRefresh,
//                   child: CustomScrollView(
//                     slivers: [
//                       SliverList(
//                         delegate: SliverChildBuilderDelegate(
//                           (BuildContext context, int index) {
//                             return const SizedBox(
//                               height: 10,
//                             );
//                           },
//                           childCount: 1, // 1000 list items
//                         ),
//                       ),
//                       SliverList(
//                         delegate: SliverChildBuilderDelegate(
//                           (BuildContext context, int index) {
//
//                             return InkWell(
//                               onTap: () {
//
//                               },
//                               child: Column(
//                                 children: [
//                                   Flex(
//                                     direction: Axis.horizontal,
//                                     children: [
//                                       FxContainer(
//                                         color :
//                                             CustomTheme.primary.withAlpha(20),
//                                         paddingAll: 10,
//                                         margin: const EdgeInsets.only(
//                                             left: 10,
//                                             right: 10,
//                                             bottom: 0,
//                                             top: 0),
//                                         child: Icon(
//                                           m.amount < 1
//                                               ? FeatherIcons.arrowUp
//                                               : FeatherIcons.arrowDown,
//                                           color :m.amount < 1
//                                               ? Colors.red.shade800
//                                               : Colors.green.shade800,
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             FxText.bodySmall(
//                                                 Utils.to_date(m.created_at)),
//                                             FxText.titleMedium(
//                                               m.farm_text,
//                                               maxLines: 1,
//                                               color :Colors.grey.shade800,
//                                               fontWeight : 800,
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                       FxText.bodyLarge(
//                                         Utils.moneyFormat(m.amount.toString()),
//                                         fontWeight : 700,
//                                         color :(m.amount < 0)
//                                             ? Colors.red.shade700
//                                             : Colors.green.shade700,
//                                       ),
//                                       const SizedBox(
//                                         width: 10,
//                                       )
//                                     ],
//                                   ),
//                                   const Padding(
//                                     padding:
//                                         EdgeInsets.only(left: 10, right: 10),
//                                     child: Divider(),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                           childCount: items.length, // 1000 list items
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               );
//             }),
//       ),
//     );
//   }
// }

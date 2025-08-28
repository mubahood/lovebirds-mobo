import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../dating/UsersListScreen.dart';
import '../../chat/ChatsScreen.dart';
import '../../movies/DownloadListScreen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menu")),
      body: Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.people),
                title: FxText.titleLarge("Users listing"),
                onTap: () {
                  Get.to(() => const UsersListScreen());
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              ),

              ListTile(
                leading: const Icon(Icons.chat),
                title: FxText.titleLarge("Chat Heads"),
                onTap: () {
                  Get.to(() => const ChatsScreen());
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: FxText.titleLarge("Downloads"),
                onTap: () {
                  Get.to(() => const DownloadListScreen());
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

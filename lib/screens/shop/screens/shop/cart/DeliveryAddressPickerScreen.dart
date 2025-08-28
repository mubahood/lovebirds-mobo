import 'package:flutter/material.dart';
import 'package:flutx/widgets/text/text.dart';

import '../../../../../models/DeliveryAddress.dart';
import '../../../../../utils/AppConfig.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../widgets.dart';

class DeliveryAddressPickerScreen extends StatefulWidget {
  const DeliveryAddressPickerScreen({super.key});

  @override
  State<DeliveryAddressPickerScreen> createState() =>
      _DeliveryAddressPickerScreenState();
}

class _DeliveryAddressPickerScreenState
    extends State<DeliveryAddressPickerScreen> {
  List<DeliveryAddress> items = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myInit();
  }

  bool isLoading = false;

  Future<void> myInit() async {
    items = await DeliveryAddress.get_items();
    setState(() {
      isLoading = true;
    });
    if (items.isEmpty) {
      await DeliveryAddress.getOnlineItems();
      items = await DeliveryAddress.get_items();
    } else {
      DeliveryAddress.getOnlineItems();
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Address')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
              ? noItemWidget('No item found.', () {
                myInit();
              })
              : ListView.separated(
                separatorBuilder: (context, index) => const Divider(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index].address),
                    subtitle: Row(
                      children: [
                        const Text('Shipping Cost: '),
                        FxText(
                          "${AppConfig.CURRENCY} ${Utils.moneyFormat(items[index].shipping_cost)}",
                          color: CustomTheme.primary,
                          fontWeight: 900,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context, items[index]);
                    },
                  );
                },
              ),
    );
  }
}

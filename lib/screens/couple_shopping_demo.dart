import 'package:flutter/material.dart';
import '../widgets/dating/couple_shopping_widget.dart';
import '../theme/dating_theme.dart';

class CoupleShoppingDemoScreen extends StatelessWidget {
  const CoupleShoppingDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Couple Shopping Demo',
      theme: DatingTheme.lightTheme,
      home: const CoupleShoppingWidget(
        partnerId: 'demo_partner_123',
        partnerName: 'Sarah',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Demo entry point
void main() {
  runApp(const CoupleShoppingDemoScreen());
}

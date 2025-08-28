import 'package:flutter/material.dart';
import '../widgets/dating/milestone_gift_suggestions_widget.dart';
import '../theme/dating_theme.dart';

class MilestoneGiftSuggestionsDemo extends StatelessWidget {
  const MilestoneGiftSuggestionsDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Milestone Gift Suggestions Demo',
      theme: DatingTheme.lightTheme,
      home: const MilestoneGiftSuggestionsWidget(
        partnerId: 'demo_partner_456',
        partnerName: 'Emma',
        relationshipStartDate: '2024-12-01', // About 2 months ago
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Demo entry point
void main() {
  runApp(const MilestoneGiftSuggestionsDemo());
}

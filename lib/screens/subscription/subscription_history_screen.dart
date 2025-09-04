import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/RespondModel.dart';
import '../../utils/dating_theme.dart';
import '../../utils/Utilities.dart';

class SubscriptionHistoryScreen extends StatefulWidget {
  const SubscriptionHistoryScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionHistoryScreenState createState() =>
      _SubscriptionHistoryScreenState();
}

class _SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen> {
  List<dynamic> _subscriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionHistory();
  }

  Future<void> _loadSubscriptionHistory() async {
    setState(() => _isLoading = true);

    try {
      final response = await Utils.http_get('subscription-history', {});
      final resp = RespondModel(response);

      if (resp.code == 1) {
        setState(() {
          _subscriptions = resp.data ?? [];
        });
      } else {
        Utils.toast('Failed to load subscription history');
      }
    } catch (e) {
      Utils.toast('Error loading subscription history: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshPaymentStatus(String subscriptionId) async {
    try {
      final response = await Utils.http_post('refresh-subscription-payment', {
        'subscription_id': subscriptionId,
      });

      final resp = RespondModel(response);
      if (resp.code == 1) {
        Utils.toast('Payment status refreshed successfully');
        await _loadSubscriptionHistory(); // Reload the list
      } else {
        Utils.toast('Failed to refresh payment status');
      }
    } catch (e) {
      Utils.toast('Error refreshing payment status: $e');
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatAmount(double? amount, String? currency) {
    if (amount == null) return 'N/A';
    return '\$${amount.toStringAsFixed(2)} ${currency ?? 'CAD'}';
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSubscriptionCard(dynamic subscription) {
    final status = subscription['status'] ?? 'unknown';
    final isPaid = subscription['payment_status'] == 'paid';
    final isActive = subscription['status'] == 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: DatingTheme.cardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subscription['plan_name'] ?? 'Premium Subscription',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Details
            _buildDetailRow(
              'Amount',
              _formatAmount(
                subscription['amount']?.toDouble(),
                subscription['currency'],
              ),
            ),
            _buildDetailRow('Plan Type', subscription['plan_type'] ?? 'N/A'),
            _buildDetailRow(
              'Start Date',
              _formatDate(subscription['start_date']),
            ),
            _buildDetailRow('End Date', _formatDate(subscription['end_date'])),
            _buildDetailRow(
              'Payment Status',
              subscription['payment_status'] ?? 'unknown',
            ),

            if (subscription['stripe_subscription_id'] != null)
              _buildDetailRow(
                'Subscription ID',
                subscription['stripe_subscription_id'],
              ),

            // Action Buttons
            if (!isPaid || status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          () => _refreshPaymentStatus(
                            subscription['id'].toString(),
                          ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Payment Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DatingTheme.primaryPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (isActive) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      () => _showCancelConfirmation(
                        subscription['id'].toString(),
                      ),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Subscription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(String subscriptionId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: DatingTheme.cardBackground,
            title: const Text(
              'Cancel Subscription',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to cancel this subscription? You will lose access to premium features at the end of your current billing period.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Keep Subscription',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _cancelSubscription(subscriptionId);
                },
                child: const Text(
                  'Cancel Subscription',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _cancelSubscription(String subscriptionId) async {
    try {
      final response = await Utils.http_post('cancel-subscription', {
        'subscription_id': subscriptionId,
      });

      final resp = RespondModel(response);
      if (resp.code == 1) {
        Utils.toast('Subscription cancelled successfully');
        await _loadSubscriptionHistory(); // Reload the list
      } else {
        Utils.toast('Failed to cancel subscription');
      }
    } catch (e) {
      Utils.toast('Error cancelling subscription: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DatingTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: DatingTheme.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Subscription History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSubscriptionHistory,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: DatingTheme.primaryPink,
                ),
              )
              : _subscriptions.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Subscriptions Found',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You haven\'t purchased any premium subscriptions yet.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to subscription plans
                        Get.toNamed('/subscription-plans');
                      },
                      icon: const Icon(Icons.star),
                      label: const Text('Browse Premium Plans'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DatingTheme.primaryPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadSubscriptionHistory,
                color: DatingTheme.primaryPink,
                backgroundColor: DatingTheme.cardBackground,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _subscriptions.length,
                  itemBuilder: (context, index) {
                    return _buildSubscriptionCard(_subscriptions[index]);
                  },
                ),
              ),
    );
  }
}

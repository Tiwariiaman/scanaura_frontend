import 'package:flutter/material.dart';

import '../pages/business_loyalty_verify_page.dart';

class LoyaltyVerifyButton extends StatelessWidget {
  const LoyaltyVerifyButton({
    super.key,
  });

  Future<void> _openScanner(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BusinessLoyaltyVerifyPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _openScanner(context),
        icon: const Icon(
          Icons.qr_code_scanner_rounded,
        ),
        label: const Text(
          'Verify / Scan Customer QR',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
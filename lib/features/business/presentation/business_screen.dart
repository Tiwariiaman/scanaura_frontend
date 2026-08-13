import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/business_notifier.dart';
import 'providers/business_state.dart';

class BusinessScreen extends ConsumerStatefulWidget {
  const BusinessScreen({super.key});

  @override
  ConsumerState<BusinessScreen> createState() =>
      _BusinessScreenState();
}

class _BusinessScreenState
    extends ConsumerState<BusinessScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(businessNotifierProvider.notifier)
          .loadMyBusiness();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(businessNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business API Test'),
      ),
      body: Center(
        child: _buildContent(state),
      ),
    );
  }

  Widget _buildContent(BusinessState state) {
    switch (state.status) {
      case BusinessStatus.initial:
        return const Text(
          'Checking business...',
        );

      case BusinessStatus.loading:
        return const CircularProgressIndicator();

      case BusinessStatus.success:
        final business = state.business;

        return Text(
          'Business found:\n\n'
              'Name: ${business?.businessName}\n'
              'Type: ${business?.businessType}\n'
              'Phone: ${business?.phone}',
          textAlign: TextAlign.center,
        );

      case BusinessStatus.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ??
                  'Unable to load business.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(
                  businessNotifierProvider.notifier,
                )
                    .loadMyBusiness();
              },
              child: const Text('Retry'),
            ),
          ],
        );
    }
  }
}
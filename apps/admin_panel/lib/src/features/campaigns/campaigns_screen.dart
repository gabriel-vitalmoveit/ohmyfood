import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_data.dart';

class CampaignsScreen extends HookConsumerWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Campanhas & promoções', style: OhMyFoodTypography.titleLg),
              FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Nova campanha')),
            ],
          ),
          const SizedBox(height: OhMyFoodSpacing.lg),
          Expanded(
            child: ListView.separated(
              itemCount: campaignTemplates.length,
              separatorBuilder: (_, __) => const SizedBox(height: OhMyFoodSpacing.md),
              itemBuilder: (context, index) {
                final campaign = campaignTemplates[index];
                return Card(
                  child: ListTile(
                    title: Text(campaign['name']!),
                    subtitle: Text('${campaign['reach']} • Budget ${campaign['budget']}'),
                    trailing: Chip(label: Text(campaign['status']!)),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

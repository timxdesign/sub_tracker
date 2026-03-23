import 'package:flutter/material.dart';

import 'looping_asset_marquee.dart';

class AnimatedShowcaseSection extends StatelessWidget {
  const AnimatedShowcaseSection({
    super.key,
    required this.cardAssets,
    required this.logoAssets,
  });

  final List<String> cardAssets;
  final List<String> logoAssets;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 127,
          child: LoopingAssetMarquee(
            assetPaths: cardAssets,
            itemWidth: 167,
            itemHeight: 127,
            spacing: 8,
            duration: const Duration(seconds: 28),
            semanticPrefix: 'Card',
            initialProgress: 1050 / 1448,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 74.33,
          child: LoopingAssetMarquee(
            assetPaths: logoAssets,
            itemWidth: 74.33,
            itemHeight: 74.33,
            spacing: 3,
            duration: const Duration(seconds: 18),
            semanticPrefix: 'Logo',
            reverse: true,
          ),
        ),
      ],
    );
  }
}

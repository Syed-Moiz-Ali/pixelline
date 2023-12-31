// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdScreenBody extends StatelessWidget {
  late NativeAd ad;

  AdScreenBody({Key? key, required this.ad}) : super(key: key);

  @override
  // void initState() {
  //   super.initState();
  //   initializing();
  // }

  // Future<void> initializing() async {
  //   widget.ad = NativeAd(
  //     adUnitId: adsNative,
  //     request: const AdRequest(),
  //     nativeTemplateStyle:
  //         NativeTemplateStyle(templateType: TemplateType.medium),
  //     listener: NativeAdListener(
  //       onAdLoaded: (ads) {
  //         setState(() {
  //           widget.ad = ads as NativeAd;
  //         });
  //       },
  //       onAdFailedToLoad: (ad, err) {
  //         if (kDebugMode) {
  //           print('Failed to load a banner ad: ${err.message}');
  //         }
  //         ad.dispose();
  //       },
  //     ),
  //   );
  //   widget.ad.load();
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: AdWidget(
        ad: ad,
      ),
    );
  }
}

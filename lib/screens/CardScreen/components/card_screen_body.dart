// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:like_button/like_button.dart';
import 'package:pixelline/components/AdUnits/ads_units_ids.dart';
import 'package:pixelline/components/ImageComponent/image_component.dart';
import 'package:pixelline/screens/AdScreen/ad_screen.dart';
import 'package:pixelline/services/Appwrite/appwrite_sevices.dart';
import 'package:pixelline/services/types/wallpaper.dart';
import 'package:pixelline/screens/DetailScreen/detail_screen.dart';
import 'package:pixelline/util/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardScreenBody extends StatefulWidget {
  String? type;
  final List<Wallpaper> content;

  CardScreenBody({Key? key, required this.content, this.type = 'card'})
      : super(key: key);

  @override
  _CardScreenBodyState createState() => _CardScreenBodyState();
}

class _CardScreenBodyState extends State<CardScreenBody> {
  List<Wallpaper> documents = [];

  late String documentId;
  bool isAdded = true;
  late RealtimeSubscription subscribtion;
  late final WallpaperStorage<Wallpaper> wallpaperStorage;
  NativeAd? nativeAd;
  @override
  void initState() {
    super.initState();
    subscribe();
    initializing().then(
      (_) => loadFavorites(),
    );
  }

  Future<void> initializing() async {
    final prefs = await SharedPreferences.getInstance();
    nativeAd = NativeAd(
      adUnitId: adsNative,
      request: const AdRequest(),
      nativeTemplateStyle:
          NativeTemplateStyle(templateType: TemplateType.medium),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            nativeAd = ad as NativeAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          if (kDebugMode) {
            print('Failed to load a banner ad: ${err.message}');
          }
          ad.dispose();
        },
      ),
    );
    nativeAd!.load();
    final newData = WallpaperStorage<Wallpaper>(
        storageKey: 'favorites',
        fromJson: (json) => Wallpaper.fromJson(json),
        toJson: (videos) => videos.toJson(),
        prefs: prefs);
    setState(() {
      wallpaperStorage = newData;
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;

    if (screenWidth <= 400) {
      crossAxisCount = 2;
    } else if (screenWidth >= 400 && screenWidth <= 600) {
      crossAxisCount = 2;
    } else if (screenWidth >= 600 && screenWidth <= 800) {
      crossAxisCount = 3;
    } else if (screenWidth >= 800) {
      crossAxisCount = 4;
    }

    return crossAxisCount;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (kDebugMode) {
      print(widget.type);
    }
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  // height: widget.type!.contains('similar') ? 25 : 70,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 8.0),
                  child: widget.type!.contains('similar')
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Similar :',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(context),
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  mainAxisExtent: 300,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if ((screenWidth <= 600
                            ? index % 30 == 0
                            : index % 30 == 0) &&
                        index != 0 &&
                        nativeAd != null) {
                      // Show the ad after every 10 cards (adjust as needed)
                      return AdScreen(
                        ad: nativeAd!,
                      );
                    } else {
                      // Show a regular card
                      final Wallpaper wallpaper =
                          widget.content[index - (index ~/ 30)];
                      final newImage = wallpaper.url;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                imageUrl: wallpaper.url,
                                imageId: wallpaper.id,
                                wallpaper: wallpaper,
                              ),
                            ),
                          ).then((_) {
                            loadFavorites();
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Stack(
                            children: [
                              ImageComponent(
                                  imagePath:
                                      newImage), // Change to your image source

                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: Center(
                                  child: LikeButton(
                                    onTap: (isLiked) => onLikeButtonTap(
                                        isLiked, context, wallpaper, index),
                                    size: 42,
                                    likeBuilder: (bool isLiked) {
                                      bool isInFavorites =
                                          checkIfInFavorites(wallpaper.id);
                                      return ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20000),
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          color: Colors.black26,
                                          child: Icon(
                                            Icons.favorite,
                                            color: isInFavorites
                                                ? Colors.red
                                                : Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  childCount:
                      widget.content.length + (widget.content.length ~/ 30),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 30,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool checkIfInFavorites(id) {
    for (var document in documents) {
      if (document.id == id) {
        return true;
      }
    }
    return false;
  }

  Future<void> loadFavorites() async {
    final jsonStringList = await wallpaperStorage.getDataList();
    await wallpaperStorage.restoreData();
    setState(() {
      documents = jsonStringList;
    });
  }

  Future<void> addToFavorites(Wallpaper item) async {
    Wallpaper videos = item;
    documents.add(item);
    // print(item.url);
    await wallpaperStorage.storeData(videos, context).then(
          (_) => loadFavorites(),
        );
  }

  Future<void> removeFromFavorites(id) async {
    await wallpaperStorage.removeData(id, context).then(
          (_) => loadFavorites(),
        );
  }

  void showRemoveDialog(BuildContext context, String imageId, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                "Warning..!!",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Text("Are you sure you want to remove this item?"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel", style: TextStyle(fontSize: 16.0)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                removeFromFavorites(imageId).then((_) => loadFavorites());
                Navigator.of(context).pop(true);
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              label: const Text("Remove", style: TextStyle(fontSize: 16.0)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> toggleFavorite(context, image, index) async {
    if (checkIfInFavorites(image)) {
      showRemoveDialog(context, image, index);
    } else {
      await addToFavorites(image);
      loadFavorites();
    }
    return true; // Return true to indicate that the like state has been changed
  }

  Future<bool?> onLikeButtonTap(
      bool isLiked, context, Wallpaper wallpaper, index) async {
    // Check if the image is in favorites
    bool isInFavorites = checkIfInFavorites(wallpaper.id);

    if (isInFavorites) {
      // If it's in favorites, show the remove dialog and return false
      showRemoveDialog(context, wallpaper.id, index);
      return false;
    } else {
      // If it's not in favorites, add it and return true
      await addToFavorites(wallpaper);
      loadFavorites();
      return true;
    }
  }

  void subscribe() {
    subscribtion = realtime.subscribe(['documents']);
    subscribtion.stream.listen((event) {
      final eventType = event.events;
      final payload = event.payload;

      if (eventType.contains('database.*.collections.*.documents.*.create')) {
        handleDocumentCreation(payload);
      } else if (eventType
          .contains('database.*.collections.*.documents.*.delete')) {
        handleDocumentUpdate(payload);
      }
    });
  }

  void handleDocumentCreation(Map<String, dynamic> payload) {
    setState(() {
      loadFavorites();
    });
  }

  void handleDocumentUpdate(Map<String, dynamic> payload) {
    setState(() {
      loadFavorites();
    });
  }

  @override
  void dispose() {
    super.dispose();

    subscribtion.close();
  }
}

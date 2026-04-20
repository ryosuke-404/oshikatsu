import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:oshikatu/screens/settings/add_oshi_screen.dart';
// App() はアプリのメインウィジェット

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<VideoPlayerController> _videoControllers;

  // 3つのスライドに合わせたコンテンツ (ローカルアセット版)
  final List<Map<String, dynamic>> onboardingPages = [
    {
      'videoAsset': 'assets/onboarding_1.mp4',
      'title': 'onboarding_page1_title',
      'description': 'onboarding_page1_description',
    },
    {
      'videoAsset': 'assets/onboarding_2.mp4',
      'title': 'onboarding_page2_title',
      'description': 'onboarding_page2_description',
    },
    {
      'videoAsset': 'assets/onboarding_3.mp4',
      'title': 'onboarding_page3_title',
      'description': 'onboarding_page3_description',
    },
  ];

  @override
  void initState() {
    super.initState();
    _videoControllers = onboardingPages.map((page) {
      // VideoPlayerController.networkUrl から .asset に変更
      final controller = VideoPlayerController.asset(page['videoAsset']);
      controller.initialize().then((_) {
        // 最初のページの動画のみ再生開始
        if (onboardingPages.indexOf(page) == 0) {
          controller.play();
          setState(() {});
        }
        controller.setLooping(true);
      });
      return controller;
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    // 前のページの動画を停止
    _videoControllers[_currentPage].pause();
    setState(() {
      _currentPage = index;
    });
    // 新しいページの動画を再生
    _videoControllers[index].play();
  }

  void _finishOnboarding() async {
    final settingsBox = Hive.box('settings');
    await settingsBox.put('hasRunBefore', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => const AddOshiScreen(fromOnboarding: true)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingPages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return OnboardingPageContent(
                    videoController: _videoControllers[index],
                    title: (onboardingPages[index]['title'] as String).tr(),
                    description:
                        (onboardingPages[index]['description'] as String).tr(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingPages.length,
                      (index) => buildDot(index, context),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // 「始める」ボタンのみを最後のページに表示するコンテナ
                  SizedBox(
                    width: double.infinity,
                    height: 50, // ボタンの高さを確保し、レイアウトが崩れないようにする
                    child: _currentPage == onboardingPages.length - 1
                        ? ElevatedButton(
                            onPressed: _finishOnboarding,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'start_button'.tr(),
                              style: const TextStyle(fontSize: 18),
                            ),
                          )
                        : null, // 他のページでは何も表示しない
                  ),
                  // スキップボタンがあった場所のスペースを確保
                  const SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Theme.of(context).primaryColor
            : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class OnboardingPageContent extends StatelessWidget {
  final VideoPlayerController videoController;
  final String title;
  final String description;

  const OnboardingPageContent({
    super.key,
    required this.videoController,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: SizedBox.expand(
            // Ensures the child fills the available space
            child: videoController.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.contain, // 動画全体が収まるように変更
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: videoController.value.size.width,
                      height: videoController.value.size.height,
                      child: VideoPlayer(videoController),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}

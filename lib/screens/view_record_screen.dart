import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/record_model.dart';
import '../../models/oshi_model.dart';
import '../../services/theme_provider.dart';
import 'edit_record_screen.dart';
import '../../utils/custom_page_route.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching URLs
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // For YouTube Player

class ViewRecordScreen extends StatelessWidget {
  final Record record;
  const ViewRecordScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: Text(record.title),
        foregroundColor: isLightMode ? Colors.black87 : Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                  CustomPageRoute(child: EditRecordScreen(record: record)));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Display
            if (record.imagePath != null && record.imagePath!.isNotEmpty)
              Image.file(File(record.imagePath!),
                  fit: BoxFit.cover, width: double.infinity, height: 300)
            else
              Container(
                height: 300,
                color:
                    themeProvider.isNeonMode ? Colors.black : Colors.grey[200],
                child: Center(
                  child: Text(
                    tr(categoryDetails[record.category]!['name'] as String),
                    style: TextStyle(color: Colors.grey[600], fontSize: 24),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Date
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          record.title,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('yyyy/MM/dd').format(record.date),
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isLightMode ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // Reduced space
                  // Category Display
                  Row(
                    children: [
                      Icon(
                        categoryDetails[record.category]!['icon'] as IconData,
                        color:
                            categoryDetails[record.category]!['color'] as Color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tr(categoryDetails[record.category]!['name'] as String),
                        style: TextStyle(
                          fontSize: 16,
                          color: isLightMode
                              ? Colors.blueGrey[700]
                              : Colors.blueGrey[200],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Oshi Name
                  if (record.oshiId != null)
                    ValueListenableBuilder<Box<Oshi>>(
                      valueListenable: Hive.box<Oshi>('oshis').listenable(),
                      builder: (context, oshiBox, _) {
                        final oshi = oshiBox.get(record.oshiId);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'oshi_label_prefix'.tr() +
                                (oshi?.name ?? 'unknown_oshi'.tr()),
                            style: TextStyle(
                              fontSize: 16,
                              color: isLightMode
                                  ? Colors.blueGrey[700]
                                  : Colors.blueGrey[200],
                            ),
                          ),
                        );
                      },
                    ),

                  // Rating
                  RatingBarIndicator(
                    rating: record.rating,
                    itemBuilder: (context, index) =>
                        const Icon(Icons.star, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 24.0,
                  ),
                  const SizedBox(height: 16),

                  // Memo
                  if (record.memo != null && record.memo!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('memo_label'.tr(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(record.memo!,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Emotion Tags
                  if (record.emotionTags.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('emotion_tags_label'.tr(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: record.emotionTags
                              .map((tag) => Chip(label: Text(tag)))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Related URL
                  if (record.relatedUrl != null &&
                      record.relatedUrl!.isNotEmpty)
                    _buildRelatedUrlSection(context, record.relatedUrl!),

                  // Setlist
                  if (record.setlist != null && record.setlist!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('setlist_label'.tr(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: record.setlist!.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Text('${index + 1}.'),
                              title: Text(record.setlist![index]),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedUrlSection(BuildContext context, String url) {
    final List<String> embeddableDomains = [
      'youtube.com',
      'youtu.be',
      'twitter.com',
      'x.com',
      'instagram.com',
      'facebook.com',
      'tiktok.com',
      'open.spotify.com',
      'music.apple.com'
    ];

    bool isEmbeddableUrl = false;
    for (String domain in embeddableDomains) {
      if (url.contains(domain)) {
        isEmbeddableUrl = true;
        break;
      }
    }

    if (isEmbeddableUrl) {
      String? videoId; // For YouTube specifically
      double contentHeight = 600; // Default height for social media

      if (url.contains('youtube.com') || url.contains('youtu.be')) {
        videoId = YoutubePlayer.convertUrlToId(url);
        contentHeight = 250; // Optimized height for YouTube videos
      }

      final Uri? parsedUri = Uri.tryParse(url);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('related_content_label'.tr(),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text('open_in_external_browser'.tr()),
              onPressed: () => _launchUrlExternal(context, url),
            ),
          ),
          // Specific app launch buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (url.contains('pinterest.com'))
                _buildAppLaunchButton(
                    context, 'Pinterest', Icons.push_pin, 'pinterest://', url),
              if (url.contains('weverse.io') || url.contains('weverse.com'))
                _buildAppLaunchButton(context, 'Weverse', Icons.apps,
                    'weverse://', url), // Generic app icon for now
              if (url.contains('threads.net'))
                _buildAppLaunchButton(context, 'Threads', Icons.forum,
                    'threads://', url), // Generic forum icon for now
            ],
          ),
          SizedBox(
            height: contentHeight,
            width: double.infinity,
            child: videoId != null
                ? YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: videoId,
                      flags: const YoutubePlayerFlags(
                        autoPlay: false,
                        mute: false,
                      ),
                    ),
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.blueAccent,
                  )
                : (parsedUri != null
                    ? InAppWebView(
                        initialUrlRequest:
                            URLRequest(url: WebUri(parsedUri.toString())),
                        initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                            javaScriptCanOpenWindowsAutomatically: true,
                            javaScriptEnabled: true,
                            mediaPlaybackRequiresUserGesture: false,
                            // Add other options as needed
                          ),
                          android: AndroidInAppWebViewOptions(
                            useHybridComposition: true,
                          ),
                        ),
                        onWebViewCreated: (InAppWebViewController controller) {
                          // You can store the controller if needed for later use
                        },
                        onProgressChanged:
                            (InAppWebViewController controller, int progress) {
                          // Update loading bar.
                        },
                        onLoadStart:
                            (InAppWebViewController controller, Uri? url) {},
                        onLoadStop:
                            (InAppWebViewController controller, Uri? url) {},
                        onLoadError: (InAppWebViewController controller,
                            Uri? url, int code, String message) {},
                        shouldOverrideUrlLoading:
                            (InAppWebViewController controller,
                                NavigationAction navigationAction) async {
                          final uri = navigationAction.request.url;
                          if (uri != null) {
                            // If it's a YouTube URL, open it in the YouTube player.
                            final String? youtubeVideoId =
                                YoutubePlayer.convertUrlToId(uri.toString());
                            if (youtubeVideoId != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => YoutubePlayerFullScreen(
                                      videoId: youtubeVideoId),
                                ),
                              );
                              return NavigationActionPolicy
                                  .CANCEL; // Prevent webview from loading it
                            }

                            // For all other URLs, cancel navigation and show a message.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('cannot_navigate_message'.tr())),
                            );
                            return NavigationActionPolicy.CANCEL;
                          }
                          return NavigationActionPolicy
                              .CANCEL; // Should not happen if uri is null
                        },
                      )
                    : Center(
                        child: Text('invalid_url_message'
                            .tr()))), // Display message for invalid URL
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    // Fallback to a clickable link if not an embeddable URL
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('related_url_label'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildLinkRow(context, 'URL', url),
        const SizedBox(height: 16),
      ],
    );
  }

  // Helper to launch URL externally
  Future<void> _launchUrlExternal(BuildContext context, String url) async {
    String normalizedUrl = url;
    if (!normalizedUrl.startsWith('http://') &&
        !normalizedUrl.startsWith('https://')) {
      normalizedUrl = 'https://$normalizedUrl';
    }
    final uri = Uri.parse(normalizedUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('could_not_launch_url'.tr(args: [normalizedUrl]))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_launching_url'.tr(args: [e.toString()]))),
      );
    }
  }

  Widget _buildLinkRow(BuildContext context, String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _launchUrlExternal(context, url),
              child: Text(
                url,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .primary, // Theme-aware link color
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build app launch buttons
  Widget _buildAppLaunchButton(BuildContext context, String appName,
      IconData icon, String urlScheme, String webUrl) {
    return TextButton.icon(
      icon: Icon(icon),
      label: Text(appName),
      onPressed: () async {
        try {
          if (await canLaunchUrl(Uri.parse(urlScheme))) {
            await launchUrl(Uri.parse(urlScheme),
                mode: LaunchMode.externalApplication);
          } else {
            // Fallback to web URL if app scheme fails
            _launchUrlExternal(context, webUrl);
          }
        } catch (e) {
          // Fallback to web URL if any error occurs
          _launchUrlExternal(context, webUrl);
        }
      },
    );
  }
}

class YoutubePlayerFullScreen extends StatelessWidget {
  final String videoId;
  const YoutubePlayerFullScreen({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        title: Text('youtube_video_title'.tr()),
        foregroundColor: isLightMode ? Colors.black87 : Colors.white,
      ),
      body: Center(
        child: YoutubePlayer(
          controller: YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
            ),
          ),
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.blueAccent,
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// For date formatting
import 'package:url_launcher/url_launcher.dart'; // For launching URLs
import '../../models/oshi_model.dart';
import '../../utils/custom_page_route.dart';
import 'edit_oshi_screen.dart'; // Assuming this is the existing edit screen

class ViewOshiScreen extends StatelessWidget {
  final Oshi oshi;

  const ViewOshiScreen({super.key, required this.oshi});

  @override
  Widget build(BuildContext context) {
    final appBarForegroundColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.black87 // ライトモードでは黒系の色
            : Colors.white; // ダークモードでは白

    return Scaffold(
      appBar: AppBar(
        title: Text(oshi.name),
        foregroundColor: appBarForegroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context)
                  .push(CustomPageRoute(child: EditOshiScreen(oshi: oshi)));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    (oshi.imagePath != null && oshi.imagePath!.isNotEmpty)
                        ? FileImage(File(oshi.imagePath!))
                        : null,
                child: (oshi.imagePath == null || oshi.imagePath!.isEmpty)
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('name_label'.tr(), oshi.name),
            _buildDetailRow(
                'level_label'.tr(), 'oshi_level_${oshi.level.name}'.tr()),
            _buildDetailRow('start_date_label'.tr(),
                DateFormat('date_format_long'.tr()).format(oshi.startDate)),

            if (oshi.officialWebsite != null &&
                oshi.officialWebsite!.isNotEmpty)
              _buildLinkRow(context, 'official_website_label'.tr(),
                  oshi.officialWebsite!),
            if (oshi.twitterUrl != null && oshi.twitterUrl!.isNotEmpty)
              _buildLinkRow(context, 'twitter_x_label'.tr(), oshi.twitterUrl!),
            if (oshi.instagramUrl != null && oshi.instagramUrl!.isNotEmpty)
              _buildLinkRow(
                  context, 'instagram_label'.tr(), oshi.instagramUrl!),
            if (oshi.facebookUrl != null && oshi.facebookUrl!.isNotEmpty)
              _buildLinkRow(context, 'facebook_label'.tr(), oshi.facebookUrl!),
            if (oshi.tiktokUrl != null && oshi.tiktokUrl!.isNotEmpty)
              _buildLinkRow(context, 'tiktok_label'.tr(), oshi.tiktokUrl!),
            if (oshi.youtubeUrl != null && oshi.youtubeUrl!.isNotEmpty)
              _buildLinkRow(context, 'youtube_label'.tr(), oshi.youtubeUrl!),
            if (oshi.spotifyUrl != null && oshi.spotifyUrl!.isNotEmpty)
              _buildLinkRow(context, 'spotify_label'.tr(), oshi.spotifyUrl!),
            if (oshi.appleMusicUrl != null && oshi.appleMusicUrl!.isNotEmpty)
              _buildLinkRow(
                  context, 'apple_music_label'.tr(), oshi.appleMusicUrl!),
            if (oshi.pinterestUrl != null && oshi.pinterestUrl!.isNotEmpty)
              _buildLinkRow(
                  context, 'pinterest_label'.tr(), oshi.pinterestUrl!),
            if (oshi.threadsUrl != null && oshi.threadsUrl!.isNotEmpty)
              _buildLinkRow(context, 'threads_label'.tr(), oshi.threadsUrl!),
            if (oshi.weverseUrl != null && oshi.weverseUrl!.isNotEmpty)
              _buildLinkRow(context, 'weverse_label'.tr(), oshi.weverseUrl!),

            if (oshi.mainColorValue != null)
              _buildColorDetailRow(
                  'main_color_label'.tr(), Color(oshi.mainColorValue!)),
            if (oshi.subColorValue != null)
              _buildColorDetailRow(
                  'sub_color_label'.tr(), Color(oshi.subColorValue!)),
            // Add more Oshi details here as needed
          ],
        ),
      ),
    );
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
              onTap: () async {
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
                          content: Text('could_not_launch_url'
                              .tr(args: [normalizedUrl]))),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'error_launching_url'.tr(args: [e.toString()]))),
                  );
                }
              },
              child: Text(
                url,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
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

  Widget _buildDetailRow(String label, String value) {
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
            child: Flexible(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorDetailRow(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8), // Add a small gap
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final bool isNeonMode;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.iconColor,
    required this.isNeonMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = isNeonMode ? Colors.grey[900]! : Colors.white;
    final Color textColor = isNeonMode ? Colors.white : Colors.black;
    final Color subtitleColor =
        isNeonMode ? Colors.grey[400]! : Colors.grey[600]!;
    final Color splashColor = iconColor.withOpacity(0.2);

    return Card(
      elevation: isNeonMode ? 8.0 : 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: cardColor,
      shadowColor: isNeonMode
          ? iconColor.withOpacity(0.5)
          : Colors.grey.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: isNeonMode
            ? BorderSide(color: iconColor, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: splashColor,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40.0, color: iconColor),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: subtitleColor, size: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

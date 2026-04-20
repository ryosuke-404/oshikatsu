import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../../models/mission_model.dart';
import '../../services/theme_provider.dart';
import './add_mission_screen.dart';

class MissionManagementScreen extends StatefulWidget {
  const MissionManagementScreen({super.key});

  @override
  State<MissionManagementScreen> createState() =>
      _MissionManagementScreenState();
}

class _MissionManagementScreenState extends State<MissionManagementScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showDepositDialog(Mission mission) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('deposit_to_mission_title'.tr(args: [mission.title])),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: 'amount_label'.tr(), prefixText: '¥'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('cancel'.tr())),
            FilledButton(
              onPressed: () {
                final amount = int.tryParse(amountController.text) ?? 0;
                if (amount > 0) {
                  final newDeposit =
                      Deposit(date: DateTime.now(), amount: amount);
                  mission.currentAmount += amount;
                  mission.deposits.add(newDeposit);
                  mission.save();
                  if (mission.currentAmount >= mission.goalAmount) {
                    _confettiController.play();
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text('deposit_button'.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Mission>('missions');

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<Mission> box, _) {
                  final missions = box.values.toList();
                  if (missions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.flag_outlined,
                              size: 80, color: Color(0xFFBDBDBD)),
                          const SizedBox(height: 16),
                          Text(
                            'no_missions_message'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: missions.length,
                    itemBuilder: (context, index) {
                      final mission = missions[index];
                      return _buildMissionCard(mission);
                    },
                  );
                },
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissionCard(Mission mission) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final progress = (mission.goalAmount > 0)
        ? (mission.currentAmount / mission.goalAmount).clamp(0.0, 1.0)
        : 0.0;
    final remainingDays = mission.deadline.difference(DateTime.now()).inDays;
    final isAchieved = progress >= 1.0;

    final remainingAmount = (mission.goalAmount - mission.currentAmount)
        .clamp(0, mission.goalAmount);
    final dailyTarget =
        remainingDays > 0 ? (remainingAmount / remainingDays).ceil() : 0;

    final currencyFormatter = NumberFormat.currency(locale: 'ja', symbol: '¥');

    final missionIcon = mission.icon ?? Icons.flag;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        key: PageStorageKey(mission.id), // Ensure state is preserved on scroll
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(missionIcon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(mission.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
                if (isAchieved)
                  Chip(
                      label: Text('achieved_chip'.tr(),
                          style: const TextStyle(color: Colors.red)),
                      backgroundColor: themeProvider.isNeonMode
                          ? Colors.black
                          : Colors.white),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _navigateToEditScreen(mission);
                    } else if (value == 'delete') {
                      _showDeleteConfirmDialog(mission);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                        value: 'edit', child: Text('edit_menu_item'.tr())),
                    PopupMenuItem<String>(
                        value: 'delete', child: Text('delete'.tr())),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(currencyFormatter.format(mission.currentAmount),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(currencyFormatter.format(mission.goalAmount),
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            // LinearProgressIndicator(
            //   value: progress,
            //   minHeight: 12,
            //   borderRadius: BorderRadius.circular(6),
            //   backgroundColor: Colors.grey[300],
            //   valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            // ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (!isAchieved && remainingDays >= 0)
                  Text(
                      'days_left_label'
                          .tr(namedArgs: {'days': remainingDays.toString()}),
                      style: const TextStyle(color: Colors.grey)),
                if (remainingDays < 0 && !isAchieved)
                  Text('deadline_expired_label'.tr(),
                      style: const TextStyle(color: Colors.red)),
              ],
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('today_target_label'.tr(),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                        isAchieved
                            ? 'achieved_label'.tr()
                            : currencyFormatter.format(dailyTarget),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                FilledButton.icon(
                  onPressed:
                      isAchieved ? null : () => _showDepositDialog(mission),
                  icon: const Icon(Icons.savings),
                  label: Text('deposit_patience_button'.tr()),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        themeProvider.themeData.primaryColor.withOpacity(0.8),
                    shadowColor:
                        themeProvider.themeData.primaryColor.withOpacity(0.5),
                    elevation: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen(Mission mission) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AddMissionScreen(mission: mission),
          ),
        )
        .then((_) => setState(() {})); // Refresh list after editing
  }

  void _showDeleteConfirmDialog(Mission mission) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('confirm'.tr()),
        content: Text('delete_mission_confirm_message'
            .tr(namedArgs: {'title': mission.title})),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('cancel'.tr())),
          TextButton(
            onPressed: () {
              try {
                mission.delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('mission_deleted_message'.tr()),
                      backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('mission_delete_failed_message'
                          .tr(args: [e.toString()])),
                      backgroundColor: Colors.redAccent),
                );
              }
              Navigator.of(ctx).pop();
            },
            child:
                Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

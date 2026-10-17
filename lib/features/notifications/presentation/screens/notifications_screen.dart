import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';
import '../../domain/entities/coach_notification.dart';
import '../widgets/notification_card.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late final NotificationsController _ctrl;

  /// One AnimationController per notification id (drives dismiss animation).
  final Map<String, AnimationController> _animCtrl = {};

  /// Frozen snapshot used while the clear animation is playing.
  List<CoachNotification>? _clearingSnapshot;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<NotificationsController>();
  }

  @override
  void dispose() {
    for (final c in _animCtrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  AnimationController _getCtrl(String id) => _animCtrl.putIfAbsent(
        id,
        () => AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        ),
      );

  Future<void> _onMarkAllRead() async {
    await _ctrl.markAllRead();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    }
  }

  Future<void> _onClearAll() async {
    if (_isClearing) return;
    final notifs = List<CoachNotification>.from(_ctrl.notifications);
    if (notifs.isEmpty) return;

    setState(() {
      _isClearing = true;
      _clearingSnapshot = notifs;
    });

    // Animate from bottom card upward — 80 ms stagger between each.
    for (int i = notifs.length - 1; i >= 0; i--) {
      final delay = (notifs.length - 1 - i) * 80;
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) _getCtrl(notifs[i].id).forward();
      });
    }

    // Wait for the last card's animation to finish, then delete.
    await Future.delayed(
      Duration(milliseconds: (notifs.length - 1) * 80 + 400),
    );
    await _ctrl.clearAll();

    if (mounted) {
      setState(() {
        _isClearing = false;
        _clearingSnapshot = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'read') _onMarkAllRead();
              if (v == 'clear') _onClearAll();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'read',
                child: Text('Mark all as read'),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Text('Clear all'),
              ),
            ],
          ),
        ],
      ),
      body: _isClearing
          ? _buildClearingView()
          : Obx(() {
              if (_ctrl.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              final notifs = _ctrl.notifications;
              if (notifs.isEmpty) return _buildEmpty();
              return _buildList(notifs);
            }),
    );
  }

  /// Shows the frozen snapshot with each card being animated out.
  Widget _buildClearingView() {
    final notifs = _clearingSnapshot ?? [];
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: notifs.length,
      itemBuilder: (_, i) => NotificationCard(
        notif: notifs[i],
        animation: _getCtrl(notifs[i].id),
      ),
    );
  }

  /// Normal list driven by the GetX stream.
  Widget _buildList(List<CoachNotification> notifs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: notifs.length,
      itemBuilder: (_, i) {
        final n = notifs[i];
        final ctrl = _getCtrl(n.id);
        // Reset if the card reappears after a cancelled clear.
        if (ctrl.value > 0) ctrl.reset();
        return NotificationCard(notif: n, animation: ctrl);
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No new notifications',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

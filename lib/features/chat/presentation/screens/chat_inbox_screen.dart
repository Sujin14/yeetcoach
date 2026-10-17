import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/widgets/shimmers/chat_inbox_shimmer.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../../domain/entities/chat_participant.dart';
import '../controllers/chat_inbox_controller.dart';
import '../widgets/chat_placeholder.dart';
import '../widgets/chat_thread_tile.dart';

class ChatInboxScreen extends GetView<ChatInboxController> {
  /// False when shown as the Chats tab, where there's nothing to go back to.
  final bool showBackButton;

  const ChatInboxScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: showBackButton ? null : 16,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        title: const Text(
          'Chats',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const ChatInboxShimmer();
        if (controller.hasError.value) {
          return const ChatPlaceholder(
            icon: Icons.cloud_off_outlined,
            title: 'Could not load messages',
            message: 'Check your connection and try again.',
          );
        }
        final threads = controller.threads.toList();
        if (threads.isEmpty) {
          return const ChatPlaceholder(
            icon: Icons.chat_bubble_outline,
            title: 'No conversations yet',
            message: 'Open a client and tap Message to start chatting.',
          );
        }
        // Read here. ListView builds its rows later, so Obx would miss updates
        // to a profile or unread count that arrive after the threads.
        final participants = Map<String, ChatParticipant>.of(controller.participants);
        final unreadCounts = Map<String, int>.of(controller.unreadCounts);
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemCount: threads.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 80, color: AppColors.divider),
          itemBuilder: (_, index) {
            final thread = threads[index];
            return ChatThreadTile(
              thread: thread,
              participant: participants[thread.clientUid],
              unreadCount: unreadCounts[thread.id] ?? 0,
              onTap: () => controller.openChat(thread),
            );
          },
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/routes/app_routes.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/widgets/confirmation_dialog.dart';
import 'package:yeetcoach/features/calls/domain/entities/call_type.dart';
import 'package:yeetcoach/core/widgets/shimmers/chat_messages_shimmer.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_avatar.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_placeholder.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController _controller;

  @override
  void initState() {
    super.initState();
    // Resolved once: Get.arguments follows the top-most route. ChatBinding registered the tag.
    final clientUid = switch (Get.arguments) {
      {'clientUid': String uid} => uid,
      _ => '',
    };
    _controller = Get.find<ChatController>(tag: AppRoutes.chatControllerTag(clientUid));
  }

  void _openClient(String uid) {
    Get.toNamed(AppRoutes.clientDetails, arguments: {'uid': uid});
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Chat',
      message: 'Are you sure you want to delete the entire chat?',
    );
    if (!confirmed || !mounted) return;
    final deleted = await _controller.deleteChat();
    if (!mounted || !deleted) return;
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Obx(() {
          final client = controller.client.value;
          if (client == null) return const SizedBox.shrink();
          return GestureDetector(
            onTap: () => _openClient(client.uid),
            child: Row(
              children: [
                ChatAvatar(
                  name: client.name,
                  photoUrl: client.photoUrl,
                  radius: 18,
                  backgroundColor: AppColors.onPrimary,
                  foregroundColor: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: Text(
                    client.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          );
        }),
        actions: [
          Obx(() {
            final ready = controller.client.value != null && !controller.isStartingCall.value;
            final canDelete = !controller.isDeleting.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.call_outlined),
                  tooltip: 'Voice call',
                  onPressed: ready ? () => controller.startCall(CallType.audio) : null,
                ),
                IconButton(
                  icon: const Icon(Icons.videocam_outlined),
                  tooltip: 'Video call',
                  onPressed: ready ? () => controller.startCall(CallType.video) : null,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'More',
                  enabled: canDelete,
                  onSelected: (value) {
                    if (value == 'delete') _confirmDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Chat', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const ChatMessagesShimmer();
              final messages = controller.messages;
              if (messages.isEmpty) {
                return ChatPlaceholder(
                  icon: Icons.waving_hand_outlined,
                  title: 'Say hello',
                  message: 'Send ${controller.client.value?.name ?? 'your client'} your first message.',
                );
              }
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.sm),
                itemCount: messages.length,
                itemBuilder: (_, index) {
                  final message = messages[index];
                  return MessageBubble(
                    key: ValueKey(message.id),
                    message: message,
                    isMine: message.senderId == controller.coachUid,
                  );
                },
              );
            }),
          ),
          Obx(() => ChatInputBar(
                controller: controller.textController,
                canSend: controller.canSend.value && !controller.isSending.value,
                onSend: controller.send,
              )),
        ],
      ),
    );
  }
}

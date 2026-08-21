import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:genui_pokemon/models/message_model.dart';
import 'package:genui_pokemon/provider/conversation_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ChatState {
  const ChatState({
    this.messages = const [],
    this.isProcessing = false,
    required this.surfaceController,
  });

  final List<Message> messages;
  final bool isProcessing;
  final SurfaceController surfaceController;

  ChatState copyWith({
    List<Message>? messages,
    bool? isProcessing,
    SurfaceController? surfaceController,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isProcessing: isProcessing ?? this.isProcessing,
      surfaceController: surfaceController ?? this.surfaceController,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ChatSessionNotifier extends Notifier<ChatState> {
  late final Conversation _conversation;
  late final SurfaceController _surfaceController;

  @override
  ChatState build() {
    _conversation = ref.watch(genuiConversationProvider);
    _surfaceController = _conversation.controller;

    final eventsSub = _conversation.events.listen(_onConversationEvent);
    ref.onDispose(eventsSub.cancel);

    _conversation.state.addListener(_onConversationStateChanged);
    ref.onDispose(
      () => _conversation.state.removeListener(_onConversationStateChanged),
    );

    return ChatState(surfaceController: _surfaceController);
  }

  /// Sends a user message and processes the AI response.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _appendMessage(Message.user(text));
    await _conversation.sendRequest(ChatMessage.user(text));
  }

  /// Invalidate the transport to empty history and rebuild this notifier
  void clearConversation() {
    ref.invalidate(genuiConversationProvider);
  }

  // -- Private helpers -------------------------------------------------------

  void _appendMessage(Message msg) {
    state = state.copyWith(messages: [...state.messages, msg]);
  }

  void _onTextChunk(String chunk) {
    final msgs = List<Message>.from(state.messages);
    final last = msgs.isNotEmpty ? msgs.last : null;

    if (last != null && !last.isUser && last.text != null) {
      // Append chunk to the existing AI text bubble.
      msgs[msgs.length - 1] = Message.aiText((last.text ?? '') + chunk);
    } else {
      msgs.add(Message.aiText(chunk));
    }
    state = state.copyWith(messages: msgs);
  }

  void _onConversationEvent(ConversationEvent event) {
    switch (event) {
      case ConversationContentReceived(:final text):
        _onTextChunk(text);
      case ConversationSurfaceAdded(:final surfaceId):
        final already = state.messages.any((m) => m.surfaceId == surfaceId);
        if (!already) _appendMessage(Message.aiSurface(surfaceId));
      case ConversationSurfaceRemoved(:final surfaceId):
        state = state.copyWith(
          messages: state.messages
              .where((m) => m.surfaceId != surfaceId)
              .toList(),
        );
      case ConversationComponentsUpdated():
      case ConversationWaiting():
      case ConversationError():
        break;
    }
  }

  void _onConversationStateChanged() {
    final isWaiting = _conversation.state.value.isWaiting;
    if (state.isProcessing != isWaiting) {
      state = state.copyWith(isProcessing: isWaiting);
    }
  }
}

/// Provides the [ChatState] and conversation management logic for the chat screen.
final conversationProvider = NotifierProvider<ChatSessionNotifier, ChatState>(
  ChatSessionNotifier.new,
);

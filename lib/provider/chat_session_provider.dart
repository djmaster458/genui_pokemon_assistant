// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:genui_pokemon/models/message_model.dart';
import 'package:genui_pokemon/provider/catalog_provider.dart';
import 'package:genui_pokemon/provider/pokemon_transport_provider.dart';
import 'package:genui_pokemon/transport/pokemon_transport.dart';



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
  late final PokemonTransport _transport;
  late final SurfaceController _surfaceController;

  @override
  ChatState build() {
    _transport = ref.watch(pokemonTransportProvider);
    final catalog = ref.watch(catalogProvider);

    _surfaceController = SurfaceController(catalogs: [catalog]);
    ref.onDispose(_surfaceController.dispose);

    // Wire incoming AI messages into the surface controller.
    final msgSub = _transport.incomingMessages.listen(
      _surfaceController.handleMessage,
    );
    ref.onDispose(msgSub.cancel);

    // Text chunks update the latest AI message bubble.
    final textSub = _transport.incomingText.listen(_onTextChunk);
    ref.onDispose(textSub.cancel);

    // Surface creation/removal tracked as Message entries.
    final surfaceSub = _surfaceController.surfaceUpdates.listen(
      _onSurfaceUpdate,
    );
    ref.onDispose(surfaceSub.cancel);

    // User interactions on a surface automatically re-send to AI.
    final submitSub = _surfaceController.onSubmit.listen((message) {
      _runRequest(() => _transport.sendRequest(message));
    });
    ref.onDispose(submitSub.cancel);

    return ChatState(surfaceController: _surfaceController);
  }

  /// Sends a user message and processes the AI response.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _appendMessage(Message.user(text));
    await _runRequest(() => _transport.sendRequest(ChatMessage.user(text)));
  }

  /// Invalidate the transport to empty history and rebuild this notifier
  void clearConversation() {
    ref.invalidate(pokemonTransportProvider);
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

  void _onSurfaceUpdate(SurfaceUpdate update) {
    if (update is SurfaceAdded) {
      // Only add once — surface updates fire multiple times.
      final already = state.messages.any(
        (m) => m.surfaceId == update.surfaceId,
      );
      if (!already) _appendMessage(Message.aiSurface(update.surfaceId));
    }
  }

  Future<void> _runRequest(Future<void> Function() body) async {
    state = state.copyWith(isProcessing: true);
    try {
      await body();
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }
}

/// Provides the [ChatState] and conversation management logic for the chat screen.
final conversationProvider = NotifierProvider<ChatSessionNotifier, ChatState>(
  ChatSessionNotifier.new,
);

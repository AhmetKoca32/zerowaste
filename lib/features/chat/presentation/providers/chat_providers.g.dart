// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatMessagesHash() => r'6fbe05e67d0b5e8d0cfb915b0d80e5b0baa3d3f4';

/// Placeholder: will hold chat messages and AI mascot conversation state.
///
/// Copied from [ChatMessages].
@ProviderFor(ChatMessages)
final chatMessagesProvider =
    AutoDisposeNotifierProvider<ChatMessages, List<ChatMessageEntry>>.internal(
      ChatMessages.new,
      name: r'chatMessagesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatMessagesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatMessages = AutoDisposeNotifier<List<ChatMessageEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

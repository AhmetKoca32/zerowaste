// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyMessageCountHash() => r'e3ee2b7e092327796264a91bf981f8c008e080f5';

/// Tracks the number of messages sent by the user today (limit is 20).
///
/// Persisted to [SharedPreferences] so the count survives app restarts, and
/// automatically resets when the calendar day changes.
///
/// Copied from [DailyMessageCount].
@ProviderFor(DailyMessageCount)
final dailyMessageCountProvider =
    AsyncNotifierProvider<DailyMessageCount, int>.internal(
      DailyMessageCount.new,
      name: r'dailyMessageCountProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dailyMessageCountHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DailyMessageCount = AsyncNotifier<int>;
String _$chatMessagesHash() => r'1c6cf6214dd261cdeead3a64c2f1273e1a66861a';

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
String _$dailyChatSuggestionsHash() =>
    r'2aa9f8c8ad6968d49120ac465a64d94863c0ba21';

/// Selects [_kDailySuggestionsCount] suggestions once per calendar day and
/// caches them in [SharedPreferences]. Re-rolls only when the local day flips.
///
/// Copied from [DailyChatSuggestions].
@ProviderFor(DailyChatSuggestions)
final dailyChatSuggestionsProvider =
    AsyncNotifierProvider<DailyChatSuggestions, List<ChatSuggestion>>.internal(
      DailyChatSuggestions.new,
      name: r'dailyChatSuggestionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dailyChatSuggestionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DailyChatSuggestions = AsyncNotifier<List<ChatSuggestion>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

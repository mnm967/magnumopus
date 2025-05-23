// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Channel _$ChannelFromJson(Map<String, dynamic> json) {
  return _Channel.fromJson(json);
}

/// @nodoc
mixin _$Channel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get topic => throw _privateConstructorUsedError;
  String? get courseId =>
      throw _privateConstructorUsedError; // If the channel is tied to a specific course
  bool get isPrivate => throw _privateConstructorUsedError;
  SubscriptionTier get allowedTier => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  int get messageCount => throw _privateConstructorUsedError;
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;

  /// Serializes this Channel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Channel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChannelCopyWith<Channel> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChannelCopyWith<$Res> {
  factory $ChannelCopyWith(Channel value, $Res Function(Channel) then) =
      _$ChannelCopyWithImpl<$Res, Channel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? topic,
      String? courseId,
      bool isPrivate,
      SubscriptionTier allowedTier,
      int order,
      int messageCount,
      DateTime? lastMessageAt});
}

/// @nodoc
class _$ChannelCopyWithImpl<$Res, $Val extends Channel>
    implements $ChannelCopyWith<$Res> {
  _$ChannelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Channel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? topic = freezed,
    Object? courseId = freezed,
    Object? isPrivate = null,
    Object? allowedTier = null,
    Object? order = null,
    Object? messageCount = null,
    Object? lastMessageAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      topic: freezed == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String?,
      courseId: freezed == courseId
          ? _value.courseId
          : courseId // ignore: cast_nullable_to_non_nullable
              as String?,
      isPrivate: null == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
      allowedTier: null == allowedTier
          ? _value.allowedTier
          : allowedTier // ignore: cast_nullable_to_non_nullable
              as SubscriptionTier,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      messageCount: null == messageCount
          ? _value.messageCount
          : messageCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastMessageAt: freezed == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChannelImplCopyWith<$Res> implements $ChannelCopyWith<$Res> {
  factory _$$ChannelImplCopyWith(
          _$ChannelImpl value, $Res Function(_$ChannelImpl) then) =
      __$$ChannelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? topic,
      String? courseId,
      bool isPrivate,
      SubscriptionTier allowedTier,
      int order,
      int messageCount,
      DateTime? lastMessageAt});
}

/// @nodoc
class __$$ChannelImplCopyWithImpl<$Res>
    extends _$ChannelCopyWithImpl<$Res, _$ChannelImpl>
    implements _$$ChannelImplCopyWith<$Res> {
  __$$ChannelImplCopyWithImpl(
      _$ChannelImpl _value, $Res Function(_$ChannelImpl) _then)
      : super(_value, _then);

  /// Create a copy of Channel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? topic = freezed,
    Object? courseId = freezed,
    Object? isPrivate = null,
    Object? allowedTier = null,
    Object? order = null,
    Object? messageCount = null,
    Object? lastMessageAt = freezed,
  }) {
    return _then(_$ChannelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      topic: freezed == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String?,
      courseId: freezed == courseId
          ? _value.courseId
          : courseId // ignore: cast_nullable_to_non_nullable
              as String?,
      isPrivate: null == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
      allowedTier: null == allowedTier
          ? _value.allowedTier
          : allowedTier // ignore: cast_nullable_to_non_nullable
              as SubscriptionTier,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      messageCount: null == messageCount
          ? _value.messageCount
          : messageCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastMessageAt: freezed == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChannelImpl with DiagnosticableTreeMixin implements _Channel {
  const _$ChannelImpl(
      {required this.id,
      required this.name,
      this.topic,
      this.courseId,
      this.isPrivate = false,
      this.allowedTier = SubscriptionTier.free,
      this.order = 0,
      this.messageCount = 0,
      this.lastMessageAt});

  factory _$ChannelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChannelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? topic;
  @override
  final String? courseId;
// If the channel is tied to a specific course
  @override
  @JsonKey()
  final bool isPrivate;
  @override
  @JsonKey()
  final SubscriptionTier allowedTier;
  @override
  @JsonKey()
  final int order;
  @override
  @JsonKey()
  final int messageCount;
  @override
  final DateTime? lastMessageAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Channel(id: $id, name: $name, topic: $topic, courseId: $courseId, isPrivate: $isPrivate, allowedTier: $allowedTier, order: $order, messageCount: $messageCount, lastMessageAt: $lastMessageAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Channel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('topic', topic))
      ..add(DiagnosticsProperty('courseId', courseId))
      ..add(DiagnosticsProperty('isPrivate', isPrivate))
      ..add(DiagnosticsProperty('allowedTier', allowedTier))
      ..add(DiagnosticsProperty('order', order))
      ..add(DiagnosticsProperty('messageCount', messageCount))
      ..add(DiagnosticsProperty('lastMessageAt', lastMessageAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChannelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            (identical(other.allowedTier, allowedTier) ||
                other.allowedTier == allowedTier) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.messageCount, messageCount) ||
                other.messageCount == messageCount) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, topic, courseId,
      isPrivate, allowedTier, order, messageCount, lastMessageAt);

  /// Create a copy of Channel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChannelImplCopyWith<_$ChannelImpl> get copyWith =>
      __$$ChannelImplCopyWithImpl<_$ChannelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChannelImplToJson(
      this,
    );
  }
}

abstract class _Channel implements Channel {
  const factory _Channel(
      {required final String id,
      required final String name,
      final String? topic,
      final String? courseId,
      final bool isPrivate,
      final SubscriptionTier allowedTier,
      final int order,
      final int messageCount,
      final DateTime? lastMessageAt}) = _$ChannelImpl;

  factory _Channel.fromJson(Map<String, dynamic> json) = _$ChannelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get topic;
  @override
  String? get courseId; // If the channel is tied to a specific course
  @override
  bool get isPrivate;
  @override
  SubscriptionTier get allowedTier;
  @override
  int get order;
  @override
  int get messageCount;
  @override
  DateTime? get lastMessageAt;

  /// Create a copy of Channel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChannelImplCopyWith<_$ChannelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  String get channelId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String? get userAvatarUrl => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String? get imageUrl =>
      throw _privateConstructorUsedError; // If the message contains an image
  MessageType get type => throw _privateConstructorUsedError;
  String? get replyToMessageId =>
      throw _privateConstructorUsedError; // If it's a reply to another message
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {String id,
      String channelId,
      String userId,
      String userName,
      String? userAvatarUrl,
      String text,
      String? imageUrl,
      MessageType type,
      String? replyToMessageId,
      DateTime timestamp});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? channelId = null,
    Object? userId = null,
    Object? userName = null,
    Object? userAvatarUrl = freezed,
    Object? text = null,
    Object? imageUrl = freezed,
    Object? type = null,
    Object? replyToMessageId = freezed,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userAvatarUrl: freezed == userAvatarUrl
          ? _value.userAvatarUrl
          : userAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      replyToMessageId: freezed == replyToMessageId
          ? _value.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String channelId,
      String userId,
      String userName,
      String? userAvatarUrl,
      String text,
      String? imageUrl,
      MessageType type,
      String? replyToMessageId,
      DateTime timestamp});
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? channelId = null,
    Object? userId = null,
    Object? userName = null,
    Object? userAvatarUrl = freezed,
    Object? text = null,
    Object? imageUrl = freezed,
    Object? type = null,
    Object? replyToMessageId = freezed,
    Object? timestamp = null,
  }) {
    return _then(_$MessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userAvatarUrl: freezed == userAvatarUrl
          ? _value.userAvatarUrl
          : userAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      replyToMessageId: freezed == replyToMessageId
          ? _value.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl with DiagnosticableTreeMixin implements _Message {
  const _$MessageImpl(
      {required this.id,
      required this.channelId,
      required this.userId,
      required this.userName,
      this.userAvatarUrl,
      required this.text,
      this.imageUrl,
      this.type = MessageType.user,
      this.replyToMessageId,
      required this.timestamp});

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final String id;
  @override
  final String channelId;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String? userAvatarUrl;
  @override
  final String text;
  @override
  final String? imageUrl;
// If the message contains an image
  @override
  @JsonKey()
  final MessageType type;
  @override
  final String? replyToMessageId;
// If it's a reply to another message
  @override
  final DateTime timestamp;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Message(id: $id, channelId: $channelId, userId: $userId, userName: $userName, userAvatarUrl: $userAvatarUrl, text: $text, imageUrl: $imageUrl, type: $type, replyToMessageId: $replyToMessageId, timestamp: $timestamp)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Message'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('channelId', channelId))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('userName', userName))
      ..add(DiagnosticsProperty('userAvatarUrl', userAvatarUrl))
      ..add(DiagnosticsProperty('text', text))
      ..add(DiagnosticsProperty('imageUrl', imageUrl))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('replyToMessageId', replyToMessageId))
      ..add(DiagnosticsProperty('timestamp', timestamp));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userAvatarUrl, userAvatarUrl) ||
                other.userAvatarUrl == userAvatarUrl) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, channelId, userId, userName,
      userAvatarUrl, text, imageUrl, type, replyToMessageId, timestamp);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(
      this,
    );
  }
}

abstract class _Message implements Message {
  const factory _Message(
      {required final String id,
      required final String channelId,
      required final String userId,
      required final String userName,
      final String? userAvatarUrl,
      required final String text,
      final String? imageUrl,
      final MessageType type,
      final String? replyToMessageId,
      required final DateTime timestamp}) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  String get id;
  @override
  String get channelId;
  @override
  String get userId;
  @override
  String get userName;
  @override
  String? get userAvatarUrl;
  @override
  String get text;
  @override
  String? get imageUrl; // If the message contains an image
  @override
  MessageType get type;
  @override
  String? get replyToMessageId; // If it's a reply to another message
  @override
  DateTime get timestamp;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIConversation _$AIConversationFromJson(Map<String, dynamic> json) {
  return _AIConversation.fromJson(json);
}

/// @nodoc
mixin _$AIConversation {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastUpdatedAt => throw _privateConstructorUsedError;

  /// Serializes this AIConversation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIConversationCopyWith<AIConversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIConversationCopyWith<$Res> {
  factory $AIConversationCopyWith(
          AIConversation value, $Res Function(AIConversation) then) =
      _$AIConversationCopyWithImpl<$Res, AIConversation>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      DateTime? createdAt,
      DateTime? lastUpdatedAt});
}

/// @nodoc
class _$AIConversationCopyWithImpl<$Res, $Val extends AIConversation>
    implements $AIConversationCopyWith<$Res> {
  _$AIConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? createdAt = freezed,
    Object? lastUpdatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdatedAt: freezed == lastUpdatedAt
          ? _value.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIConversationImplCopyWith<$Res>
    implements $AIConversationCopyWith<$Res> {
  factory _$$AIConversationImplCopyWith(_$AIConversationImpl value,
          $Res Function(_$AIConversationImpl) then) =
      __$$AIConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      DateTime? createdAt,
      DateTime? lastUpdatedAt});
}

/// @nodoc
class __$$AIConversationImplCopyWithImpl<$Res>
    extends _$AIConversationCopyWithImpl<$Res, _$AIConversationImpl>
    implements _$$AIConversationImplCopyWith<$Res> {
  __$$AIConversationImplCopyWithImpl(
      _$AIConversationImpl _value, $Res Function(_$AIConversationImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? createdAt = freezed,
    Object? lastUpdatedAt = freezed,
  }) {
    return _then(_$AIConversationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdatedAt: freezed == lastUpdatedAt
          ? _value.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIConversationImpl
    with DiagnosticableTreeMixin
    implements _AIConversation {
  const _$AIConversationImpl(
      {required this.id,
      required this.userId,
      required this.title,
      this.createdAt,
      this.lastUpdatedAt});

  factory _$AIConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIConversationImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? lastUpdatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AIConversation(id: $id, userId: $userId, title: $title, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AIConversation'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('lastUpdatedAt', lastUpdatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastUpdatedAt, lastUpdatedAt) ||
                other.lastUpdatedAt == lastUpdatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, title, createdAt, lastUpdatedAt);

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIConversationImplCopyWith<_$AIConversationImpl> get copyWith =>
      __$$AIConversationImplCopyWithImpl<_$AIConversationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIConversationImplToJson(
      this,
    );
  }
}

abstract class _AIConversation implements AIConversation {
  const factory _AIConversation(
      {required final String id,
      required final String userId,
      required final String title,
      final DateTime? createdAt,
      final DateTime? lastUpdatedAt}) = _$AIConversationImpl;

  factory _AIConversation.fromJson(Map<String, dynamic> json) =
      _$AIConversationImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get lastUpdatedAt;

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIConversationImplCopyWith<_$AIConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIMessage _$AIMessageFromJson(Map<String, dynamic> json) {
  return _AIMessage.fromJson(json);
}

/// @nodoc
mixin _$AIMessage {
  String get id => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  bool get isUserMessage =>
      throw _privateConstructorUsedError; // true if sent by user, false if AI response
  String get content => throw _privateConstructorUsedError;
  String? get imageUrl =>
      throw _privateConstructorUsedError; // For image uploads by user
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this AIMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIMessageCopyWith<AIMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIMessageCopyWith<$Res> {
  factory $AIMessageCopyWith(AIMessage value, $Res Function(AIMessage) then) =
      _$AIMessageCopyWithImpl<$Res, AIMessage>;
  @useResult
  $Res call(
      {String id,
      String conversationId,
      bool isUserMessage,
      String content,
      String? imageUrl,
      DateTime timestamp});
}

/// @nodoc
class _$AIMessageCopyWithImpl<$Res, $Val extends AIMessage>
    implements $AIMessageCopyWith<$Res> {
  _$AIMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? isUserMessage = null,
    Object? content = null,
    Object? imageUrl = freezed,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      isUserMessage: null == isUserMessage
          ? _value.isUserMessage
          : isUserMessage // ignore: cast_nullable_to_non_nullable
              as bool,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIMessageImplCopyWith<$Res>
    implements $AIMessageCopyWith<$Res> {
  factory _$$AIMessageImplCopyWith(
          _$AIMessageImpl value, $Res Function(_$AIMessageImpl) then) =
      __$$AIMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String conversationId,
      bool isUserMessage,
      String content,
      String? imageUrl,
      DateTime timestamp});
}

/// @nodoc
class __$$AIMessageImplCopyWithImpl<$Res>
    extends _$AIMessageCopyWithImpl<$Res, _$AIMessageImpl>
    implements _$$AIMessageImplCopyWith<$Res> {
  __$$AIMessageImplCopyWithImpl(
      _$AIMessageImpl _value, $Res Function(_$AIMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? isUserMessage = null,
    Object? content = null,
    Object? imageUrl = freezed,
    Object? timestamp = null,
  }) {
    return _then(_$AIMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      isUserMessage: null == isUserMessage
          ? _value.isUserMessage
          : isUserMessage // ignore: cast_nullable_to_non_nullable
              as bool,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIMessageImpl with DiagnosticableTreeMixin implements _AIMessage {
  const _$AIMessageImpl(
      {required this.id,
      required this.conversationId,
      required this.isUserMessage,
      required this.content,
      this.imageUrl,
      required this.timestamp});

  factory _$AIMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String conversationId;
  @override
  final bool isUserMessage;
// true if sent by user, false if AI response
  @override
  final String content;
  @override
  final String? imageUrl;
// For image uploads by user
  @override
  final DateTime timestamp;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AIMessage(id: $id, conversationId: $conversationId, isUserMessage: $isUserMessage, content: $content, imageUrl: $imageUrl, timestamp: $timestamp)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AIMessage'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('conversationId', conversationId))
      ..add(DiagnosticsProperty('isUserMessage', isUserMessage))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('imageUrl', imageUrl))
      ..add(DiagnosticsProperty('timestamp', timestamp));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.isUserMessage, isUserMessage) ||
                other.isUserMessage == isUserMessage) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, conversationId,
      isUserMessage, content, imageUrl, timestamp);

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIMessageImplCopyWith<_$AIMessageImpl> get copyWith =>
      __$$AIMessageImplCopyWithImpl<_$AIMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIMessageImplToJson(
      this,
    );
  }
}

abstract class _AIMessage implements AIMessage {
  const factory _AIMessage(
      {required final String id,
      required final String conversationId,
      required final bool isUserMessage,
      required final String content,
      final String? imageUrl,
      required final DateTime timestamp}) = _$AIMessageImpl;

  factory _AIMessage.fromJson(Map<String, dynamic> json) =
      _$AIMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get conversationId;
  @override
  bool get isUserMessage; // true if sent by user, false if AI response
  @override
  String get content;
  @override
  String? get imageUrl; // For image uploads by user
  @override
  DateTime get timestamp;

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIMessageImplCopyWith<_$AIMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

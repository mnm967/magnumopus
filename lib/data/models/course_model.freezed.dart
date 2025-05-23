// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CourseCategory _$CourseCategoryFromJson(Map<String, dynamic> json) {
  return _CourseCategory.fromJson(json);
}

/// @nodoc
mixin _$CourseCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Serializes this CourseCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CourseCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseCategoryCopyWith<CourseCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseCategoryCopyWith<$Res> {
  factory $CourseCategoryCopyWith(
          CourseCategory value, $Res Function(CourseCategory) then) =
      _$CourseCategoryCopyWithImpl<$Res, CourseCategory>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String? imageUrl,
      int order});
}

/// @nodoc
class _$CourseCategoryCopyWithImpl<$Res, $Val extends CourseCategory>
    implements $CourseCategoryCopyWith<$Res> {
  _$CourseCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CourseCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? order = null,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CourseCategoryImplCopyWith<$Res>
    implements $CourseCategoryCopyWith<$Res> {
  factory _$$CourseCategoryImplCopyWith(_$CourseCategoryImpl value,
          $Res Function(_$CourseCategoryImpl) then) =
      __$$CourseCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String? imageUrl,
      int order});
}

/// @nodoc
class __$$CourseCategoryImplCopyWithImpl<$Res>
    extends _$CourseCategoryCopyWithImpl<$Res, _$CourseCategoryImpl>
    implements _$$CourseCategoryImplCopyWith<$Res> {
  __$$CourseCategoryImplCopyWithImpl(
      _$CourseCategoryImpl _value, $Res Function(_$CourseCategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of CourseCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? order = null,
  }) {
    return _then(_$CourseCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseCategoryImpl
    with DiagnosticableTreeMixin
    implements _CourseCategory {
  const _$CourseCategoryImpl(
      {required this.id,
      required this.name,
      this.description,
      this.imageUrl,
      this.order = 0});

  factory _$CourseCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? imageUrl;
  @override
  @JsonKey()
  final int order;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CourseCategory(id: $id, name: $name, description: $description, imageUrl: $imageUrl, order: $order)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CourseCategory'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('imageUrl', imageUrl))
      ..add(DiagnosticsProperty('order', order));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, description, imageUrl, order);

  /// Create a copy of CourseCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseCategoryImplCopyWith<_$CourseCategoryImpl> get copyWith =>
      __$$CourseCategoryImplCopyWithImpl<_$CourseCategoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseCategoryImplToJson(
      this,
    );
  }
}

abstract class _CourseCategory implements CourseCategory {
  const factory _CourseCategory(
      {required final String id,
      required final String name,
      final String? description,
      final String? imageUrl,
      final int order}) = _$CourseCategoryImpl;

  factory _CourseCategory.fromJson(Map<String, dynamic> json) =
      _$CourseCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get imageUrl;
  @override
  int get order;

  /// Create a copy of CourseCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseCategoryImplCopyWith<_$CourseCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Course _$CourseFromJson(Map<String, dynamic> json) {
  return _Course.fromJson(json);
}

/// @nodoc
mixin _$Course {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  SubscriptionTier get tier => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  int get lessonCount => throw _privateConstructorUsedError;
  int get totalDuration => throw _privateConstructorUsedError;

  /// Serializes this Course to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseCopyWith<Course> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseCopyWith<$Res> {
  factory $CourseCopyWith(Course value, $Res Function(Course) then) =
      _$CourseCopyWithImpl<$Res, Course>;
  @useResult
  $Res call(
      {String id,
      String title,
      String categoryId,
      String? description,
      SubscriptionTier tier,
      String? thumbnailUrl,
      DateTime? createdAt,
      DateTime? lastUpdated,
      int order,
      int lessonCount,
      int totalDuration});
}

/// @nodoc
class _$CourseCopyWithImpl<$Res, $Val extends Course>
    implements $CourseCopyWith<$Res> {
  _$CourseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? categoryId = null,
    Object? description = freezed,
    Object? tier = null,
    Object? thumbnailUrl = freezed,
    Object? createdAt = freezed,
    Object? lastUpdated = freezed,
    Object? order = null,
    Object? lessonCount = null,
    Object? totalDuration = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as SubscriptionTier,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      lessonCount: null == lessonCount
          ? _value.lessonCount
          : lessonCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CourseImplCopyWith<$Res> implements $CourseCopyWith<$Res> {
  factory _$$CourseImplCopyWith(
          _$CourseImpl value, $Res Function(_$CourseImpl) then) =
      __$$CourseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String categoryId,
      String? description,
      SubscriptionTier tier,
      String? thumbnailUrl,
      DateTime? createdAt,
      DateTime? lastUpdated,
      int order,
      int lessonCount,
      int totalDuration});
}

/// @nodoc
class __$$CourseImplCopyWithImpl<$Res>
    extends _$CourseCopyWithImpl<$Res, _$CourseImpl>
    implements _$$CourseImplCopyWith<$Res> {
  __$$CourseImplCopyWithImpl(
      _$CourseImpl _value, $Res Function(_$CourseImpl) _then)
      : super(_value, _then);

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? categoryId = null,
    Object? description = freezed,
    Object? tier = null,
    Object? thumbnailUrl = freezed,
    Object? createdAt = freezed,
    Object? lastUpdated = freezed,
    Object? order = null,
    Object? lessonCount = null,
    Object? totalDuration = null,
  }) {
    return _then(_$CourseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as SubscriptionTier,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      lessonCount: null == lessonCount
          ? _value.lessonCount
          : lessonCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseImpl with DiagnosticableTreeMixin implements _Course {
  const _$CourseImpl(
      {required this.id,
      required this.title,
      required this.categoryId,
      this.description,
      this.tier = SubscriptionTier.free,
      this.thumbnailUrl,
      this.createdAt,
      this.lastUpdated,
      this.order = 0,
      this.lessonCount = 0,
      this.totalDuration = 0});

  factory _$CourseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String categoryId;
  @override
  final String? description;
  @override
  @JsonKey()
  final SubscriptionTier tier;
  @override
  final String? thumbnailUrl;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? lastUpdated;
  @override
  @JsonKey()
  final int order;
  @override
  @JsonKey()
  final int lessonCount;
  @override
  @JsonKey()
  final int totalDuration;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Course(id: $id, title: $title, categoryId: $categoryId, description: $description, tier: $tier, thumbnailUrl: $thumbnailUrl, createdAt: $createdAt, lastUpdated: $lastUpdated, order: $order, lessonCount: $lessonCount, totalDuration: $totalDuration)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Course'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('categoryId', categoryId))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('tier', tier))
      ..add(DiagnosticsProperty('thumbnailUrl', thumbnailUrl))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('lastUpdated', lastUpdated))
      ..add(DiagnosticsProperty('order', order))
      ..add(DiagnosticsProperty('lessonCount', lessonCount))
      ..add(DiagnosticsProperty('totalDuration', totalDuration));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.lessonCount, lessonCount) ||
                other.lessonCount == lessonCount) &&
            (identical(other.totalDuration, totalDuration) ||
                other.totalDuration == totalDuration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      categoryId,
      description,
      tier,
      thumbnailUrl,
      createdAt,
      lastUpdated,
      order,
      lessonCount,
      totalDuration);

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseImplCopyWith<_$CourseImpl> get copyWith =>
      __$$CourseImplCopyWithImpl<_$CourseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseImplToJson(
      this,
    );
  }
}

abstract class _Course implements Course {
  const factory _Course(
      {required final String id,
      required final String title,
      required final String categoryId,
      final String? description,
      final SubscriptionTier tier,
      final String? thumbnailUrl,
      final DateTime? createdAt,
      final DateTime? lastUpdated,
      final int order,
      final int lessonCount,
      final int totalDuration}) = _$CourseImpl;

  factory _Course.fromJson(Map<String, dynamic> json) = _$CourseImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get categoryId;
  @override
  String? get description;
  @override
  SubscriptionTier get tier;
  @override
  String? get thumbnailUrl;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get lastUpdated;
  @override
  int get order;
  @override
  int get lessonCount;
  @override
  int get totalDuration;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseImplCopyWith<_$CourseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Lesson _$LessonFromJson(Map<String, dynamic> json) {
  return _Lesson.fromJson(json);
}

/// @nodoc
mixin _$Lesson {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get courseId => throw _privateConstructorUsedError;
  @HiveField(2)
  String get title => throw _privateConstructorUsedError;
  @HiveField(3)
  String get type => throw _privateConstructorUsedError; // video, text, etc.
  @HiveField(4)
  String? get description => throw _privateConstructorUsedError;
  @HiveField(5)
  int? get duration => throw _privateConstructorUsedError; // in seconds
  @HiveField(6)
  String? get videoUrl => throw _privateConstructorUsedError;
  @HiveField(7)
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  @HiveField(8)
  String? get textContent => throw _privateConstructorUsedError;
  @HiveField(9)
  bool get freePreview =>
      throw _privateConstructorUsedError; // If true, available to free users regardless of course tier
  @HiveField(10)
  Map<String, dynamic> get resources =>
      throw _privateConstructorUsedError; // Additional resources (PDFs, links, etc.)
  @HiveField(11)
  int get order => throw _privateConstructorUsedError;
  @HiveField(12)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @HiveField(13)
  bool get isDownloaded => throw _privateConstructorUsedError;
  @HiveField(14)
  String? get localPath => throw _privateConstructorUsedError;

  /// Serializes this Lesson to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonCopyWith<Lesson> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonCopyWith<$Res> {
  factory $LessonCopyWith(Lesson value, $Res Function(Lesson) then) =
      _$LessonCopyWithImpl<$Res, Lesson>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String courseId,
      @HiveField(2) String title,
      @HiveField(3) String type,
      @HiveField(4) String? description,
      @HiveField(5) int? duration,
      @HiveField(6) String? videoUrl,
      @HiveField(7) String? thumbnailUrl,
      @HiveField(8) String? textContent,
      @HiveField(9) bool freePreview,
      @HiveField(10) Map<String, dynamic> resources,
      @HiveField(11) int order,
      @HiveField(12) DateTime? createdAt,
      @HiveField(13) bool isDownloaded,
      @HiveField(14) String? localPath});
}

/// @nodoc
class _$LessonCopyWithImpl<$Res, $Val extends Lesson>
    implements $LessonCopyWith<$Res> {
  _$LessonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseId = null,
    Object? title = null,
    Object? type = null,
    Object? description = freezed,
    Object? duration = freezed,
    Object? videoUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? textContent = freezed,
    Object? freePreview = null,
    Object? resources = null,
    Object? order = null,
    Object? createdAt = freezed,
    Object? isDownloaded = null,
    Object? localPath = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      courseId: null == courseId
          ? _value.courseId
          : courseId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      textContent: freezed == textContent
          ? _value.textContent
          : textContent // ignore: cast_nullable_to_non_nullable
              as String?,
      freePreview: null == freePreview
          ? _value.freePreview
          : freePreview // ignore: cast_nullable_to_non_nullable
              as bool,
      resources: null == resources
          ? _value.resources
          : resources // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDownloaded: null == isDownloaded
          ? _value.isDownloaded
          : isDownloaded // ignore: cast_nullable_to_non_nullable
              as bool,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LessonImplCopyWith<$Res> implements $LessonCopyWith<$Res> {
  factory _$$LessonImplCopyWith(
          _$LessonImpl value, $Res Function(_$LessonImpl) then) =
      __$$LessonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String courseId,
      @HiveField(2) String title,
      @HiveField(3) String type,
      @HiveField(4) String? description,
      @HiveField(5) int? duration,
      @HiveField(6) String? videoUrl,
      @HiveField(7) String? thumbnailUrl,
      @HiveField(8) String? textContent,
      @HiveField(9) bool freePreview,
      @HiveField(10) Map<String, dynamic> resources,
      @HiveField(11) int order,
      @HiveField(12) DateTime? createdAt,
      @HiveField(13) bool isDownloaded,
      @HiveField(14) String? localPath});
}

/// @nodoc
class __$$LessonImplCopyWithImpl<$Res>
    extends _$LessonCopyWithImpl<$Res, _$LessonImpl>
    implements _$$LessonImplCopyWith<$Res> {
  __$$LessonImplCopyWithImpl(
      _$LessonImpl _value, $Res Function(_$LessonImpl) _then)
      : super(_value, _then);

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseId = null,
    Object? title = null,
    Object? type = null,
    Object? description = freezed,
    Object? duration = freezed,
    Object? videoUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? textContent = freezed,
    Object? freePreview = null,
    Object? resources = null,
    Object? order = null,
    Object? createdAt = freezed,
    Object? isDownloaded = null,
    Object? localPath = freezed,
  }) {
    return _then(_$LessonImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      courseId: null == courseId
          ? _value.courseId
          : courseId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      textContent: freezed == textContent
          ? _value.textContent
          : textContent // ignore: cast_nullable_to_non_nullable
              as String?,
      freePreview: null == freePreview
          ? _value.freePreview
          : freePreview // ignore: cast_nullable_to_non_nullable
              as bool,
      resources: null == resources
          ? _value._resources
          : resources // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDownloaded: null == isDownloaded
          ? _value.isDownloaded
          : isDownloaded // ignore: cast_nullable_to_non_nullable
              as bool,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonImpl extends _Lesson with DiagnosticableTreeMixin {
  const _$LessonImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.courseId,
      @HiveField(2) required this.title,
      @HiveField(3) this.type = 'video',
      @HiveField(4) this.description,
      @HiveField(5) this.duration,
      @HiveField(6) this.videoUrl,
      @HiveField(7) this.thumbnailUrl,
      @HiveField(8) this.textContent,
      @HiveField(9) this.freePreview = false,
      @HiveField(10) final Map<String, dynamic> resources = const {},
      @HiveField(11) this.order = 0,
      @HiveField(12) this.createdAt,
      @HiveField(13) this.isDownloaded = false,
      @HiveField(14) this.localPath})
      : _resources = resources,
        super._();

  factory _$LessonImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String courseId;
  @override
  @HiveField(2)
  final String title;
  @override
  @JsonKey()
  @HiveField(3)
  final String type;
// video, text, etc.
  @override
  @HiveField(4)
  final String? description;
  @override
  @HiveField(5)
  final int? duration;
// in seconds
  @override
  @HiveField(6)
  final String? videoUrl;
  @override
  @HiveField(7)
  final String? thumbnailUrl;
  @override
  @HiveField(8)
  final String? textContent;
  @override
  @JsonKey()
  @HiveField(9)
  final bool freePreview;
// If true, available to free users regardless of course tier
  final Map<String, dynamic> _resources;
// If true, available to free users regardless of course tier
  @override
  @JsonKey()
  @HiveField(10)
  Map<String, dynamic> get resources {
    if (_resources is EqualUnmodifiableMapView) return _resources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_resources);
  }

// Additional resources (PDFs, links, etc.)
  @override
  @JsonKey()
  @HiveField(11)
  final int order;
  @override
  @HiveField(12)
  final DateTime? createdAt;
  @override
  @JsonKey()
  @HiveField(13)
  final bool isDownloaded;
  @override
  @HiveField(14)
  final String? localPath;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Lesson(id: $id, courseId: $courseId, title: $title, type: $type, description: $description, duration: $duration, videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, textContent: $textContent, freePreview: $freePreview, resources: $resources, order: $order, createdAt: $createdAt, isDownloaded: $isDownloaded, localPath: $localPath)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Lesson'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('courseId', courseId))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('duration', duration))
      ..add(DiagnosticsProperty('videoUrl', videoUrl))
      ..add(DiagnosticsProperty('thumbnailUrl', thumbnailUrl))
      ..add(DiagnosticsProperty('textContent', textContent))
      ..add(DiagnosticsProperty('freePreview', freePreview))
      ..add(DiagnosticsProperty('resources', resources))
      ..add(DiagnosticsProperty('order', order))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('isDownloaded', isDownloaded))
      ..add(DiagnosticsProperty('localPath', localPath));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.textContent, textContent) ||
                other.textContent == textContent) &&
            (identical(other.freePreview, freePreview) ||
                other.freePreview == freePreview) &&
            const DeepCollectionEquality()
                .equals(other._resources, _resources) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isDownloaded, isDownloaded) ||
                other.isDownloaded == isDownloaded) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      courseId,
      title,
      type,
      description,
      duration,
      videoUrl,
      thumbnailUrl,
      textContent,
      freePreview,
      const DeepCollectionEquality().hash(_resources),
      order,
      createdAt,
      isDownloaded,
      localPath);

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonImplCopyWith<_$LessonImpl> get copyWith =>
      __$$LessonImplCopyWithImpl<_$LessonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonImplToJson(
      this,
    );
  }
}

abstract class _Lesson extends Lesson {
  const factory _Lesson(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String courseId,
      @HiveField(2) required final String title,
      @HiveField(3) final String type,
      @HiveField(4) final String? description,
      @HiveField(5) final int? duration,
      @HiveField(6) final String? videoUrl,
      @HiveField(7) final String? thumbnailUrl,
      @HiveField(8) final String? textContent,
      @HiveField(9) final bool freePreview,
      @HiveField(10) final Map<String, dynamic> resources,
      @HiveField(11) final int order,
      @HiveField(12) final DateTime? createdAt,
      @HiveField(13) final bool isDownloaded,
      @HiveField(14) final String? localPath}) = _$LessonImpl;
  const _Lesson._() : super._();

  factory _Lesson.fromJson(Map<String, dynamic> json) = _$LessonImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get courseId;
  @override
  @HiveField(2)
  String get title;
  @override
  @HiveField(3)
  String get type; // video, text, etc.
  @override
  @HiveField(4)
  String? get description;
  @override
  @HiveField(5)
  int? get duration; // in seconds
  @override
  @HiveField(6)
  String? get videoUrl;
  @override
  @HiveField(7)
  String? get thumbnailUrl;
  @override
  @HiveField(8)
  String? get textContent;
  @override
  @HiveField(9)
  bool
      get freePreview; // If true, available to free users regardless of course tier
  @override
  @HiveField(10)
  Map<String, dynamic>
      get resources; // Additional resources (PDFs, links, etc.)
  @override
  @HiveField(11)
  int get order;
  @override
  @HiveField(12)
  DateTime? get createdAt;
  @override
  @HiveField(13)
  bool get isDownloaded;
  @override
  @HiveField(14)
  String? get localPath;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonImplCopyWith<_$LessonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Comment _$CommentFromJson(Map<String, dynamic> json) {
  return _Comment.fromJson(json);
}

/// @nodoc
mixin _$Comment {
  String get id => throw _privateConstructorUsedError;
  String get lessonId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String? get userAvatarUrl => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get parentCommentId => throw _privateConstructorUsedError;

  /// Serializes this Comment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentCopyWith<Comment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentCopyWith<$Res> {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) then) =
      _$CommentCopyWithImpl<$Res, Comment>;
  @useResult
  $Res call(
      {String id,
      String lessonId,
      String userId,
      String userName,
      String? userAvatarUrl,
      String text,
      DateTime timestamp,
      String? parentCommentId});
}

/// @nodoc
class _$CommentCopyWithImpl<$Res, $Val extends Comment>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lessonId = null,
    Object? userId = null,
    Object? userName = null,
    Object? userAvatarUrl = freezed,
    Object? text = null,
    Object? timestamp = null,
    Object? parentCommentId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: null == lessonId
          ? _value.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
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
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      parentCommentId: freezed == parentCommentId
          ? _value.parentCommentId
          : parentCommentId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentImplCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$$CommentImplCopyWith(
          _$CommentImpl value, $Res Function(_$CommentImpl) then) =
      __$$CommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String lessonId,
      String userId,
      String userName,
      String? userAvatarUrl,
      String text,
      DateTime timestamp,
      String? parentCommentId});
}

/// @nodoc
class __$$CommentImplCopyWithImpl<$Res>
    extends _$CommentCopyWithImpl<$Res, _$CommentImpl>
    implements _$$CommentImplCopyWith<$Res> {
  __$$CommentImplCopyWithImpl(
      _$CommentImpl _value, $Res Function(_$CommentImpl) _then)
      : super(_value, _then);

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lessonId = null,
    Object? userId = null,
    Object? userName = null,
    Object? userAvatarUrl = freezed,
    Object? text = null,
    Object? timestamp = null,
    Object? parentCommentId = freezed,
  }) {
    return _then(_$CommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: null == lessonId
          ? _value.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
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
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      parentCommentId: freezed == parentCommentId
          ? _value.parentCommentId
          : parentCommentId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentImpl with DiagnosticableTreeMixin implements _Comment {
  const _$CommentImpl(
      {required this.id,
      required this.lessonId,
      required this.userId,
      required this.userName,
      this.userAvatarUrl,
      required this.text,
      required this.timestamp,
      this.parentCommentId});

  factory _$CommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentImplFromJson(json);

  @override
  final String id;
  @override
  final String lessonId;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String? userAvatarUrl;
  @override
  final String text;
  @override
  final DateTime timestamp;
  @override
  final String? parentCommentId;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Comment(id: $id, lessonId: $lessonId, userId: $userId, userName: $userName, userAvatarUrl: $userAvatarUrl, text: $text, timestamp: $timestamp, parentCommentId: $parentCommentId)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Comment'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('lessonId', lessonId))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('userName', userName))
      ..add(DiagnosticsProperty('userAvatarUrl', userAvatarUrl))
      ..add(DiagnosticsProperty('text', text))
      ..add(DiagnosticsProperty('timestamp', timestamp))
      ..add(DiagnosticsProperty('parentCommentId', parentCommentId));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userAvatarUrl, userAvatarUrl) ||
                other.userAvatarUrl == userAvatarUrl) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.parentCommentId, parentCommentId) ||
                other.parentCommentId == parentCommentId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, lessonId, userId, userName,
      userAvatarUrl, text, timestamp, parentCommentId);

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      __$$CommentImplCopyWithImpl<_$CommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentImplToJson(
      this,
    );
  }
}

abstract class _Comment implements Comment {
  const factory _Comment(
      {required final String id,
      required final String lessonId,
      required final String userId,
      required final String userName,
      final String? userAvatarUrl,
      required final String text,
      required final DateTime timestamp,
      final String? parentCommentId}) = _$CommentImpl;

  factory _Comment.fromJson(Map<String, dynamic> json) = _$CommentImpl.fromJson;

  @override
  String get id;
  @override
  String get lessonId;
  @override
  String get userId;
  @override
  String get userName;
  @override
  String? get userAvatarUrl;
  @override
  String get text;
  @override
  DateTime get timestamp;
  @override
  String? get parentCommentId;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

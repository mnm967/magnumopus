// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LessonAdapter extends TypeAdapter<Lesson> {
  @override
  final int typeId = 0;

  @override
  Lesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lesson(
      id: fields[0] as String,
      courseId: fields[1] as String,
      title: fields[2] as String,
      type: fields[3] as String,
      description: fields[4] as String?,
      duration: fields[5] as int?,
      videoUrl: fields[6] as String?,
      thumbnailUrl: fields[7] as String?,
      textContent: fields[8] as String?,
      freePreview: fields[9] as bool,
      resources: (fields[10] as Map).cast<String, dynamic>(),
      order: fields[11] as int,
      createdAt: fields[12] as DateTime?,
      isDownloaded: fields[13] as bool,
      localPath: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Lesson obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.videoUrl)
      ..writeByte(7)
      ..write(obj.thumbnailUrl)
      ..writeByte(8)
      ..write(obj.textContent)
      ..writeByte(9)
      ..write(obj.freePreview)
      ..writeByte(10)
      ..write(obj.resources)
      ..writeByte(11)
      ..write(obj.order)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.isDownloaded)
      ..writeByte(14)
      ..write(obj.localPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseCategoryImpl _$$CourseCategoryImplFromJson(Map<String, dynamic> json) =>
    _$CourseCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CourseCategoryImplToJson(
        _$CourseCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'order': instance.order,
    };

_$CourseImpl _$$CourseImplFromJson(Map<String, dynamic> json) => _$CourseImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      categoryId: json['categoryId'] as String,
      description: json['description'] as String?,
      tier: $enumDecodeNullable(_$SubscriptionTierEnumMap, json['tier']) ??
          SubscriptionTier.free,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      order: (json['order'] as num?)?.toInt() ?? 0,
      lessonCount: (json['lessonCount'] as num?)?.toInt() ?? 0,
      totalDuration: (json['totalDuration'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CourseImplToJson(_$CourseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'categoryId': instance.categoryId,
      'description': instance.description,
      'tier': _$SubscriptionTierEnumMap[instance.tier]!,
      'thumbnailUrl': instance.thumbnailUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'order': instance.order,
      'lessonCount': instance.lessonCount,
      'totalDuration': instance.totalDuration,
    };

const _$SubscriptionTierEnumMap = {
  SubscriptionTier.free: 'free',
  SubscriptionTier.advanced: 'advanced',
  SubscriptionTier.elite: 'elite',
};

_$LessonImpl _$$LessonImplFromJson(Map<String, dynamic> json) => _$LessonImpl(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      type: json['type'] as String? ?? 'video',
      description: json['description'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      videoUrl: json['videoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      textContent: json['textContent'] as String?,
      freePreview: json['freePreview'] as bool? ?? false,
      resources: json['resources'] as Map<String, dynamic>? ?? const {},
      order: (json['order'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      localPath: json['localPath'] as String?,
    );

Map<String, dynamic> _$$LessonImplToJson(_$LessonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'title': instance.title,
      'type': instance.type,
      'description': instance.description,
      'duration': instance.duration,
      'videoUrl': instance.videoUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'textContent': instance.textContent,
      'freePreview': instance.freePreview,
      'resources': instance.resources,
      'order': instance.order,
      'createdAt': instance.createdAt?.toIso8601String(),
      'isDownloaded': instance.isDownloaded,
      'localPath': instance.localPath,
    };

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      parentCommentId: json['parentCommentId'] as String?,
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lessonId': instance.lessonId,
      'userId': instance.userId,
      'userName': instance.userName,
      'userAvatarUrl': instance.userAvatarUrl,
      'text': instance.text,
      'timestamp': instance.timestamp.toIso8601String(),
      'parentCommentId': instance.parentCommentId,
    };

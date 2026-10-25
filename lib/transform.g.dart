// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transform.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Point _$PointFromJson(Map<String, dynamic> json) => Point(
  x: (json['x'] as num?)?.toDouble() ?? 0.0,
  t: (json['t'] as num?)?.toDouble() ?? 0.0,
  z: (json['z'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$PointToJson(Point instance) => <String, dynamic>{
  'x': instance.x,
  't': instance.t,
  'z': instance.z,
};

Vector _$VectorFromJson(Map<String, dynamic> json) => Vector(
  dx: (json['dx'] as num?)?.toDouble() ?? 0.0,
  dt: (json['dt'] as num?)?.toDouble() ?? 0.0,
  dz: (json['dz'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$VectorToJson(Vector instance) => <String, dynamic>{
  'dx': instance.dx,
  'dt': instance.dt,
  'dz': instance.dz,
};

ReferenceFrame _$ReferenceFrameFromJson(Map<String, dynamic> json) =>
    ReferenceFrame()
      ..center = Point.fromJson(json['center'] as Map<String, dynamic>)
      ..velocity = (json['velocity'] as num).toDouble();

Map<String, dynamic> _$ReferenceFrameToJson(ReferenceFrame instance) =>
    <String, dynamic>{'center': instance.center, 'velocity': instance.velocity};

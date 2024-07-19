//
//  Generated code. Do not modify.
//  source: service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class BlendshapeResponse extends $pb.GeneratedMessage {
  factory BlendshapeResponse({
    $core.Map<$core.String, $core.double>? blendshape,
  }) {
    final $result = create();
    if (blendshape != null) {
      $result.blendshape.addAll(blendshape);
    }
    return $result;
  }
  BlendshapeResponse._() : super();
  factory BlendshapeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BlendshapeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlendshapeResponse', createEmptyInstance: create)
    ..m<$core.String, $core.double>(1, _omitFieldNames ? '' : 'blendshape', entryClassName: 'BlendshapeResponse.BlendshapeEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BlendshapeResponse clone() => BlendshapeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BlendshapeResponse copyWith(void Function(BlendshapeResponse) updates) => super.copyWith((message) => updates(message as BlendshapeResponse)) as BlendshapeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlendshapeResponse create() => BlendshapeResponse._();
  BlendshapeResponse createEmptyInstance() => create();
  static $pb.PbList<BlendshapeResponse> createRepeated() => $pb.PbList<BlendshapeResponse>();
  @$core.pragma('dart2js:noInline')
  static BlendshapeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlendshapeResponse>(create);
  static BlendshapeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$core.String, $core.double> get blendshape => $_getMap(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');

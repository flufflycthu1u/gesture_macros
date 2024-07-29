//
//  Generated code. Do not modify.
//  source: service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use blendshapeResponseDescriptor instead')
const BlendshapeResponse$json = {
  '1': 'BlendshapeResponse',
  '2': [
    {'1': 'blendshape', '3': 1, '4': 3, '5': 11, '6': '.BlendshapeResponse.BlendshapeEntry', '10': 'blendshape'},
  ],
  '3': [BlendshapeResponse_BlendshapeEntry$json],
};

@$core.Deprecated('Use blendshapeResponseDescriptor instead')
const BlendshapeResponse_BlendshapeEntry$json = {
  '1': 'BlendshapeEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 2, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `BlendshapeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blendshapeResponseDescriptor = $convert.base64Decode(
    'ChJCbGVuZHNoYXBlUmVzcG9uc2USQwoKYmxlbmRzaGFwZRgBIAMoCzIjLkJsZW5kc2hhcGVSZX'
    'Nwb25zZS5CbGVuZHNoYXBlRW50cnlSCmJsZW5kc2hhcGUaPQoPQmxlbmRzaGFwZUVudHJ5EhAK'
    'A2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgCUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor = $convert.base64Decode(
    'CgVFbXB0eQ==');


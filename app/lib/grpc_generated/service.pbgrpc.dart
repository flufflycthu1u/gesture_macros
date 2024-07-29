//
//  Generated code. Do not modify.
//  source: service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'service.pb.dart' as $0;

export 'service.pb.dart';

@$pb.GrpcServiceName('FacialLandmarkerService')
class FacialLandmarkerServiceClient extends $grpc.Client {
  static final _$getBlendshapeStream = $grpc.ClientMethod<$0.Empty, $0.BlendshapeResponse>(
      '/FacialLandmarkerService/GetBlendshapeStream',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BlendshapeResponse.fromBuffer(value));

  FacialLandmarkerServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseStream<$0.BlendshapeResponse> getBlendshapeStream($0.Empty request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$getBlendshapeStream, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('FacialLandmarkerService')
abstract class FacialLandmarkerServiceBase extends $grpc.Service {
  $core.String get $name => 'FacialLandmarkerService';

  FacialLandmarkerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.BlendshapeResponse>(
        'GetBlendshapeStream',
        getBlendshapeStream_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.BlendshapeResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.BlendshapeResponse> getBlendshapeStream_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async* {
    yield* getBlendshapeStream(call, await request);
  }

  $async.Stream<$0.BlendshapeResponse> getBlendshapeStream($grpc.ServiceCall call, $0.Empty request);
}

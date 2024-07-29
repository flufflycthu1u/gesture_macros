import 'package:grpc/grpc.dart';

import 'grpc_generated/client.dart';
import 'grpc_generated/service.pbgrpc.dart';

typedef CancelationToken = Function();


(Stream, CancelationToken) streamBlendshapes() {
  Stream stream = FacialLandmarkerServiceClient(getClientChannel()).getBlendshapeStream(Empty());
  CancelationToken cancellationToken;
  cancellationToken = () => (stream as ResponseStream).cancel();
  return (stream, cancellationToken);
}
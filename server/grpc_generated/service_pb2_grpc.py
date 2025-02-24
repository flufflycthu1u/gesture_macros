# Generated by the gRPC Python protocol compiler plugin. DO NOT EDIT!
"""Client and server classes corresponding to protobuf-defined services."""
import grpc
import warnings

import service_pb2 as service__pb2

GRPC_GENERATED_VERSION = '1.65.1'
GRPC_VERSION = grpc.__version__
EXPECTED_ERROR_RELEASE = '1.66.0'
SCHEDULED_RELEASE_DATE = 'August 6, 2024'
_version_not_supported = False

try:
    from grpc._utilities import first_version_is_lower
    _version_not_supported = first_version_is_lower(GRPC_VERSION, GRPC_GENERATED_VERSION)
except ImportError:
    _version_not_supported = True

if _version_not_supported:
    warnings.warn(
        f'The grpc package installed is at version {GRPC_VERSION},'
        + f' but the generated code in service_pb2_grpc.py depends on'
        + f' grpcio>={GRPC_GENERATED_VERSION}.'
        + f' Please upgrade your grpc module to grpcio>={GRPC_GENERATED_VERSION}'
        + f' or downgrade your generated code using grpcio-tools<={GRPC_VERSION}.'
        + f' This warning will become an error in {EXPECTED_ERROR_RELEASE},'
        + f' scheduled for release on {SCHEDULED_RELEASE_DATE}.',
        RuntimeWarning
    )


class FacialLandmarkerServiceStub(object):
    """A service that provides the blendshapes of a face from a webcam
    """

    def __init__(self, channel):
        """Constructor.

        Args:
            channel: A grpc.Channel.
        """
        self.GetBlendshapeStream = channel.unary_stream(
                '/FacialLandmarkerService/GetBlendshapeStream',
                request_serializer=service__pb2.Empty.SerializeToString,
                response_deserializer=service__pb2.BlendshapeResponse.FromString,
                _registered_method=True)


class FacialLandmarkerServiceServicer(object):
    """A service that provides the blendshapes of a face from a webcam
    """

    def GetBlendshapeStream(self, request, context):
        """Streams blendshapes as maps
        """
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')


def add_FacialLandmarkerServiceServicer_to_server(servicer, server):
    rpc_method_handlers = {
            'GetBlendshapeStream': grpc.unary_stream_rpc_method_handler(
                    servicer.GetBlendshapeStream,
                    request_deserializer=service__pb2.Empty.FromString,
                    response_serializer=service__pb2.BlendshapeResponse.SerializeToString,
            ),
    }
    generic_handler = grpc.method_handlers_generic_handler(
            'FacialLandmarkerService', rpc_method_handlers)
    server.add_generic_rpc_handlers((generic_handler,))
    server.add_registered_method_handlers('FacialLandmarkerService', rpc_method_handlers)


 # This class is part of an EXPERIMENTAL API.
class FacialLandmarkerService(object):
    """A service that provides the blendshapes of a face from a webcam
    """

    @staticmethod
    def GetBlendshapeStream(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_stream(
            request,
            target,
            '/FacialLandmarkerService/GetBlendshapeStream',
            service__pb2.Empty.SerializeToString,
            service__pb2.BlendshapeResponse.FromString,
            options,
            channel_credentials,
            insecure,
            call_credentials,
            compression,
            wait_for_ready,
            timeout,
            metadata,
            _registered_method=True)

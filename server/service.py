from concurrent import futures
import cv2
import time
import mediapipe as mp
import numpy as np
from os import path
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2
from grpc_generated import service_pb2_grpc
from grpc_generated import service_pb2


class FacialLandmarkerService():
    def GetBlendshapeStream(self, request, context):
        c = 0.0
        f = open("server.log", "w")
        f.write("started\n")
        cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

        callback = landmarker_results()

        bundle_dir = path.abspath(path.dirname(__file__))
        model_path = path.join(bundle_dir, 'face_landmarker.task')

        BaseOptions = mp.tasks.BaseOptions

        options = mp.tasks.vision.FaceLandmarkerOptions(
                        base_options = BaseOptions(model_asset_path = model_path),
                        output_face_blendshapes = True,
                        running_mode = mp.tasks.vision.RunningMode.LIVE_STREAM,
                        result_callback = callback.result_callback,
        )

        try:
            landmarker = vision.FaceLandmarker.create_from_options(options)
        except Exception as e:
            f.write(f"Error: {e=}, {type(e)=}")
            f.flush()
        else:
            with landmarker:
                prev_time = 0
                while cap.isOpened():
                    _, img = cap.read()
                    rgb_img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
                    mp_img = mp.Image(image_format = mp.ImageFormat.SRGB, data = rgb_img)
                    landmarker.detect_async(mp_img, int(time.time() * 1000))
                    time.sleep(0.03)

                    if(callback.result != None):
                        f.write("result found\n")
                        if(prev_time != callback.timestamp):
                            f.write("new time\n")
                            prev_time = callback.timestamp
                            msg = service_pb2.BlendshapeResponse()
                            for blendshape in callback.result:
                                msg.blendshape[blendshape.category_name] = blendshape.score
                            yield msg
                    else:
                        msg = service_pb2.BlendshapeResponse()
                        msg.blendshape['test'] = c
                        yield msg
                    f.write("loop\n")
                    f.flush()
                    c += 1.0
        cap.release


class landmarker_results:
    result = None
    timestamp = 0
    def result_callback(self, result: mp.tasks.vision.FaceLandmarkerResult, output_image: mp.Image, timestamp_ms: int):
        if result.face_blendshapes:
            self.result = result.face_blendshapes[0]
            self.timestamp = timestamp_ms

if __name__ == "__main__":
    f = FacialLandmarkerService()
    for blendshape_data in f.GetBlendshapeStream(None, None):
        print(blendshape_data)

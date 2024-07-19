import cv2
import time
import sys
import math
import mediapipe as mp
import numpy as np
import matplotlib.pyplot as plt

from sortedcontainers import SortedList
from collections import deque
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2

def draw_landmarks_on_image(rgb_image, detection_result):
  face_landmarks_list = detection_result.face_landmarks
  annotated_image = np.copy(rgb_image)

  # Loop through the detected faces to visualize.
  for idx in range(len(face_landmarks_list)):
    face_landmarks = face_landmarks_list[idx]

    # Draw the face landmarks.
    face_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
    face_landmarks_proto.landmark.extend([
      landmark_pb2.NormalizedLandmark(x=landmark.x, y=landmark.y, z=landmark.z) for landmark in face_landmarks
    ])

    solutions.drawing_utils.draw_landmarks(
        image=annotated_image,
        landmark_list=face_landmarks_proto,
        connections=mp.solutions.face_mesh.FACEMESH_TESSELATION,
        landmark_drawing_spec=None,
        connection_drawing_spec=mp.solutions.drawing_styles
        .get_default_face_mesh_tesselation_style())
    solutions.drawing_utils.draw_landmarks(
        image=annotated_image,
        landmark_list=face_landmarks_proto,
        connections=mp.solutions.face_mesh.FACEMESH_CONTOURS,
        landmark_drawing_spec=None,
        connection_drawing_spec=mp.solutions.drawing_styles
        .get_default_face_mesh_contours_style())
    solutions.drawing_utils.draw_landmarks(
        image=annotated_image,
        landmark_list=face_landmarks_proto,
        connections=mp.solutions.face_mesh.FACEMESH_IRISES,
          landmark_drawing_spec=None,
          connection_drawing_spec=mp.solutions.drawing_styles
          .get_default_face_mesh_iris_connections_style())

  return annotated_image

def plot_face_blendshapes_bar_graph(face_blendshapes):
    # Extract the face blendshapes category names and scores.
    face_blendshapes_names = [face_blendshapes_category.category_name for face_blendshapes_category in face_blendshapes]
    face_blendshapes_scores = [face_blendshapes_category.score for face_blendshapes_category in face_blendshapes]
    # The blendshapes are ordered in decreasing score value.
    face_blendshapes_ranks = range(len(face_blendshapes_names))

    fig, ax = plt.subplots(figsize=(12, 12))
    bar = ax.barh(face_blendshapes_ranks, face_blendshapes_scores, label=[str(x) for x in face_blendshapes_ranks])
    ax.set_yticks(face_blendshapes_ranks, face_blendshapes_names)
    ax.invert_yaxis()

    # Label each bar with values
    for score, patch in zip(face_blendshapes_scores, bar.patches):
        plt.text(patch.get_x() + patch.get_width(), patch.get_y(), f"{score:.4f}", va="top")

    ax.set_xlabel('Score')
    ax.set_title("Face Blendshapes")
    plt.tight_layout()
    plt.show()

model_path = './face_landmarker.task'

def main():
    detection_result_list = []
    image_result_list = []
    delay_queue = deque(maxlen=300)

    counter, fps = 0, 0
    start_time = time.time()

    cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

    # Visualization parameters
    row_size = 20  # pixels
    left_margin = 24  # pixels
    text_color = (255, 255, 0)  # cyan
    font_size = 1
    font_thickness = 1
    fps_avg_frame_count = 10

    BaseOptions = mp.tasks.BaseOptions
    FaceLandmarker = mp.tasks.vision.FaceLandmarker
    FaceLandmarkerOptions = mp.tasks.vision.FaceLandmarkerOptions
    FaceLandmarkerResult = mp.tasks.vision.FaceLandmarkerResult
    VisionRunningMode = mp.tasks.vision.RunningMode

    def result_callback(result: FaceLandmarkerResult, output_image: mp.Image, timestamp_ms: int):
        if (len(result.face_landmarks) > 0):
            result.timestamp_ms = timestamp_ms

            delay_queue.append(int(time.time() * 1000) - timestamp_ms)

            detection_result_list.append(result)

            image_result_list.append(output_image)

    options = FaceLandmarkerOptions(
                    base_options=BaseOptions(model_asset_path=model_path),
                    output_face_blendshapes=True,
                    running_mode=VisionRunningMode.LIVE_STREAM,
                    result_callback=result_callback)
    
    landmarker = vision.FaceLandmarker.create_from_options(options)

    while cap.isOpened():
        ret, img = cap.read()

        if not ret:
           sys.exit('ERROR: Unable to read from webcam. Please verify your webcam settings.')

        counter += 1

        # convert default bgr image capture to rgb
        rgb_img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        mp_img = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_img)

        landmarker.detect_async(mp_img, int(time.time() * 1000))

        current_frame = img

        # Calculate the FPS
        if counter % fps_avg_frame_count == 0:
            end_time = time.time()
            fps = fps_avg_frame_count / (end_time - start_time)
            start_time = time.time()

        if len(detection_result_list) > 0 and len(image_result_list) > 0:
            current_frame = image_result_list[0].numpy_view()
            current_frame = cv2.cvtColor(current_frame, cv2.COLOR_RGB2BGR)
            # Show the FPS
            fps_text = 'FPS = {:.1f}'.format(fps)
            text_location = (left_margin, row_size)
            cv2.putText(current_frame, fps_text, text_location, cv2.FONT_HERSHEY_PLAIN,
                        font_size, text_color, font_thickness)
            vis_img = draw_landmarks_on_image(current_frame, detection_result_list[0])

            # Show the delay
            delay = 0
            if len(delay_queue) > 0:
                delay = sum(delay_queue) / len(delay_queue)
            delay_text = 'Delay = {:1f} ms'.format(delay)
            text_location = (left_margin, 2 * row_size)
            cv2.putText(vis_img, delay_text, text_location, cv2.FONT_HERSHEY_PLAIN,
                        font_size, text_color, font_thickness)

            cv2.imshow('face detection', vis_img)

            if detection_result_list[0].face_blendshapes[0] is not None and keypress == 112:
                plot_face_blendshapes_bar_graph(detection_result_list[0].face_blendshapes[0])
            detection_result_list.clear()
            image_result_list.clear()

        keypress = cv2.waitKey(1)

        # End when esc is pressed
        if keypress == 27:
            break

        

    landmarker.close()
    cap.release()
    cv2.destroyAllWindows()

if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(e)
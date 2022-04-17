import sys
import os

from charset_normalizer import detect
from pandas import value_counts

from RegionGazeCounter import RegionGazeCounter
sys.path.append('Proctoring-AI')
import argparse
import asyncio
import json
import logging
import os
import ssl
import uuid
import numpy as np
import cv2
from aiohttp import web
from av import VideoFrame
import aiohttp_cors
from aiortc import MediaStreamTrack, RTCPeerConnection, RTCSessionDescription
from aiortc.contrib.media import MediaBlackhole, MediaPlayer, MediaRecorder, MediaRelay
import requests
import sched, time
import threading
import random
from head_pose_estimation import *
from face_detector import get_face_detector, find_faces
from face_landmarks import get_landmark_model, detect_marks
import threading
import time

ROOT = os.path.dirname(__file__)

logger = logging.getLogger("pc")
pcs = set()
relay = MediaRelay()

#angle detection
face_model = get_face_detector()
landmark_model = get_landmark_model()

size = (1080,1920)
font = cv2.FONT_HERSHEY_SIMPLEX 
        # 3D model points.
model_points = np.array([
                                    (0.0, 0.0, 0.0),             # Nose tip
                                    (0.0, -330.0, -65.0),        # Chin
                                    (-225.0, 170.0, -135.0),     # Left eye left corner
                                    (225.0, 170.0, -135.0),      # Right eye right corne
                                    (-150.0, -150.0, -125.0),    # Left Mouth corner
                                    (150.0, -150.0, -125.0)      # Right mouth corner
                                ])

        # Camera internals
focal_length = size[1]
center = (size[1]/2, size[0]/2)
camera_matrix = np.array(
                                [[focal_length, 0, center[0]],
                                [0, focal_length, center[1]],
                                [0, 0, 1]], dtype = "double"
                                )


# Load Yolo
net = cv2.dnn.readNet(os.path.join("cocoluyolo","yolo_object_detection","yolov3.weights"), os.path.join("cocoluyolo","yolo_object_detection","yolov3.cfg"))
classes = []
with open(os.path.join("cocoluyolo","yolo_object_detection","coco.names"), "r") as f:
    classes = [line.strip() for line in f.readlines()]
layer_names = net.getLayerNames()
output_layers = [layer_names[i - 1] for i in net.getUnconnectedOutLayers()]
colors = np.random.uniform(0, 255, size=(len(classes), 3))
is_ended = False
processing = False
look_processing=False





def object_detect(img):
    global processing
    img = cv2.resize(img, None, fx=0.4, fy=0.4)
    height, width, channels = img.shape

    # Detecting objects
    blob = cv2.dnn.blobFromImage(img, 0.00392, (416, 416), (0, 0, 0), True, crop=False)

    net.setInput(blob)
    outs = net.forward(output_layers)

    # Showing informations on the screen
    class_ids = []
    confidences = []
    
    found = False
    db_value = 0
    for out in outs:
        for detection in out:
            scores = detection[5:]
            class_id = np.argmax(scores)
            confidence = scores[class_id]
            if confidence > 0.5:
                # Object detected
                if class_id == 67:
                    print("FOUND SOMETHING!")
                    db_value = 100
                    found = True
                elif class_id == 63:
                    print("FOUND SOMETHING!")
                    db_value = 100
                    found = True
                elif class_id == 62:
                    print("FOUND SOMETHING!")
                    db_value = 100
                    found = True
                elif class_id == 74:
                    print("FOUND SOMETHING!")
                    db_value = 100
                    found = True
                else:
                    print(class_id)

                confidences.append(float(confidence))
                class_ids.append(class_id)

        print(db_value)
        writeToDB(db_value)
    processing = False



counter = 0
totalangleX = 0
totalangleY = 0
percentageX = 0
percentageY = 0
faceCounter = 0
gazeCounter = RegionGazeCounter()
  
def look_detect(img):
    global look_processing, counter, totalangleX, totalangleY,percentageX,percentageY,gazeCounter
    faces = find_faces(img, face_model)
    if len(faces) != 1:
        writeToDB(100)
    for face in faces:
        marks = detect_marks(img, landmark_model, face)
        # mark_detector.draw_marks(frame, marks, color=(0, 255, 0))
        image_points = np.array([
                                    marks[30],     # Nose tip
                                    marks[8],     # Chin
                                    marks[36],     # Left eye left corner
                                    marks[45],     # Right eye right corne
                                    marks[48],     # Left Mouth corner
                                    marks[54]      # Right mouth corner
                                ], dtype="double")
        dist_coeffs = np.zeros((4,1)) # Assuming no lens distortion
        (success, rotation_vector, translation_vector) = cv2.solvePnP(model_points, image_points, camera_matrix, dist_coeffs, flags=cv2.SOLVEPNP_UPNP)
        (nose_end_point2D, jacobian) = cv2.projectPoints(np.array([(0.0, 0.0, 1000.0)]), rotation_vector, translation_vector, camera_matrix, dist_coeffs)

        for p in image_points:
            cv2.circle(img, (int(p[0]), int(p[1])), 3, (0,0,255), -1)


        p1 = ( int(image_points[0][0]), int(image_points[0][1]))
        p2 = ( int(nose_end_point2D[0][0][0]), int(nose_end_point2D[0][0][1]))
        x1, x2 = head_pose_points(img, rotation_vector, translation_vector, camera_matrix)

        cv2.line(img, p1, p2, (0, 255, 255), 2)
        cv2.line(img, tuple(x1), tuple(x2), (255, 255, 0), 2)


        try:
            m = (p2[1] - p1[1])/(p2[0] - p1[0])
            ang1 = int(math.degrees(math.atan(m)))
        except:
            ang1 = 0

        try:
            m = (x2[1] - x1[1])/(x2[0] - x1[0])
            ang2 = int(math.degrees(math.atan(-1/m)))
        except:
            ang2 = 0


        totalCheatPercentage = gazeCounter.updateAndCountLookedRegionCount([ang1,ang2])
        if totalCheatPercentage != 0:
            print(totalCheatPercentage)
            writeToDB(totalCheatPercentage)
        
    look_processing=False

class VideoTransformTrack(MediaStreamTrack):
    """
    A video stream track that transforms frames from an another track.
    """
    global focal_length,center,camera_matrix,model_points,font,size,face_model,landmark_model
    global totalCheatPercentage,net,classes,layer_names,output_layers,colors,processing,object_detect,look_processing,look_detect
    kind = "video"
   

    def __init__(self, track, transform,id):
        super().__init__()  # don't forget this!
        self.track = track
        self.transform = transform
        global user_id
        user_id = id
        print("id ==================> ")
        print(user_id)



    async def recv(self):
        global processing, data, object_detect,look_detect,look_processing
        frame = await self.track.recv()
        
        img = frame.to_ndarray(format="bgr24")
        
        if processing == False:
            processing = True
            threading.Thread(target = object_detect, args=(img,)).start()
            
        if look_processing == False:
            look_processing = True
            threading.Thread(target = look_detect, args=(img,)).start()
       
        return frame


def writeToDB(totalCheatP):
    url = 'http://kemalbayik.com/write_od_outputs.php'
    myobj = {'id': user_id,
            'percentage': totalCheatP}
    x = requests.post(url, data = myobj)

async def index(request):
    content = open(os.path.join(ROOT, "index.html"), "r").read()
    return web.Response(content_type="text/html", text=content)


async def javascript(request):
    content = open(os.path.join(ROOT, "client.js"), "r").read()
    return web.Response(content_type="application/javascript", text=content)


async def offer(request):
    params = await request.json()
    offer = RTCSessionDescription(sdp=params["sdp"], type=params["type"])

    global user_id
    user_id = params["id"]
    global is_ended
    is_ended = False

    pc = RTCPeerConnection()
    pc_id = "PeerConnection(%s)" % uuid.uuid4()
    pcs.add(pc)

    f_stop = threading.Event()
    # start calling f now and every 60 sec thereafter
    f(f_stop)

    def log_info(msg, *args):
        logger.info(pc_id + " " + msg, *args)

    log_info("Created for %s", request.remote)

    # prepare local media
    #player = MediaPlayer(os.path.join(ROOT, "demo-instruct.wav"))
    recorder = MediaBlackhole()

    @pc.on("datachannel")
    def on_datachannel(channel):
        @channel.on("message")
        def on_message(message):
            if isinstance(message, str) and message.startswith("ping"):
                channel.send("pong" + message[4:])

    @pc.on("connectionstatechange")
    async def on_connectionstatechange():
        log_info("Connection state is %s", pc.connectionState)
        if pc.connectionState == "failed":
            await pc.close()
            pcs.discard(pc)

    @pc.on("track")
    def on_track(track):
        log_info("Track %s received", track.kind)

        if track.kind == "audio":
            #pc.addTrack(player.audio)
            recorder.addTrack(track)
        elif track.kind == "video":
            pc.addTrack(
                VideoTransformTrack(
                    relay.subscribe(track), transform=params["video_transform"], id=params["id"]
                )
            )

        @track.on("ended")
        async def on_ended():
            global is_ended
            is_ended = True
            log_info("Track %s ended", track.kind)
            await recorder.stop()

    # handle offer
    await pc.setRemoteDescription(offer)
    await recorder.start()

    # send answer
    answer = await pc.createAnswer()
    await pc.setLocalDescription(answer)

    return web.Response(
        content_type="application/json",
        text=json.dumps(
            {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}
        ),
    )

async def heartbeat(request):
    return web.Response(
        text= json.dumps(
            {
                "is_ended": is_ended
            }
        )
    )


async def on_shutdown(app):
    # close peer connections
    coros = [pc.close() for pc in pcs]
    await asyncio.gather(*coros)
    pcs.clear()


app = web.Application()
cors = aiohttp_cors.setup(app)
app.on_shutdown.append(on_shutdown)
app.router.add_get("/", index)
app.router.add_get("/client.js", javascript)
app.router.add_post("/offer", offer)
app.router.add_post("/heartbeat", heartbeat)

for route in list(app.router.routes()):
    cors.add(route, {
        "*": aiohttp_cors.ResourceOptions(
            allow_credentials=True,
            expose_headers="*",
            allow_headers="*",
            allow_methods="*"
        )
    })

def f(f_stop):
    url = 'http://kemalbayik.com/write_od_outputs.php'
    myobj = {'id': user_id,
             'percentage': 0}

    x = requests.post(url, data = myobj)
    print(x.text)

    if not f_stop.is_set():
        # call f() again in 60 seconds
        threading.Timer(10, f, [f_stop]).start()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="WebRTC audio / video / data-channels demo"
    )
    parser.add_argument("--cert-file", help="SSL certificate file (for HTTPS)")
    parser.add_argument("--key-file", help="SSL key file (for HTTPS)")
    parser.add_argument(
        "--host", default="192.168.1.111", help="Host for HTTP server (default: 0.0.0.0)"
    )
    parser.add_argument(
        "--port", type=int, default=9098, help="Port for HTTP server (default: 8080)"
    )
    parser.add_argument("--record-to", help="Write received media to a file."),
    parser.add_argument("--verbose", "-v", action="count")
    args = parser.parse_args()

    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.INFO)

    if args.cert_file:
        ssl_context = ssl.SSLContext()
        ssl_context.load_cert_chain(args.cert_file, args.key_file)
    else:
        ssl_context = None

    web.run_app(
        app, access_log=None, host=args.host, port=args.port, ssl_context=ssl_context
    )
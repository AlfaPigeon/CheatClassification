from tkinter.tix import INTEGER
import cv2
import mediapipe as mp
import time

class handDetector():
    def __init__(self, mode=False, maxHands=2, modelComplexity=1, detectionCon=0.5, trackCon=0.5):
        self.mode = mode
        self.maxHands = maxHands
        self.modelComplex = modelComplexity
        self.detectionCon = detectionCon
        self.trackCon = trackCon

        self.mpHands = mp.solutions.hands
        self.hands = self.mpHands.Hands(self.mode, self.maxHands, self.modelComplex, self.detectionCon, self.trackCon)
        self.mpDraw = mp.solutions.drawing_utils
        
    def findHands(self,img, draw = False):
        imgRGB = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        self.results = self.hands.process(imgRGB)
        if self.results.multi_hand_landmarks:
            for handLms in self.results.multi_hand_landmarks:
                if draw:
                    self.mpDraw.draw_landmarks(img, handLms, self.mpHands.HAND_CONNECTIONS)
        return img

    def findPosition(self, img, draw = False):
        list = []
        h, w, c = img.shape
        if self.results.multi_hand_landmarks:
            for hand in self.results.multi_hand_landmarks:
                minx,miny = 1e6, 1e6
                maxx,maxy = -1, -1
                for id, lm in enumerate(hand.landmark):
                    cx, cy = int(lm.x * w), int(lm.y * h)
                    if minx > cx:
                        minx = cx
                    elif maxx < cx:
                        maxx = cx
                    if miny > cy:
                        miny = cy
                    elif maxy < cy:
                        maxy = cy
                list.append(((minx,miny),(maxx,maxy)))
                if draw:
                    cv2.rectangle(img, (minx,miny), (maxx,maxy), (255, 0, 255), 1)
        return list

pTime = 0
cTime = 0
cap = cv2.VideoCapture(0)
detector = handDetector()

while True:
    success, img = cap.read()
    img = detector.findHands(img, draw = True)
    rect = detector.findPosition(img, draw = True)
    print(rect)
    cv2.imshow("Image", img)
    if cv2.waitKey(1) & 0xFF == ord('q'):
            break

cv2.destroyAllWindows()
cap.release()

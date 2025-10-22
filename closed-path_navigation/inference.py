from ultralytics import YOLO
import scipy.io

model = YOLO("best.pt")
results = model("test.jpg")

detections = []
for r in results:
    for box in r.boxes:
        cls = int(box.cls)   # 0=blue, 1=yellow
        xyxy = box.xyxy[0].tolist()
        detections.append([cls, xyxy])

scipy.io.savemat("detections.mat", {"detections": detections})
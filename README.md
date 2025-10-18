# Team FalconE Racing - Driverless Recruitment Assignment

This repository contains the submission for the Driverless Subsystem assignment for the 22 Batch Recruitment. The project implements an end-to-end perception and control pipeline for navigating a track marked by colored cones.

---
## Part 1: Cone Detection Model

This section details the development and training of a vision model to detect blue and yellow cones from an image feed, as required by the assignment.

### Model and Training Methodology

A **YOLOv8n (nano)** model was selected for this task due to its excellent balance of high speed and accuracy, making it suitable for real-time applications on a race car.

The model was trained for **40 epochs** using a Google Colab environment with a Tesla T4 GPU. The source code for the training process is available in the `cone_detection/` directory in the provided Colab Notebook.

### Dataset

The model was trained on the "cone Dataset" [1], which is available under the Creative Commons BY 4.0 license. This dataset was chosen as it contains a sufficient number of images with variations in lighting conditions and cone poses, which helps improve the model's robustness.

The dataset was downloaded and configured directly in the training script using the following Roboflow command:

```python
# NOTE: API key has been removed for security.
from roboflow import Roboflow
rf = Roboflow(api_key="xxxxxxxxxxxx")
project = rf.workspace("cone-xrbfs").project("cone-xy8w7")
version = project.version(1)
dataset = version.download("yolov8")
```
### Performance Results

The trained model demonstrates high performance and meets the requirements for a reliable cone detector.

* **Accuracy (mAP):** The model achieved a final **mAP50-95 of 0.862** and a **mAP50 of 0.991**, indicating a high level of accuracy in detecting the cone bounding boxes.
* **Runtime:** The model has an average inference speed of **2.0 ms per image** on a Tesla T4 GPU, confirming its suitability for real-time processing.

#### Training Results

The learning curves below show that the model's loss decreased steadily while the performance metrics (precision, recall, mAP) increased and stabilized, indicating a successful training process.

![Training Results](./cone_detection/training%20results/results.png)

#### Class Separation

The confusion matrix below demonstrates a clear separation between the `blue` and `yellow` cone classes, with very few misclassifications. This confirms the model's ability to reliably distinguish between the two types of cones.

![Confusion Matrix](./cone_detection/training%20results/confusion_matrix.png)

### Reference
[1] cone-xrbfs, "Cone," *Roboflow Universe*, Oct. 2025. [Online]. Available: [https://universe.roboflow.com/cone-xrbfs/cone-xy8w7](https://universe.roboflow.com/cone-xrbfs/cone-xy8w7). [Accessed: Oct. 17, 2025].

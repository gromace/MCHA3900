"""
Mask R-CNN
Duckie Detection
"""

import os
import sys
import json
import datetime
import numpy as np
import skimage.draw
import cv2
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from numpy import asarray
from visualize import random_colors
import matlab.engine
from detection import detectDuckie, detectRobotX
from videoVisualise import getPoints

# Root directory of the project
ROOT_DIR = os.getcwd()

# Import Mask RCNN
sys.path.append(ROOT_DIR)
from config import Config
import utils
import modellib

# Start MATLAB engine
eng = matlab.engine.start_matlab()

############################################################
#  Classes: Configuration
############################################################
class InferenceConfig(Config):

    # Run detection on one image at a time
    GPU_COUNT = 1
    IMAGES_PER_GPU = 1


class DuckieConfig(Config):
    """Configuration for training on the duckie dataset."""

    # Configuration name
    NAME = "duckie"

    # Depends on the GPU power - my GPU only has 6GB, so using 1 image
    IMAGES_PER_GPU = 1

    # Number of classes (including background)
    NUM_CLASSES = 1 + 1  # background + duckie

    # Number of training steps per epoch
    STEPS_PER_EPOCH = 100

    # Skip detections with < 90% confidence - can be tuned by user
    DETECTION_MIN_CONFIDENCE = 0.9


class RobotXConfig(Config):
    """Configuration for training on the RobotX dataset."""

    # Configuration name
    NAME = "RobotX"

    # Depends on the GPU power - my GPU only has 6GB, so using 1 image
    IMAGES_PER_GPU = 1

    # Number of classes (including background)
    NUM_CLASSES = 1 + 1  # Background + buoy (add more)

    # Number of training steps per epoch
    STEPS_PER_EPOCH = 100

    # Skip detections with < 90% confidence - can be tuned by user
    DETECTION_MIN_CONFIDENCE = 0.90


############################################################
#  Classes: Datasets
############################################################
class DuckieDataset(utils.Dataset):

    def load_ducks(self, dataset_dir, subset):
        """ Load a subset of the duck dataset. """

        # Add classes. Only adding one class: ducks
        self.add_class("duckie", 1, "duckie")

        # Load either training or validation dataset (based on user input)
        assert subset in ["train", "val"]
        dataset_dir = os.path.join(dataset_dir, subset)

        # Load annotations
        annotations = json.load(open(os.path.join(dataset_dir,
                                                  "via_region_data.json")))
        annotations = list(annotations.values())

        # Skip unannotated images in the json (i.e. those w/ no label data).
        annotations = [a for a in annotations if a['regions']]

        # Add images
        for a in annotations:
            # Get the (x,y) coordinates of boundary mask polygon points
            polygons = [r['shape_attributes'] for r in a['regions'].values()]

            # Determine image size
            image_path = os.path.join(dataset_dir, a['filename'])
            image = skimage.io.imread(image_path)
            height, width = image.shape[:2]

            # Add to duckie dataset repository
            self.add_image(
                "duckie",
                image_id=a['filename'],
                path=image_path,
                width=width, height=height,
                polygons=polygons)

    def load_mask(self, image_id):
        """
        Generate instance masks for an image.
        Returns:
            masks:      A bool array with one mask per instance.
            class_ids: a 1D array of class IDs of the instance masks.
        """

        # If not a duckie dataset image, delegate to parent class.
        image_info = self.image_info[image_id]
        if image_info["source"] != "duckie":
            return super(self.__class__, self).load_mask(image_id)

        # Convert polygons to a bitmap mask
        info = self.image_info[image_id]
        mask = np.zeros([info["height"], info["width"], len(info["polygons"])],
                        dtype=np.uint8)

        for i, p in enumerate(info["polygons"]):
            # Get indexes of pixels inside the polygon and set them to 1
            rr, cc = skimage.draw.polygon(p['all_points_y'], p['all_points_x'])
            mask[rr, cc, i] = 1

        # Return mask, and array of class IDs of each instance
        return mask, np.ones([mask.shape[-1]], dtype=np.int32)

    def image_reference(self, image_id):
        """Return the path of the image."""
        info = self.image_info[image_id]
        if info["source"] == "duckie":
            return info["path"]
        else:
            super(self.__class__, self).image_reference(image_id)


class RobotXDataset(utils.Dataset):

    def load_RobotX(self, dataset_dir, subset):
        """ Load a subset of the duck dataset. """
        # Add classes - only adding buoy class at the moment.
        self.add_class("buoy", 1, "buoy")

        # Load either training or validation dataset (based on cmd call input)
        assert subset in ["train", "val"]
        dataset_dir = os.path.join(dataset_dir, subset)

        # Load annotations
        annotations = json.load(open(os.path.join(dataset_dir,
                                                  "via_region_data.json")))
        annotations = list(annotations.values())

        # Skip unannotated images in the json (i.e. no label data).
        annotations = [a for a in annotations if a['regions']]

        # Add images
        for a in annotations:
            # Get the x & y coordinates of points of the polygons that make up
            # the outline of each object
            polygons = [r['shape_attributes'] for r in a['regions'].values()]

            # Determine image size
            image_path = os.path.join(dataset_dir, a['filename'])
            image = skimage.io.imread(image_path)
            height, width = image.shape[:2]

            self.add_image(
                "buoy",
                image_id=a['filename'],
                path=image_path,
                width=width, height=height,
                polygons=polygons)

    def load_mask(self, image_id):
        """
        Generate instance masks for an image.
        Returns:
            masks:      A bool array with one mask per instance.
            class_ids: a 1D array of class IDs of the instance masks.
        """

        # If not a RobotX dataset image, delegate to parent class.
        image_info = self.image_info[image_id]
        if image_info["source"] != "buoy":
            return super(self.__class__, self).load_mask(image_id)

        # Convert polygons to a bitmap mask
        info = self.image_info[image_id]
        mask = np.zeros([info["height"], info["width"], len(info["polygons"])],
                        dtype=np.uint8)

        for i, p in enumerate(info["polygons"]):
            # Get indexes of pixels inside the polygon and set them to 1
            rr, cc = skimage.draw.polygon(p['all_points_y'], p['all_points_x'])
            mask[rr, cc, i] = 1

        # Return mask, and array of class IDs of each instance
        return mask, np.ones([mask.shape[-1]], dtype=np.int32)

    def image_reference(self, image_id):
        """Return the path of the image."""
        info = self.image_info[image_id]
        if info["source"] == "buoy":
            return info["path"]
        else:
            super(self.__class__, self).image_reference(image_id)

############################################################
#  Training
############################################################

def trainDuckie(model):
    """Train the duckie detection model."""
    # Training dataset.
    dataset_train = DuckieDataset()
    dataset_train.load_ducks(DUCKIE_DATASET, "train")
    dataset_train.prepare()

    # Validation dataset
    dataset_val = DuckieDataset()
    dataset_val.load_ducks(DUCKIE_DATASET, "val")
    dataset_val.prepare()

    # Training config (can adjust hyperparameters to tune)
    print("Practicing for duck season")
    model.train(dataset_train,
                dataset_val,
                learning_rate=config.LEARNING_RATE,
                epochs=100,
                layers='heads')


def trainRobotX(model):
    """Train the RobotX detection model."""
    # Training dataset.
    dataset_train = RobotXDataset()
    dataset_train.load_RobotX(ROBOTX_DATASET, "train")
    dataset_train.prepare()

    # Validation dataset
    dataset_val = RobotXDataset()
    dataset_val.load_RobotX(ROBOTX_DATASET, "val")
    dataset_val.prepare()

    # Training config
    print("Avoiding icebergs")
    model.train(dataset_train,
                dataset_val,
                learning_rate=config.LEARNING_RATE,
                epochs=100,
                layers='heads')

############################################################
#  Main
############################################################
if __name__ == '__main__':
    import argparse

    # Preference to run through command line, but will work if not
    try:
        # Parse command line arguments
        parser = argparse.ArgumentParser(description='Run network: Mask R-CNN')

        parser.add_argument("command",
                            metavar="<command>",
                            help="'train or test'")

        parser.add_argument("--dataset",
                            metavar="<dataset>",
                            help="'dataset: 'duckie' or 'RobotX''")

        parser.add_argument('--weights',
                            required=True,
                            metavar="/path/to/weights.h5",
                            help="Path to weights .h5 file or 'coco'")

        parser.add_argument('--video',
                            required=False,
                            metavar=r"<y/n>",
                            help="Run webfeed (y) or not (n)")

        args = parser.parse_args()
        dataset = args.dataset.lower()
        weights = args.weights.lower()
        command = args.command.lower()

        if args.video.lower == 'y':
            video = True
        else:
            video = False

    # If not running through command line, edit here to do desired task
    except:
        commandAll = ["train", "test"]
        datasetAll = ["duckie", "RobotX"]
        weightsAll = ["coco"]
        booleanAll = [True, False]

        command = commandAll[1].lower()
        dataset = datasetAll[0].lower()
        weights = weightsAll[0].lower()
        video = booleanAll[0]
        live = booleanAll[1]
        video_path = "ducks-05312018160553.avi"

    print("Training: \t" + command)
    print("Weights: \t" + weights)
    print("Video: \t\t" + str(video))
    ##########################################################

    # Configurations
    if dataset == "duckie":
        COCO_WEIGHTS_PATH = ROOT_DIR + "\DuckieDetection\duckieDetection.h5"
        #DEFAULT_LOGS_DIR = ROOT_DIR + "\DuckieDetection\modelLogs"
        DUCKIE_DATASET = ROOT_DIR + "\DuckieDetection\dataset"
        DEFAULT_LOGS_DIR = "D:\Model\logs"
        config = DuckieConfig()

    elif dataset == "robotx":
        COCO_WEIGHTS_PATH = ROOT_DIR + "\RobotXDetection\RobotXDetection.h5"
        DEFAULT_LOGS_DIR = ROOT_DIR + "\RobotXDetection\modelLogs"
        ROBOTX_DATASET = ROOT_DIR + "\RobotXDetection\dataset"
        config = RobotXConfig()
    else:
        raise ValueError('Dataset not recognised: use duckie or RobotX')

    if command == "train":
        model = modellib.MaskRCNN(mode="training", config=config,
                                  model_dir=DEFAULT_LOGS_DIR)

        if weights == "coco":
            weights_path = COCO_WEIGHTS_PATH
            model.load_weights(weights_path, by_name=True,
                               exclude=["mrcnn_class_logits",
                                        "mrcnn_bbox_fc",
                                        "mrcnn_bbox",
                                        "mrcnn_mask"])
    elif command == "test":
        model = modellib.MaskRCNN(mode="inference", config=config,
                                  model_dir=DEFAULT_LOGS_DIR)
        weights_path = COCO_WEIGHTS_PATH
        model.load_weights(weights_path, by_name=True)

    else:
        raise ValueError('Command not recognised: use train or test')

    # Select weights file to load
    if weights == "coco":
        weights_path = COCO_WEIGHTS_PATH
        model.load_weights(weights_path, by_name=True,
                           exclude=["mrcnn_class_logits",
                                    "mrcnn_bbox_fc",
                                    "mrcnn_bbox",
                                    "mrcnn_mask"])

    #############################################################
    # Training mode
    if command == 'train':
        if dataset == "duckie":
            trainDuckie(model)
        elif dataset == "robotx":
            trainRobotX(model)
        else:
            print("'{}' is not recognized. "
                  "Use 'duckie' or 'RobotX'".format(dataset))

    # Testing mode - photo or video
    elif command == 'test':
        if dataset == "duckie":
            # Load validation dataset
            dataset = DuckieDataset()
            dataset.load_ducks(DUCKIE_DATASET, "val")
            dataset.prepare()
            detectDuckie(model, dataset, config, video_path, live, video)

        elif dataset == "robotx":
            dataset = RobotXDataset()
            dataset.load_RobotX(ROBOTX_DATASET, "val")
            dataset.prepare()
            detectRobotX(model, dataset, video)
        else:
            print("'{}' is not recognized. "
                  "Use 'duckie' or 'RobotX'".format(dataset))

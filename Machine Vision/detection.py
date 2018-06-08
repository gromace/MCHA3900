# -*- coding: utf-8 -*-
"""
Created on Fri Jun  1 04:37:00 2018

@author: Chloe
"""
from plotVectors import detectVideo

def detectDuckie(model, dataset, config, video_path=None, live=False, video=False):
    import random
    from visualize import display_instances
    from videoVisualise import getPoints, displayDetections
    import matplotlib.pyplot as plt
    import modellib
    from vidDetectionLive import detectVideoLive
    from vidDetectionOffline import detectVideoOffline
    
#    assert(video is True and live is False and video_path is not None)

    # If running on photo
    if video is False:
        print("Images: {}\nClasses: {}".format(len(dataset.image_ids),
              dataset.class_names))

        image_id = random.choice(dataset.image_ids)
        image, image_meta, gt_class_id, gt_bbox, gt_mask = modellib.load_image_gt(dataset,
                                                                               config,
                                                                               image_id,
                                                                               use_mini_mask=False)
        # Run object detection
        results = model.detect([image], verbose=1)

        # Display results
        fig = plt.figure(figsize=(15,15/3))
        ax = fig.add_subplot(111)
        r = results[0]
        display_instances(image,
                          r['rois'],
                          r['masks'],
                          r['class_ids'],
                          dataset.class_names,
                          r['scores'],
                          ax=ax)

        topLeft, botLeft, topRight, botRight, centre = getPoints(r['rois'])

        # Verification plot
        for i in range(r['rois'].shape[0]):
            plt.scatter(topLeft[i][0], topLeft[i][1])
            plt.scatter(botLeft[i][0], botLeft[i][1])
            plt.scatter(topRight[i][0], topRight[i][1])
            plt.scatter(botRight[i][0], botRight[i][1])
            plt.scatter(centre[i][1], centre[i][0])

    elif video is True and live is True:
        detectVideoLive(model)
    elif video is True and live is False and video_path is not None:
        detectVideoOffline(model, video_path)
    else:
        raise ValueError("Non-valid testing configuration")


def detectRobotX(model, dataset, config, video=False):
    import random
    from visualize import display_instances
    import matplotlib.pyplot as plt
    import cv2
    import model as modellib
    from videoVisualise import getPoints, display_cv_instances

    print("Images: {}\nClasses: {}".format(len(dataset.image_ids),
          dataset.class_names))

    image_id = random.choice(dataset.image_ids)
    image, image_meta, gt_class_id, gt_bbox, gt_mask = modellib.load_image_gt(dataset,
                                                                              config,
                                                                              image_id,
                                                                              use_mini_mask=False)
    info = dataset.image_info[image_id]

    print("image ID: {}.{} ({}) {}".format(info["source"],
                                           info["id"], image_id,
                                           dataset.image_reference(image_id)))

    # Run object detection
    results = model.detect([image], verbose=1)

    # Display results
    fig = plt.figure(figsize=(15,15/3))
    ax = fig.add_subplot(111)
    r = results[0]
    display_instances(image,
                      r['rois'],
                      r['masks'],
                      r['class_ids'],
                      dataset.class_names,
                      r['scores'],
                      ax=ax,
                      title="Predictions")

    topLeft, botLeft, topRight, botRight, centre = getPoints(r['rois'])

    # Verification plot
    for i in range(r['rois'].shape[0]):
        plt.scatter(topLeft[i][0], topLeft[i][1])
        plt.scatter(botLeft[i][0], botLeft[i][1])
        plt.scatter(topRight[i][0], topRight[i][1])
        plt.scatter(botRight[i][0], botRight[i][1])
        plt.scatter(centre[i][1], centre[i][0])

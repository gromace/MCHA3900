# -*- coding: utf-8 -*-
"""
Created on Fri May  18 11:50:26 2018

@author: Chloe
"""

def getPoints(bboxes):
    """ Gets the points of the bounding boxes for detected instances    
    
    Parameters
    ----------
    bboxes : numpy array 
        array containing points corresponding to bounding box

    Returns
    -------
    [] : numpy array [instances,2]
        (u,v) coordinates for the centre and boundary box corners
    """

    # Get centre
    topLeft = []
    topRight = []
    botLeft = []
    botRight = []
    centre = []

    for i in range(bboxes.shape[0]):
        # Put into arrays for easier post-processing
        topLeft.append([bboxes[i, 1], bboxes[i, 0]])
        botLeft.append([bboxes[i, 1], bboxes[i, 2]])
        topRight.append([bboxes[i, 3], bboxes[i, 0]])
        botRight.append([bboxes[i, 3], bboxes[i, 2]])

        # Calculate horizontal and vertical radius (centre to bounding box)
        centre.append([0.5*(topLeft[i][1]+botLeft[i][1]),
                      0.5*(topRight[i][0]+topLeft[i][0])])

    return(topLeft, botLeft, topRight, botRight, centre)


def vectorAngle(v1, v2):
    """ Returns the angle in radians between vectors 'v1' and 'v2'
    
    Note
    -----
    Using atan2 instead of cos to improve robustness w/ small angles
    
    
    Parameters
    ----------
    v1 : numpy array 
        vector 1
    v2 : numpy array
        vector 2

    Returns
    -------
    ang : scalar angle
        Angle between v1 and v2 in radians.

    """
    import numpy as np
    import numpy.linalg as la

    cosAng = np.dot(v1, v2)
    sinAng = la.norm(np.cross(v1, v2))
    ang = np.arctan2(sinAng, cosAng)
    return(ang)


def displayDetections(image, boxes, masks, ids, names, scores, angDiameter, distance):
    """ Take Mask-RCNN output and annotate image with details    

    Parameters
    ----------
    image :  RGB image [height, width, 3]
    
    boxes : numpy array 
        Array containing points corresponding to bounding box
    
    masks : image segmentation mask [height, width, instance num]
        Masks corresponding to pixels predicted to belong to object class.
    
    
    ids : numpy array [instances]
        Array of values corresponding to the detected class ID for each
        detected instance. For duckieDetection:
                                    0 = background (ignored)
                                    1 = Duckie
    
    names : numpy array [num classes]
        Array of class names for Mask-RCNN
        For duckieDetection, this is ['BG','Duckie']
    
    scores : numpy array [1,instances]
        Array of values from 0-1, corresponding to the prediction confidence.
        0 = no confidence, 1 = full confidence
    
    angDiameter : numpy array [instances]
        Predicted angular diameter
    
    distance : numpy array [instances]
        Predicted distance to the object, based on object size and angWidth
        
    Returns
    -------
    image : RGB image [height, width, 3]
        Image with annotations
        
    """

    import cv2
    import numpy as np
    
    n_instances = boxes.shape[0]
    colors = randomColours(n_instances)

    if not n_instances:
        print('Detected: Nothing')
    else:
        assert boxes.shape[0] == masks.shape[-1] == ids.shape[0]
        print('Detected: ' + names[ids[0]])

    for i, color in enumerate(colors):
        if not np.any(boxes[i]):
            continue

        y1, x1, y2, x2 = boxes[i]
        if (angDiameter[i] <= 0):
            caption = "C:'{}' L:{:.2f}%".format(names[ids[i]], float(scores[i]*100))
        else:
            caption = "C:'{}' L:{:.2f}% W:{:.2f}rad D:{:.2f}mm".format(names[ids[i]], float(scores[i]*100), float(angDiameter[i]), float(distance[i]))

        mask = masks[:, :, i]

        image = applyMask(image, mask, color)
        image = cv2.rectangle(image, (x1, y1), (x2, y2), color, 2)
        image = cv2.putText(image, caption, (x1, y1), cv2.FONT_HERSHEY_COMPLEX, 0.7, color, 2)

    return image


def colourRegion(image, mask):
    """Apply color effect on regions of detected objects in image.

    Parameters
    ----------
    image :  RGB image [height, width, 3]
        The image/frame upon which to put the colour effect.
        Passed from detect_and_colour()

    mask : image segmentation mask [height, width, instance num]
        Mask corresponding to pixels predicted to belong to object class.
        Returns from model.detect().
        Used to determine which pixels to colour.

    Returns
    -------
    detectFlag : boolean
        Indicates whether colour effect was implemented in frame.
        True == colour effect implemented
        False == colour effect not implemented

    img : 
        The edited image, either in grayscale or with the colour effect.

    """

    from skimage.color import rgb2gray, gray2rgb
    import numpy as np
    # Make a grayscale copy of the image
    gray = gray2rgb(rgb2gray(image))*255

    # Collapse masks into a single layer
    mask = (np.sum(mask, -1, keepdims=True) >= 1)

    # Copy colour pixels in the masked region from the original colour image
    # Replace these pixels in the grayscale image
    if mask.shape[0] > 0:
        img = np.where(mask, image, gray).astype(np.uint8)
        detectFlag = True
    else:
        img = gray
        detectFlag = False
    return detectFlag, img


def randomColours(N):

    import numpy as np
    # Random seed - VR46 #MotoGP
    np.random.seed(46)

    # Generate 3 random numbers
    randArray = np.random.rand(3)

    # Generate N number of colours
    colours = [tuple(255*randArray) for throwawayVar in range(N)]
    return(colours)


def applyMask(image, mask, colour, alpha=0.5):
    """ Apply mask to image
    """

    import numpy as np
    for n, c in enumerate(colour):
        image[:, :, n] = np.where(mask == 1,
                                 image[:, :, n] * (1 - alpha) + alpha * c,
                                 image[:, :, n])
    return(image)

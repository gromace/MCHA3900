# -*- coding: utf-8 -*-
"""
Created on Tue May 29 09:54:00 2018

@author: Sleepy Chloe
"""

import os
import sys
import datetime
import numpy as np
import cv2
import matplotlib.pyplot as plt
from numpy import asarray
from visualize import random_colors
from videoVisualise import getPoints, displayDetections, vectorAngle, colourRegion
import matlab.engine
import matplotlib.image as image
from mpl_toolkits.mplot3d import proj3d
from matplotlib.offsetbox import AnnotationBbox, OffsetImage

# Root directory of the project
ROOT_DIR = os.getcwd()

# Start MATLAB engine
eng = matlab.engine.start_matlab()

def detectVideoOffline(model, video_path):
    """ Detects instances in video, produces vector plots and saves to file
    
    Notes
    -----
    - Saves to local directory:
            Video with colour effect applied
            Images of vector plots
        
    - Requires matlab.engine to interface with camera model script for
      pixelToVector calculations.
    
    Parameters
    ----------
    model :  Tensorflow model
        Mask-RCNN model in inference mode.
        Generated in runNetwork().
        
    video_path : file/path/to/video
        Path to video upon which to do detection.
        User-defined.
    
    Returns
    -------
    None
    
    """
    angle1 = -125
    angle2 = -70 
    class_names = ['BG', 'Duckie']
    
    # Open 3d plot with origin at [0,0,0]
    fig = plt.figure(figsize=(7,7/3))
    ax2 = fig.add_subplot(121, projection='3d')
    ax2.cla()
    ax2.set_xlim(-1, 1)
    ax2.set_ylim(-1, 1)                
    ax2.set_zlim(0, 1)
    ax2.set_title('Optimised pixelToVector function')
    ax2.set_xlabel("x", fontsize=16)
    ax2.set_ylabel("y", fontsize=16)
    ax2.set_zlabel("z", fontsize=16)
    ax2.view_init(elev=angle1, azim=angle2)
    
#    ax2 = fig.add_subplot(122, projection='3d')
#    ax2.cla()
#    ax2.set_xlim(-1, 1)
#    ax2.set_ylim(-1, 1)                
#    ax2.set_zlim(0, 1)
#    ax2.set_title('Non-optimised pixelToVector function')
#    ax2.set_xlabel("x", fontsize=16)
#    ax2.set_ylabel("y", fontsize=16)
#    ax2.set_zlabel("z", fontsize=16)
#    ax2.view_init(elev=angle1, azim=angle2)
#    plt.tight_layout()
    plt.show()
    
    # Generate filenames and create directories
    file_name_orig = "offline_rec_{:%Y%m%dT%H%M%S}".format(datetime.datetime.now())
    rootDir = ROOT_DIR + r'/Recordings/' + file_name_orig + r'/'
    rootDir_orig = rootDir + r'orig/'
    rootDir_vec = rootDir + r'vec/'
    rootDir_col = rootDir + r'col/'
    os.mkdir(rootDir)
    os.mkdir(rootDir_orig)
    os.mkdir(rootDir_vec)
    os.mkdir(rootDir_col)

    lines = []
    lines2 = []
    frameCount = -1
    origin = [0,0,0]
    height = 200
    angularWidth = 0
    distance = 0
    dpi = 72
    imageSize = (32,32)
    imDuckie = image.imread(r'PlotImages\duckie.png')
    imCamera = image.imread(r'PlotImages\wheatley.png')
    imDuckie = OffsetImage(imDuckie, zoom=0.25)
    imCamera = OffsetImage(imCamera, zoom=0.1)
    capture = cv2.VideoCapture(video_path)

    while True:
        frameCount += 1
        print("Frame #", frameCount)

        ret, frame = capture.read()

        # Detect objects
        results = model.detect([frame], verbose=0)
        r = results[0]

        # Get points of interest
        tL, bL, tR, bT, centre = getPoints(r['rois'])

        if (r['rois'].shape[0] > 0):
            # Clear previous lines and reset format
            ax2.cla()
            ax2.set_xlim(-1, 1)
            ax2.set_ylim(-1, 1)
            ax2.set_zlim(0, 1)
            ax2.set_title('Non-optimised pixelToVector function')
            ax2.set_xlabel("x", fontsize=16)
            ax2.set_ylabel("y", fontsize=16)
            ax2.set_zlabel("z", fontsize=16)
            #ax2.view_init(elev=angle1, azim=angle2)

            angularWidth = []
            distance = []

            # Plot vector from origin to centre of each object
            for i in range(r['rois'].shape[0]):

                # Do pixeltovector function using upper left and bottom left
                u_uLeft = float(tL[i][0])
                v_uLeft = float(tL[i][1])
                u_bLeft = float(bL[i][0])
                v_bLeft = float(bL[i][1])

                l_Vec = eng.pixeltovector(float(u_uLeft), float(v_uLeft))
                r_Vec = eng.pixeltovector(float(u_bLeft), float(v_bLeft))

                l_Vec = [l_Vec[0][3], l_Vec[0][4], l_Vec[0][5]]
                r_Vec = [r_Vec[0][3], r_Vec[0][4], r_Vec[0][5]]

                # Using diameter, not radius
                angularWidth.append(vectorAngle(l_Vec,r_Vec))

                # Estimating distance
                # (probably doing this wrong, too sleepy to think)
                distance.append(height/np.tan(angularWidth[i]))

                # Do pixeltovector function using centre points
                # Run from MATLAB
                u_centre = float(centre[i][0])
                v_centre = float(centre[i][1])
                res = eng.pixeltovector(float(u_centre), float(v_centre))
                noptVect = [res[0][0], res[0][1], res[0][2]]
                optVect = [res[0][3], res[0][4], res[0][5]]
                
                # Plot optimised vector
#                duckieVector = optVect
#                xs = asarray([origin[0], duckieVector[0]])
#                ys = asarray([origin[1], duckieVector[1]])
#                zs = asarray([origin[2], duckieVector[2]])
#                colors = random_colors(r['rois'].shape[0])
#                lines.append(ax.plot(xs, ys, zs, color=colors[i],
#                                     mfc="None", mec="None",
#                                     markersize=imageSize[0]*(dpi/96)))
#                
#                xOrigin, yOrigin, _ = proj3d.proj_transform(0,0,0,
#                                                            ax.get_proj())
#    
#                xDuck, yDuck, _ = proj3d.proj_transform(duckieVector[0],
#                                                        duckieVector[1],
#                                                        duckieVector[2],
#                                                        ax.get_proj())
#                ab1 = AnnotationBbox(imDuckie, [xDuck,yDuck])
#                ab2 = AnnotationBbox(imCamera, [xOrigin,yOrigin])
#                ax.add_artist(ab1)
#                ax.add_artist(ab2)
    
                # Plot non-optimised vector
                duckieVector = noptVect
                xs = asarray([origin[0], duckieVector[0]])
                ys = asarray([origin[1], duckieVector[1]])
                zs = asarray([origin[2], duckieVector[2]])
                plt.tight_layout()
                colors = random_colors(r['rois'].shape[0])
                lines2.append(ax2.plot(xs, ys, zs, color=colors[i],
                                    mfc="None", mec="None",
                                    markersize=imageSize[0]*(dpi/96)))

                xOrigin, yOrigin, _ = proj3d.proj_transform(0,0,0,
                                                            ax2.get_proj())

                xDuck, yDuck, _ = proj3d.proj_transform(duckieVector[0],
                                                        duckieVector[1],
                                                        duckieVector[2],
                                                        ax2.get_proj())
                ab1 = AnnotationBbox(imDuckie, [xDuck,yDuck])
                ab2 = AnnotationBbox(imCamera, [xOrigin,yOrigin])
                ax2.add_artist(ab1)
                ax2.add_artist(ab2)
                plt.tight_layout()
                plt.pause(0.1)

        frame = displayDetections(frame, r['rois'], r['masks'], r['class_ids'],
                                  class_names, r['scores'],
                                  angularWidth, distance)

        # Save 3D vector plots
        imagePath = rootDir_vec + file_name_orig + 'vector_' + "{:03d}".format(frameCount) + '.png'
        fig.savefig(imagePath)

        # Write the annotated image to a file
        imagePath = rootDir_col + file_name_orig + 'img_' + "{:03d}".format(frameCount)  + '.png'
        cv2.imwrite(imagePath,frame) 

        cv2.imshow('frame', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    capture.release()
    cv2.destroyAllWindows()
    
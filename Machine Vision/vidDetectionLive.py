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

# Root directory of the project
ROOT_DIR = os.getcwd()

# Import Mask RCNN
sys.path.append(ROOT_DIR)

# Start MATLAB engine
eng = matlab.engine.start_matlab()

def detectVideoLive(model):
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
    class_names = ['BG', 'Duckie']

    # Open 3d plot with origin at [0,0,0]
    fig = plt.figure(figsize=(15,15/3))
    ax = fig.add_subplot(121, projection='3d')
    ax.cla()
    ax.set_xlim(-1, 1)
    ax.set_ylim(-1, 1)                
    ax.set_zlim(0, 1)
    ax.set_title('Optimised pixelToVector function')
    ax.set_xlabel("x", fontsize=16)
    ax.set_ylabel("y", fontsize=16)
    ax.set_zlabel("z", fontsize=16)
    ax.view_init(elev=45, azim=45)
    
    ax2 = fig.add_subplot(122, projection='3d')
    ax2.cla()
    ax2.set_xlim(-1, 1)
    ax2.set_ylim(-1, 1)                
    ax2.set_zlim(0, 1)
    ax2.set_title('Non-optimised pixelToVector function')
    ax2.set_xlabel("x", fontsize=16)
    ax2.set_ylabel("y", fontsize=16)
    ax2.set_zlabel("z", fontsize=16)
    ax2.view_init(elev=45, azim=45)
    plt.tight_layout()
    plt.show()

    # Generate filenames and create directories
    file_name_orig = "live_rec_{:%Y%m%dT%H%M%S}".format(datetime.datetime.now())
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

    capture = cv2.VideoCapture(0)

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
            ax.cla()
            ax.set_xlim(-1, 1)
            ax.set_ylim(-1, 1)
            ax.set_zlim(0, 1)
            ax.set_title('Optimised pixelToVector function')
            ax.set_xlabel("x", fontsize=16)
            ax.set_ylabel("y", fontsize=16)
            ax.set_zlabel("z", fontsize=16)
            ax.view_init(elev=45, azim=45)

            ax2.cla()
            ax2.set_xlim(-1, 1)
            ax2.set_ylim(-1, 1)
            ax2.set_zlim(0, 1)
            ax2.set_title('Non-optimised pixelToVector function')
            ax2.set_xlabel("x", fontsize=16)
            ax2.set_ylabel("y", fontsize=16)
            ax2.set_zlabel("z", fontsize=16)
            ax2.view_init(elev=45, azim=45)

            angularWidth = []
            distance = []

            # Plot vector from origin to centre of each object
            for i in range(r['rois'].shape[0]):

                #duckieDistance = pixel2mm*(rad[i])/duckieRadius
                #duckieLocation = [centre[i][1], centre[i][0], 1]
                #duckieVector = duckieLocation             

                # Do pixeltovector function using upper left and bottom left
                u_uLeft = float(tL[i][0])
                v_uLeft = float(tL[i][1])
                u_bLeft = float(bL[i][0])
                v_bLeft = float(bL[i][1])

                l_Vec = eng.pixeltovector(float(u_uLeft), float(v_uLeft))
                r_Vec = eng.pixeltovector(float(u_bLeft), float(v_bLeft))

                l_Vec = [l_Vec[0][3], l_Vec[0][4], l_Vec[0][5]]
                r_Vec = [r_Vec[0][3], r_Vec[0][4], r_Vec[0][5]]

                # Diameter, not radius
                angularWidth.append(vectorAngle(l_Vec,r_Vec))

                # Estimating distance
                # (probably doing this wrong, too sleepy to think)
                distance.append(height/np.tan(angularWidth[i]))

                # Do pixeltovector function using cansentre points
                # Run from MATLAB
                u_centre = float(centre[i][0])
                v_centre = float(centre[i][1])
                res = eng.pixeltovector(float(u_centre), float(v_centre))
                noptVect = [res[0][0], res[0][1], res[0][2]]
                optVect = [res[0][3], res[0][4], res[0][5]]

                # Plot optimised vector
                duckieVector = optVect
                xs = asarray([origin[0], abs(duckieVector[0])])
                ys = asarray([origin[1], abs(duckieVector[1])])
                zs = asarray([origin[2], duckieVector[2]])
                colors = random_colors(r['rois'].shape[0])
                lines.append(ax.plot(xs, ys, zs, color=colors[i],
                                     marker=r'$\bigotimes$',
                                     markersize=22))

                # Plot non-optimised vector
                duckieVector = noptVect
                xs = asarray([origin[0], abs(duckieVector[0])])
                ys = asarray([origin[1], abs(duckieVector[1])])
                zs = asarray([origin[2], duckieVector[2]])
                plt.tight_layout()
                colors = random_colors(r['rois'].shape[0])
                lines2.append(ax2.plot(xs, ys, zs, color=colors[i],
                                     marker=r'$\bigotimes$',
                                     markersize=22))
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


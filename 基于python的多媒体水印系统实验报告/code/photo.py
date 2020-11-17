#!/bin/python
# -*- coding=utf8 - *-
import cv2
import numpy as np
def encode(s):
    return ' '.join([bin(ord(c)).replace('0b', '') for c in s])
def embed_watermark(image_path):
    image_array=cv2.imread(image_path,cv2.IMREAD_GRAYSCALE)
    
    image_array_flatten=image_array.flatten()#返回一个一位数组
    watermarks='Rhea'
    
    
    water1='{:08b}'.format(len(watermarks))#十进制转二进制，不足补0
    #print(water1)
   
    length_bin_string = '0b'
    length_bin='0b'
    water2=''
    for i in range(0, 8):#获得前 8 个像素灰度值的最低位
        if water1[i]=='1':
            
            image_array_flatten[i]=image_array_flatten[i]|1
            
        else:
            image_array_flatten[i]=image_array_flatten[i]&254
            
    for i in range(len(watermarks)):
        water2='{:08b}'.format(ord(watermarks[i]))
        k=0
        for j in range(8*(i+1),8*(i+1)+8):
            if water2[k]=='1':
                
                image_array_flatten[j]=image_array_flatten[j]|1
                
                k+=1
            else:
                image_array_flatten[j]=image_array_flatten[j]&254
                k+=1
            
 
    img=np.array(image_array_flatten).reshape(image_array.shape[0],image_array.shape[1])
   
    cv2.imwrite("Rhea2.bmp",img)
def extract_watermark(embed_path):
    im_array = cv2.imread(embed_path, cv2.IMREAD_GRAYSCALE)
    im_array_flatten = im_array.flatten()

    length_bin_string = '0b'
    for i in range(0, 8):
        if im_array_flatten[i] & 1 == 0:
            length_bin_string += '0'
        else:
            length_bin_string += '1'

    watermark_length = int(length_bin_string, 2)

    watermark = ''
    for i in range(watermark_length):
        char_bin_string = '0b'
        for j in range(8 * (i + 1), 8 * (i + 1) + 8):
            if im_array_flatten[j] & 1 == 0:
                char_bin_string += '0'
            else:
                char_bin_string += '1'

        char = chr(int(char_bin_string, 2))

        watermark += char

    print(watermark)
       


     
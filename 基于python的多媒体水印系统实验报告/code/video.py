FFMPEG_BIN="ffmpeg"
import subprocess as sp 
import numpy

import robust
def embed_video(input_video,watermark_string,output_video):
    command_read=[FFMPEG_BIN,
                   '-i',input_video,
                   '-f','image2pipe',
                   '-pix_fmt','yuv420p',
                   '-c:v','rawvideo','-'] 
    pipe_read=sp.Popen(command_read,stdout=sp.PIPE,bufsize=10 ** 8)
    command_write=[FFMPEG_BIN,'-y',
                              '-f','rawvideo',
                              '-c:v','rawvideo',
                              '-s','1280x720',
                              '-pix_fmt','yuv420p',
                              '-i','-',
                              '-q:v','2',
                              output_video]
    pipe_write=sp.Popen(command_write, stdin=sp.PIPE)

    raw_image=pipe_read.stdout.read(1280*720*3)

    while raw_image != None and len(raw_image) !=0:
          image=numpy.fromstring(raw_image,dtype='uint8')
        #if (len(image)==2764800):
          #print(len(image))
          image=image.reshape((720,1280,3))
          pipe_read.stdout.flush()
         
          img_tmp=image[:720, :1280, 0]
          robust.embed_watermark(img_tmp,watermark_string)

          pipe_write.stdin.write(image.tostring())

          raw_image=pipe_read.stdout.read(1280 * 720 * 3)

def extract_video(input_video):
    command_read=[FFMPEG_BIN,
                  '-i',input_video,
                  '-f','image2pipe',
                  '-pix_fmt','yuv420p',
                  '-c:v','rawvideo','-']
    pipe_read=sp.Popen(command_read,stdout=sp.PIPE,bufsize=10 ** 8)
    raw_image=pipe_read.stdout.read(1280*720*3)

    while raw_image != None and len(raw_image)!=0:
        image=numpy.fromstring(raw_image,dtype='uint8')
        if len(image)==2764800:
          image=image.reshape((720,1280,3))
          pipe_read.stdout.flush()

          img_tmp=image[:720, :1280, 0]
          robust.extract_watermark(img_tmp)
        
          raw_image=pipe_read.stdout.read(1280*720*3)

#if __name__ == '__main__':
    
    #watermark='Rhea'
    #video_path2=embed_video('myvideo.mp4',watermark,'myvideo2.mp4')
    #print(extract_video('myvideo2.mp4'))




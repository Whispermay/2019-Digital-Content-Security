import argparse
import photo
import audio
import video


if __name__=='__main__':
    parser=argparse.ArgumentParser(description='数字水印系统，可以支持音频、图像、视频的水印嵌入和提取：')
    parser.add_argument('--type',metavar='type',type=str,help='处理文件的类型！')
    parser.add_argument( '--operate',metavar='operate',type=str,help='操作类型：embed为嵌入，extract为提取' )
    parser.add_argument('input',metavar='input',type=str,help='输入文件')

    args=parser.parse_args()
    if args.type=='image':
        if args.operate=='embed':
            photo.embed_watermark(args.input)
        if args.operate=='extract':
            photo.extract_watermark(args.input)
    if args.type=='video':
        if args.operate=='embed':
            video.embed_video(args.input,'Rhea','myvideo2.mp4')
        if args.operate=='extract':
            video.extract_video(args.input)

    if args.type=='audio':
        if args.operate=='embed':
            audio.lsb_watermark(args.input,'Rhea','F010.wav')

        if args.operate=='extract':
            print(audio.recover_lsb_watermark(args.input))

    print(args.input)
    print(args.type)
    print(args.operate)




# Jsteg信息隐藏算法仿真测试

## 实验目的

用matlab实现图像信息隐藏算法Jsteg仿真测试

## 实验环境

使用的图像为512x512的灰度图像和1080x1440的灰度图像各一幅，使用的工具及版本为 MATLAB R2018a。

## 实验内容

* 对每个图像分别嵌入10个文本文件（容量从小到大），绘制PSNR~容量曲线，计算提出水印的误码率。
* 对其中一幅带有水印的图像进行不同质量因子的图像压缩，再将压缩后的图像进行水印提取操作，计算误码率。

## 实验过程

* 水印嵌入与提取
  * 读取图像

    ```matlab
    cover = imread('测试图像/1.jpeg');
    [m,n]=size(cover); 
    ```

  * 循环读取要嵌入的水印文件，提取对应的二进制

    ```matlab
    for Q=1:10
    watermark=['水印文件/',num2str(Q),'.txt'] ;  %打开要嵌入的10个文件
    watermark=fopen(watermark,'r');
    watermark=fgetl(watermark);
    wlength = length(watermark);
    %figure(1),subplot(2,1,1),imshow(cover),title('原图');
    watermark = uint8(watermark);
    end 
    ```

    ```matlab
    bitlength=1;
    for i=1:wlength
    
    
    for imbed=1:8
    watermarkshift=bitshift(watermark(i),8-imbed);
    
    singlebit=uint8(watermarkshift);
    singlebit=bitshift(singlebit,-7);
    
    watermarkbit(bitlength)=singlebit; %得到信息的二进制数码
    bitlength=bitlength+1;
    
    
    end
    end
    ```

    

  * 水印逐个嵌入

    ```matlab
    i=1;
        for m1=1:m
            for n1=1:n
               x=jpeg_img(m1,n1);
               if (x~=0) && (x~=1)  %如果DCT系数不是0或1
                   r=mod(x,2); %获得x的LSB
                   if r==0 % 如果LSB为0，x为2k
                       if watermarkbit(i)==1 %如果水印的二进制数码为1
                           x=x+1;
                       end
                   else
                       if watermarkbit(i)==0
                           x=x-1; 
                       end
                   end
                   i=i+1;
               end
            jpeg_img(m1,n1)=x; %用x的值代替原DCT系数值
            
            if i==bitlength
                break;
            end
              
            end
            
            if i==bitlength
                break;
            end
            
        end
    ```

    

  * 生成并保存水印图像

    ```matlab
    new_img = coverzero - coverzero;  % 清零
    for m1 = 1: blocksize: m
      for n1 = 1: blocksize: n
    
          IDCT_num = jpeg_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1);
          IDCT_num = round(idct2(IDCT_num .* (DCT_quantizer(1:blocksize, 1:blocksize))));
          new_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1) = IDCT_num;
      end
    end
    
    
    m = m - pad_m; %去掉补的块
    n = n - pad_n;
    new_img = new_img(1:m, 1:n);
    
    
    filename2=['水印图1/',num2str(Q),'.jpeg'];
    imwrite(new_img,filename2,'jpeg','quality',100); %保存嵌入水印的图
    ```

    

  * 对水印图像进行DCT量化，获得水印图像量化的DCT系数

    ```matlab
    for m1 = 1: blocksize: m
      for n1 = 1: blocksize: n
          DCT_num = new_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1);%8*8分块
          DCT_num = dct2(DCT_num);%DCT
          DCT_num = round (DCT_num ./ (DCT_quantizer(1:blocksize, 1:blocksize) ));%量化取整
         
        jpeg_img(m1: m1 + blocksize-1, n1: n1 + blocksize-1) = DCT_num; %DCT矩阵
       
      end
    end
    ```

    

  * 提取水印

    ```matlab
    stego=jpeg_img; %水印图量化后的DCT系数
    stegoindex=1;
    imbed=1;
    watermarkchar=0;
    watermarkindex=1;
    for m1=1:m
        for n1=1:n
        stegowatermark = stego(m1,n1); %DCT系数
        if (stegowatermark~=0)&&(stegowatermark~=1) %如果DCT系数不为0或1
          
            r=mod(stegowatermark,2); %DCT系数的LSB
            if (r==0)     
                singlebit=0;
            else singlebit=1;
            end
            
            singlebit=uint8(singlebit);  
            
            singlebit=bitshift(singlebit,(imbed-1)); %逐位生成水印的二进制数码（十进制表示）
            watermarkchar=uint8(watermarkchar+singlebit);%格式转换
            watermark1(watermarkindex)=watermarkchar;%存储提出的每个字符的ASCII码
            
            stegoindex = stegoindex+1;
            imbed=imbed+1;
            if (imbed==9) 
                watermarkindex=watermarkindex+1;
                watermark1(watermarkindex-1)=watermarkchar;
                
                watermarkchar=0;
                imbed=1;
            end
            
        end
        if (stegoindex==wlength*8)
            break;
        end
        end
        if (stegoindex==wlength*8)
            break;
        end
    end
    ```

    

  * 绘制PSNR~容量曲线

    ```matlab
    MES=sum(sum((coverzero-new_img).^2))/(m*n);     %均方差
        PSNR=20*log10(255/sqrt(MES));           %峰值信噪比
        arr1(Q)=wlength;
        arr2(Q)=PSNR;
    ```

    

  * 计算误码率

    ```matlab
     if(isequal(watermark,watermark1)==0)
     if(wlength~=length(watermark1))%如果长度不相等
         for i=length(watermark1):wlength
             watermark1(i)=0;%用2填充
         end
         for i=1:wlength
             if(watermark1(i)~=watermark(i))
             wr=wr+1;
             end
         end
     else %若长度相等
         for i=1:wlength
             if(watermark1(i)~=watermark(i))
             wr=wr+1;
             end
         end
         
     end
    p=wr/wlength;
    disp('误码率：'),disp(p);
    end
    ```

    

* 分析测试所研究算法的缺陷

  * 这里选取嵌入5.txt水印的lena图像，以质量因子为[1,21,41,61,81]分别对水印图像进行压缩。

    ```matlab
    for Q=1:20:100
        wr=0;
        filename=['水印图压缩/Q=',num2str(Q),'.jpeg'];
        imwrite(img,filename,'jpeg','quality',Q);  %保存文件
        cover=imread(filename); 
        [m,n]=size(cover);
    end 
    ```

  * 读取压缩的图像再次进行水印提取

  * 将提取出的水印与5.txt进行比较，并计算误码率。

## 测试数据

* 原图像：测试图像文件夹下

  ![](\测试图像\1.jpeg)

  ![](测试图像\2.jpeg)

* 嵌入的信息：在水印文件夹下 。

## 实验结果

* 512x512图像的PSNR~容量曲线

  ![](Figure\lenaPSNR.jpg)

* 1080x1440图像PSNR~容量曲线

  ![](Figure\tihuPSNR.jpg)

* 若嵌入容量过大会发生提取信息错误，本实验是从嵌入文件7.txt后出现提取错误。

  ![](实验截图\误码率0.png)

* 在对嵌有水印的图像进行图像压缩后再进行水印提取会出现提取错误的情况，在质量因子Q=1的情况下什么都提取不出来。

  ![](实验截图\误码率.png)


function [nzAC,embedding_efficiency,changes] = nsf5_simulation(COVER,STEGO,ALPHA,SEED)
% -------------------------------------------------------------------------
% Contact: jan@kodovsky.com | June 2011
% -------------------------------------------------------------------------
% This program simulates the embedding impact of the steganographic
% algorithm nsF5 [1] as if the best possible coding was used. Please, visit
% the webpage http://dde.binghamton.edu/download/nsf5simulator for more
% information.
% -------------------------------------------------------------------------
% Input:
%  COVER - cover image (grayscale JPEG image)
%  STEGO - resulting stego image that will be created
%  ALPHA - relative payload in terms of bits per nonzero AC DCT coefficient
%  SEED - PRNG seed for the random walk over the coefficients
% Output:
%  nzAC - number of nonzero AC DCT coefficients in the cover image
%  embedding_efficiency - bound on embedding efficiency used for simulation
%  changes - number of changes made
% -------------------------------------------------------------------------
% References:
% [1] J. Fridrich, T. Pevny, and J. Kodovsky, Statistically undetectable
%     JPEG steganography: Dead ends, challenges, and opportunities. In J.
%     Dittmann and J. Fridrich, editors, Proceedings of the 9th ACM
%     Multimedia & Security Workshop, pages 3-14, Dallas, TX, September
%     20-21, 2007.
% -------------------------------------------------------------------------
% Note: The program requires Phil Sallee's MATLAB JPEG toolbox available at
% http://www.philsallee.com/
% -------------------------------------------------------------------------

%%% load the cover image
try
    
    jobj = jpeg_read(COVER); % JPEG image structure
    img =imread('cover.jpg');
    img2=img(193:256,193:256);%提取第28块
    DCT = jobj.coef_arrays{1}; % DCT plane
    DCT2=DCT(193:256,193:256);%提取第28块量化后DCT系数
    Q=cell2mat(jobj.quant_tables);%转化为double矩阵
    figure(1),subplot(3,3,1),imshow(img),title('原图');
    figure(1),subplot(3,3,2),imshow(img2),title('分块图');
    figure(1),subplot(3,3,3),imshow(DCT),title('原图DCT');
    figure(1),subplot(3,3,4),imshow(DCT2),title('分块图DCT');
    
    % 反量化
     fun_re_quan = @(block_struct) (block_struct.data.* Q);
     Q2 = blockproc(DCT2, [8 8], fun_re_quan);
     figure(1),subplot(3,3,5),imshow(Q2),title('反量化');
    %IDCT
     fun_idct = @(block_struct) idct2(block_struct.data);
     IDCT =  blockproc(Q2, [8 8], fun_idct);
     figure(1),subplot(3,3,6),imshow(IDCT+128),title('逆DCT');
     figure(1),subplot(3,3,7),imshow(uint8(IDCT+128)),title('逆DCT分块图');
    
catch
    error('ERROR (problem with the cover image)');
end

if ALPHA>0
    
    %%% embedding simulation
    embedding_efficiency = ALPHA/invH(ALPHA);  % bound on embedding efficiency
    nzAC = nnz(DCT)-nnz(DCT(1:8:end,1:8:end)); % 非零交流DCT系数的数目number of nonzero AC DCT coefficients
    changes = ceil(ALPHA*nzAC/embedding_efficiency); % nsF5将对绑定进行的更改数number of changes nsF5 would make on bound
    changeable = (DCT~=0); % 遮罩的所有非零的DCT系数的图像mask of all nonzero DCT coefficients in the image
    changeable(1:8:end,1:8:end) = false; %不嵌入直流模式 do not embed into DC modes
    changeable = find(changeable); %变系数的指数 indexes of the changeable coefficients
    rand('state',SEED); % 使用给定的种子初始化PRNGinitialize PRNG using given SEED
    changeable = changeable(randperm(nzAC)); % 创建一个伪随机遍历非零的交流系数create a pseudorandom walk over nonzero AC coefficients
    to_be_changed = changeable(1:changes); %需要更改的系数 coefficients to be changed
    DCT(to_be_changed) = DCT(to_be_changed)-sign(DCT(to_be_changed)); % 减小要改变的系数的绝对值decrease the absolute value of the coefficients to be changed
    
end

%%% save the resulting stego image
try
    jobj.coef_arrays{1} = DCT;
    jobj.optimize_coding = 1;
    jpeg_write(jobj,STEGO);
catch
    error('ERROR (problem with saving the stego image)')
end

function res = invH(y)
% inverse of the binary entropy function二进制熵函数的逆
to_minimize = @(x) (H(x)-y)^2;
res = fminbnd(to_minimize,eps,0.5-eps);

function res = H(x)
% binary entropy function
res = -x*log2(x)-(1-x)*log2(1-x);




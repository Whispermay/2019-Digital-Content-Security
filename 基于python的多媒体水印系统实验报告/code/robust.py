# - * - coding=utf-8 -*-

import cv2
import numpy as np

SPREAD_WIDTH = 33
STRENGTH = 30

# 返回value对应的二进制字符串
# 其中value是要转化的整数
# bitsize是转化为字符串的长度
# bin_value(6, 8)将整数6转化为长度为8的二进制'00000110'
def bin_value(value, bitsize=8):
    binval = bin(value)[2:]
    if len(binval) > bitsize:
        print("Larger than the expected size")
    while len(binval) < bitsize:
        binval = "0" + binval
    return binval

# 1->'1'*5->'11111'
# bit_string -> '101010101010'
def spread_spectrum(bit_string):
    ret = ""

    # bit -> '1' / '0'
    for bit in bit_string:
        # bit * SPREAD_WIDTH(33) '1111...111' 共SPREAD_WIDTH次重放
        ret = ret + bit * SPREAD_WIDTH

    return ret


# '11111'->'1'
def get_original_bin(bit_string):
    if len(bit_string) % SPREAD_WIDTH != 0:
        print("长度错误，需是%d整数倍。" % SPREAD_WIDTH)
        return None

    ret_string = ""
    # original_bit_length 是原始二进制字符串的长度，即bit个数
    original_bit_length = int(len(bit_string) / SPREAD_WIDTH)
    for i in range(original_bit_length):
        count = 0
        for j in range(SPREAD_WIDTH):
            value = int(bit_string[i * SPREAD_WIDTH + j])
            count = count + value

        if count < SPREAD_WIDTH * 0.6:
            ret_string += "0"
        else:
            ret_string += "1"

    return ret_string


# 'anjing' -> '6anjing' -> '00000110......' - > ''
def watermark_encode(watermark_string):
    # 初始化水印信息
    watermark = ""

    # 水印字符串长度转化为32bits的二进制字符串并加入水印信息中
    watermark_size = bin_value(len(watermark_string), 8)
    watermark += spread_spectrum(watermark_size)

    # 循环转化字符串中的字符为二进制字符串并加入+水印信息中
    for char in watermark_string:
        temp_string = bin_value(ord(char))
        watermark += spread_spectrum(temp_string)
    return watermark


# 把单个bit 嵌入到8*8的dct块中
def embed_bit(bit, dcted_block, alpha):
    if bit == 1:
        if dcted_block[4, 3] < dcted_block[5, 2]:
            dcted_block[4, 3], dcted_block[5, 2] = dcted_block[5, 2], dcted_block[4, 3]
            if dcted_block[4, 3] - dcted_block[5, 2] < alpha:
                dcted_block[4, 3] += alpha
        elif dcted_block[4, 3] == dcted_block[5, 2]:
            dcted_block[4, 3] += alpha
    elif bit == 0:
        if dcted_block[4, 3] > dcted_block[5, 2]:
            dcted_block[4, 3], dcted_block[5, 2] = dcted_block[5, 2], dcted_block[4, 3]
            if dcted_block[5, 2] - dcted_block[4, 3] < alpha:
                dcted_block[4, 3] -= alpha
        elif dcted_block[4, 3] == dcted_block[5, 2]:
            dcted_block[4, 3] -= alpha
    else:
        print("请输入正确的水印值，0或1。")


# 从8*8的dct块中提取单个bit
def extract_bit(dcted_block):
    if dcted_block[4, 3] > dcted_block[5, 2]:
        return 1
    else:
        return 0

# 嵌入
def embed_watermark(image_array, watermark_string):

    watermark = watermark_encode(watermark_string)

    iHeight, iWidth = image_array.shape

    # img2 = np.empty(shape=(iHeight, iWidth))

    index = 0
    # 分块DCT
    for startY in range(0, iHeight, 8):
        for startX in range(0, iWidth, 8):
            block = image_array[startY:startY + 8, startX:startX + 8]

            # 进行DCT
            blockf = np.float32(block)
            block_dct = cv2.dct(blockf)

            if index < len(watermark):
                embed_bit(int(watermark[index]), block_dct, STRENGTH)
                index += 1

            block_idct = cv2.idct(block_dct)

            # store the result
            for y in range(8):
                for x in range(8):
                    image_array[startY + y, startX + x] = block_idct[y, x]


# 提取
def extract_watermark(img):
    iHeight, iWidth = img.shape

    index = 0
    length_string = ""
    watermark_length = 0
    watermark_string = ""

    # 分块DCT
    for startY in range(0, iHeight, 8):
        for startX in range(0, iWidth, 8):
            block = img[startY:startY + 8, startX:startX + 8].reshape((8, 8))

            # 进行DCT
            blockf = np.float32(block)
            block_dct = cv2.dct(blockf)

            if index < 8 * SPREAD_WIDTH:
                bit = extract_bit(block_dct)

                if bit == 1:
                    length_string += "1"
                else:
                    length_string += "0"

                if index == 8 * SPREAD_WIDTH - 1:
                    length_string = get_original_bin(length_string)
                    watermark_length = int(length_string, 2)

                index += 1

            elif index < 8 * SPREAD_WIDTH + watermark_length * 8 * SPREAD_WIDTH:

                bit = extract_bit(block_dct)

                if bit == 1:
                    watermark_string += "1"
                else:
                    watermark_string += "0"

                if index == 8 * SPREAD_WIDTH + watermark_length * 8 * SPREAD_WIDTH - 1:
                    watermark_string = get_original_bin(watermark_string)

                    decoded_watermark = ""
                    for i in range(watermark_length):
                        decoded_watermark += chr(int(watermark_string[i * 8: (i + 1) * 8], 2))

                    print(decoded_watermark)
                    return decoded_watermark

                index += 1
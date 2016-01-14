//
//  UIImage+QRCodeGenerator.m
//
//  Created by Oscar Sanderson on 3/8/13.
//  Copyright (c) 2013 Oscar Sanderson. All rights reserved.
//

#import "UIImage+QRCodeGenerator.h"
#import "ZXMultiFormatWriter.h"
#import "ZXBitMatrix.h"
#import "ZXImage.h"

@implementation UIImage (QRCodeGenerator)

+(id)qrCodefromString:(NSString*)data size:(int)size
{
    NSError *error = nil;
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    ZXBitMatrix* result = [writer encode:data
                                  format:kBarcodeFormatQRCode
                                   width:size
                                  height:size
                                   error:&error];
    if (result) {
        CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage];
        return [UIImage imageWithCGImage:image];
        // This CGImageRef image can be placed in a UIImage, NSImage, or written to a file.
    } else {
//        NSString *errorMessage = [error localizedDescription];
        return error;
    }
}

@end

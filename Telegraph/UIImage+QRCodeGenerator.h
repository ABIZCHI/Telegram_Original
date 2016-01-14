//
//  UIImage+QRCodeGenerator.h
//
//  Created by Oscar Sanderson on 3/8/13.
//  Copyright (c) 2013 Oscar Sanderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRCodeGenerator)

/**Returns a UIImage of the encoded data as a QR.
    Will return NSError if it fails.
 */
+(UIImage*)qrCodefromString:(NSString*)data size:(int)size;

@end

//
//  BRBubbleView.h
//  BreadWallet
//
//  Created by Aaron Voisine on 3/10/14.
//  Copyright (c) 2014 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <UIKit/UIKit.h>

@class CoachMarkView;
typedef void(^TouchEventBlock)(CoachMarkView *coachMark);

typedef enum {
    CMBubbleTipDirectionDown = 0,
    CMBubbleTipDirectionUp
} CMBubbleTipDirection;

@interface CoachMarkView : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGPoint tipPoint;
@property (nonatomic, assign) CMBubbleTipDirection tipDirection;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) TouchEventBlock touchEvent;
@property (nonatomic, strong) NSString *uniqueID;

+ (instancetype)viewWithText:(NSString *)text center:(CGPoint)center uniqueID:(NSString*)uniqueID customTouchEvent:(TouchEventBlock)touchEvent;
+ (instancetype)viewWithText:(NSString *)text tipPoint:(CGPoint)point tipDirection:(CMBubbleTipDirection)direction  uniqueID:(NSString*)uniqueID;
+ (instancetype)viewWithText:(NSString *)text tipPoint:(CGPoint)point tipDirection:(CMBubbleTipDirection)direction  uniqueID:(NSString*)uniqueID customTouchEvent:(TouchEventBlock)touchEvent;

- (instancetype)popIn;
- (instancetype)popOut;
- (instancetype)popOutAfterDelay:(NSTimeInterval)delay;

@end

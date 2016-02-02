//
//  BRBubbleView.m
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

#import "CoachMarkView.h"
#import "TGNavigationBar.h"
#import "TGAppDelegate.h"
#import "TGImageUtils.h"
#import "GemsNavigationController.h"

// GemsUI
#import <GemsUI/UILabel+EmphasizedText.h>

#define RADIUS    10.0
#define MARGIN    10.0
#define MAX_WIDTH 300.0

// text place holders
#define GEMS_USD_VALUE_PLACEHOLDER @"$%^&"
#define GEMS_REWARD_FOR_INVITING_FRIENDS_PLACEHOLDER @"!@#$"

@interface CoachMarkView ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) CAShapeLayer *arrow;

@end

@implementation CoachMarkView

+ (instancetype)viewWithText:(NSString *)text center:(CGPoint)center uniqueID:(NSString*)uniqueID customTouchEvent:(TouchEventBlock)touchEvent
{
    CoachMarkView *v = [[self alloc] initWithFrame:CGRectMake(center.x - MARGIN, center.y - MARGIN, MARGIN*2, MARGIN*2)];
    v.uniqueID = uniqueID;
    v.text = [v replacePlaceholders:text];
    v.touchEvent = touchEvent;
    return v;
}

+ (instancetype)viewWithText:(NSString *)text tipPoint:(CGPoint)point tipDirection:(CMBubbleTipDirection)direction  uniqueID:(NSString*)uniqueID
{
    return [self viewWithText:text tipPoint:point tipDirection:direction uniqueID:uniqueID customTouchEvent:nil];
}

+ (instancetype) viewWithText:(NSString *)text tipPoint:(CGPoint)point tipDirection:(CMBubbleTipDirection)direction  uniqueID:(NSString*)uniqueID customTouchEvent:(TouchEventBlock)touchEvent
{
    CoachMarkView *v = [[self alloc] initWithFrame:CGRectMake(0, 0, MARGIN*2, MARGIN*2)];
    
    v.uniqueID = uniqueID;
    v.touchEvent = touchEvent;
    v.tipDirection = direction;
    v.tipPoint = point;
    v.text = [v replacePlaceholders:text];
    return v;
}

- (NSString*)replacePlaceholders:(NSString*)text
{
    GemsAmount *ga = [[GemsAmount alloc] initWithAmount:1 currency:_G unit:Gem];
    double oneGemUSDValue = [[ga toFiat:[self getFiatCode]] doubleValue];
    int rewardPerInvitee = kGemsRewardUserInvite;
    text = [text stringByReplacingOccurrencesOfString:GEMS_USD_VALUE_PLACEHOLDER withString:[NSString stringWithFormat:@"$ %@", formatDoubleToStringWithDecimalPrecision(oneGemUSDValue, 3)]];
    text = [text stringByReplacingOccurrencesOfString:GEMS_REWARD_FOR_INVITING_FRIENDS_PLACEHOLDER withString:[NSString stringWithFormat:@"%d", rewardPerInvitee]];
    return text;
}

- (id)initWithFrame:(CGRect)frame
{
    if (! (self = [super initWithFrame:frame])) return nil;

    UIColor *bgColor;
    TGNavigationController *navController = (TGNavigationController*)TGAppDelegateInstance.rootController.presentedViewController;
    TGNavigationBar *navBar = (TGNavigationBar*)navController.navigationBar;
    if(TGIsPad()) {
        bgColor = navBar.barBackgroundView.backgroundColor;
    }
    else {
        bgColor = navBar.barBackgroundView.backgroundColor;
    }
    
    self.layer.cornerRadius = RADIUS;
    self.backgroundColor = bgColor;
    self.alpha = 0.8f;
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, MARGIN, frame.size.width - MARGIN*2,
                                                           frame.size.height - MARGIN*2)];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor whiteColor];
    self.label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    self.label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.15];
    self.label.shadowOffset = CGSizeMake(0.0, 1.0);
    self.label.numberOfLines = 0;
    [self addSubview:self.label];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
    self.label.userInteractionEnabled = YES;
    [self.label addGestureRecognizer:tap];
    
    return self;
}

- (void)tap: (UITapGestureRecognizer *) __unused recognizer
{
    if(self.touchEvent)
        self.touchEvent(self);
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)setText:(NSString *)text
{
    [self.label setSpecialAttribuitedText:text];
    [self setNeedsLayout];
}

- (NSString *)text
{
    return self.label.text;
}

- (void)setFont:(UIFont *)font
{
    self.label.font = font;
    [self setNeedsLayout];
}

- (UIFont *)font
{
    return self.label.font;
}

- (void)setTipPoint:(CGPoint)tipPoint
{
    _tipPoint = tipPoint;
    [self setNeedsLayout];
}

- (void)setTipDirection:(CMBubbleTipDirection)tipDirection
{
    _tipDirection = tipDirection;
    [self setNeedsLayout];
}

- (void)setCustomView:(UIView *)customView
{
    if (_customView) [_customView removeFromSuperview];
    _customView = customView;
    customView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                  UIViewAutoresizingFlexibleBottomMargin;
    if (customView) [self addSubview:customView];
    [self setNeedsLayout];
}

- (instancetype)popIn
{
    self.alpha = 0.0;
    self.transform = CGAffineTransformMakeScale(0.75, 0.75);

    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0
     options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.alpha = 1.0;
    } completion:nil];

    return self;
}

- (instancetype)popOut
{
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.75, 0.75);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];

    return self;
}

- (instancetype)popOutAfterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(popOut) withObject:nil afterDelay:delay];
    return self;
}

- (void)layoutSubviews
{
    CGPoint center = self.center;
    CGRect rect = [self.label textRectForBounds:CGRectMake(0.0, 0.0, MAX_WIDTH - MARGIN*2, CGFLOAT_MAX)
                   limitedToNumberOfLines:0];

    if (self.customView) {
        if (rect.size.width < self.customView.frame.size.width) rect.size.width = self.customView.frame.size.width;
        rect.size.height += self.customView.frame.size.height + (self.text.length > 0 ? MARGIN : 0);
    }

    if (self.tipPoint.x > 1) { // position bubble to point to tipPoint
        center.x = self.tipPoint.x;
        if (center.x + rect.size.width/2 > MAX_WIDTH)
            center.x = MAX_WIDTH - rect.size.width/2 + MARGIN;
        else if (center.x - rect.size.width/2 < MARGIN*2)
            center.x = MARGIN*2 + rect.size.width/2;

        center.y = self.tipPoint.y;
        center.y += (self.tipDirection == CMBubbleTipDirectionUp ? 1 : -1)*((rect.size.height + MARGIN*2)/2 + RADIUS);
    }

    self.frame = CGRectMake(center.x - rect.size.width/2, center.y - (rect.size.height + MARGIN*2)/2,
                            rect.size.width, rect.size.height + MARGIN*2);

    if (self.customView) { // layout customView and label
        self.customView.center = CGPointMake((rect.size.width + MARGIN*2)/2,
                                             self.customView.frame.size.height/2 + MARGIN);
        self.label.frame = CGRectMake(MARGIN, self.customView.frame.size.height + MARGIN*2, self.label.frame.size.width,
                                      self.frame.size.height - (self.customView.frame.size.height + MARGIN*3));
    }
    else self.label.frame = CGRectMake(MARGIN, MARGIN, self.label.frame.size.width, self.frame.size.height - MARGIN*2);

    if (self.tipPoint.x > 1) { // draw tip arrow
        CGMutablePathRef path = CGPathCreateMutable();
        CGFloat x = self.tipPoint.x - (center.x - rect.size.width/2);

        if (! self.arrow) self.arrow = [[CAShapeLayer alloc] init];
        if (x > rect.size.width + MARGIN*2 - (RADIUS + 7.5)) x = rect.size.width + MARGIN*2 - (RADIUS + 7.5);
        if (x < self.layer.cornerRadius + 7.5) x = self.layer.cornerRadius + 7.5;

        if (self.tipDirection == CMBubbleTipDirectionUp) {
            CGPathMoveToPoint(path, NULL, 0.0, 7.5);
            CGPathAddLineToPoint(path, NULL, 7.5, 0.0);
            CGPathAddLineToPoint(path, NULL, 15.0, 7.5);
            CGPathAddLineToPoint(path, NULL, 0.0, 7.5);
            self.arrow.position = CGPointMake(x, 0.5);
            self.arrow.anchorPoint = CGPointMake(0.5, 1.0);
        }
        else {
            CGPathMoveToPoint(path, NULL, 0.0, 0.0);
            CGPathAddLineToPoint(path, NULL, 7.5, 7.5);
            CGPathAddLineToPoint(path, NULL, 15.0, 0.0);
            CGPathAddLineToPoint(path, NULL, 0.0, 0.0);
            self.arrow.position = CGPointMake(x, rect.size.height + MARGIN*2 - 0.5);
            self.arrow.anchorPoint = CGPointMake(0.5, 0.0);
        }

        self.arrow.path = path;
        self.arrow.strokeColor = [[UIColor clearColor] CGColor];
        self.arrow.fillColor = [self.backgroundColor CGColor];
        self.arrow.bounds = CGRectMake(0.0, 0.0, 15.0, 7.5);
        [self.layer addSublayer:self.arrow];
        
        CGPathRelease(path);
    }
    else if (self.arrow) { // remove tip arrow
        [self.arrow removeFromSuperlayer];
        self.arrow = nil;
    }

    [super layoutSubviews];
}

#pragma mark - currency coversion
-(NSString*)getFiatCode
{
    CDGemsSystem *s = [CDGemsSystem MR_findFirst];
    return [s.currencySymbol uppercaseString];
}

@end

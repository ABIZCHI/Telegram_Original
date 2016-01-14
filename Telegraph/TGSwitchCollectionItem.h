/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItem.h"

@class ASHandle;

@interface TGSwitchCollectionItem : TGCollectionItem

@property (nonatomic, strong) ASHandle *interfaceHandle;
@property (nonatomic, copy) void (^toggled)(bool value);

@property (nonatomic, strong) NSString *title;
GEMS_ADDED_PROPERTY @property (nonatomic, strong) UIImage *icon;
@property (nonatomic) bool isOn;

- (instancetype)initWithTitle:(NSString *)title isOn:(bool)isOn;
GEMS_ADDED_METHOD - (instancetype)initWithTitle:(NSString *)title icon:(UIImage*)icon isOn:(bool)isOn;

- (void)setIsOn:(bool)isOn animated:(bool)animated;

@end

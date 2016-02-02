//
//  SquareImageCell.h
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import <UIKit/UIKit.h>
#import "AppStoreCellBase.h"

// GemsUI
#import <GemsUI/DoneCircleView.h>

@interface SquareImageCell : AppStoreCellBase

@property (strong, nonatomic) IBOutlet UIImageView *iv;
@property (strong, nonatomic) IBOutlet UIButton *lbl;


// cell properties
@property(nonatomic, strong) UIColor *titleColor, *detailsColor;
@property (nonatomic, strong) id data;

@end

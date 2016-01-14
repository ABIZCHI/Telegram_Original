//
//  FeatureController.m
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import "FeatureController.h"
#import "TGAppDelegate.h"
#import "TGImageUtils.h"
#import "UserNotifications.h"
#import "PurchaseItemHelper.h"
#import "iToast+Gems.h"
#import <QuartzCore/QuartzCore.h>

// GemsCore
#import <GemsLocalization.h>

@interface FeatureController ()
{
    StoreItemData *_data;
}
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *txvHeightConstraint;

@end

@implementation FeatureController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _txv.textContainerInset = UIEdgeInsetsZero;
    _txv.textContainer.lineFragmentPadding = 0;

    _imgView.layer.masksToBounds = YES;
    _imgView.layer.cornerRadius = 15.0f;
    
    // shadow
    _imgBackgroundView.layer.masksToBounds = NO;
    _imgBackgroundView.layer.cornerRadius = 15.0f; // if you like rounded corners
    _imgBackgroundView.layer.shadowOffset = CGSizeMake(1, 2);
    _imgBackgroundView.layer.shadowRadius = 5;
    _imgBackgroundView.layer.shadowOpacity = 0.7f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupWithData:(StoreItemData*)data
{
    _data = data;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setTitleText:_data.title];
    
    _btnBuyView.price = _data.price;
    _btnBuyView.currency = _data.currency;
    _btnBuyView.btn.toggleAnimation = ASBConfirmButtonToggleAnimationCenter;
    _btnBuyView.btn.anchor = CGPointMake(_btnBuyView.frame.size.width/2, _btnBuyView.frame.origin.y);
    _btnBuyView.btn.height = 30.0f;
    _btnBuyView.btn.lbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
    _btnBuyView.btn.layer.cornerRadius = 15.0f;
    _btnBuyView.btn.sidePadding = 60.0f;
    _btnBuyView.buyClicked = ^{
        [self purchaseItem];
    };
    [_btnBuyView setup];
    
    [_imgView sd_setImageWithURL:[NSURL URLWithString:_data.cardURL]];
    
    _lblTitle.text = _data.title;
    
    _lblDetails.titleLabel.numberOfLines = 0;
    [_lblDetails setTitle:_data.descr forState:UIControlStateNormal];
    
    _txv.text = _data.tos;
    
    if(TGIsPad()) {
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:GemsLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(closePressed)]];
        
        // resize text view
        CGFloat lblToBottom = _outerView.frame.size.height - (_btnTermsAndConditions.frame.origin.y + _btnTermsAndConditions.frame.size.height);
        _txvHeightConstraint.constant += lblToBottom;
        [self.view layoutIfNeeded];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(IS_IPAD)
    {
        // resize text view
        CGFloat lblToBottom = _outerView.frame.size.height - (_btnTermsAndConditions.frame.origin.y + _btnTermsAndConditions.frame.size.height) - 30;
        _txvHeightConstraint.constant = lblToBottom;
        [self.view layoutIfNeeded];
    }
    
}

- (void)closePressed
{
//    TGAppDelegateInstance.tabletMainViewController.detailViewController = nil;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect frame = [_data.descr boundingRectWithSize:CGSizeMake(_lblDetails.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:_lblDetails.titleLabel.font } context:nil];
    CGSize s = frame.size;
    
    _lblDetailsHeightConstraint.constant = s.height + 20.0f;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [_btnBuyView.btn displayStateIdx:ASBPrice];
    
    UITouch *touch = [touches anyObject];
    if (![touch.view isMemberOfClass:[UITextView class]]) {
        [self hideTermsAndConditions:YES];
    }}

- (IBAction)termsAndConditionsPressed:(id)sender {
    [self hideTermsAndConditions:(_txv.alpha == 1.0f)];
}

- (void)hideTermsAndConditions:(BOOL)hidding
{
    if(hidding && _txv.alpha == 0.0f) return;
    if(!hidding && _txv.alpha == 1.0f) return;
    
    if(hidding) {
        [UIView animateWithDuration:0.3f animations:^{
            _txv.alpha = 0.0f;
            _topContainerTopConstraint.constant = 0;
            [self.view layoutIfNeeded];
        }];
    }
    else {
        CGFloat lblToBottom = _outerView.frame.size.height - (_btnTermsAndConditions.frame.origin.y + _btnTermsAndConditions.frame.size.height);
        CGFloat diff = MAX(0, _txv.frame.size.height - lblToBottom + 20);
        if(IS_IPAD)
            diff = 0;
        [UIView animateWithDuration:0.3f animations:^{
            _txv.alpha = 1.0f;
           _topContainerTopConstraint.constant = - diff;
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - UItextViewDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return NO;
}

#pragma mark - buy

- (void)purchaseItem
{
    [PurchaseItemHelper purchaseItem:_data completion:^(bool result, NSString *error) {
        if(error) {
            [UserNotifications showUserMessage:error];
            return ;
        }
        
        if(result) {
            [_btnBuyView.btn displayStateIdx:ASBBoughtDisabled];
            [iToast showInfoToastWithText:GemsLocalized(@"GemsCouponInTransactionScreen")];
        }
    }];
}

@end

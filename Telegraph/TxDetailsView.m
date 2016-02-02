//
//  TxDetailsView.m
//  GetGems
//
//  Created by alon muroch on 6/25/15.
//
//

#import "TxDetailsView.h"
#import "TGTelegraph.h"
#import "TGUserDataRequestBuilder.h"
#import "UILabel+Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>

// GemsCore
#import <GemsCore/GemsCD.h>
#import <GemsCore/GemsStringUtils.h>

// GemsUI
#import <GemsUI/UILabel+ShortenFormating.h>

@interface TxDetailsView()
{

}
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *detailsViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UIView *detailsView;
@property (strong, nonatomic) IBOutlet UILabel *lblExtendedDetails;

@end

@implementation TxDetailsView

+ (TxDetailsView*)newWithTransaction:(Transaction*)transaction
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TxDetailsView" owner:self options:nil];
    TxDetailsView *v = (TxDetailsView *)[nib objectAtIndex:0];
    v.transaction = transaction;
    return v;
}

- (void)awakeFromNib
{
    _bottomContainer.layer.cornerRadius = 10.0f;
    _bottomContainer.clipsToBounds = YES;
    
    _lblLeft.titleLabel.textColor = TGAccentColor();
    _lblLeft.titleLabel.numberOfLines = 0;
    _lblLeft.titleLabel.minimumScaleFactor = 0.5;
    _lblLeft.titleLabel.adjustsFontSizeToFitWidth = YES;
    _lblRight.titleLabel.textColor = TGAccentColor();
    _lblRight.titleLabel.numberOfLines = 0;
    _lblRight.titleLabel.minimumScaleFactor = 0.5;
    _lblRight.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [_rightIV setSingleFontSize:17.0f doubleFontSize:17.0f useBoldFont:true];
    [_leftIV setSingleFontSize:17.0f doubleFontSize:17.0f useBoldFont:true];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _leftIV.layer.cornerRadius = _leftIV.frame.size.width / 2;
    _leftIV.layer.masksToBounds = YES;
    _rightIV.layer.cornerRadius = _rightIV.frame.size.width / 2;
    _rightIV.layer.masksToBounds = YES;
}

- (IBAction)close:(id)sender {
    if(_close)
        _close();
}

- (IBAction)btnLeftPressed:(id)sender {
    [self openInfoForTxId:_transaction.source[@"address"] asset:_transaction.currency];
}

- (IBAction)btnRightPressed:(id)sender {
    [self openInfoForAddress:_transaction.destination[@"address"] asset:_transaction.currency];
}

- (void)setTransaction:(Transaction *)transaction
{
    _transaction = transaction;
    [self bindView];
}

- (void)setShowDetailsView:(BOOL)showDetailsView
{
    _showDetailsView = showDetailsView;
    
    if(_showDetailsView)
    {
        _detailsViewHeightConstraint.constant = 70.0f;
        _detailsView.hidden = NO;
    }
    else
    {
        _detailsViewHeightConstraint.constant = 0.0f;
        _detailsView.hidden = YES;
    }
}

- (void)bindView
{
    _lblRight.userInteractionEnabled = NO;
    _lblLeft.userInteractionEnabled = NO;
    
    TGUser *me = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
    if(_transaction.type == TxReceive ||
       _transaction.type == TxDeposit ||
       _transaction.type == TxInvBonus ||
       _transaction.type == TxMigrate ||
       _transaction.type == TxAirDrop ||
       _transaction.type == TxRegistrationBonus ||
       _transaction.type == TxFbLike ||
       _transaction.type == TxFbLogin ||
       _transaction.type == TxTwitterLike ||
       _transaction.type == TxFaucetBonus ||
       _transaction.type == TxAppRating) {
        [self refreshImageWithUser:me imageView:_rightIV];
        [_lblRight setTitle:@"You" forState:UIControlStateNormal];
    }
    else {
        [self refreshImageWithUser:me imageView:_leftIV];
        [_lblLeft setTitle:@"You" forState:UIControlStateNormal];
    }
    
    //  amount
    [self updateAmount];
    [self updateDate];
    
    
    switch (_transaction.type) {
        case TxReceive:
        case TxSend:
            [self bindForReceiveAndSend];
            break;
        case TxDeposit:
        {
            UIImage *img = [UIImage imageNamed:@"deposit_icon"];
            [_leftIV setImage:img];
            
            [self bindForDeposit];
        }
            break;
        case TxWithdrawl:
        {
            UIImage *img = [UIImage imageNamed:@"withdrawl_icon"];
            [_rightIV setImage:img];
            
            [self bindForWithdrawl];
        }
            break;
        case TxRegistrationBonus:
        {
            UIImage *img = [UIImage imageNamed:@"withdrawl_icon"];
            [_leftIV setImage:img];
            
            [_lblLeft setTitle:@"GetGems" forState:UIControlStateNormal];
        }
            break;
        case TxInvBonus:
        {
            UIImage *img = [UIImage imageNamed:@"invite_bonus_icon"];
            [_leftIV setImage:img];
            
            [_lblLeft setTitle:@"GetGems" forState:UIControlStateNormal];
        }
            break;
        case TxMigrate:
        {
            UIImage *img = [UIImage imageNamed:@"migrate_icon"];
            [_leftIV setImage:img];
            
            [_lblLeft setTitle:@"GetGems" forState:UIControlStateNormal];
        }
            break;
        case TxAirDrop:
        {
            UIImage *img = [UIImage imageNamed:@"airdorp_icon"];
            [_leftIV setImage:img];
            
            [_lblLeft setTitle:@"GetGems" forState:UIControlStateNormal];
        }
            break;
        case TxFbLogin:
        case TxFbLike:
        {
            UIImage *img = [UIImage imageNamed:@"fb_like_icon"];
            [_leftIV setImage:img];
            
            [_lblLeft setTitle:@"GetGems" forState:UIControlStateNormal];
        }
            break;
        case TxTwitterLike:
        {
            UIImage *img = [UIImage imageNamed:@"twitter_like_icon"];
            [_leftIV setImage:img];
            
            [_lblLeft setTitle:@"GetGems" forState:UIControlStateNormal];
        }
            break;
        case TxFaucetBonus:
        {
            UIImage *img = [UIImage imageNamed:@"faucet_bonus_icon"];
            [_leftIV setImage:img];
            
            [_lblLeft setTitle:@"GetGems" forState:UIControlStateNormal];
        }
            break;
        case TxAppRating:
        {
            UIImage *img = [UIImage imageNamed:@"app_rating"];
            [_leftIV setImage:img];
            
            [_lblLeft setTitle:@"GetGems" forState:UIControlStateNormal];
        }
            break;
        case TxPurchase:
        {
            [_lblRight setTitle:_transaction.storeItem.title forState:UIControlStateNormal];
            [_rightIV sd_setImageWithURL:[NSURL URLWithString:_transaction.storeItem.iconURL]];
            _lblExtendedDetails.text = [NSString stringWithFormat:@"Coupon Code:\n%@", _transaction.storeItem.redeemCode];
        }
            break;
        case TxTypeKnown:

            break;
        default:
            break;
    }
}

- (void)bindForWithdrawl
{
    _lblRight.userInteractionEnabled = YES;
    [_lblRight setTitle:_transaction.destination[@"address"] forState:UIControlStateNormal];
    [_lblRight.titleLabel resizeFontForLabelForSize:CGSizeApplyAffineTransform(_lblRight.frame.size, CGAffineTransformMakeScale(0.95, 0.95)) text:_transaction.destination[@"address"]];
}

- (void)bindForDeposit
{
    _lblLeft.userInteractionEnabled = YES;
    [_lblLeft setTitle:_transaction.source[@"address"] forState:UIControlStateNormal];
    [_lblLeft.titleLabel resizeFontForLabelForSize:CGSizeApplyAffineTransform(_lblLeft.frame.size, CGAffineTransformMakeScale(0.95, 0.95)) text:_transaction.source[@"address"]];
}


- (void)bindForReceiveAndSend
{
    int32_t tgId = 0;
    
    NSDictionary *data = _transaction.type == TxSend? _transaction.destination:_transaction.source;
    
    for(NSString *d in data)
    {
        if([d isEqualToString:@"telegramUserId"]) {
            NSNumber *n = (NSNumber*)[data objectForKey:@"telegramUserId"];
            tgId = [n intValue];
            break;
        }
    }

    // load user info
    TGUser *user = [TGDatabaseInstance() loadUser:tgId];
    if(!user)
    {
        user = [[TGUser alloc] init];
        user.uid = tgId;
    }
    
    // update image
    NSString *userName = [NSString stringWithFormat:@"%@%@", (user.firstName.length > 0 ? user.firstName:@""), (user.lastName.length > 0 ? [@" " stringByAppendingString:user.lastName]:@"")];
    if(_transaction.type == TxReceive) {
        [self refreshImageWithUser:user imageView:_leftIV];
        [_lblLeft setTitle:userName forState:UIControlStateNormal];
    }
    else {
        [self refreshImageWithUser:user imageView:_rightIV];
        [_lblRight setTitle:userName forState:UIControlStateNormal];
    }
}

- (void)updateDate
{
    // date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/YY"];
    _lblDate.text = [dateFormat stringFromDate:_transaction.timestamp];
}

- (void)updateAmount
{
    //  amount
    NSString *amountStr;
    if(_transaction.currency == _B) {
        NSNumber *amountInRightUnit = [@(llabs(_transaction.amount)) CD_satoshiToSysUnit];
        amountStr = formatDoubleToStringWithDecimalPrecision([amountInRightUnit doubleValue], sysDecimalPrecisionForUI(_transaction.currency));
    }
    else {
        NSNumber *amountInRightUnit = [@(llabs(_transaction.amount)) currency_gillosToGems];
        amountStr = formatDoubleToStringWithDecimalPrecision([amountInRightUnit doubleValue], 8);
    }
    
    //  unit
    NSString *assetUnit = [[_transaction.currency symbol] uppercaseString];
    if(_transaction.currency == _B)
        assetUnit = [GemsStringUtils btcSysUnitName];
    
    // amount + tx type lable
    NSString *title;
    if(_transaction.type == TxReceive)
        title = [NSString stringWithFormat:@"%@ %@ Received", amountStr, assetUnit];
    else if(_transaction.type == TxSend)
        title = [NSString stringWithFormat:@"%@ %@ Sent", amountStr, assetUnit];
    
    switch (_transaction.type) {
        case TxReceive:
            title = [NSString stringWithFormat:@"%@ %@ Received", amountStr, assetUnit];
            break;
        case TxSend:
            title = [NSString stringWithFormat:@"%@ %@ Sent", amountStr, assetUnit];
            break;
        case TxDeposit:
            title = [NSString stringWithFormat:@"%@ %@ Deposited", amountStr, assetUnit];
            break;
        case TxWithdrawl:
            title = [NSString stringWithFormat:@"%@ %@ Withdrawl", amountStr, assetUnit];
            break;
        case TxRegistrationBonus:
            title = [NSString stringWithFormat:@"%@ %@ Registration Bonus", amountStr, assetUnit];
            break;
        case TxInvBonus:
            title = [NSString stringWithFormat:@"%@ %@ Invite Bonus", amountStr, assetUnit];
            break;
        case TxMigrate:
            title = [NSString stringWithFormat:@"%@ %@ Migrated", amountStr, assetUnit];
            break;
        case TxAirDrop:
            title = [NSString stringWithFormat:@"%@ %@ Air Drop", amountStr, assetUnit];
            break;
        case TxFbLike:
        case TxTwitterLike:
        case TxFaucetBonus:
            title = [NSString stringWithFormat:@"%@ %@ Reward", amountStr, assetUnit];
            break;
        case TxPurchase:
            title = [NSString stringWithFormat:@"%@ %@ Purchase", amountStr, assetUnit];
            break;
        case TxTypeKnown:
            
            break;
        default:
            break;
    }
    _lblReceivedAmount.text = title;
}

- (void)refreshImageWithUser:(TGUser*)user imageView:(TGLetteredAvatarView*)iv
{
    static dispatch_once_t onceToken;
    static UIImage *placeholder;
    dispatch_once(&onceToken, ^
                  {
                      UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), false, 0.0f);
                      CGContextRef context = UIGraphicsGetCurrentContext();
                      
                      //!placeholder
                      CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                      CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 50, 50));
                      CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
                      CGContextSetLineWidth(context, 1.0f);
                      CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, 50 - 1.0f, 50 - 1.0f));
                      
                      placeholder = UIGraphicsGetImageFromCurrentImageContext();
                      UIGraphicsEndImageContext();
                  });
    
    [iv loadUserPlaceholderWithSize:iv.frame.size uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
    
    if(user.photoUrlSmall)
        [iv loadImage:user.photoUrlSmall filter:@"circle:40x40" placeholder:placeholder forceFade:true];
    else {
        [iv loadUserPlaceholderWithSize:iv.frame.size uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
        
//        [iv loadRandomFunkyPlaceholderWithUniqueIdentifier:[NSString stringWithFormat:@"%d", user.uid] andFilter:@"circle:40x40"];
    }
}

#pragma mark - blockchain info 

- (void)openInfoForAddress:(NSString*)address asset:(Currency*)currency
{
    if(currency == _B)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://blockchain.info/address/%@", address]]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.blockscan.com/address?q=%@", address]]];
}

- (void)openInfoForTxId:(NSString*)txid asset:(Currency*)currency
{
    if(currency == _B)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://blockchain.info/tx/%@", txid]]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.blockscan.com/tx?txhash=%@", txid]]];
}

@end

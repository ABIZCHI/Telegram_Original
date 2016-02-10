//
//  ReferralCell.m
//  GetGems
//
//  Created by alon muroch on 6/3/15.
//
//

#import "TransactionCell.h"
#import "TGTelegraph.h"
#import "TGUserDataRequestBuilder.h"
#import "TGImageUtils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>

// GemsCore
#import <GemsCore/Macros.h>
#import <GemsCore/GemsCD.h>
#import <GemsCore/GemsStringUtils.h>

// GemsUI
#import <GemsUI/GemsAppearance.h>
#import <GemsUI/UILabel+ShortenFormating.h>

static UIImage *placeholder;

@implementation TransactionCell

- (void)awakeFromNib {
    _lblitle.textColor = TGAccentColor();
    _lblAmount.textColor = TGAccentColor();
    
    [_iv setSingleFontSize:17.0f doubleFontSize:17.0f useBoldFont:true];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _iv.layer.cornerRadius = _iv.frame.size.width / 2;
    _iv.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bindCellWithTransaction:(Transaction*)tx
{
    [_iv loadImage:nil];
    
    [self commonBindingForTransaction:tx];
    
    if(tx.currency == _G)
    { 
        switch (tx.type) {
            case TxReceive:
            case TxSend:
                [self bindCellForSentOrReceivedTransaction:tx];
                break;
            case TxDeposit:
                [self bindCellForDepositTransaction:tx];
                break;
            case TxWithdrawl:
                [self bindCellForWithdrawlTransaction:tx];
                break;
            case TxRegistrationBonus:
                [self bindCellForRegistrationBonusTransaction:tx];
                break;
            case TxInvBonus:
                [self bindCellForInviteBonusTransaction:tx];
                break;
            case TxMigrate:
                [self bindCellForMigrateTransaction:tx];
                break;
            case TxAirDrop:
                [self bindCellForAirDropTransaction:tx];
                break;
            case TxAppRating:
            case TxFbLogin:
            case TxFbLike:
            case TxTwitterLike:
            case TxFaucetBonus:
                [self bindCellForBonuses:tx];
                break;
            case TxPurchase:
                [self bindCellForPurchase:tx];
                break;
            case TxTypeKnown:
                [self bindCellForUnKnownTypeTransaction:tx];
                break;
            default:
                break;
        }
    }
    else
    {
        switch (tx.type) {
            case TxDeposit:
                [self bindCellForDepositTransaction:tx];
                break;
            case TxWithdrawl:
                [self bindCellForWithdrawlTransaction:tx];
                break;
            default:
                break;
        }
    }
}

- (void)refreshCellImageWithUser:(TGUser*)user
{
    CGFloat diameter = IS_IPAD ? 45.0f : 37.0f;
    
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
                      CGContextRef context = UIGraphicsGetCurrentContext();
                      
                      //!placeholder
                      CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                      CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
                      CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
                      CGContextSetLineWidth(context, 1.0f);
                      CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, diameter - 1.0f, diameter - 1.0f));
                      
                      placeholder = UIGraphicsGetImageFromCurrentImageContext();
                      UIGraphicsEndImageContext();
                  });
    TGDispatchOnMainThread(^
       {
           if(user.photoUrlSmall)
               [_iv loadImage:user.photoUrlSmall filter:@"circle:37x37" placeholder:placeholder];
           else {
               [_iv loadUserPlaceholderWithSize:CGSizeMake(diameter, diameter) uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
           }
       });
}

#pragma mark - binding by type
- (void)commonBindingForTransaction:(Transaction*)tx
{
    // date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/YY"];
    _lblDate.text = [dateFormat stringFromDate:tx.timestamp];
    
    // amount
    NSString *baseTxt;
    NSString *sign = @"";
    if(tx.currency == _G)
    {
        if(tx.type != TxSend && tx.type != TxWithdrawl && tx.type != TxPurchase)
        {
            sign = @"+";
            _lblAmount.textColor = UIColorRGB(0x2abc4f);
        }
        else {
            _lblAmount.textColor = [UIColor darkGrayColor];
        }
        
        NSNumber *n = [@(tx.amount) currency_gillosToGems];
        _lblAmount.text = [NSString stringWithFormat:@"%@%@",sign, formatDoubleToStringWithDecimalPrecision([n doubleValue], sysDecimalPrecisionForUI(tx.currency))];
    }
    else
    {
        if((tx.type == TxSend || tx.type == TxWithdrawl)) {
            _lblAmount.textColor = [UIColor darkGrayColor];
            sign = @"-";
        }
        else {
            _lblAmount.textColor = UIColorRGB(0x2abc4f);
            sign = @"+";
        }
        
        NSNumber *n = [@(tx.amount) CD_satoshiToSysUnit];
        _lblAmount.text = [NSString stringWithFormat:@"%@%@",sign, formatDoubleToStringWithDecimalPrecision([n doubleValue], sysDecimalPrecisionForUI(tx.currency))];
    }
}

- (NSString*)assetDenominationForTransaction:(Transaction*)tx
{
    if(tx.currency == _B)
        return [GemsStringUtils btcSysUnitName];
    return [[_G symbol] uppercaseString];
}

// gems only methods
- (void)loadUserAndUpdate:(int32_t)uid tx:(Transaction*)tx
{
    TGUser *user = [TGDatabaseInstance() loadUser:uid];
    if(!user)
    {
        user = [[TGUser alloc] init];
        user.uid = uid;
    }

    [self refreshCellImageWithUser:user];
    
    // title
    NSString *title;
    if(tx.type == TxReceive)
        title = [NSString stringWithFormat:@"Received %@", [self assetDenominationForTransaction:tx]];
    else if(tx.type == TxSend)
        title = [NSString stringWithFormat:@"Sent %@", [self assetDenominationForTransaction:tx]];
    _lblitle.text = title;
    
    // change date title to include name
    // date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/YY"];
    NSString *date = [dateFormat stringFromDate:tx.timestamp];
    if(tx.type == TxReceive)
        _lblDate.text = [NSString stringWithFormat:@"%@ from %@%@", date,(user.firstName.length > 0 ? user.firstName:@""), (user.lastName.length > 0 ? [@" " stringByAppendingString:user.lastName]:@"")];
    else if(tx.type == TxSend)
        _lblDate.text = [NSString stringWithFormat:@"%@ to %@%@", date,(user.firstName.length > 0 ? user.firstName:@""), (user.lastName.length > 0 ? [@" " stringByAppendingString:user.lastName]:@"")];
}

- (void)bindCellForSentOrReceivedTransaction:(Transaction*)tx
{

    int32_t tgId = 0;
    
    NSDictionary *data = tx.type == TxSend? tx.destination:tx.source;
    
    for(NSString *d in data)
    {
        if([d isEqualToString:@"telegramUserId"]) {
            NSNumber *n = (NSNumber*)[data objectForKey:@"telegramUserId"];
            tgId = [n intValue];
        }
    }
    
    [self loadUserAndUpdate:tgId tx:tx];
}

- (void)bindCellForInviteBonusTransaction:(Transaction*)tx
{
    UIImage *img = [UIImage imageNamed:@"invite_bonus_icon"];
    [_iv setImage:img];
    
    NSString *title = @"Invite Bonus";
    _lblitle.text = title;
}

- (void)bindCellForRegistrationBonusTransaction:(Transaction*)tx
{
    UIImage *img = [UIImage imageNamed:@"singup_bonus_icon"];
    [_iv setImage:img];
    
    NSString *title = @"Registration Bonus";
    _lblitle.text = title;
}

- (void)bindCellForMigrateTransaction:(Transaction*)tx
{
    UIImage *img = [UIImage imageNamed:@"migrate_icon"];
    [_iv setImage:img];
    
    NSString *title = @"Migration";
    _lblitle.text = title;
}

- (void)bindCellForAirDropTransaction:(Transaction*)tx
{
    UIImage *img = [UIImage imageNamed:@"airdorp_icon"];
    [_iv setImage:img];
    
    NSString *title = @"Gems AirDrop";
    _lblitle.text = title;
}

- (void)bindCellForBonuses:(Transaction*)tx
{
    if(tx.type == TxFbLike) {
        UIImage *img = [UIImage imageNamed:@"fb_like_icon"];
        [_iv setImage:img];
        
        NSString *title = @"Facebook Like Bonus";
        _lblitle.text = title;
    }
    
    if(tx.type == TxFbLogin) {
        UIImage *img = [UIImage imageNamed:@"fb_like_icon"];
        [_iv setImage:img];
        
        NSString *title = @"Facebook Login Bonus";
        _lblitle.text = title;
    }
    
    if(tx.type == TxAppRating) {
        UIImage *img = [UIImage imageNamed:@"app_rating"];
        [_iv setImage:img];
        
        NSString *title = @"App Rating Bonus";
        _lblitle.text = title;
    }

    
    if(tx.type == TxTwitterLike) {
        UIImage *img = [UIImage imageNamed:@"twitter_like_icon"];
        [_iv setImage:img];
        
        NSString *title = @"Twitter Like Bonus";
        _lblitle.text = title;
    }
    
    if(tx.type == TxFaucetBonus) {
        UIImage *img = [UIImage imageNamed:@"faucet_bonus_icon"];
        [_iv setImage:img];
        
        NSString *title = @"Daily Giveaway Bonus";
        _lblitle.text = title;
    }
}

- (void)bindCellForPurchase:(Transaction*)tx
{
    _lblitle.text = tx.storeItem.title;
    [_iv sd_setImageWithURL:[NSURL URLWithString:tx.storeItem.iconURL]];
}

// methods for both bitcoin and gems

- (void)bindCellForDepositTransaction:(Transaction*)tx
{
    UIImage *img = [UIImage imageNamed:@"deposit_icon"];
    [_iv setImage:img];
    
    NSString *title = [NSString stringWithFormat:@"Deposit %@", [self assetDenominationForTransaction:tx]];
    _lblitle.text = title;
}

- (void)bindCellForWithdrawlTransaction:(Transaction*)tx
{
    UIImage *img = [UIImage imageNamed:@"withdrawl_icon"];
    [_iv setImage:img];
    
    NSString *title = [NSString stringWithFormat:@"Withdrawn %@", [self assetDenominationForTransaction:tx]];
    _lblitle.text = title;
}

- (void)bindCellForUnKnownTypeTransaction:(Transaction*)tx
{
    UIImage *img = [UIImage imageNamed:@""];
    [_iv setImage:img];
    
    NSString *title = @"Unknow";
    _lblitle.text = title;
}

@end

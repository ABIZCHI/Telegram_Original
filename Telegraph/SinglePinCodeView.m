//
//  SinglePinCodeView.m
//  GetGems
//
//  Created by alon muroch on 7/15/15.
//
//

#import "SinglePinCodeView.h"
#import "TGLetteredAvatarView.h"
#import "TGUser.h"
#import "TGDatabase.h"
#import "TGGemsWallet.h"

// GemsUI
#import <GemsUI/GemsTxConfirmationMessage.h>

// GemsCore
#import <GemsCore/GemsLocalization.h>
#import <GemsCore/Macros.h>
#import <GemsCore/GemsStringUtils.h>

@interface SinglePinCodeView()
{
    UIView *_avaterView;
    TGLetteredAvatarView *_iv;
    UILabel *_lblUsername;
}

@end

@implementation SinglePinCodeView

- (void)authenticatePinhash:(NSString*)pinhash forPaymentRequests:(PaymentRequestsContainer*)prContainer completion:(PinCodeBlock)completion
{    
    self.pinHash = pinhash;
    self.completion = completion;
    
    self.alertView = [[GemsAlertView alloc]
                      initWithTitle:@"" message:nil delegate:self
                      cancelButtonTitle:GemsLocalized(@"GemsCancel") otherButtonTitles:nil];
    [self setAlertTitleForPaymentRequests:prContainer alertView:self.alertView];
    self.alertView.showPinCodeLabel = YES;
    
    
    CGFloat h = 70;
    CGFloat w = [GemsAlertView alertWidth];
    if(IS_IPHONE_6 || IS_IPHONE_6_PLUS || IS_IPAD)  h = 100;
    CGRect r = CGRectMake(0, 1, w, h);
    
    _avaterView = [[UIView alloc] initWithFrame:r];
    
    _iv = [[TGLetteredAvatarView alloc] init];
    [_iv setSingleFontSize:17.0f doubleFontSize:17.0f useBoldFont:true];
    _iv.fadeTransition = NO;
    CGFloat avatarHeight = h - 25 - 5;
    _iv.frame = CGRectMake(_avaterView.frame.size.width/2 - avatarHeight/2, 5, avatarHeight, avatarHeight);
    [self loadUserImageInImageView:_iv paymentReq:[prContainer.paymentRequests firstObject]];
    [_avaterView addSubview:_iv];
    
    _lblUsername = [[UILabel alloc] initWithFrame:CGRectMake(0, avatarHeight + 10, _avaterView.frame.size.width, 20)];
    _lblUsername.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
    _lblUsername.adjustsFontSizeToFitWidth = YES;
    _lblUsername.minimumScaleFactor = 0.5f;
    _lblUsername.textAlignment = NSTextAlignmentCenter;
    _lblUsername.textColor = [UIColor darkGrayColor];
    [self setUsernameInLabel:_lblUsername paymentReq:[prContainer.paymentRequests firstObject]];
    [_avaterView addSubview:_lblUsername];
    
    [self.alertView addCustomView:_avaterView];
    
    [self.alertView show];
}

- (void)loadUserImageInImageView:(TGLetteredAvatarView*)iv paymentReq:(PaymentRequest*)pr
{
    TGUser *user = [TGDatabaseInstance() loadUser:pr.receiverTelegramID];
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
    
    if(user.photoUrlSmall)
        [_iv loadImage:user.photoUrlSmall filter:@"circle:40x40" placeholder:placeholder forceFade:true];
    else {
        [_iv loadUserPlaceholderWithSize:CGSizeMake(diameter, diameter) uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
    }

}

- (void)setUsernameInLabel:(UILabel *)lbl paymentReq:(PaymentRequest*)pr
{
    TGUser *user = [TGDatabaseInstance() loadUser:pr.receiverTelegramID];
    lbl.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
}

- (void)setAlertTitleForPaymentRequests:(PaymentRequestsContainer*)prContainer alertView:(GemsAlertView*)alertView
{
    GemsTxConfirmationMessage *confirmMsg = [prContainer confirmationMessageWithNameFetcher:^NSString *(PaymentRequest *pr) {
        TGUser *user = [TGDatabaseInstance() loadUser:pr.receiverTelegramID];
        return [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    }];
    NSString *calcStr, *amountStr;
    if(prContainer.currency == _G)
    {
        calcStr = @"";
    }
    else {
        calcStr = [NSString stringWithFormat:@"%@ + %@ fee = ", confirmMsg.digitalTokenAmountStr, confirmMsg.feeAmountStr];
    }
    amountStr = [NSString stringWithFormat:@"%@ %@", confirmMsg.totalAmountStr, confirmMsg.digitalAssetStr];
    alertView.title.attributedText = [self attribuitedStringWithCalculation:calcStr amountTotal:amountStr];
}

- (NSAttributedString*)attribuitedStringWithCalculation:(NSString*)calc amountTotal:(NSString*)amountTotal
{
    
    NSMutableString *cleanText = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", calc, amountTotal]];
    
    NSMutableAttributedString *attribuitedText = [[NSMutableAttributedString alloc]initWithString:cleanText];
    
    // calc
    NSDictionary *titleAtt = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIColor grayColor], NSForegroundColorAttributeName,
                              nil];
    NSRange r = [cleanText rangeOfString:calc];
    [attribuitedText addAttributes:titleAtt range:r];
    
    // amount
    NSDictionary *detailsAtt = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor darkGrayColor], NSForegroundColorAttributeName,
                                nil];
    r = [cleanText rangeOfString:amountTotal];
    [attribuitedText addAttributes:detailsAtt range:r];
    
    return attribuitedText;
}


@end

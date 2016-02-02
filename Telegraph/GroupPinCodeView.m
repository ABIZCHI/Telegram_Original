//
//  GroupPinCodeView.m
//  GetGems
//
//  Created by alon muroch on 7/14/15.
//
//

#import "GroupPinCodeView.h"
#import "GroupPayeesCollectionView.h"
#import "TGGemsWallet.h"
#import <objc/runtime.h>

// GemsCore
#import <GemsCore/GemsStringUtils.h>
#import <GemsCore/GemsCD.h>

@implementation PaymentRequestsContainer (GroupPinCodeView)

- (GroupPinCodeType)groupPinCodeType
{
    NSNumber *ret = (NSNumber*)objc_getAssociatedObject(self, @selector(groupPinCodeType));
    return [ret intValue];
}

- (void)setGroupPinCodeType:(GroupPinCodeType)groupPinCodeType
{
    objc_setAssociatedObject(self, @selector(groupPinCodeType), @(groupPinCodeType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end



@interface GroupPinCodeView()
{
    GroupPayeesCollectionView *_collection;
    BOOL _showingPincode;
}

@end

@implementation GroupPinCodeView

- (void)confirmPaymentRequests:(PaymentRequestsContainer*)prContainer
                       type:(GroupPinCodeType)type
                 completion:(PinCodeBlock)completion
{
    [self showDialogForPinhash:nil forPaymentRequests:prContainer type:type completion:completion];
}

- (void)authenticatePinhash:(NSString*)pinhash
         forPaymentRequests:(PaymentRequestsContainer*)prContainer
                       type:(GroupPinCodeType)type
                 completion:(PinCodeBlock)completion
{
    [self showDialogForPinhash:pinhash forPaymentRequests:prContainer type:type completion:completion];
}

- (void)showDialogForPinhash:(NSString*)pinhash
         forPaymentRequests:(PaymentRequestsContainer*)prContainer
                       type:(GroupPinCodeType)type
                 completion:(PinCodeBlock)completion
{
    self.pinHash = pinhash;
    self.completion = completion;
    
    if(self.pinHash) // force pincode for sending
    {
        self.alertView = [[GemsAlertView alloc]
                          initWithTitle:@"" message:nil delegate:self
                          cancelButtonTitle:GemsLocalized(@"GemsCancel") otherButtonTitles:nil];
        self.alertView.showPinCodeLabel = YES;
        _showingPincode = YES;
    }
    else { // just show the dialog with an ok button
        self.alertView = [[GemsAlertView alloc]
                          initWithTitle:@"" message:nil delegate:self
                          cancelButtonTitle:GemsLocalized(@"GemsCancel") otherButtonTitles:@[GemsLocalized(@"GemsOk")]];
        _showingPincode = NO;
    }
    
    [self setAlertTitleForPaymentRequests:prContainer alertView:self.alertView];
    
    
    
    CGFloat h = 80;
    CGFloat w = [GemsAlertView alertWidth];
    if(IS_IPHONE_5)  h = 130;
    if(IS_IPHONE_6 || IS_IPHONE_6_PLUS || IS_IPAD)  h = 200;
    CGRect r = CGRectMake(0, 1, w, h);
    _collection = [[GroupPayeesCollectionView alloc] initWithFrame:r];
    _collection.prContainer = prContainer;
    DigitalTokenAmount initialAmount = prContainer.totalOutputAmounts;
    _collection.selectionChanged = ^(NSArray *selected){
        PaymentRequestsContainer *tmpContainer = [PaymentRequestsContainer Factory_newGroupPayment];
        tmpContainer.currency = prContainer.currency;
        if(type == GroupPinCodeEach)
        {
            tmpContainer.paymentRequests = [NSMutableArray arrayWithArray:selected];
        }
        else {
            tmpContainer.paymentRequests = [[NSMutableArray alloc] init];
            DigitalTokenAmount each = (double)initialAmount / (double)selected.count;
            for(PaymentRequest *pr in selected)
            {
                pr.outputAmount = each;
                [tmpContainer.paymentRequests addObject:pr];
            }
        }
        
        [self setAlertTitleForPaymentRequests:tmpContainer alertView:self.alertView];
        return tmpContainer.paymentRequests;
    };
    [self.alertView addCustomView:_collection];
    
    // top line
    UIColor *c = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 1)];
    line.backgroundColor = c;
    [self.alertView addCustomView:line];
    
    [self.alertView show];
}

- (void)setAlertTitleForPaymentRequests:(PaymentRequestsContainer*)prContainer alertView:(GemsAlertView*)alertView
{
    NSString *amountStr;
    NSString *calcStr, *singleAmount;
    NSString *tokenName;
    PaymentRequest *pr = [prContainer.paymentRequests firstObject];
    if(prContainer.currency == _G)
    {
        tokenName = [_G symbol];
        double amount = [[@(prContainer.totalOutputAmounts) currency_gillosToGems] doubleValue];
        amountStr = [NSString stringWithFormat:@"%@ %@ total",
                     formatDoubleToStringWithDecimalPrecision(amount, sysDecimalPrecisionForUI(prContainer.currency)),
                     tokenName];
        
        amount = [[@(pr.outputAmount) currency_gillosToGems] doubleValue];
        singleAmount = formatDoubleToStringWithDecimalPrecision(amount, sysDecimalPrecisionForUI(prContainer.currency));
        
        calcStr = [NSString stringWithFormat:@"%lu Users X %@ %@ = ", (unsigned long)prContainer.paymentRequests.count, singleAmount, tokenName];
    }
    else
    {
        tokenName = [GemsStringUtils btcSysUnitName];
        double amount = [[@(prContainer.totalAmount) CD_satoshiToSysUnit] doubleValue];
        amountStr = [NSString stringWithFormat:@"%@ %@ total",
                     formatDoubleToStringWithDecimalPrecision(amount, sysDecimalPrecisionForUI(prContainer.currency)),
                     tokenName];
        
        amount = [[@(pr.outputAmount) CD_satoshiToSysUnit] doubleValue];
        singleAmount = formatDoubleToStringWithDecimalPrecision(amount, sysDecimalPrecisionForUI(prContainer.currency));
        
        NSString *fee = formatDoubleToStringWithDecimalPrecision([[@(prContainer.networkFee) CD_satoshiToSysUnit] doubleValue], sysDecimalPrecisionForUI(prContainer.currency));
        
        calcStr = [NSString stringWithFormat:@"%lu Users X %@ %@ + %@ %@ fee = ",
                   (unsigned long)prContainer.paymentRequests.count,
                   singleAmount,
                   tokenName,
                   fee,
                   tokenName];
    }
    
    alertView.title.attributedText = [self attribuitedStringWithCalculation:calcStr amountTotal:amountStr];
}

- (NSArray*)selectedPaymentRequests
{
    return _collection.selectedPaymentRequests;
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

#pragma mark -

- (void)alertView:(GemsAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    
    if(!_showingPincode && buttonIndex == 1) {
        if(self.completion)
            self.completion(AUTHENTICATED, nil, nil);
        [self.alertView close];
    }
}

- (BOOL)alertView:(GemsAlertView *)alertView pinCodeEntered:(NSString *)pincode
{
    return [super alertView:alertView pinCodeEntered:pincode];
}

@end

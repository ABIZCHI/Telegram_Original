//
//  GemsModernConversationInputTextPanel.m
//  GetGems
//
//  Created by alon muroch on 3/18/15.
//
//

#import "GemsModernConversationInputTextPanel.h"
#import "HPGrowingTextView.h"
#import "GemsMessageRegexHelper.h"
#import "CurrencyExchangeProvider.h"
#import "GemsAnalytics.h"
#import "GemsStringUtils.h"
#import "PaymentRequestsContainer+TG.h"
#import "GemsModernConversationControllerHelper.h"
#import "HPGrowingTextView.h"
#import "GroupPinCodeView.h"
#import "HPTextViewInternal.h"

#import "TGConversation.h"
#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGModernButton.h"
#import "TGImageUtils.h"

#import <UIImage+Loader.h>

//GemsCore
#import <GemsCore/GemsLocalization.h>

@interface GemsModernConversationInputTextPanel() <UITableViewDelegate>
{    
    UIImage *_imgGems;
    TGModernButton *_btnRandomGif;
}

@end

@implementation GemsModernConversationInputTextPanel

- (instancetype)initWithFrame:(CGRect)frame accessoryView:(UIView *)panelAccessoryView
{
    self = [super initWithFrame:frame accessoryView:panelAccessoryView];
    if (self)
    {
        _imgGems = [UIImage Loader_gemsImageWithName:@"dice_icon"];
        
        _btnRandomGif = [[TGModernButton alloc] initWithFrame:CGRectMake(9, 11, 40, 40)];
        _btnRandomGif.exclusiveTouch = true;
        [_btnRandomGif setImage:_imgGems forState:UIControlStateNormal];
        [_btnRandomGif addTarget:self action:@selector(randomGifPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnRandomGif];
    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    int cntLeftIcons = 2;
    CGFloat iconSize = 35;
    CGFloat originY = self.fieldBackground.frame.origin.y + self.fieldBackground.frame.size.height - iconSize + 4;
    CGFloat leftSpace = self.fieldBackground.frame.origin.x;
    CGFloat padding = (leftSpace - iconSize * cntLeftIcons)/ (cntLeftIcons + 1);
    
    self.attachButton.frame = CGRectMake(padding,
                                         originY,
                                         iconSize,
                                         iconSize);
    
    _btnRandomGif.frame = CGRectMake(self.attachButton.frame.origin.x + self.attachButton.frame.size.width + padding,
                                    originY,
                                    iconSize,
                                    iconSize);
}

- (void)randomGifPressed
{
    id<TGModernConversationInputTextPanelDelegate> delegate = (id<TGModernConversationInputTextPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(inputPanelTextRandomGifPressed:)])
        [delegate inputPanelTextRandomGifPressed:self];    
}

#pragma mark - HPGrowingTextDelegate
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView afterSetText:(bool)afterSetText afterPastingText:(bool)afterPastingText {
    [super growingTextViewDidChange:growingTextView afterSetText:afterSetText afterPastingText:afterPastingText];
    
    [self checkAndActOnSendingRequestInString:self.inputField.text];
}

- (void)checkAndActOnSendingRequestInString:(NSString*)str
{
    NSMutableString *text = [[NSMutableString alloc] initWithString:str];
    
    NSString *currencyStr;
    NSNumber *amount;
    NSMutableArray *users = [[NSMutableArray alloc] init];
    [GemsMessageRegexHelper getDataFromMsg:text currencyType:&currencyStr amount:&amount toUsers:&users];
    
    if(([[currencyStr uppercaseString] isEqualToString:@"BITS"] || [[currencyStr uppercaseString] isEqualToString:@"BTC"]) && ![_B isActive])
        currencyStr = nil;
    
    if(!currencyStr)
    {
        self.prContainer = nil;
        [self.sendButton setTitle:GemsLocalized(@"Conversation.Send") forState:UIControlStateNormal];
        [self.sendButton setImage:nil forState:UIControlStateNormal];
    }
    else
    {
        if(!GroupConversation(_conversationID) && users.count > 0) // allow users to be more than 0 only in groups
            return;
        
        if(GroupConversation(_conversationID) && users.count == 0) // if no users are specified in a group chat, assume all
        {
            TGConversation *conv = [TGDatabaseInstance() loadConversationWithId:_conversationID];
            NSMutableArray *usersMut = [[NSMutableArray alloc] init];
            for(NSNumber *uid in conv.chatParticipants.chatParticipantUids)
            {
                if([uid int64Value] == TGTelegraphInstance.clientUserId)
                    continue;
                
                TGUser *user = [TGDatabaseInstance() loadUser:[uid int64Value]];
                if(user)
                   [usersMut addObject:user.userName];
            }
            users = usersMut;
        }
        
        _prContainer = [self paymentRequestForDigitalCurrency:currencyStr amount:amount userList:users];
        [_prContainer setGroupPinCodeType:GroupPinCodeEach];
        
        if(!_prContainer) // fiat payment req
        {
            NSArray *availableCurrencies = [CurrencyExchangeProvider sharedInstance].allSupportedFiatCodes;
            if(![availableCurrencies containsObject:[currencyStr lowercaseString]])
                return;
            
            _prContainer = [PaymentRequestsContainer TG_container:_conversationID];
            _prContainer.currency = _B;
            _prContainer.includeNetworkFee = YES;
            if(users.count == 0)
                users = [NSMutableArray arrayWithArray:@[[NSNull null]]];
            
            for(NSString *user in users)
            {
                GemsAmount *ga = [[GemsAmount alloc] initWithAmount:[amount doubleValue] currency:_B fiatCode:currencyStr];
                
                PaymentRequest *pr = [PaymentRequest new];
                pr.receiverTelegramUsername = user;
                pr.outputAmount = [self convertFiatTextualAmountToBitcoin:currencyStr textualAmount:amount];
                pr.fiatCode = currencyStr;
                pr.outputAmount = [[ga fromFiat] longLongValue];
                [_prContainer.paymentRequests addObject:pr];
            }
        }
        
        // track for analytics
        [self trackSendForAnalytics:_prContainer];
        
        // animate sending button
        {
            [self.sendButton setTitle:@"" forState:UIControlStateNormal];
            [self.sendButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            
            if([[currencyStr uppercaseString] isEqualToString:@"BTC"] || [[currencyStr uppercaseString] isEqualToString:@"BITS"])
            {
                [self animateSendButtonWithTitle:nil orImage:[UIImage Loader_gemsImageWithName:@"bitcoin"]];
            }
            else if([[currencyStr uppercaseString] isEqualToString:@"GEMS"])
            {
                [self animateSendButtonWithTitle:nil orImage:[UIImage Loader_gemsImageWithName:@"gem"]];
            }
            else {
                [self animateSendButtonWithTitle:[GemsStringUtils fiatSymbolFromFiatCode:currencyStr] orImage:nil];
            }
        }
    }
}

- (Currency*)currencyFromString:(NSString*)currencyStr
{
    if([[currencyStr uppercaseString] isEqualToString:[[_G symbol] uppercaseString]])
        return _G;
    return _B;
}


-(DigitalTokenAmount)convertFiatTextualAmountToBitcoin:(NSString*)fiat textualAmount:(NSNumber*)textualAmount
{
    GemsAmount *ga = [[GemsAmount alloc] initWithAmount:[textualAmount doubleValue] currency:_B fiatCode:fiat];
    return [[ga fromFiat] longLongValue];
}

- (PaymentRequestsContainer*)paymentRequestForDigitalCurrency:(NSString*)token amount:(NSNumber*)amount userList:(NSArray*)users
{
    PaymentRequestsContainer *prContainer = [PaymentRequestsContainer TG_container:_conversationID];
    if(users.count == 0)
    {
        users = @[[NSNull null]];
    }
    
    for(NSString *user in users)
    {
        PaymentRequest *pr = [[PaymentRequest alloc] init];
        pr.receiverTelegramUsername = user;
        if([[token uppercaseString] isEqualToString:[[_G symbol] uppercaseString]])
        {
            prContainer.includeNetworkFee = NO;
            prContainer.currency = _G;
            pr.outputAmount = [[amount currency_gemsToGillos] longLongValue];
            [prContainer.paymentRequests addObject:pr];
        }
        else if([[token uppercaseString] isEqualToString:[[_B symbol] uppercaseString]])
        {
            prContainer.includeNetworkFee = YES;
            prContainer.currency = _B;
            pr.outputAmount = [[amount currency_bitcoinToSatoshies] longLongValue];
            [prContainer.paymentRequests addObject:pr];
        }
        else if([[token uppercaseString] isEqualToString:@"BITS"])
        {
            prContainer.includeNetworkFee = YES;
            prContainer.currency = _B;
            pr.outputAmount = [[amount currency_bitsToSatoshies] longLongValue];
            [prContainer.paymentRequests addObject:pr];
        }
    }
    
    return prContainer.paymentRequests.count > 0? prContainer: nil;
}

-(void)animateSendButtonWithTitle:(NSString*)__unused title orImage:(UIImage*)__unused img
{
    [UIView animateWithDuration:1.0 delay:0.0f usingSpringWithDamping:0.5 initialSpringVelocity:0
    options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.sendButton.transform = CGAffineTransformMakeScale(0.3,0.3);
        
        if(title)
            [self.sendButton setTitle:title forState:UIControlStateNormal];
        
        if(img)
            [self.sendButton setImage:img forState:UIControlStateNormal];
        
        self.sendButton.transform = CGAffineTransformIdentity;
    } completion:nil];

}

- (void)setText:(NSString*)text animated:(BOOL)animated
{
    [self.inputField setText:text animated:animated];
    self.inputField.internalTextView.enableFirstResponder = true;
}

#pragma mark - analytics
- (void)trackSendForAnalytics:(PaymentRequestsContainer *)prContainer
{
    PaymentRequest *pr = [prContainer.paymentRequests firstObject];

    [GemsAnalytics track:AnalyticsChatSendMoney args:@{
                                                       @"chat_type": @"user",
                                                       @"source": @"chat",
                                                       @"value": [[NSNumber numberWithLongLong:pr.outputAmount] stringValue],
                                                       @"currency": [prContainer.currency symbol]
                                                       }];
}

@end

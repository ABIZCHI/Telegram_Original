//
//  BalancesView.h
//  GetGems
//
//  Created by alon muroch on 5/19/15.
//
//

#import <UIKit/UIKit.h>
#import "UICountingLabel.h"

// Currencies
#import <GemsCurrencyManager.h>

@interface BalanceObject : NSObject

@property (strong, nonatomic) NSString *cryptoSuffix;
@property (strong, nonatomic) Currency *currency;
@property (strong, nonatomic) UIColor *assetColor;
@property (strong, nonatomic) NSNumber *startingValue;
@property (strong, nonatomic) UIImage *assetIcon;

@end

@interface BalanceView : UIView

+(BalanceView*)viewFromBalanceObject:(BalanceObject*)obj;

@property (strong, nonatomic) UICountingLabel *lblCrypto;
@property (strong, nonatomic) UICountingLabel *lblFiat;
@property (strong, nonatomic) BalanceObject *obj;
@property (nonatomic) int pageNumber;

- (void)refreshCryptoValueToValue:(NSNumber*)newValue;
- (Currency *)currency;

@end

@protocol BalancesViewDelegate <NSObject>

- (void)chnagedToBalanceView:(BalanceView*)view;

@end

@interface BalancesView : UIView <UIScrollViewDelegate>
{
    CGFloat _beginScrllOffset;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *arrBalances;
@property (strong, nonatomic) id<BalancesViewDelegate> delegate;

- (void)addBalances:(NSArray*)arr;
- (void)clearAll;
- (void)refreshCurrency:(Currency*)currency withNewValue:(NSNumber*)newValue;
- (void)scrollToCurrency:(Currency*)currency animated:(BOOL)animated;

@end


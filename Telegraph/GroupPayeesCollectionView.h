//
//  GroupPayeesCollectionView.h
//  GetGems
//
//  Created by alon muroch on 7/14/15.
//
//

#import <UIKit/UIKit.h>
#import "PaymentRequestsContainer.h"

typedef void (^PinCodeBlock)(BOOL result, NSDictionary *data, NSString* errorString);

@interface GroupPayeesCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) PaymentRequestsContainer *prContainer;
@property (nonatomic, strong) NSMutableArray *selectedPaymentRequests;
/**A block that can modify the amounts of the payments requests
 */
@property (nonatomic, strong) NSArray*(^selectionChanged)(NSArray* currentlySelectedPaymentRequests);

@end

//
//  TGGemsWallet.h
//  GetGems
//
//  Created by alon muroch on 7/8/15.
//
//

#import <GemsUI/GemsWallet.h>

#ifdef WALLET
#undef WALLET
#define WALLET [TGGemsWallet sharedInstance]
#endif

@interface TGGemsWallet : GemsWallet

@end

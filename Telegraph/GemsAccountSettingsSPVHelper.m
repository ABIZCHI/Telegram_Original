//
//  GemsAccountSettingsSPVHelper.m
//  GetGems
//
//  Created by alon muroch on 9/9/15.
//
//

#import "GemsAccountSettingsSPVHelper.h"

// BreadWallet
#import <BreadWalletCore/NSMutableData+Bitcoin.h>
#import <BreadWalletCore/BRBIP39Mnemonic.h>
#import <BreadWalletCore/BRBIP32Sequence.h>
#import <BreadWalletCore/BRKey.h>

@implementation GemsAccountSettingsSPVHelper

+ (NSString*)receiveAddressFromPassphrase:(NSString*)phrase
{
    BRBIP39Mnemonic *mnemonic = [BRBIP39Mnemonic new];
    NSData *seed = [mnemonic deriveKeyFromPhrase:phrase withPassphrase:nil];
    
    BRBIP32Sequence *seq = [BRBIP32Sequence new];
    NSString *priv = [seq privateKey:0 internal:NO fromSeed:seed];
    
    return [BRKey keyWithPrivateKey:priv].address;
}

@end

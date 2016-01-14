//
//  GemsAccountSettingsSPVHelper.m
//  GetGems
//
//  Created by alon muroch on 9/9/15.
//
//

#import "GemsAccountSettingsSPVHelper.h"

// BreadWallet
#import <NSMutableData+Bitcoin.h>
#import <BRBIP39Mnemonic.h>
#import <BRBIP32Sequence.h>
#import <BRKey.h>

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

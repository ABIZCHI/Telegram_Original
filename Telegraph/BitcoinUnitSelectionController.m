//
//  BitcoinUnitSelectionController.m
//  GetGems
//
//  Created by alon muroch on 6/17/15.
//
//

#import "BitcoinUnitSelectionController.h"
#import "UnitItem.h"
#import "BitcoinUnitView.h"


// GemsCore
#import <GemsCore/GemsLocalization.h>
#import <GemsCore/GemsStringUtils.h>

@interface BitcoinUnitSelectionController ()
{
    UnitItem *_currentSelectedCell;
}

@end

@implementation BitcoinUnitSelectionController

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setTitleText:GemsLocalized(@"GemsBitcoinDisplayUnit")];
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:GemsLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:GemsLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
                
        CDGemsSystem *gemsSystem = [CDGemsSystem MR_findFirst];
        
        UnitItem *bitcoin = [[UnitItem alloc] initWithUnitName:[NSString stringWithFormat:@"%@ %@", [GemsStringUtils bitcoinUnitNameFromDenomination:Btc], [GemsStringUtils bitcoinSymbolForDenomination:Btc]] action:@selector(unitSelected:)];
        bitcoin.denomination = Btc;
        
        UnitItem *bits = [[UnitItem alloc] initWithUnitName:[NSString stringWithFormat:@"%@ %@", [GemsStringUtils bitcoinUnitNameFromDenomination:Bits], [GemsStringUtils bitcoinSymbolForDenomination:Bits]] action:@selector(unitSelected:)];
        bits.denomination = Bits;
        
        BitcoinUnit d = [gemsSystem.bitcoinDenomination integerValue];
        if(d == Bits) {
           [bits setIsChecked:YES];
            _currentSelectedCell = bits;
        }
        else {
            [bitcoin setIsChecked:YES];
            _currentSelectedCell = bitcoin;
        }
        
        TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:@[bitcoin, bits]];
        [self.menuSections addSection:section];
    }
    
    return self;
}

- (void)unitSelected:(UnitItem*)cell
{
    if(_currentSelectedCell)
        [_currentSelectedCell setIsChecked:NO];
    
    _currentSelectedCell = cell;
    [_currentSelectedCell setIsChecked:YES];
}

- (void)cancelPressed
{
    [self close];
}

- (void)donePressed
{
    if(_currentSelectedCell) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            CDGemsSystem *gemsSystem = [CDGemsSystem MR_findFirstInContext:localContext];
            gemsSystem.bitcoinDenomination = @(_currentSelectedCell.denomination);
        } completion:^(BOOL success, NSError *error) {
            [self close];
        }];
    }
}

- (void)close {
    if(self.completionBlock)
        self.completionBlock();
}

@end

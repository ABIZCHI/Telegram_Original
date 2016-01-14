//
//  GemsCurrencySelectionController.m
//  GetGems
//
//  Created by alon muroch on 5/12/15.
//
//

#import "GemsCurrencySelectionController.h"
#import "CurrencyExchangeProvider.h"
#import "CurrencyItem.h"
#import "TGCollectionMenuSection.h"

// GemsCore
#import <UIImage+Loader.h>
#import <GemsCD.h>
#import <GemsLocalization.h>

@interface GemsCurrencySelectionController ()
{
    CurrencyItem *_currentSelectedCell;
    
}

@end

@implementation GemsCurrencySelectionController

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setTitleText:GemsLocalized(@"GemsNativeCurrency")];
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:GemsLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)]];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:GemsLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        
        NSMutableArray *currenciesCells = [[NSMutableArray alloc] init];
        
        CDGemsSystem *gemsSystem = [CDGemsSystem MR_findFirst];
        
        for(NSDictionary *dic in [CurrencyExchangeProvider sharedInstance].allSupportedCurrencies) {
            NSString *code = [[dic objectForKey:@"code"] uppercaseString];
            NSString *desc = [dic objectForKey:@"desc"];
            NSString *icon = [dic objectForKey:@"iconName"];
            
            NSString *imagePath = [NSString stringWithFormat:@"Countries.bundle/%@", icon];
            CurrencyItem *i = [[CurrencyItem alloc] initWithCurrencyName:code desciption:desc icon:[UIImage Loader_gemsImageWithName:imagePath] action:@selector(currencySelected:)];
            [currenciesCells addObject:i];
            
            if([gemsSystem.currencySymbol isEqualToString:[code lowercaseString]]) {
                _currentSelectedCell = i;
                [_currentSelectedCell setIsChecked:YES];
            }
        }
        
        [currenciesCells sortUsingComparator:^NSComparisonResult(CurrencyItem *obj1, CurrencyItem *obj2) {
            return [[obj1 getCurrencyCode] compare:[obj2 getCurrencyCode]];
        }];
        
        TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:currenciesCells];
        [self.menuSections addSection:section];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)currencySelected:(CurrencyItem*)cell
{
    NSIndexPath *indexPath = [self indexPathForItem:cell];
    
    if(_currentSelectedCell)
        [_currentSelectedCell setIsChecked:NO];
    
    _currentSelectedCell = cell;
    [_currentSelectedCell setIsChecked:YES];
}

#pragma mark - done and cancel
- (void)cancelPressed
{
    [self close];
}

- (void)donePressed
{
    if(_currentSelectedCell) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            CDGemsSystem *gemsSystem = [CDGemsSystem MR_findFirstInContext:localContext];
            gemsSystem.currencySymbol = [_currentSelectedCell getCurrencyCode];
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

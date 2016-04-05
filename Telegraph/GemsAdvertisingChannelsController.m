//
//  GemsAdvertisingChannelsController.m
//  GetGems
//
//  Created by Onizhuk Anton on 3/9/16.
//
//

#import "GemsAdvertisingChannelsController.h"

#import "TGSwitchCollectionItem.h"
#import "TGHeaderCollectionItem.h"

#import "LDAdvertisingChannel.h"
#import "LDAdvertisingManager.h"

#import <GemsCore/GemsAnalytics.h>

#import <GemsUI/DiamondActivityIndicator.h>




@implementation GemsAdvertisingChannelsController {
    NSArray <LDAdvertisingChannel *> * channels;
    
}

- (instancetype)init {
    if (self = [super init]) {
        
        [self setTitleText:GemsLocalized(@"Advertising")];
        
        channels = [[LDAdvertisingManager sharedManager] advertisingChannels];

        if (channels) {
        
            NSMutableArray * channelCells = [[NSMutableArray alloc] init];
        
            
            
            for (LDAdvertisingChannel * channel in channels) {
                TGSwitchCollectionItem * item = [[TGSwitchCollectionItem alloc] initWithTitle:channel.channelName isOn:channel.status];
                
                __weak GemsAdvertisingChannelsController * weakSelf = self;
                __weak TGSwitchCollectionItem * weakItem = item;
                item.toggled = ^(bool isOn) {
                    __strong GemsAdvertisingChannelsController * strongSelf = weakSelf;
                    if (!strongSelf) {
                        return;
                    }
                    
                    [strongSelf setState:isOn forChannel:channel sender:weakItem];
                
                };
                
        
                
                [channelCells addObject:item];
                
                
            }
            
            TGHeaderCollectionItem *header = [[TGHeaderCollectionItem alloc] initWithTitle:GemsLocalized(@"Channels")];
            
            TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:[@[header] arrayByAddingObjectsFromArray:channelCells]];
            [self.menuSections addSection:section];
            
        } else {
            TGHeaderCollectionItem *header = [[TGHeaderCollectionItem alloc] initWithTitle:GemsLocalized(@"No channels available")];
            
            TGCollectionMenuSection *section = [[TGCollectionMenuSection alloc] initWithItems:@[header]];
            [self.menuSections addSection:section];
        }
        
        
    } return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [GemsAnalytics track:AdChannelListViewed args:nil];
}


- (void)setState:(BOOL)state forChannel:(LDAdvertisingChannel *)channel sender:(TGSwitchCollectionItem *)sender {
    if (channel.status == state) {
        return;
    }
    
    
    [self showIndicator];
    
    [[LDAdvertisingManager sharedManager] setState:state forChannel:channel completion:^(LDAdvertisingChannel * updatedChannel, __unused NSError * err) {
        if (updatedChannel) {
            if (sender) {
                [sender setIsOn:channel.status animated:NO];
            } else {
                [sender setIsOn:!sender.isOn animated:NO];
            }
            
            [self hideIndicator];
            
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    

    
}

- (void)showIndicator {
    [DiamondActivityIndicator showDiamondIndicatorInView:self.view];
}
- (void)hideIndicator {
    [DiamondActivityIndicator hideDiamondIndicatorFromView:self.view];
}


@end

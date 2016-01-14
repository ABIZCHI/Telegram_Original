//
//  GemsAttachmentSheetHorizontalImageButtonsView.h
//  GetGems
//
//  Created by alon muroch on 5/4/15.
//
//

#import "TGAttachmentSheetItemView.h"

@interface GemsAttachmentSheetHorizontalImageButtonsView : TGAttachmentSheetItemView <UIScrollViewDelegate>
{
    NSMutableArray *_items;
    UIScrollView *_scrlView;
}

- (void)addItem:(TGAttachmentSheetItemView*)item;

@end

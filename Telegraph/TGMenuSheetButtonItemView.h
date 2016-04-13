#import "TGMenuSheetItemView.h"

@class TGModernButton;

typedef enum
{
    TGMenuSheetButtonTypeDefault,
    TGMenuSheetButtonTypeCancel,
    TGMenuSheetButtonTypeDestructive,
    TGMenuSheetButtonTypeSend
} TGMenuSheetButtonType;

@interface TGMenuSheetButtonItemView : TGMenuSheetItemView

@property (nonatomic, strong) NSString *title;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGModernButton *button;

- (instancetype)initWithTitle:(NSString *)title type:(TGMenuSheetButtonType)type action:(void (^)(void))action;

@end

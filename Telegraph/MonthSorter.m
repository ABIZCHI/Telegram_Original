//
//  MonthSorter.m
//  GetGems
//
//  Created by alon muroch on 6/10/15.
//
//

#import "MonthSorter.h"
#import "Transaction.h"

@implementation MonthSorter 

- (NSArray *)sort:(NSArray*)transactions
{
    NSArray *arr = [transactions sortedArrayUsingComparator:^NSComparisonResult(Transaction *obj1, Transaction *obj2) {
        return [obj2.timestamp compare:obj1.timestamp];
    }];
    
    return arr;
}

- (NSDictionary*)group:(NSArray*)transactions
{
    if(transactions.count == 0) {
        return @{};
    }
    
    NSDate *first = ((Transaction*)[transactions firstObject]).timestamp;
    NSDate *last = ((Transaction*)[transactions lastObject]).timestamp;
    
    NSArray *months = [self generateListOfMonthsFrom:last to:first];
    
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    for(NSDateComponents *c in months)
    {
        [ret setObject:@[] forKey:c];
    }
    
    for(Transaction *tx in transactions)
    {
        NSDateComponents *componentsTx = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:tx.timestamp];
        NSDateComponents *c = [[NSDateComponents alloc] init];
        c.year = componentsTx.year;
        c.month = componentsTx.month;
        
        NSArray *arr = [ret objectForKey:c];
        if(!arr)
            continue;
        arr = [arr arrayByAddingObject:tx];
        [ret setObject:arr forKey:c];
    }
    
    NSMutableDictionary *cleaned = [[NSMutableDictionary alloc] init];
    NSArray *keys = [ret allKeys];
    for(NSDateComponents *c in keys) {
        NSArray *arr = [ret objectForKey:c];
        if(arr.count > 0)
            [cleaned setObject:arr forKey:c];
    }
    
    return cleaned;
}


- (NSArray*)generateListOfMonthsFrom:(NSDate*)from to:(NSDate*)to
{
    if(!from || !to)
    {
        NSLog(@"");
    }
    
    NSDateComponents *componentsFrom = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:from];
    NSDateComponents *componentsTo = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:to];
    
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    
    for(NSInteger year = componentsFrom.year; year <= componentsTo.year; year ++ )
    {
        for(NSInteger month = 1; month <= 12; month ++)
        {
            NSDateComponents *c = [[NSDateComponents alloc] init];
            c.year = year;
            c.month = month;
            [ret addObject:c];
        }
    }
    
    return ret;
}

@end

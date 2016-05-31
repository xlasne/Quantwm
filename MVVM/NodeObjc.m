//
//  NodeObjc.m
//  QUANTWM
//
//  Created by Xavier on 16/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

#import <QuantwmOSX/QuantwmOSX.h>
#import "NodeObjc.h"
#import "MVVM-Swift.h"

@implementation NodeObjc

@synthesize intValue = _intValue;

-(id) initWithVal: (NSInteger) val
{
    _changeCounter = [[ChangeCounter alloc] init];
    _intValue = val;
    return self;
}


+(PropertyDescription*) intValueK {

    return [[PropertyDescription alloc] initWithObjc_propKey:@"_intValue"
                                               sourceTypeStr:NSStringFromClass ([NodeObjc class])
                                                 destTypeStr:nil
                                                      option:PropertyDescriptionOptionNone
                                       dependFromPropertySet:[NSSet<PropertyDescription*> set]];
}

-(NSInteger) intValue
{
    [self.changeCounter performedReadOnMainThread:NodeObjc.intValueK];
    return _intValue;
}

-(void) setIntValue:(NSInteger)intValue
{
    [self.changeCounter performedWriteOnMainThread:NodeObjc.intValueK];
    _intValue = intValue;
}


@end

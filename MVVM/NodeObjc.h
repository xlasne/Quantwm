//
//  NodeObjc.h
//  QUANTWM
//
//  Created by Xavier Lasne on 16/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertyDescriptionOption.h"

@class ChangeCounter;
@class PropertyDescription;

@interface NodeObjc : NSObject

@property (strong, readonly) ChangeCounter* changeCounter;
@property NSInteger intValue;

-(id) initWithVal: (NSInteger) val;
+(PropertyDescription*) intValueK;

@end



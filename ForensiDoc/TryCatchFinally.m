//
//  TryCatchFinally.m
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 19/05/2016.
//  Copyright © 2016 Bitmelter Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TryCatchFinally.h"

void tryCatchFinally(void(^tryBlock)(), void(^catchBlock)(NSException *e), void(^finallyBlock)()) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        catchBlock(exception);
    }
    @finally {
        finallyBlock();
    }
}
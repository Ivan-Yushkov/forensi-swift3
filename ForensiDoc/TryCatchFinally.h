//
//  TryCatchFinally.h
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 19/05/2016.
//  Copyright © 2016 Bitmelter Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

void tryCatchFinally(void(^tryBlock)(void), void(^catchBlock)(NSException *e), void(^finallyBlock)(void));

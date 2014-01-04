//
//  YYWebDelegate.h
//  Appsence
//
//  Created by Yoppy Yunhasnawa on 8/12/13.
//  Copyright (c) 2013 Yunhasnawa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    YYWebAsynchronousRequestResultOK = 0,
    YYWebAsynchronousRequestResultTimedOut,
    YYWebAsynchronousRequestResultEmpty,
    YYWebAsynchronousRequestResultError
} YYWebAsynchronousRequestResult;

@class YYWebWorker;

@protocol YYWebWorkerDelegate <NSObject>

@required
- (void) webWorker:(YYWebWorker*) web didFinishReceivingAsynchronousResponseWithResult:(YYWebAsynchronousRequestResult) result error:(NSError*) error;

@end

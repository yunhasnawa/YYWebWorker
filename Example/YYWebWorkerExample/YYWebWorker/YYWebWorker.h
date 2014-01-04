//
//  YYWeb.h
//  Appsence
//
//  Created by Yoppy Yunhasnawa on 7/23/13.
//  Copyright (c) 2013 Yunhasnawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYWebWorkerDelegate.h"

typedef enum
{
    YYWebRequestTypeSynchronous = 0,
    YYWebRequestTypeAsynchronous
} YYWebRequestType;

typedef enum
{
    YYWebRequestMethodGET = 0,
    YYWebRequestMethodPOST
} YYWebRequestMethod;

@interface YYWebWorker : NSObject

@property (assign, nonatomic) YYWebRequestMethod requestMethod;
@property (assign, nonatomic) YYWebRequestType requestType;
@property (strong, nonatomic) NSObject<YYWebWorkerDelegate>* delegate;
@property (strong, nonatomic, readonly) NSString* lastURLString;

- (id) init;
- (void) sendRequestToURLString:(NSString*) urlString withData:(NSDictionary*) data;
- (NSString*) responseString;
- (NSDictionary*) responseDictionaryFromJSON;
- (BOOL) responseIsArray;

+ (BOOL) networkIsAvailable;
+ (void) sendPOSTAsynchronousToURLString:(NSString*) url data:(NSDictionary*) data delegateOrNil:(NSObject<YYWebWorkerDelegate>*) delegateOrNil;
+ (void) sendGETAsynchronousToURLString:(NSString *)url data:(NSDictionary *)data delegateOrNil:(NSObject<YYWebWorkerDelegate> *)delegateOrNil;
+ (NSDictionary*) sendPOSTSynchronousToURLString:(NSString *)url data:(NSDictionary *)data;
+ (NSDictionary*) sendGETSynchronousToURLString:(NSString *)url data:(NSDictionary *)data;

@end
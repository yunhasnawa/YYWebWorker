//
//  YYWeb.m
//  Appsence
//
//  Created by Yoppy Yunhasnawa on 7/23/13.
//  Copyright (c) 2013 Yunhasnawa. All rights reserved.
//

#import "YYWebWorker.h"
#import "Reachability.h"

@interface YYWebWorker ()

@property (strong, nonatomic) NSString* lastURLString;
@property (strong, nonatomic) NSData* responseData;

- (void) sendSynchronousRequest:(NSURLRequest*) request;
- (void) sendAsynchronousRequest:(NSURLRequest*) request;
- (NSData*) responseDataForJSONArray;

+ (NSString*) requestDataStringFromDictionary:(NSDictionary*) dictionary;
+ (NSURLRequest*) GETRequestFromRequestDataString:(NSString*) requestDataString URLString:(NSString*) urlString;
+ (NSURLRequest*) POSTRequestFromRequestDataString:(NSString*) requestDataString URLString:(NSString*) urlString;

+ (NSString*) string:(NSString*) string fromIndex:(NSUInteger)start toIndex:(NSUInteger)end;

@end

@implementation YYWebWorker

@synthesize requestMethod;
@synthesize requestType;
@synthesize responseData;
@synthesize delegate;
@synthesize lastURLString;

- (id) init
{
    self = [super init];
    
    if(self)
    {
        [self setRequestMethod:YYWebRequestMethodGET];
        [self setRequestType:YYWebRequestTypeSynchronous];
    }
    
    return self;
}

- (void) sendRequestToURLString:(NSString *)urlString withData:(NSDictionary *)data
{
    [self setLastURLString:urlString];
    
    NSString* requestDataString = [YYWebWorker requestDataStringFromDictionary:data];
    
    NSLog(@"Sending request to URL: %@\nData: %@", urlString, requestDataString);
    
    NSURLRequest* request;
    
    if([self requestMethod] == YYWebRequestMethodGET)
    {
        request = [YYWebWorker GETRequestFromRequestDataString:requestDataString URLString:urlString];
    }
    else
    {
        request = [YYWebWorker POSTRequestFromRequestDataString:requestDataString URLString:urlString];
    }
    
    if([self requestType] == YYWebRequestTypeSynchronous)
    {
        [self sendSynchronousRequest:request];
    }
    else
    {
        [self sendAsynchronousRequest:request];
    }
}

- (NSString*) responseString
{
    NSString* responseString = [[NSString alloc] initWithData:[self responseData] encoding:NSUTF8StringEncoding];
    
    return responseString;
}

- (NSDictionary*) responseDictionaryFromJSON
{
    NSError* error;
    
    BOOL isArray = [self responseIsArray];
    
    NSData* data = isArray ? [self responseDataForJSONArray] : [self responseData];
    
    if(data == nil)
    {
        return nil;
    }
    else
    {
        NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if(error)
        {
            NSLog(@"YYWeb::responseDictionaryFromJSON - Error on parsing response data. Error description: \n%@\nResponse string:\n%@", [error description], [self responseString]);
        }
        
        return dictionary;
    }
}

#pragma mark - Tools

+ (NSString*) string:(NSString*) string fromIndex:(NSUInteger)start toIndex:(NSUInteger)end
{
    NSString* copy = @"";
    
    NSUInteger count = [string length];
    
    for(NSUInteger i = start; i <= end; i++)
    {
        if(i < count)
        {
            if((NSInteger)i < 0)
            {
                continue;
            }
            
            unichar c = [string characterAtIndex:i];
            
            copy = [copy stringByAppendingFormat:@"%c", c];
        }
        else
        {
            break;
        }
    }
    
    return copy;
}

- (BOOL) responseIsArray
{
    NSString* responseString = [self responseString];
    
    NSString* firstString = [YYWebWorker string:responseString fromIndex:0 toIndex:0];
    
    if([firstString isEqualToString:@"["])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSData*) responseDataForJSONArray
{
    NSString* responseString = [self responseString];
    
    NSString* refinedString = [NSString stringWithFormat:@"{\"array\":%@}", responseString];
    
    NSData* data = [refinedString dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}

+ (NSString*) requestDataStringFromDictionary:(NSDictionary *)dictionary
{
    NSString* requestDataString = @"";
    
    for(id key in dictionary)
    {
        id value = [dictionary objectForKey:key];
        
        NSString* pair = [NSString stringWithFormat:@"%@=%@&", key, value];
        
        requestDataString = [requestDataString stringByAppendingString:pair];
    }
    
    // Check if last char is '&'
    NSInteger lastIndex = ([requestDataString length] - 1);
    char lastChar = [requestDataString characterAtIndex:lastIndex];
    
    if(lastChar == '&')
    {
        requestDataString = [YYWebWorker string:requestDataString fromIndex:0 toIndex:(lastIndex - 1)];
    }
    
    return requestDataString;
}

+ (NSURLRequest*) GETRequestFromRequestDataString:(NSString *)requestDataString URLString:(NSString *)urlString
{
    NSString* getUri = [NSString stringWithFormat:@"?%@", requestDataString];
    
    urlString = [urlString stringByAppendingString:getUri];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"URL String -> %@", urlString);
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    
    return request;
}

+ (NSURLRequest*) POSTRequestFromRequestDataString:(NSString *)requestDataString URLString:(NSString *)urlString
{
    NSData* dataBody = [requestDataString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString* dataBodyLength = [NSString stringWithFormat:@"%lu", (unsigned long)[dataBody length], nil];
 
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:dataBodyLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:dataBody];
    
    return request;
}

- (void) sendSynchronousRequest:(NSURLRequest*) request
{
    NSError* error;
    
    NSHTTPURLResponse* urlResponse;
    
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    if(error)
    {
        NSLog(@"YYWeb::sendSynchronousRequest - Error on send synchronous request. Detail: %@\nStatus code: %ld", error, (long)[urlResponse statusCode]);
    }
    
    [self setResponseData:response];
}

- (void) sendAsynchronousRequest:(NSURLRequest*) request
{
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* error)
    {
        YYWebAsynchronousRequestResult result = YYWebAsynchronousRequestResultError;
        
        if([data length] > 0 && error == nil)
        {
            result = YYWebAsynchronousRequestResultOK;
        }
        else if([data length] == 0 && error == nil)
        {
            result = YYWebAsynchronousRequestResultEmpty;
        }
        else if(error != nil && [error code] == NSURLErrorTimedOut)
        {
            result = YYWebAsynchronousRequestResultTimedOut;
        }
        
        [self setResponseData:data];
        
        if([self delegate] != nil)
        {
            [[self delegate] webWorker:self didFinishReceivingAsynchronousResponseWithResult:result error:error];
        }
    }];
}

#pragma mark Public tools

+ (BOOL) networkIsAvailable
{
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

+ (void) sendPOSTAsynchronousToURLString:(NSString *)url data:(NSDictionary *)data delegateOrNil:(NSObject<YYWebWorkerDelegate> *)delegateOrNil
{
    YYWebWorker* web = [[YYWebWorker alloc] init];
    
    if(delegateOrNil != nil)
    {
        [web setDelegate:delegateOrNil];
    }
    
    [web setRequestType:YYWebRequestTypeAsynchronous];
    [web setRequestMethod:YYWebRequestMethodPOST];
    
    [web sendRequestToURLString:url withData:data];
}

+ (NSDictionary*) sendPOSTSynchronousToURLString:(NSString *)url data:(NSDictionary *)data
{
    YYWebWorker* web = [[YYWebWorker alloc] init];
    
    [web setRequestMethod:YYWebRequestMethodPOST];
    
    [web sendRequestToURLString:url withData:data];
    
    return [web responseDictionaryFromJSON];
}

+ (void) sendGETAsynchronousToURLString:(NSString *)url data:(NSDictionary *)data delegateOrNil:(NSObject<YYWebWorkerDelegate> *)delegateOrNil
{
    YYWebWorker* web = [[YYWebWorker alloc] init];
    
    if(delegateOrNil != nil)
    {
        [web setDelegate:delegateOrNil];
    }
    
    [web setRequestType:YYWebRequestTypeAsynchronous];
    [web setRequestMethod:YYWebRequestMethodGET];
    
    [web sendRequestToURLString:url withData:data];
}

+ (NSDictionary*) sendGETSynchronousToURLString:(NSString *)url data:(NSDictionary *)data
{
    YYWebWorker* web = [[YYWebWorker alloc] init];
    
    [web setRequestMethod:YYWebRequestMethodGET];
    
    [web sendRequestToURLString:url withData:data];
    
    return [web responseDictionaryFromJSON];
}

@end

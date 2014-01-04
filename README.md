YYWebWorker
===========

Simple POST/GET ASYNC/SYNC web API retrieval helper for iOS

Simply use like this to send synchronous request:

    YYWebRequestMethod method = [self isPOST] ? YYWebRequestMethodPOST : YYWebRequestMethodGET;
    
    NSDictionary* data = @{@"username":[self username], @"password":[self password]};
    
    NSDictionary* response;
    
    if(method == YYWebRequestMethodPOST)
    {
        response = [YYWebWorker sendPOSTSynchronousToURLString:kURL data:data];
    }
    else
    {
        response = [YYWebWorker sendGETSynchronousToURLString:kURL data:data];
    }
	

Or do like below if you want to do asynchronous:

    YYWebRequestMethod method = [self isPOST] ? YYWebRequestMethodPOST : YYWebRequestMethodGET;
    
    NSDictionary* data = @{@"username":[self username], @"password":[self password]};
    
    if(method == YYWebRequestMethodPOST)
    {
        [YYWebWorker sendPOSTAsynchronousToURLString:kURL data:data delegateOrNil:self];
    }
    else
    {
        [YYWebWorker sendGETAsynchronousToURLString:kURL data:data delegateOrNil:self];
    }
	
But in this case, dont forget to set your class as delegate of YYWebWorker. First, import and add the delegate protocol in your header file:

    #import "YYWebWorkerDelegate.h"

    @interface YWEViewController : UIViewController<YYWebWorkerDelegate>
	
And then implement the delegate method in your definition file:

    - (void) webWorker:(YYWebWorker *)web didFinishReceivingAsynchronousResponseWithResult:(YYWebAsynchronousRequestResult)result error:(NSError *)error
    {
        if(result == YYWebAsynchronousRequestResultOK)
        {
            // Get the response
            NSDictionary* response = [web responseDictionaryFromJSON];
        
            // Then do smething with that response
        }
    }

That's it! Hope it help you in your project.. :)

p.s. Sorry at this time, it only for JSON.
//
//  OKAchievementScore.m
//  OpenKit
//
//  Created by Suneet Shah on 12/10/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import "OKAchievementScore.h"
#import "OKUser.h"
#import "OKError.h"
#import "OKNetworker.h"
#import "OKMacros.h"
#import "OKUserUtilities.h"

@implementation OKAchievementScore

@synthesize progress, GKAchievementID, OKAchievementID;

-(NSDictionary*)getAchievementScoreAsJSON
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:[NSNumber numberWithInt:progress] forKey:@"progress"];
    [jsonDict setObject:[NSNumber numberWithInt:OKAchievementID] forKey:@"achievement_id"];
    
    if([OKUser currentUser]) {
        [jsonDict setObject:[[OKUser currentUser] OKUserID] forKey:@"user_id"];
    }
    return jsonDict;
}

-(void)submitAchievementScoreWithCompletionHandler:(void (^)(NSError *error))completionHandler
{
    if(![OKUser currentUser]) {
        //TODO cache local achievement scores
        completionHandler([OKError noOKUserError]);
        return;
    }
    
    NSDictionary *requestParams = [NSDictionary dictionaryWithObject:[self getAchievementScoreAsJSON] forKey:@"achievement_score"];
    
    [OKNetworker postToPath:@"/achievement_scores" parameters:requestParams handler:^(id responseObject, NSError *error) {
        
        if(!error) {
            completionHandler(nil);
        } else {
            [OKUserUtilities checkIfErrorIsUnsubscribedUserError:error];
            completionHandler(error);
            OKLog(@"Error submitting achievement score: %@",error);
        }
    }];
}

@end
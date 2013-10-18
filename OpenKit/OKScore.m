//
//  OKScore.m
//  OKClient
//
//  Created by Suneet Shah on 1/3/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import "OKScore.h"
#import "OKUser.h"
#import "OKManager.h"
#import "OKNetworker.h"
#import "OKDefines.h"
#import "OKMacros.h"
#import "OKError.h"
#import "OKDBScore.h"
#import "OKHelper.h"
#import "OKUtils.h"
#import "OKLeaderboard.h"
#import "OKFacebookUtilities.h"
#import "OKChallenge.h"
#import "OKPrivate.h"


@implementation OKScore

- (id)init
{
    self = [super init];
    if (self) {
        _scoreID = -1;
        _leaderboardID = -1;
    }
    return self;
}


- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        [self configWithDictionary:dict];
    }
    return self;
}


- (id)initWithLeaderboardID:(int)index
{
    self = [super init];
    if (self) {
        self.leaderboardID = index;
    }
    return self;
}


- (void)configWithDictionary:(NSDictionary*)dict
{
    self.rowIndex       = [OKHelper getIntFrom:dict key:@"row_id"];
    self.modifyDate     = [OKHelper getNSDateFrom:dict key:@"modify_date"];
    
    self.scoreID        = [OKHelper getIntFrom:dict key:@"id"];
    self.scoreValue     = [OKHelper getInt64From:dict key:@"value"];
    self.scoreRank      = [OKHelper getIntFrom:dict key:@"rank"];
    self.leaderboardID  = [OKHelper getIntFrom:dict key:@"leaderboard_id"];
    self.user           = [OKUser createUserWithDictionary:[dict objectForKey:@"user"]];
    self.displayString  = [OKHelper getNSStringFrom:dict key:@"display_string"];
    self.metadata       = [OKHelper getIntFrom:dict key:@"metadata"];
}


- (NSDictionary*)JSONDictionary
{
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [paramDict setValue:[NSNumber numberWithInt:_leaderboardID] forKey:@"leaderboard_id"];
    [paramDict setValue:[NSNumber numberWithLongLong:_scoreValue] forKey:@"value"];
    [paramDict setValue:[_user userID] forKey:@"user_id"];
    [paramDict setValue:[NSNumber numberWithInt:_metadata] forKey:@"metadata"];
    [paramDict setValue:[self scoreDisplayString] forKey:@"display_string"];
    
    return paramDict;
}


- (void)submitWithCompletion:(void (^)(NSError *error))completion
{
    [OKScore submitScore:self withCompletion:completion];
}


- (BOOL)isSubmissible
{
    return
        self.leaderboardID != -1 &&
        self.scoreValue != 0;
}


- (BOOL)isScoreBetter:(OKScore*)score
{
    return YES;
}


-(NSString*)scoreDisplayString
{
    if([self displayString])
        return _displayString;
    
    return [NSString stringWithFormat:@"%lld", [self scoreValue]];
}


-(NSString*)userDisplayString
{
    return [[self user] userNick];
}


-(NSString*)rankDisplayString
{
    return [NSString stringWithFormat:@"%d", [self scoreRank]];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"OKScore id: %d, submitted: %d, value: %lld, leaderboard id: %d, display string: %@, metadata: %d", [self scoreID], [self submitState], [self scoreValue], [self leaderboardID], [self displayString], [self metadata]];
}


#pragma mark - Class methods

+ (BOOL)shouldSubmit:(OKScore*)score
{
    return YES;
}


+ (void)submitScore:(OKScore*)score withCompletion:(void (^)(NSError *error))handler
{
    [score setDbConnection:[OKDBScore sharedConnection]];
    
    if([score isSubmissible] && [OKScore shouldSubmit:score]) {
        [score syncWithDB];
        [OKScore resolveScore:score withCompletion:handler];
    }else if(handler)
        handler([OKError OKScoreNotSubmittedError]);
}


+ (void)resolveScore:(OKScore*)score withCompletion:(void (^)(NSError *error))handler
{
    [score setUser:[OKLocalUser currentUser]];
    if([score user] == nil) {
        if(handler)
            handler([OKError noOKUserErrorScoreCached]); // ERROR
        
        return;
    }
    
    [OKLeaderboard getLeaderboardWithID:[score leaderboardID]
                         withCompletion:^(OKLeaderboard *leaderboard, NSError *error)
    {
        // private method, never call it manually
        [leaderboard submitScore:score withCompletion:handler];
    }];
}


+ (void)resolveUnsubmittedScores
{
    // Removing
    NSArray *scores = [[OKDBScore sharedConnection] getUnsubmittedScores];
    
    for(OKScore *score in scores)
        [OKScore resolveScore:score withCompletion:nil];
}


+ (void)clearSubmittedScore
{
    [[OKDBScore sharedConnection] clearSubmittedScores];
}

@end

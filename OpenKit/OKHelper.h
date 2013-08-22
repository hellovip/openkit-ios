//
//  OKHelper.h
//  OKClient
//
//  Created by Suneet Shah on 1/7/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OKHelper : NSObject

+ (NSDate *)dateNDaysFromToday:(int)n;
+(NSArray*)getNSArraySafeForKey:(NSString*)key fromJSONDictionary:(NSDictionary*)jsonDict;
+(NSString*)getStringSafeForKey:(NSString*)key fromJSONDictionary:(NSDictionary*)jsonDict;
+(NSNumber*)getNSNumberSafeForKey:(NSString*)key fromJSONDictionary:(NSDictionary*)jsonDict;
+(NSString*)getPathToDocsDirectory;
+(BOOL)isEmpty:(id)obj;

@end

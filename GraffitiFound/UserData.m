//
//  UserData.m
//  graffitifound
//
//  Created by Leonard Bogdonoff on 11/9/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import "UserData.h"

@implementation UserData

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userEmail forKey:@"userEmail"];
    [aCoder encodeObject:self.defaultLocation forKey:@"defaultLocation"];
}

@end

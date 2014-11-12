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

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _userEmail = [aDecoder decodeObjectForKey:@"userEmail"];
        _defaultLocation = [aDecoder decodeObjectForKey:@"defaultLocation"];
    }
    
    return self;
}

- (instancetype) initWithDefaultLocation:(NSString *) location
{
    
    return self;
}

- (instancetype)init
{
    return [self initWithDefaultLocation:@"defaultLocation"];
}

- (NSString *)description
{
    NSString *descriptionString =
    [[NSString alloc] initWithFormat:@"Location: %@, User: %@",
     self.defaultLocation,
     self.userEmail];
    
    return descriptionString;
}

@end

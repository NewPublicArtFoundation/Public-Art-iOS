//
//  UserData.h
//  graffitifound
//
//  Created by Leonard Bogdonoff on 11/9/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UserData : NSObject <NSCoding>

@property (nonatomic) NSString *defaultLocation;
@property (nonatomic) NSString *userEmail;

-(instancetype)initWithUserName:(NSString *) email;

@end

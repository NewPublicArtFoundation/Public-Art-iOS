//
//  ATRgraffiti.h
//  ATRRandomNumber
//
//  Created by Leonard Bogdonoff on 10/15/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface GraffitiData : NSObject <NSCoding>
{
}

@property (nonatomic) NSString *graffitiName;
@property (nonatomic) NSString *serialNumber;
@property (nonatomic) int valueInDollars;
@property (nonatomic,readonly) NSDate *dateCreated;
@property (nonatomic, copy) NSString *graffitiKey;


+(instancetype)randomgraffiti;

-(instancetype)initWithgraffitiName:(NSString *) name
                 valueInDollars:(int)value
                   serialNumber:(NSString *)sNumber;

-(instancetype)initWithgraffitiName:(NSString *)name;


@end

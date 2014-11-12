//
//  GraffitiDataStore.h
//  graffitifound
//
//  Created by Leonard Bogdonoff on 11/9/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GraffitiData;

@interface GraffitiDataStore : NSObject

@property (nonatomic, readonly, copy) NSArray *allGraffiti;

+ (instancetype)sharedStore;

- (GraffitiData *)createGraffiti;
-(void)removeGraffiti:(GraffitiData *)graffiti;
-(void)moveGraffitiAtIndex:(NSUInteger)fromIndex
                   toIndex:(NSUInteger)toIndex;

//-(BOOL)saveChanges;

@end

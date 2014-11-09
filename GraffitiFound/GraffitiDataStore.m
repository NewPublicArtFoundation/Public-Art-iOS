//
//  GraffitiDataStore.m
//  graffitifound
//
//  Created by Leonard Bogdonoff on 11/9/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import "GraffitiData.h"
#import "GraffitiDataStore.h"

@interface GraffitiDataStore ()

@property (nonatomic) NSMutableArray *privateGraffitis;

@end

@implementation GraffitiDataStore

+ (instancetype)sharedStore
{
    static GraffitiDataStore *sharedStore;
    
    if(!sharedStore){
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (BOOL)saveChanges
{
    NSString *path = [self graffitiArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:self.privateGraffitis
                                       toFile:path];
}

- (NSString *)graffitiArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"graffitis.archive"];
}

- (instancetype)init
{
    [NSException raise:@"Singleton"
                format:@"User +[GraffitiDataStore sharedStore]"];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self){
        NSString *path = [self graffitiArchivePath];
        _privateGraffitis = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!_privateGraffitis){
            _privateGraffitis = [[NSMutableArray alloc] init];
        }
    }
    
    return self;
}

- (void)moveGraffitiAtIndex:(NSUInteger)fromIndex
                    toIndex:(NSUInteger)toIndex
{
    if(fromIndex == toIndex){
        return;
    }
    
    GraffitiData *graffiti = self.privateGraffitis[fromIndex];
    
    [self.privateGraffitis removeObjectAtIndex:fromIndex];
    
    [self.privateGraffitis insertObject:graffiti atIndex:toIndex];
}

- (void)removeGraffiti:(GraffitiData *)graffiti
{
    NSString *key = graffiti.graffitiKey;
    
    [self.privateGraffitis removeObjectIdenticalTo:graffiti];
}

- (NSArray *)allGraffitis
{
    return [self.privateGraffitis copy];
}

- (GraffitiData *)createGraffiti
{
    GraffitiData *graffiti = [[GraffitiData alloc] init];
    [self.privateGraffitis addObject:graffiti];
    
    return graffiti;
}

@end

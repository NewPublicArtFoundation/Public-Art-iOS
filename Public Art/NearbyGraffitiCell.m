//
//  NearbyGraffitiCell.m
//  GraffitiFound
//
//  Created by Leonard Bogdonoff on 10/24/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import "NearbyGraffitiCell.h"

@implementation NearbyGraffitiCell

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

@end

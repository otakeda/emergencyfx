//
//  ef_Cell.m
//  emergencyfx
//
//  Created by otakeda on 2012/10/29.
//  Copyright (c) 2012年 otakeda. All rights reserved.
//


#import "ef_Cell.h"

@implementation ef_Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

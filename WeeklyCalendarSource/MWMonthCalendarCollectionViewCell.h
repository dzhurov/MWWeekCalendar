//
//  MWMonthCalendarCollectionViewCell.h
//  TempMonthCalendar
//
//  Created by Andrey Durbalo on 6/2/15.
//  Copyright (c) 2015 Andrey Durbalo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWMonthCalendarCollectionViewCell : UICollectionViewCell

@property(nonatomic) BOOL isDayOff;
@property(nonatomic, strong) NSArray *events;

-(void)configurateWithObject:(id)object;
+(NSString*)identifier;

@end

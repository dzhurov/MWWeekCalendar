//
//  MWWeekdayTitleCollectionViewCell.h
//  TempMonthCalendar
//
//  Created by Andrey Durbalo on 6/3/15.
//  Copyright (c) 2015 Andrey Durbalo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWWeekdayTitleCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

+(NSString*)identifier;

@end

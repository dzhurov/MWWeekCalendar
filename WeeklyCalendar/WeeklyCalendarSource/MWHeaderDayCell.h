//
//  HeaderDayCell.h
//  WeeklyCalendar
//
//  Created by DZhurov on 4/27/15.
//
//

#import <UIKit/UIKit.h>

@interface MWHeaderDayCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *dayOfWeekLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayOfMonthLabel;

- (void)setDate:(NSDate*)date selected:(BOOL)selected weekend:(BOOL)weekend;

@end

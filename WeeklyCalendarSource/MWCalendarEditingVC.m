//
//  MWCalendarEditingVC.m
//  WeeklyCalendar
//
//  Created by Sergey Konovorotskiy on 5/18/15.
//
//

#import "MWCalendarEditingVC.h"
#import "MWWeekCalendarViewController.h"
#import "MWCalendarEvent.h"

@interface MWCalendarEditingVC ()

@property (weak, nonatomic) IBOutlet UINavigationItem *theNavigationItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveItem;
@property (weak, nonatomic) IBOutlet UIButton *deleteItem;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation MWCalendarEditingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateContent];
}

-(void)setEvent:(MWCalendarEvent *)event
{
    _event = event;
    [self updateContent];
}

-(void)updateContent
{
    self.theNavigationItem.title = self.event.title;
    self.textField.text = self.event.title;
    self.textView.text = self.event.eventDescription;
}

- (IBAction)cancelPressed:(id)sender
{
    [self.calendarVC cancelEditingForEvent:self.event];
}

- (IBAction)savePressed:(id)sender
{
    MWCalendarEvent *event = [self.event copy];
    event.eventDescription = self.textView.text;
    event.title = self.textField.text;
    [self.calendarVC saveEvent:self.event withNew:event];
}

- (IBAction)deletePressed:(id)sender
{
    [self.calendarVC deleteEvent:self.event];
}

@end

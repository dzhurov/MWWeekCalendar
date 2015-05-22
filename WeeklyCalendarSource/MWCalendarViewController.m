//
//  MWCalendarViewController.m
//  WeeklyCalendar
//
//  Created by Andrey Durbalo on 5/19/15.
//
//

#import "MWCalendarViewController.h"
#import "MWWeekCalendarViewController.h"

@interface MWCalendarViewController ()

@property (weak, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainContentViewRightConstraint;
@property (weak, nonatomic) IBOutlet UIView *sideMenuBaseView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sideMenuBaseViewWidthConstraint;

@property (nonatomic, weak) id <MWCalendarDelegate> delegate;
@property (nonatomic, weak) id <MWCalendarDataSource> dataSource;

@property (strong, nonatomic) UIPopoverController *editingControllerPopover;

@end

#define MW_CALENDAR_ANIMATION_DURATION 0.15

@implementation MWCalendarViewController

-(instancetype)initWithDelegate:(NSObject<MWCalendarDelegate> *)delegate andDataSource:(NSObject<MWCalendarDataSource> *)dataSource
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.delegate = delegate;
        self.dataSource = dataSource;
    }
    return self;
}

- (void)baseConfiguration
{
    MWWeekCalendarViewController *weekCalendarVC = [MWWeekCalendarViewController new];
    [self addChildViewController:weekCalendarVC];
    weekCalendarVC.delegate = self.delegate;
    weekCalendarVC.dataSource = self.dataSource;
    weekCalendarVC.view.frame = self.mainContentView.bounds;
    weekCalendarVC.startWorkingDay = [self dateComponentsWithHours:9 minutes:30];
    weekCalendarVC.endWorkingDay = [self dateComponentsWithHours:19 minutes:30];

    [self.mainContentView addSubview:weekCalendarVC.view];
}

- (NSDateComponents *)dateComponentsWithHours:(NSInteger)hours minutes:(NSInteger)minutes
{
    NSDateComponents *components = [NSDateComponents new];
    components.hour = hours;
    components.minute = minutes;
    return components;
}

#pragma mark - Live cycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self baseConfiguration];
}

#pragma mark --- MWCalendarViewControllerProtocol

#pragma mark - Show

-(void)showEditingController:(UIViewController *)editingController fromRect:(CGRect)rect inView:(UIView*)view completion:(void (^)())completion;
{
    switch ([self.dataSource calendarEditingPresentationMode]) {
        case MWCalendarEditingPresentationModeSideMenu:
        {
            [self showEditingController:editingController fromSideMenuWithCompletion:completion];
        }
            break;
        case MWCalendarEditingPresentationModePopover:
        {
            [self showEditingController:editingController withPopoverfromRect:rect inView:view completion:completion];
        }
            break;
        case MWCalendarEditingPresentationModeModal:
        {
            [self showEditingController:editingController modalWithCompletion:completion];
        }
            break;
        default:
            NSAssert(NO, @"Unknow MWCalendarEditingPresentationMode: %lu", (unsigned long)[self.dataSource calendarEditingPresentationMode]);
            break;
    }
}

-(void)showEditingController:(UIViewController *)editingController fromSideMenuWithCompletion:(void (^)())completion
{
    self.sideMenuBaseViewWidthConstraint.constant = CGRectGetWidth(editingController.view.frame);
    editingController.view.frame = self.sideMenuBaseView.bounds;
    [self.sideMenuBaseView addSubview:editingController.view];
    [self addChildViewController:editingController];
    
    [UIView animateWithDuration:MW_CALENDAR_ANIMATION_DURATION animations:^{
        
        self.mainContentViewRightConstraint.constant = self.sideMenuBaseViewWidthConstraint.constant;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        if (completion) {
            completion();
        }
        
    }];
}

-(void)showEditingController:(UIViewController *)editingController withPopoverfromRect:(CGRect)rect inView:(UIView *)view completion:(void (^)())completion
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.editingControllerPopover isPopoverVisible]) {
        [self.editingControllerPopover dismissPopoverAnimated:NO];
    }
    
    self.editingControllerPopover = [[UIPopoverController alloc] initWithContentViewController:editingController];
    [self.editingControllerPopover presentPopoverFromRect:rect
                                                   inView:view
                                 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    if (completion) {
        completion();
    }
}

-(void)showEditingController:(UIViewController *)editingController modalWithCompletion:(void (^)())completion
{
    editingController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:editingController animated:YES completion:completion];
}

#pragma mark - Hide

-(void)hideEditingController:(UIViewController *)editingController completion:(void (^)())completion
{
    switch ([self.dataSource calendarEditingPresentationMode]) {
        case MWCalendarEditingPresentationModeSideMenu:
        {
            [self hideEditingController:editingController fromSideMenuWithCompletion:completion];
        }
            break;
        case MWCalendarEditingPresentationModePopover:
        {
            [self hideEditingController:editingController fromPopoverWithCompletion:completion];
        }
            break;
        case MWCalendarEditingPresentationModeModal:
        {
            [self hideEditingController:editingController modalWithCompletion:completion];
        }
            break;
        default:
            NSAssert(NO, @"Unknow MWCalendarEditingPresentationMode: %lu", (unsigned long)[self.dataSource calendarEditingPresentationMode]);
            break;
    }
}

-(void)hideEditingController:(UIViewController *)editingController fromSideMenuWithCompletion:(void (^)())completion
{
    [UIView animateWithDuration:MW_CALENDAR_ANIMATION_DURATION animations:^{
        
        self.mainContentViewRightConstraint.constant = 0;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [editingController.view removeFromSuperview];
        [editingController removeFromParentViewController];
        
        if (completion) {
            completion();
        }
        
    }];
}

-(void)hideEditingController:(UIViewController *)editingController fromPopoverWithCompletion:(void (^)())completion
{
    [self.editingControllerPopover dismissPopoverAnimated:YES];
    
    if (completion) {
        completion();
    }
}

-(void)hideEditingController:(UIViewController *)editingController modalWithCompletion:(void (^)())completion
{
    [editingController dismissViewControllerAnimated:YES completion:completion];
}

@end

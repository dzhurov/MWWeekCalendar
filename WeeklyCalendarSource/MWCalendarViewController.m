//
//  MWCalendarViewController.m
//  WeeklyCalendar
//
//  Created by Andrey Durbalo on 5/19/15.
//
//

#import "MWCalendarViewController.h"
#import "MWWeekCalendarViewController.h"
#import "MWMonthCalendarViewController.h"
#import "PureLayout.h"

@interface MWCalendarViewController ()

@property (weak, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainContentViewRightConstraint;
@property (weak, nonatomic) IBOutlet UIView *sideMenuBaseView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sideMenuBaseViewWidthConstraint;

@property (nonatomic, weak) id <MWCalendarDelegate> delegate;
@property (nonatomic, weak) id <MWCalendarDataSource> dataSource;

@property (strong, nonatomic) UIPopoverController *editingControllerPopover;

@property (nonatomic, strong) MWMonthCalendarViewController *monthCalendarVC;

@end

#define MW_CALENDAR_ANIMATION_DURATION 0.15

@implementation MWCalendarViewController
@synthesize weekCalendarVC = _weekCalendarVC;

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
    weekCalendarVC.view.hidden = YES;
    weekCalendarVC.startWorkingDay = [self dateComponentsWithHours:9 minutes:30];
    weekCalendarVC.endWorkingDay = [self dateComponentsWithHours:19 minutes:30];
    _weekCalendarVC = weekCalendarVC;
    [self.mainContentView addSubview:weekCalendarVC.view];
    
    self.monthCalendarVC = [MWMonthCalendarViewController new];
    [self addChildViewController:self.monthCalendarVC];
    [self.mainContentView addSubview:self.monthCalendarVC.view];
    
    [self.monthCalendarVC.view autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.monthCalendarVC.view autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.monthCalendarVC.view autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.monthCalendarVC.view autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    
    [self.view layoutSubviews];
}

- (NSDateComponents *)dateComponentsWithHours:(NSInteger)hours minutes:(NSInteger)minutes
{
    NSDateComponents *components = [NSDateComponents new];
    components.hour = hours;
    components.minute = minutes;
    return components;
}

- (MWWeekCalendarViewController *)weekCalendarVC
{
    return _weekCalendarVC;
}

#pragma mark - Live cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self baseConfiguration];
}

- (IBAction)segmentControlValueChanged:(UISegmentedControl *)sender
{
    sender.userInteractionEnabled = NO;
    
    __weak __typeof(self)weakSelf = self;
    void(^complete)() = ^(){
        weakSelf.monthCalendarVC.view.hidden = sender.selectedSegmentIndex!=0;
        weakSelf.weekCalendarVC.view.hidden = sender.selectedSegmentIndex==0;
        
        sender.userInteractionEnabled = YES;
    };
    
    if ( ([self.dataSource calendarEditingPresentationMode]==MWCalendarEditingPresentationModeSideMenu) && [self isSideMenuOpen]) {
        UIViewController *editingVC = [[self childViewControllers] lastObject];
        [self hideEditingController:editingVC fromSideMenuWithCompletion:complete];
    } else {
        complete();
    }
}

-(BOOL)isSideMenuOpen
{
    return self.mainContentViewRightConstraint.constant > 0;
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

#pragma mark - IBActions

- (IBAction)todayButtonPressed:(id)sender
{
    [self.monthCalendarVC showToday];
}


@end

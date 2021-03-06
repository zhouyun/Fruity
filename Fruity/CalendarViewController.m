//
//  CalendarViewController.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/13/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "CalendarViewController.h"
#import "DisplayCalendarMonthView.h"
#import "GlobalVariables.h"

@interface CalendarViewController ()

@property GlobalVariables *globalVs;
@property (nonatomic) NSMutableArray *allMonthViews;

@property (nonatomic) UIScrollView *calendarView;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.globalVs = [GlobalVariables getInstance];
    self.allMonthViews = [[NSMutableArray alloc] init];
    
    NSDate *date = [self.globalVs.userPreference valueForKey:@"FruityStartDate"];
    
    // Initialize the calendar view
    self.calendarView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.globalVs.screenHeight / 6, self.globalVs.screenWidth, self.globalVs.screenHeight / 2)];
    self.calendarView.contentSize = CGSizeMake(self.globalVs.screenWidth, self.globalVs.screenHeight);
    self.calendarView.scrollEnabled = YES;
    self.calendarView.backgroundColor = self.view.backgroundColor;
    
    // Initialize the bottom view
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.globalVs.screenHeight * 2 / 3, self.globalVs.screenWidth, self.globalVs.screenHeight / 3)];
    bottomView.backgroundColor = self.globalVs.softWhiteColor;
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(bottomView.frame.size.width / 8, 0, bottomView.frame.size.width * 3 / 4, bottomView.frame.size.height * 4 / 5)];
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.numberOfLines = 0;
    textLabel.font = self.globalVs.font;
    textLabel.textColor = self.globalVs.darkGreyColor;
    textLabel.text = @"Congrats! You just started your journey!";
    [bottomView addSubview:textLabel];
    
    [self.view addSubview:self.calendarView];
    [self.view addSubview:bottomView];
    
    int numberOfPastMonths = 0;
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *YearMonthDayCompsOfDate = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSDateComponents *YearMonthDayCompsOfCurrentDate = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
    NSDateComponents *oneMonthUnit = [NSDateComponents new];
    oneMonthUnit.month = 1;
    
    // Add past months to the month view
    while (YearMonthDayCompsOfDate.year <= YearMonthDayCompsOfCurrentDate.year
            && YearMonthDayCompsOfDate.month < YearMonthDayCompsOfCurrentDate.month) {
        DisplayCalendarMonthView *monthView = [[DisplayCalendarMonthView alloc] initWithFrame:CGRectMake(0, numberOfPastMonths * self.view.frame.size.height / 11, self.view.frame.size.width, self.view.frame.size.height * 5 / 11) date:date willDisplayDays:NO];
        monthView.delegate = self;
        [self.calendarView addSubview:monthView];
        
        // Add one month to the date
        date = [calendar dateByAddingComponents:oneMonthUnit toDate:date options:0];
        YearMonthDayCompsOfDate = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        
        // Add one to number of past months too
        numberOfPastMonths++;
        
        // Store the all month views for the purpose of changing frame size of certain month view according to the button inside
        [self.allMonthViews addObject:monthView];
    }
    
    // Expand the current month view to show fruit eating information on each day
    DisplayCalendarMonthView *currentMonthView = [[DisplayCalendarMonthView alloc] initWithFrame:CGRectMake(0, numberOfPastMonths * self.view.frame.size.height / 11, self.view.frame.size.width, self.view.frame.size.height * 5 / 11) date:date willDisplayDays:YES];
    currentMonthView.delegate = self;
    [self.calendarView addSubview:currentMonthView];
    [self.allMonthViews addObject:currentMonthView];
    
    // Resize the scroll view and set the offset so that the current month is at the beginning of the view
    self.calendarView.contentSize = CGSizeMake(self.globalVs.screenWidth, numberOfPastMonths * self.view.frame.size.height / 10 + self.view.frame.size.height * 5 / 12 + self.view.frame.size.height / 8);
    self.calendarView.contentOffset = CGPointMake(0, (numberOfPastMonths - 1) * self.view.frame.size.height / 10);
    
    
}

- (void) reloadSuperView:(id)view {
    float lastHeight = 0.0;
    for (DisplayCalendarMonthView *monthView in self.allMonthViews) {
        if (monthView != view) {
            [monthView setWillDisplayDaysToNO];
        }
        else {
            [monthView setWillDisplayDaysToYES];
            self.calendarView.contentOffset = CGPointMake(0, lastHeight);
        }
        monthView.frame = CGRectMake(0, lastHeight, monthView.frame.size.width, monthView.frame.size.height);
        lastHeight += monthView.frame.size.height;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

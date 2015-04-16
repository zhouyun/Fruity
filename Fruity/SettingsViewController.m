//
//  SettingsViewController.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/11/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "SettingsViewController.h"
#import "AddReminderViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SettingsViewController ()

@property (nonatomic) UIView *displayReminderView;
@property UIButton *addReminderButton;

@property (nonatomic) CGRect screenRect;

@property (nonatomic) NSMutableArray *reminderTimes;
@property (nonatomic) NSUserDefaults *userPreference;

@property (nonatomic) UITextView *notificationTipTextView;
@property (nonatomic) UITextView *notificationTextView;

@property (nonatomic) UIButton *switchNotificationButton;
@property (nonatomic) UIButton *notificationTipButton;
@property (nonatomic) NSMutableArray *allRemindersButtons;
@property (nonatomic) NSMutableArray *allRemindersDeleteButtons;

@property (nonatomic) UIFont *font;
@property (nonatomic) bool isNotificationOn;


// The tag -1 refers to the addReminderButton.
// The tag with other number refers to the index of the reminder button
@property (nonatomic) int pressButtonTag;

@property (weak, nonatomic) IBOutlet UIButton *backButton;

// Formatter that is used to transform date to string
@property NSDateFormatter *dateFormatter;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set Font for the text
    self.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:16];
    
    // Get the screen resolution
    self.screenRect = [[UIScreen mainScreen] bounds];
    
    self.displayReminderView = [[UIView alloc] init];
    self.displayReminderView.frame = CGRectMake(0, 60, self.screenRect.size.width, self.screenRect.size.height / 3);
    self.displayReminderView.backgroundColor = self.view.backgroundColor;
    
    // Initialize the formatter to transform date to string
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"hh:mm a"];
    
    // Initialize the user preference
    self.userPreference = [[NSUserDefaults alloc] init];
    
    // Load data from userDefaults
    [self loadUserPreference];
    
    // Display each notification reminder set by users
    [self displayReminders];
    
    // Display all static sub views
    [self displayStaticSubviews];
    
    UITapGestureRecognizer *tapToHideTipForNotification = [[UITapGestureRecognizer alloc]
                                                           initWithTarget:self
                                                           action:@selector(hideTipForNotification)];
    [self.view addGestureRecognizer:tapToHideTipForNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUserPreference {
    /*
    // Set a reminder at 10:00 the first time launching the view controller
    if ([self.userPreference objectForKey:@"notificationRemindTimes"] == nil || [[self.userPreference objectForKey:@"notificationRemindTimes"] count] == 0) {
        // Set the initial reminder time to 10:00
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents * comps = [[NSDateComponents alloc] init];
        [comps setHour:10];
        [comps setMinute:0];
        NSDate *date = [cal dateFromComponents:comps];
        
        NSMutableArray *reminders = [[NSMutableArray alloc] initWithObjects:date, nil];
        [self.userPreference setObject:reminders forKey:@"notificationRemindTimes"];
    }*/
    
    // Load all reminders
    self.reminderTimes = [[NSMutableArray alloc] initWithArray:[self.userPreference objectForKey:@"notificationRemindTimes"]];
    
    // Set notification on the first time launching the view controller
    if ([self.userPreference objectForKey:@"isNotificationOn"] == nil) {
        [self.userPreference setBool:YES forKey:@"isNotificationOn"];
    }
    self.isNotificationOn = [self.userPreference boolForKey:@"isNotificationOn"];
}

- (void)displayReminders {
    // Remove all subviews currently in the notificationsView
    [self.displayReminderView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    // Reinitialize the array of all reminder buttons
    [self.allRemindersButtons removeAllObjects];
    self.allRemindersButtons = [[NSMutableArray alloc] init];
    
    // Reinitialize the array of all reminder delete buttons
    [self.allRemindersDeleteButtons removeAllObjects];
    self.allRemindersDeleteButtons = [[NSMutableArray alloc] init];
    
    // Each row is going to display 3 timers
    int remindersPerRow = 3;
    
    for (int i = 0; i < [self.reminderTimes count]; i++) {
        
        UIButton *reminderDisplayButton = [[UIButton alloc] init];
        reminderDisplayButton.titleLabel.font = self.font;
        reminderDisplayButton.titleLabel.textColor = [UIColor blackColor];
        [reminderDisplayButton setTitle:[self.dateFormatter stringFromDate:self.reminderTimes[i]] forState:UIControlStateNormal];
        reminderDisplayButton.backgroundColor = UIColorFromRGB(0xd26168);
        
        reminderDisplayButton.frame = CGRectMake(0, 0, self.screenRect.size.width / 5, self.screenRect.size.width / 5);
        reminderDisplayButton.center = CGPointMake(self.screenRect.size.width / 6 + i % remindersPerRow * self.screenRect.size.width / 3, self.screenRect.size.width / 6 + i / remindersPerRow * self.screenRect.size.width / 3);
        reminderDisplayButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        reminderDisplayButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        reminderDisplayButton.layer.cornerRadius = self.screenRect.size.width / 10;
        reminderDisplayButton.tag = i;
        [reminderDisplayButton addTarget:self action:@selector(updateReminder:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.allRemindersButtons addObject:reminderDisplayButton];
        
        UIButton *reminderDeleteButton = [[UIButton alloc] init];
        [reminderDeleteButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        reminderDeleteButton.frame = CGRectMake(0, 0, self.screenRect.size.width / 24, self.screenRect.size.width / 24);
        reminderDeleteButton.center = CGPointMake(reminderDisplayButton.center.x + self.screenRect.size.width / 10, reminderDisplayButton.center.y - self.screenRect.size.width / 10);
        reminderDeleteButton.tag = i;
        [reminderDeleteButton addTarget:self action:@selector(deleteReminder:) forControlEvents:UIControlEventTouchUpInside];
        [self.allRemindersDeleteButtons addObject:reminderDeleteButton];
        
        [self.displayReminderView addSubview:reminderDisplayButton];
        [self.displayReminderView addSubview:reminderDeleteButton];
    }
    
    [self.view addSubview:self.displayReminderView];
    
    // Hide all reminder buttons and related delete buttons if the notification switch is off
    if (!self.isNotificationOn) {
        [self.displayReminderView setHidden:YES];
    }
}

- (void)displayStaticSubviews {
    // Initialize the add reminder button
    self.addReminderButton = [[UIButton alloc] init];
    [self.addReminderButton setImage:[UIImage imageNamed:@"add-timer.png"] forState:UIControlStateNormal];
    self.addReminderButton.frame = CGRectMake(0, 0, self.screenRect.size.width / 2, self.screenRect.size.width / 2);
    self.addReminderButton.center = CGPointMake(self.screenRect.size.width / 2, self.screenRect.size.height * 2 / 3);
    [self.addReminderButton addTarget:self action:@selector(addReminder:) forControlEvents:UIControlEventTouchUpInside];
    
    self.notificationTextView = [[UITextView alloc] init];
    self.notificationTextView.text = @"Notification";
    self.notificationTextView.textColor = UIColorFromRGB(0xabacab);
    self.notificationTextView.font = self.font;
    self.notificationTextView.frame = CGRectMake(0, 0, self.screenRect.size.width / 2, 30);
    self.notificationTextView.textAlignment = NSTextAlignmentCenter;
    self.notificationTextView.backgroundColor = self.view.backgroundColor;
    self.notificationTextView.center = CGPointMake(self.screenRect.size.width / 2, self.addReminderButton.center.y + self.screenRect.size.height / 5);
    self.notificationTextView.editable = NO;
    
    self.switchNotificationButton = [[UIButton alloc] init];
    if (self.isNotificationOn)
        [self.switchNotificationButton setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    else
        [self.switchNotificationButton setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    self.switchNotificationButton.frame = CGRectMake(0, 0, self.screenRect.size.width / 9, self.screenRect.size.width / 9);
    self.switchNotificationButton.center = CGPointMake(self.screenRect.size.width / 2, self.notificationTextView.center.y + self.screenRect.size.height / 16);
    [self.switchNotificationButton addTarget:self action:@selector(switchNotification:) forControlEvents:UIControlEventTouchUpInside];
    
    self.notificationTipButton = [[UIButton alloc] init];
    [self.notificationTipButton setImage:[UIImage imageNamed:@"questionmark.png"] forState:UIControlStateNormal];
    self.notificationTipButton.frame = CGRectMake(0, 0, self.screenRect.size.width / 20, self.screenRect.size.width / 20);
    [self.notificationTipButton addTarget:self action:@selector(showTipForNotification:) forControlEvents:UIControlEventTouchUpInside];
    [self.notificationTipButton setHidden:YES];
    
    self.notificationTipTextView = [[UITextView alloc] init];
    self.notificationTipTextView.text = @"Send Notification to remind you of fruits time";
    self.notificationTipTextView.textColor = UIColorFromRGB(0xf4f4cd);
    self.notificationTipTextView.font = self.font;
    self.notificationTipTextView.frame = CGRectMake(0, 0, self.screenRect.size.width * 5 / 6, self.screenRect.size.height / 12);
    self.notificationTipTextView.textAlignment = NSTextAlignmentCenter;
    self.notificationTipTextView.layer.cornerRadius = 5;
    self.notificationTipTextView.backgroundColor = UIColorFromRGB(0xd26168);
    self.notificationTipTextView.center = CGPointMake(self.screenRect.size.width / 2, self.screenRect.size.height * 2 / 5);
    self.notificationTipTextView.editable = NO;
    [self.notificationTipTextView setHidden:YES];
    
    [self.view addSubview:self.addReminderButton];
    [self.view addSubview:self.notificationTextView];
    [self.view addSubview:self.switchNotificationButton];
    [self.view addSubview:self.notificationTipButton];
    [self.view addSubview:self.notificationTipTextView];
    
    // Hide related sub views if the notification switch is off
    if (!self.isNotificationOn) {
        [self.addReminderButton setHidden:YES];
        [self.notificationTipButton setHidden:NO];
        
        self.notificationTextView.center = CGPointMake(self.screenRect.size.width / 2, self.screenRect.size.height / 2);
        self.switchNotificationButton.center = CGPointMake(self.screenRect.size.width / 2, self.screenRect.size.height / 2 + self.screenRect.size.height / 16);
        
        self.notificationTipButton.center = CGPointMake(self.screenRect.size.width * 3 / 4, self.screenRect.size.height / 2);
        [self.notificationTipButton setHidden:NO];
    }
}

- (void)addReminder:(UIButton*)addButton {
    // User has a maximum of 6 reminders
    if ([self.allRemindersButtons count] < 6) {
        // Go to the add reminder view controller
        [self performSegueWithIdentifier:@"addOrUpdateReminderSegue" sender:addButton];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Don't eat too much!"
                                                        message:@"My mum told me that never eat fruits over six times a day. It is true!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Got it!"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)updateReminder:(UIButton*)reminderButton {
    // Go to the add reminder view controller
    [self performSegueWithIdentifier:@"addOrUpdateReminderSegue" sender:reminderButton];
}

- (void)deleteReminder:(UIButton*)deleteButton {
    // Make the reminder button and it's related delete button vanish gradually
    [UIView animateWithDuration:0.5
                          delay:0
                        options:0
                     animations:^{
                         [self.allRemindersButtons[deleteButton.tag] setAlpha:0.0];
                         [self.allRemindersDeleteButtons[deleteButton.tag] setAlpha:0.0];
                     }
                     completion:^(BOOL finished){
                         // Delete the row from deleteButton.tag
                         [self.reminderTimes removeObjectAtIndex:deleteButton.tag];
                         
                         // Update stored object in the userPreference
                         [self.userPreference setObject:self.reminderTimes forKey:@"notificationRemindTimes"];
                         
                         // Reload all reminders
                         [self displayReminders];
                     }];
}

- (void)switchNotification:(UIButton*)switchButton {
    
    // Reverse notification on/off and save it to the user preference
    self.isNotificationOn = !self.isNotificationOn;
    [self.userPreference setBool:self.isNotificationOn forKey:@"isNotificationOn"];
    
    if (self.isNotificationOn) {
        // Change the switch notification button to on
        [self.switchNotificationButton setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
        
        // Hide the notification tip button
        [self.notificationTipButton setHidden:YES];
        
        // Hide the notification tip text view if the user has not done it already
        [self.notificationTipTextView setHidden:YES];
        
        for (int i = 0; i < [self.allRemindersButtons count]; i++) {
            [self.allRemindersButtons[i] setAlpha:0.0];
            [self.allRemindersDeleteButtons[i] setAlpha:0.0];
        }
        
        [self.displayReminderView setHidden:NO];
        
        [self.addReminderButton setAlpha:0.0];
        [self.addReminderButton setHidden:NO];
        
        // Move the notification text view and the switch button to the bottom
        [UIView animateWithDuration:0.5
                              delay:0
                            options:0
                         animations:^{
                             self.notificationTextView.center = CGPointMake(self.screenRect.size.width / 2, self.addReminderButton.center.y + self.screenRect.size.height / 5);
                             self.switchNotificationButton.center = CGPointMake(self.screenRect.size.width / 2, self.notificationTextView.center.y + self.screenRect.size.height / 16);
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.5
                                                   delay:0
                                                 options:0
                                              animations:^{
                                                  
                                                  // Show all reminder buttons
                                                  for (int i = 0; i < [self.allRemindersButtons count]; i++) {
                                                      [self.allRemindersButtons[i] setAlpha:1.0];
                                                      [self.allRemindersDeleteButtons[i] setAlpha:1.0];
                                                  }
                                                  // Show add reminder button hidden
                                                  [self.addReminderButton setAlpha:1.0];
                                              }
                                              completion:nil];
                         }];
        
        // Set the notification service on
        
        
        
        
        
        
        
        
        
    }
    else {
        // Change the switch notification button to off
        [self.switchNotificationButton setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
        
        // Make add reminder button, all reminder buttons and their related delete buttons vanish gradually
        [UIView animateWithDuration:0.5
                              delay:0
                            options:0
                         animations:^{
                             // Set all reminder buttons hidden
                             for (int i = 0; i < [self.allRemindersButtons count]; i++) {
                                 [self.allRemindersButtons[i] setAlpha:0.0];
                                 [self.allRemindersDeleteButtons[i] setAlpha:0.0];
                             }
                             // Set add reminder button hidden
                             [self.addReminderButton setAlpha:0.0];
                         }
                         completion:^(BOOL finished){
                             [self.displayReminderView setHidden:YES];
                             
                             // Set add reminder button hidden;
                             [self.addReminderButton setHidden:YES];
                             
                             // Move the notification text view and the switch button to the middle
                             [UIView animateWithDuration:0.5
                                                   delay:0
                                                 options:0
                                              animations:^{
                                                  self.notificationTextView.center = CGPointMake(self.screenRect.size.width / 2, self.screenRect.size.height / 2);
                                                  self.switchNotificationButton.center = CGPointMake(self.screenRect.size.width / 2, self.screenRect.size.height / 2 + self.screenRect.size.height / 16);
                                              }
                                              completion:^(BOOL finished){
                                                  // Adjust the notification tip button center and show it to the user
                                                  self.notificationTipButton.center = CGPointMake(self.screenRect.size.width * 3 / 4, self.screenRect.size.height / 2);
                                                  [self.notificationTipButton setHidden:NO];
                                              }];
                         }];
        

        
            
        // Set the notification service off
            
            
            
            
            
            
            
        
    }
}

- (void)showTipForNotification:(UIButton*)tipButton {
    [self.notificationTipTextView setHidden:NO];
}

- (void)hideTipForNotification{
    [self.notificationTipTextView setHidden:YES];
}

- (IBAction)unwindFromAddReminderView:(UIStoryboardSegue *)segue {
    AddReminderViewController *sourceViewController = segue.sourceViewController;
    
    // If the user pressed the add button and return from the addReminderViewController
    if (self.pressButtonTag == -1) {
        // If it is not the cancel button pressed at the other side
        if (sourceViewController.date != nil) {
            [self.reminderTimes addObject:sourceViewController.date];
    
            // Update stored object in the userPreference
            [self.userPreference setObject:self.reminderTimes forKey:@"notificationRemindTimes"];
    
            // Reload all reminders
            [self displayReminders];
        }
    }
    // If the user pressed one reminder button and return from the addReminderViewController
    else {
        // Update the date at index of datePicker.tag in notificationRemindTimes array
        [self.reminderTimes replaceObjectAtIndex:self.pressButtonTag withObject:sourceViewController.date];
        
        // Update the stored object in the userPreference
        [self.userPreference setObject:self.reminderTimes forKey:@"notificationRemindTimes"];
        
        // Reload all reminders
        [self displayReminders];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    AddReminderViewController *destinationViewController = segue.destinationViewController;
    if (sender == self.addReminderButton) {
        destinationViewController.date = [NSDate date];
        destinationViewController.isFromAddButton = YES;
        self.pressButtonTag = -1;
    }
    else if (sender != self.backButton) {
        UIButton *currentReminderButton = sender;
        destinationViewController.date = self.reminderTimes[currentReminderButton.tag];
        destinationViewController.isFromAddButton = NO;
        self.pressButtonTag = (int)currentReminderButton.tag;
    }
}


@end
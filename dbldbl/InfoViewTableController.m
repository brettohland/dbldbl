//
//  InfoViewTableController.m
//  dbldbl
//
//  Created by brett ohland on 12-04-12.
//  Copyright (c) 2012 brett dot ohland dot ca. All rights reserved.
//

#import "InfoViewTableController.h"
#import "iRate.h"
#import "AppDelegate.h"

@interface InfoViewTableController ()

@end

@implementation InfoViewTableController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidAppear:(BOOL)animated {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Rate and email hit
    if (indexPath.row == 0) {
        // Rate
        [[iRate sharedInstance] openRatingsPageInAppStore];
    } else if (indexPath.row == 1) {
        // Email
        if ([MFMailComposeViewController canSendMail]) {
            // Show the composer
            MFMailComposeViewController* emailController = [[MFMailComposeViewController alloc] init];
            emailController.mailComposeDelegate = self;
            [emailController setSubject:@"Feedback from app"];
            [emailController setToRecipients:[[NSArray alloc] initWithObjects:@"hello@dbldblapp.com", nil]];
            if (emailController) [self presentViewController:emailController animated:YES completion:nil];
        } else {
            NSURL *emailUrl = [[NSURL alloc] initWithString:@"mailto:hello@dbldblapp.com"];
            [[UIApplication sharedApplication] openURL: emailUrl];
        }
    } else if (indexPath.row == 2) {
        // See more hit
        NSURL *url = [[NSURL alloc] initWithString:@"http://dbldblapp.com"];
        [[UIApplication sharedApplication] openURL:url];
    }

}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

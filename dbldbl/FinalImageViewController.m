//
//  FinalImageViewController.m
//  dbldbl
//
//  Created by brett ohland on 12-03-15.
//  Copyright (c) 2012 brett dot ohland dot ca. All rights reserved.
//

#import "AppDelegate.h"
#import "FinalImageViewController.h"
#import <Twitter/Twitter.h>
#import "DejalActivityView.h"
#import <dispatch/dispatch.h>
#import "UIImage+Resize.h"

@interface FinalImageViewController ()

@end

@implementation FinalImageViewController {
    CIImage *backgroundImage;
    CIImage *foregroundImage;

    NSString *filterToUse;
    
    NSMutableDictionary *imageCache;
    
    BOOL firstRun;
    BOOL sentToLoginToFacebook;
    BOOL imageShared;
    
    dispatch_queue_t imageQueue;
    dispatch_queue_t filterQueue;
    dispatch_queue_t mainQueue;
}

@synthesize ShareButton, FilterButton, docInteractionController, firstImage, secondImage, Indicator, FilterLabel, ImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    firstRun = YES;
    
//    [TestFlight passCheckpoint:@"On the composite screen"];
    
	// Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    imageCache = [[NSMutableDictionary alloc] init];
    
    self.docInteractionController = [[UIDocumentInteractionController alloc] init];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Start again" style:UIBarButtonSystemItemCancel target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = backButton;

    imageShared = NO;
    
    // Create the image generation queues, reference the main queue
    imageQueue = dispatch_queue_create("com.dbldbl.image", NULL);
    filterQueue = dispatch_queue_create("com.dbldbl.filter", NULL);
    mainQueue = dispatch_get_main_queue();
    
}

- (void) viewDidAppear:(BOOL)animated {
    if (firstRun) {
        firstRun = NO;
        [self generateImageWithFilter:@"CIMultiplyCompositing"];
    }
}

- (void) goBack {
    UIAlertView *backWarning = [[UIAlertView alloc] initWithTitle:@"You sure?" 
                                                           message:@"You haven't saved or shared this image, it will be deleted" 
                                                          delegate:self 
                                                 cancelButtonTitle:@"Stay here" 
                                                 otherButtonTitles:@"Continue", nil];
    backWarning.tag = 0;

    if (!imageShared) {
        [backWarning show];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0 && buttonIndex == 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (UIImage *) runFilter:(NSString *)filterName onFirstImage:(UIImage *)first onSecondImage:(UIImage *)second {
    
    // runs the required filter on the specified images
        backgroundImage = [[CIImage alloc] initWithImage:first];
        foregroundImage = [[CIImage alloc] initWithImage:second];
        
        CIContext *context = [CIContext contextWithOptions: [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] 
                                                                                        forKey:kCIContextUseSoftwareRenderer]];
        CIFilter *mergeFilter = [CIFilter filterWithName:filterName
                                           keysAndValues:kCIInputImageKey, foregroundImage, @"inputBackgroundImage", backgroundImage, nil];
        CIImage *outputImage = [mergeFilter outputImage];
        CGRect imageViewDimentions = CGRectMake(0, 0, first.size.width, first.size.height);
        CGImageRef cgimg = [context createCGImage:outputImage fromRect:imageViewDimentions];
        UIImage *newImage = [UIImage imageWithCGImage:cgimg];
        CGImageRelease(cgimg);
        return newImage;
}


- (IBAction)ShareImage:(id)sender {
    
    // Ignore this whole thing for iOS 6+
    if ( [UIDevice currentDevice].systemVersion.floatValue >= 6.0 ) {
        // This is identical to hitting sendToInstagram
        // Instagram it
        
//        NSString *pathToFinalImage = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/compositeInstagram.ig"];
//        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pathToFinalImage];
  
        // Work on this, stop it from generating the image every time.
//        if ( fileExists ){
//            NSURL *URLToFinalImage = [NSURL fileURLWithPath:pathToFinalImage];
//            [self shareToServices:URLToFinalImage];
//        } else {
            [DejalBezelActivityView activityViewForView:self.view withLabel:@"Generating final image"];
            dispatch_async(imageQueue, ^{
                NSURL *finalCompositePath = [NSURL fileURLWithPath:[self generateFinalImage:@"instagramPlus"]];
                dispatch_async(mainQueue,^{
                    [DejalBezelActivityView removeViewAnimated:YES];
                    [self shareToServices:finalCompositePath];
                });
            });
//        }
    }
//    else {
//        UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                                      delegate:self 
//                                                             cancelButtonTitle:@"Cancel" 
//                                                        destructiveButtonTitle:nil 
//                                                             otherButtonTitles:@"Tweet it", @"Instagram it", @"Facebook it", @"Save it", nil];
//        [shareActionSheet showInView:self.view];
//    }
}

//- (void) actionSheet:(UIActionSheet *)sender clickedButtonAtIndex:(NSInteger)buttonIndex {
////    [TestFlight passCheckpoint:@"Hit the share button"];
//    
//    imageShared = YES;
//    
//    if (buttonIndex == 0) {
//        // Tweet it
//        [DejalBezelActivityView activityViewForView:self.view withLabel:@"Generating final image"];
//        dispatch_async(imageQueue, ^{
//            UIImage *finalComposite = [[UIImage alloc] initWithContentsOfFile:[self generateFinalImage:@"large"]];
//            dispatch_async(mainQueue,^{
//                [self tweetImage:finalComposite];
//                [DejalBezelActivityView removeViewAnimated:YES];
//            });
//        });
//    } else if (buttonIndex == 1) {
//        // Instagram it
//        [DejalBezelActivityView activityViewForView:self.view withLabel:@"Generating image"];
//        dispatch_async(imageQueue, ^{
//            NSURL *finalCompositePath = [NSURL fileURLWithPath:[self generateFinalImage:@"instagram"]];
//            dispatch_async(mainQueue,^{
//                [DejalBezelActivityView removeViewAnimated:YES];
//                [self sendToInstagram:finalCompositePath];
//            });
//        });
//    } else if (buttonIndex == 2) {
//        // Facebook 
//        // Check Facebook status
//        if (![sharedFacebookInstance isConnected]) {
//            // Not connected, start the dog and pony show
//            
//            UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"One second" 
//                                                                 message:@"dbldbl needs to ask Facebook permission to post images, this will only happen once." 
//                                                                delegate:self 
//                                                       cancelButtonTitle:nil 
//                                                       otherButtonTitles:@"Okay", nil];
//            loginAlert.tag = 1;
//            sentToLoginToFacebook = YES;
//            [loginAlert show];
//        } else {
//            [self sendToFacebook];
//        }
//        
//    } else if (buttonIndex == 3) {
//        // Save it
//        [self saveImageToCameraRoll];    
//    } else if (buttonIndex == 4) {
//        // Cancel
//        imageShared = NO;
//    }
//}



//- (void) sendToFacebook {
//    
//    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Generating image"];
//    
//    dispatch_async(imageQueue, ^{
//        UIImage *finalComposite = [[UIImage alloc] initWithContentsOfFile:[self generateFinalImage:@"large"]];
//        
//        dispatch_async(mainQueue,^{
//            [DejalBezelActivityView activityViewForView:self.view withLabel:@"Sending to Facebook\n (Sorry, this takes a while)"];
//            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                           finalComposite, @"source", 
//                                           nil, nil,             
//                                           nil];
//            [sharedFacebookInstance.facebook requestWithGraphPath:[NSString stringWithFormat:@"/me/photos?access_token=%@", sharedFacebookInstance.facebook.accessToken]
//                                                        andParams:params andHttpMethod:@"POST" andDelegate:sharedFacebookInstance];
//        });
//    });
//}

- (void) sendToInstagram: (NSURL *) finalCompositePath {
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://camera"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        //imageToUpload is a file path with .ig file extension
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:finalCompositePath];
        self.docInteractionController.UTI = @"com.instagram.exclusivegram";
//        self.docInteractionController.UTI = @"com.instagram.photo";
        self.docInteractionController.delegate = self;
        self.docInteractionController.annotation = [NSDictionary dictionaryWithObject:@"#dbldblapp" forKey:@"InstagramCaption"];
        //            [documentInteractionController presentOpenInMenuFromBarButtonItem:self.ShareButton animated:YES];
        [self.docInteractionController presentOptionsMenuFromBarButtonItem:self.ShareButton animated:YES];
    } else {
        UIAlertView *noInstagram = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
                                                              message:@"Instagram hasn't been installed on this device."
                                                             delegate:nil 
                                                    cancelButtonTitle:@"Cancel" 
                                                    otherButtonTitles:nil, nil];
        [noInstagram show];
    }
}

- (void) shareToServices: (NSURL *) finalCompositePath {
    NSLog(@"shareToServices %@", finalCompositePath);
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://camera"];
    self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:finalCompositePath];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        NSLog(@"instagram installed");
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:finalCompositePath];
        self.docInteractionController.UTI = @"com.instagram.photo";
        self.docInteractionController.delegate = self;
        self.docInteractionController.annotation = [NSDictionary dictionaryWithObject:@"#dbldblapp" forKey:@"InstagramCaption"];
        [self.docInteractionController presentOptionsMenuFromBarButtonItem:self.ShareButton animated:YES];
    } else {
        NSLog(@"instagram not installed");
        self.docInteractionController.delegate = self;
        [self.docInteractionController presentOptionsMenuFromBarButtonItem:self.ShareButton animated:YES];
    }
    
//    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
//        //imageToUpload is a file path with .ig file extension
//        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:finalCompositePath];
//        self.docInteractionController.UTI = @"com.instagram.exclusivegram";
//        //        self.docInteractionController.UTI = @"com.instagram.photo";
//        self.docInteractionController.delegate = self;
//        self.docInteractionController.annotation = [NSDictionary dictionaryWithObject:@"#dbldblapp" forKey:@"InstagramCaption"];
//        //            [documentInteractionController presentOpenInMenuFromBarButtonItem:self.ShareButton animated:YES];
//        [self.docInteractionController presentOptionsMenuFromBarButtonItem:self.ShareButton animated:YES];
//    } else {
//        UIAlertView *noInstagram = [[UIAlertView alloc] initWithTitle:@"Sorry!"
//                                                              message:@"Instagram hasn't been installed on this device."
//                                                             delegate:nil
//                                                    cancelButtonTitle:@"Cancel"
//                                                    otherButtonTitles:nil, nil];
//        [noInstagram show];
//    }
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application{
//    [TestFlight passCheckpoint:@"Instagram'd it"];    
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL *) fileURL
                                               usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

//- (void)image:(UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
//    
//    UIAlertView *saveError = [[UIAlertView alloc] initWithTitle:nil 
//                                                        message:@"Sorry, image couldn't save" 
//                                                       delegate:self 
//                                              cancelButtonTitle:@"Okay" 
//                                              otherButtonTitles:nil, nil];
//
//    [self performSelector:@selector(dismissActivityView) withObject:nil afterDelay:1];
//
////    [TestFlight passCheckpoint:@"Saved it"];
//    
//    if(error != nil) {
//        [saveError show];
////        [TestFlight passCheckpoint:@"Save error'd out"];
//    }
//}

 - (void) dismissActivityView {
    [DejalBezelActivityView removeViewAnimated:YES]; 
 }

- (NSString *) generateFinalImage: (NSString *) whichSize {
    NSLog(@"generateFinalImage: %@", whichSize);
    NSString *firstLargeImagePath =  [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/firstImageLarge.png"];
    NSString *secondLargeImagePath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/secondImageLarge.png"];
    NSString *scratchPathLarge =     [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/compositeLarge.png"];
    
    NSString *scratchPathSmall =     [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/compositeSmall.png"];
    NSString *scratchPathInstagram = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/compositeInstagram.igo"];
    NSString *scratchPathInstagramPlus = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/compositeInstagram.ig"];
    
    UIImage *firstImageToUse;
    UIImage *secondImageToUse;
    NSString *pathToUse;
    
    if ([whichSize isEqualToString:@"large"])  {
        firstImageToUse = [[UIImage alloc] initWithContentsOfFile:firstLargeImagePath];
        secondImageToUse = [[UIImage alloc] initWithContentsOfFile:secondLargeImagePath];
        pathToUse = scratchPathLarge;
    } else if ([whichSize isEqualToString:@"small"]) {
        firstImageToUse = self.firstImage;
        secondImageToUse = self.secondImage;
        pathToUse = scratchPathSmall;
    } else if ([whichSize isEqualToString:@"instagram"]) {
        firstImageToUse = [[UIImage alloc] initWithContentsOfFile:firstLargeImagePath];
        secondImageToUse = [[UIImage alloc] initWithContentsOfFile:secondLargeImagePath];
        pathToUse = scratchPathInstagram;
    } else if ([whichSize isEqualToString:@"instagramPlus"]) {
        firstImageToUse = [[UIImage alloc] initWithContentsOfFile:firstLargeImagePath];
        secondImageToUse = [[UIImage alloc] initWithContentsOfFile:secondLargeImagePath];
        pathToUse = scratchPathInstagramPlus;
    }
    
    UIImage *compositeImage = [self runFilter:filterToUse onFirstImage:firstImageToUse onSecondImage:secondImageToUse];
    
//    NSLog(@"Image size %f, %f", compositeImage.size.width, compositeImage.size.height);
    
    [UIImagePNGRepresentation(compositeImage) writeToFile:pathToUse atomically:YES];

    // Returns the path to the final image you just asked for
    NSLog(@"%@", pathToUse);
    return pathToUse;
}

- (void)setSelectedOnButton:(UIButton*)button {
    [button setSelected:YES];
}

- (void)setUnselectedOnButton:(UIButton*)button {
    [button setSelected:NO];
}

- (IBAction)ChangeFilter:(UIButton *)sender {
    
    [self moveDotTo:sender];
    
    // Kludgy!
    NSString *max = @"CIMaximumCompositing";
//    NSString *min = @"CIMinimumCompositing";
//    NSString *blend = @"CIMultiplyBlendMode";
    NSString *multiply = @"CIMultiplyCompositing";
    NSString *overlay = @"CIOverlayBlendMode";
    NSString *saturation = @"CISaturationBlendMode";
    NSString *screen = @"CIScreenBlendMode";
//    NSString *soft = @"CISoftLightBlendMode";
    
    NSString *whichFilter;
    
    if (sender.tag == 1) {
        whichFilter = multiply;
        FilterLabel.text = @"Multiply";
    } else if (sender.tag == 2) {
        whichFilter = screen;
        FilterLabel.text = @"Screen";
    } else if (sender.tag == 3) {
        whichFilter = saturation;
        FilterLabel.text = @"Saturation";
    } else if (sender.tag == 4) {
        whichFilter = overlay;
        FilterLabel.text = @"Overlay";
    } else if (sender.tag == 5) {
        whichFilter = max;
        FilterLabel.text = @"Max";
    } else {
        // Use #1 by decfault, just in case
        whichFilter = multiply;
    }
    
    [self generateImageWithFilter:whichFilter];

}

- (void) generateImageWithFilter: (NSString *) whichFilter {
        
    // Store which filter was the final choice
    filterToUse = whichFilter;
    
    if ([imageCache objectForKey:whichFilter] != nil) {
        // it exists, slap it on
        [ImageView setImage:[imageCache objectForKey:whichFilter]];
    } else {
        [DejalBezelActivityView activityViewForView:self.view withLabel:@"Applying filter"];
        dispatch_async(filterQueue,^{
            UIImage *compositeImage = [self runFilter:whichFilter onFirstImage:firstImage onSecondImage:secondImage];
            
            dispatch_async(mainQueue,^{
                [imageCache setObject:compositeImage forKey:whichFilter];
                [ImageView setImage:compositeImage];
                [DejalBezelActivityView removeViewAnimated:YES];
            });
        });
    }
}

- (void) moveDotTo: (UIButton *) button {
    int newIndicatorX = button.frame.origin.x + ((button.frame.size.width/2) - 10);
    CGRect destination = CGRectMake(newIndicatorX, 
                                    Indicator.frame.origin.y, 
                                    Indicator.frame.size.width, 
                                    Indicator.frame.size.height);
    [UIView animateWithDuration:0.25
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         Indicator.frame = destination;
                     } 
                     completion:^(BOOL finished){
//                         NSLog(@"Done!");
                     }];
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setShareButton:nil];
    [self setFilterButton:nil];
    [self setIndicator:nil];
    [self setFilterLabel:nil];
    [super viewDidUnload];
// Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

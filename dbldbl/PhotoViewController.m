//
//  PhotoViewController.m
//  dbldbl
//
//  Created by brett ohland on 12-03-15.
//  Copyright (c) 2012 brett dot ohland dot ca. All rights reserved.
//

#import "PhotoViewController.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "FinalImageViewController.h"
#import "DejalActivityView.h"
#import "UIImage+Resize.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController {
    BOOL hasFirstImage;
    NSDictionary *firstImagePaths;
    NSDictionary *secondImagePaths;
    dispatch_queue_t imageQueue;
    dispatch_queue_t mainQueue;
}

@synthesize ImageView, Instructions, firstImage, secondImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        hasFirstImage = NO;
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self cleanFiles];
    
    // Create the image generation queues, reference the main queue
    imageQueue = dispatch_queue_create("com.dbldbl.image", NULL);
    mainQueue = dispatch_get_main_queue();
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self showCameraUi];
        
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)ActivateCamera:(UIBarButtonItem *)sender {
    [self showCameraUi];
}

- (IBAction)ChoosePhoto:(UIBarButtonItem *)sender {
    UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
    pickerC.delegate = self;
    pickerC.allowsEditing = YES;
    [self presentViewController:pickerC animated:YES completion:nil];
}

-(void) showCameraUi {
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.delegate = self;
    cameraUI.allowsEditing = YES;
    [self presentViewController:cameraUI animated:YES completion:nil];
}

// get sub image
- (UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect {
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image 
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);
    
    // clip to the bounds of the image context
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [img drawInRect:drawRect];
    
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSValue *cropValue = [info objectForKey:UIImagePickerControllerCropRect];
    CGRect cropRect = [cropValue CGRectValue];
    
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *smallCroppedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    NSString *pngPath;
    
    if (!hasFirstImage) {
        // First image
//        [TestFlight passCheckpoint:@"Took first photo"];
        
        hasFirstImage = YES;
        
        Instructions.text = @"Take a second picture";
        
        firstImage = (smallCroppedImage.size.width != smallCroppedImage.size.height) ? [self squareImage: smallCroppedImage] : smallCroppedImage;
        
        [info objectForKey:UIImagePickerControllerEditedImage];
        
        ImageView.backgroundColor = [UIColor blackColor];
        ImageView.image = [info objectForKey:UIImagePickerControllerEditedImage];
        
        pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/firstImageLarge.png"];
        
    } else {
        // Second image
        
        ImageView.backgroundColor = [UIColor blackColor];
        ImageView.image = [info objectForKey:UIImagePickerControllerEditedImage];
        
        secondImage = (smallCroppedImage.size.width != smallCroppedImage.size.height) ? [self squareImage: smallCroppedImage] : smallCroppedImage;
        
        pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/secondImageLarge.png"];

    }
    
    dispatch_async(imageQueue, ^{
        NSLog(@"Dispatching Image queue");
        UIImage *croppedImage = [self getSubImageFrom:originalImage WithRect:cropRect];
        UIImage *imageScaledForFinalUse = [croppedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(1440, 1440) interpolationQuality:kCGInterpolationMedium];
        
        // If the image isn't square (it was cropped from a landscape image)
        if ( croppedImage.size.width != croppedImage.size.height ){
            imageScaledForFinalUse = [self squareImage:imageScaledForFinalUse];
        }
        
        [UIImagePNGRepresentation(imageScaledForFinalUse) writeToFile:pngPath atomically:YES];
        
        dispatch_async(mainQueue,^{
            NSLog(@"Image done");
        });
    });
    
    NSLog(@"firstImage: %@ secondImage: %@", firstImage.description, secondImage.description);
    
    if (firstImage != NULL && secondImage != NULL) {
        [self performSegueWithIdentifier:@"ShowComposite" sender:self];   
    }
}

- (UIImage *) squareImage: (UIImage *)image {
    
    // In the case where the user crops a landscape image to include black bars, we need to do the same
    // Centre the image vertically/horizontally, using the height of the image to deduce all sizes.
    
    int backgroundSidesLength;
    int imageWidth;
    int imageHeight;
    float startingY;
    float startingX;
    
    if (image.size.width > image.size.height) {
        // Image is wider than tall
        backgroundSidesLength = image.size.width;
        imageWidth = backgroundSidesLength; 
        imageHeight = image.size.height;
        startingX = 0;
        startingY = roundf((backgroundSidesLength / 2) - (imageHeight / 2));
    } else {
        // image is taller than wide
        backgroundSidesLength = image.size.height;
        imageWidth = image.size.width;
        imageHeight = backgroundSidesLength;
        startingX = roundf((backgroundSidesLength / 2) - (imageWidth / 2));
        startingY = 0;
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(backgroundSidesLength, backgroundSidesLength));
    
    // Fill the background with a colour
    [[UIColor blackColor] set];
    UIRectFill(CGRectMake(0.0, 0.0, backgroundSidesLength, backgroundSidesLength));
    [image drawInRect:CGRectMake(startingX, startingY, imageWidth, imageHeight)];
    UIImage* squaredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return squaredImage;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowComposite"]) {

        hasFirstImage = NO;
        Instructions.text = @"Take your first picture";
        
        ImageView.image = nil;   
        ImageView.backgroundColor = nil;
        
        FinalImageViewController *finalImageViewController = [segue destinationViewController];
        
        finalImageViewController.firstImage = firstImage;
        finalImageViewController.secondImage = secondImage;
        
        firstImage = NULL;
        secondImage = NULL;
        
//        dispatch_release(imageQueue);
        
    }
    
}

- (UIImage *)imageScaledFromImage:(UIImage *)image toSize:(CGSize)targetSize {
    UIGraphicsBeginImageContext(targetSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];            
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void) cleanFiles {
    
//    NSLog(@"Clean Files called");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString  *firstImgPath     = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/firstImageLarge.png"];
    NSString  *secondImgPath    = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/secondImageLarge.png"];
    NSString  *compositeImgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/compositeLarge.png"];
    
    [fileManager removeItemAtPath:firstImgPath error:NULL];
    [fileManager removeItemAtPath:secondImgPath error:NULL];
    [fileManager removeItemAtPath:compositeImgPath error:NULL];
    
//    NSLog(@"Documents directory: %@", [fileManager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] error:NULL]);
    
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setInstructions:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

@end

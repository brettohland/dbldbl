//
//  PhotoViewController.h
//  dbldbl
//
//  Created by brett ohland on 12-03-15.
//  Copyright (c) 2012 brett dot ohland dot ca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>
#import "ImageLayer.h"

@interface PhotoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    dispatch_queue_t backgroundQueue;
}

- (IBAction)ActivateCamera:(UIBarButtonItem *)sender;
- (IBAction)ChoosePhoto:(UIBarButtonItem *)sender;

@property (strong, nonatomic) IBOutlet UIImageView *ImageView;
@property (strong, nonatomic) IBOutlet UILabel *Instructions;
@property (strong, nonatomic) UIImage *firstImage;
@property (strong, nonatomic) UIImage *secondImage;

@end
            
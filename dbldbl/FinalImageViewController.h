//
//  FinalImageViewController.h
//  dbldbl
//
//  Created by brett ohland on 12-03-15.
//  Copyright (c) 2012 brett dot ohland dot ca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinalImageViewController : UIViewController <UIActionSheetDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *ImageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *ShareButton;
@property (strong, nonatomic) IBOutlet UIButton *FilterButton;
@property (strong, nonatomic) UIDocumentInteractionController *docInteractionController;
@property (strong, nonatomic) UIImage *firstImage;
@property (strong, nonatomic) UIImage *secondImage;
@property (strong, nonatomic) IBOutlet UILabel *Indicator;
@property (strong, nonatomic) IBOutlet UILabel *FilterLabel;

- (IBAction)ShareImage:(id)sender;
- (IBAction)ChangeFilter:(UIButton *)sender;

@end

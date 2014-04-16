//
//  ImageLayer.m
//  dbldbl
//
//  Created by brett ohland on 12-04-02.
//  Copyright (c) 2012 brett dot ohland dot ca. All rights reserved.
//

#import "ImageLayer.h"
#import "DejalActivityView.h"

@interface ImageLayer()

@end

@implementation ImageLayer {
    
}

@synthesize smallImage, originalImage, scaledImage, cropValue, isFirstImage, pngPath, pngPathSm;

-(id)init {
    // Initializes by default to be the first image.
    return [self initWithState:YES];
}

-(id) initWithState:(BOOL) state {
    self = [super init];
    if (self) {
        self.isFirstImage = state;
        NSLog(@"ImagePath initialized with %@", state?@"yes":@"no");
        if (self.isFirstImage) {
            self.pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/firstImageLarge.png"];
            self.pngPathSm = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/firstImage.png"];
        } else {
            self.pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/secondImageLarge.png"];
            self.pngPathSm = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/secondImage.png"];
        }   
    }
    return (self);
}

// Setter override.
-(void) setOriginalImage:(UIImage *)newOriginalImage {
    // Need to crop down the image ASAP.
    self.originalImage = newOriginalImage;
    self.originalImage = NULL;
}


- (UIImage *)imageScaledFromImage:(UIImage *)image toSize:(CGSize)targetSize {
    UIGraphicsBeginImageContext(targetSize);
    [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];            
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (UIImage*) cropImageToRect: (UIImage*) img WithRect: (CGRect) rect {
    
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

@end



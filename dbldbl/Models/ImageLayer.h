//
//  ImageLayer.h
//  dbldbl
//
//  Created by brett ohland on 12-04-02.
//  Copyright (c) 2012 brett dot ohland dot ca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

@interface ImageLayer : NSObject {
    dispatch_queue_t backgroundQueue;
}

@property (nonatomic, strong) UIImage *smallImage;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *scaledImage;
@property (nonatomic, strong) NSValue *cropValue;
@property BOOL isFirstImage;
@property (nonatomic, strong) NSString *pngPath;
@property (nonatomic, strong) NSString *pngPathSm;

-(id)initWithState: (BOOL)state;

@end

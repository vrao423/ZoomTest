//
//  ZoomableScrollView.m
//  Pods
//
//  Created by Venkat Rao on 6/22/15.
//
//

#import "RSZoomableImageView.h"

@interface RSZoomableImageView () <UIScrollViewDelegate>

@property (assign, nonatomic) CGRect oldBounds;
@property (assign, nonatomic) CGSize oldImageSize;
@property (assign, nonatomic) BOOL updatingFrame;

@end

@implementation RSZoomableImageView

-(instancetype)initWithFrame: (CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;

        self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(doubleTapRecognized:)];
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:self.doubleTapGestureRecognizer];
        
        [super addSubview:self.imageViewFull];
    }
    
    return self;
}

-(void)centerScrollViewContents {

    CGSize boundsSize = self.bounds.size;
    boundsSize.width -= self.adjustedContentInset.left + self.adjustedContentInset.right;
    boundsSize.height -= self.adjustedContentInset.top + self.adjustedContentInset.bottom;

    CGRect contentsFrame = self.imageViewFull.frame;

    if (CGSizeEqualToSize(contentsFrame.size, CGSizeZero) ) {
        return;
    }
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }

    self.imageViewFull.frame = contentsFrame;
}

-(void)updateContentSize {

    if (CGRectIsEmpty(self.bounds)) {
        return;
    }

    CGSize imageSize = CGSizeApplyAffineTransform(self.currentImage.size,
                                                  CGAffineTransformMakeScale(self.currentImage.scale,
                                                                             self.currentImage.scale));

    if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
        return;
    }

    self.contentSize = imageSize;

    if (!CGSizeEqualToSize(self.contentSize, self.imageViewFull.frame.size)) {
        self.imageViewFull.frame = CGRectMake(0.0,
                                              0.0,
                                              self.contentSize.width,
                                              self.contentSize.height);
    }
}

-(void)updateZoomBounds {

    CGSize imageSize = self.imageViewFull.image.size;

    CGSize screenSize = self.bounds.size;
    screenSize.width -= self.adjustedContentInset.left + self.adjustedContentInset.right;
    screenSize.height -= self.adjustedContentInset.top + self.adjustedContentInset.bottom;

    self.minimumZoomScale = [self minimumZoomScaleForImageSize:imageSize
                                                withImageScale:self.imageViewFull.image.scale
                                           andScreenSizeBounds:screenSize
                                                     withScale:[UIScreen mainScreen].scale];
    
    self.maximumZoomScale = MAX(self.minimumZoomScale * 2.0, 1.0);
}

-(CGFloat)minimumZoomScaleForImageSize:(CGSize)imageSize
                         withImageScale:(CGFloat)imageScale
                    andScreenSizeBounds:(CGSize)screenSize
                              withScale:(CGFloat)screenScale {

    NSAssert(!CGSizeEqualToSize(imageSize, CGSizeZero), @"rect cannot be empty");
    
    CGFloat ratio = imageSize.width / imageSize.height;
    CGFloat deviceRatio = screenSize.width / screenSize.height;
    
    if (ratio > deviceRatio) {
        return (screenSize.width * screenScale) / (imageSize.width * imageScale);
    } else {
        return (screenSize.height * screenScale) / (imageSize.height * imageScale);
    }
}


-(void)layoutSubviews {
    [super layoutSubviews];

    [self centerScrollViewContents];
}

-(void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];

    if (CGSizeEqualToSize(self.currentImage.size, CGSizeZero)) {
        return;
    }

    if (CGSizeEqualToSize(bounds.size, self.oldBounds.size)) {
        return;
    }

    [self updateFrame];

    self.oldBounds = bounds;
}

-(void)doubleTapRecognized:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self setZoomScale:self.minimumZoomScale animated:YES];
}

-(void)addSubview:(UIView *)view {
    [self.imageViewFull addSubview:view];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
    [self.zoomDelegate zoomableImageViewDidZoom:self];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageViewFull;
}

-(void)updateFrame {

    if (self.updatingFrame) {
        return;
    }

    if (CGSizeEqualToSize(self.currentImage.size, CGSizeZero)) {
        return;
    }

    if (CGRectIsEmpty(self.bounds)) {
        return;
    }

    if (CGSizeEqualToSize(self.oldImageSize, self.imageViewFull.image.size)) {
        return;
    }

    self.updatingFrame = YES;

    [self updateZoomBounds];
    [self updateContentSize];
    [self centerScrollViewContents];

    self.zoomScale = self.minimumZoomScale;

    self.oldImageSize = self.imageViewFull.image.size;

    self.updatingFrame = NO;

    NSLog(@"contentInset: %@", NSStringFromUIEdgeInsets(self.contentInset));
    NSLog(@"adjustedContentInset: %@", NSStringFromUIEdgeInsets(self.adjustedContentInset));

}

-(void)setCurrentImage:(UIImage *)currentImage {
    UIImage *newImage = [UIImage imageWithCGImage:currentImage.CGImage
                                            scale:[UIScreen mainScreen].scale
                                      orientation:currentImage.imageOrientation];

    self.imageViewFull.image = newImage;
    [self updateFrame];
}

-(UIImage *)currentImage {
    return self.imageViewFull.image;
}


-(void)prepareForReuse {
    self.imageViewFull.image = nil;
    self.oldBounds = CGRectZero;
    self.oldImageSize = CGSizeZero;
}

#pragma mark - Lazy Instantiation

-(UIImageView *)imageViewFull {
    if (!_imageViewFull) {
        _imageViewFull = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_imageViewFull setContentMode:UIViewContentModeScaleAspectFit];
        _imageViewFull.translatesAutoresizingMaskIntoConstraints = NO;
        [_imageViewFull setUserInteractionEnabled:YES];
    }
    return _imageViewFull;
}

@end

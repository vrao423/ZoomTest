//
//  ZoomableScrollView.m
//  Pods
//
//  Created by Venkat Rao on 6/22/15.
//
//

#import "RSZoomableImageView.h"

@interface RSZoomableImageView () <UIScrollViewDelegate>

@property (assign, nonatomic) CGSize oldBounds;
@property (assign, nonatomic) CGSize oldImageSize;
@property (assign, nonatomic, getter = isUpdatingFrame) BOOL updatingFrame;

@property (assign, nonatomic) CGFloat screenScale;

@end

@implementation RSZoomableImageView

-(instancetype)initWithFrame:(CGRect)frame withScreenScale:(CGFloat)screenScale {
    self = [self initWithFrame:frame];
    self.screenScale = screenScale;
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
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

        self.screenScale = [UIScreen mainScreen].scale;

//        [NSTimer scheduledTimerWithTimeInterval:5.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            NSLog(@"imageview frame: %@", NSStringFromCGRect(self.imageViewFull.frame));
//            NSLog(@"imageview bounds: %@", NSStringFromCGRect(self.imageViewFull.bounds));
//            NSLog(@"affine: %@", NSStringFromCGAffineTransform(self.imageViewFull.transform));
//            NSLog(@"zoomScale: %.2f", self.zoomScale);
//        }];
    }
    
    return self;
}

-(void)centerScrollViewContents {
    NSLog(@"centerScrollViewContents");

    CGSize screenSize = [self constrainedSize];
    CGRect contentsFrame = self.imageViewFull.frame;

    NSLog(@"screenSize: %@", NSStringFromCGSize(screenSize));
    NSLog(@"old contentsFrame: %@\n\n\n", NSStringFromCGRect(contentsFrame));

    if (CGSizeEqualToSize(contentsFrame.size, CGSizeZero) ) {
        return;
    }
    
    if (contentsFrame.size.width < screenSize.width) {
        contentsFrame.origin.x = (screenSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < screenSize.height) {
        contentsFrame.origin.y = (screenSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }

    NSLog(@"new contentsFrame: %@\n\n\n", NSStringFromCGRect(contentsFrame));

    self.imageViewFull.frame = contentsFrame;
}

-(void)adjustedContentInsetDidChange {
    [super adjustedContentInsetDidChange];
    [self updateFrame];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGSize screenSize = [self constrainedSize];

    if (CGSizeEqualToSize(screenSize, self.oldBounds)) {
        return;
    }

    NSLog(@"layoutSubviews");

    [self updateFrame];
    self.oldBounds = screenSize;
}

-(void)addSubview:(UIView *)view {
    [self.imageViewFull addSubview:view];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (self.updatingFrame) {
        return;
    }

    NSLog(@"scrollViewDidZoom:");

    [self centerScrollViewContents];
    [self.zoomDelegate zoomableImageViewDidZoom:self];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageViewFull;
}

- (BOOL)scrollsToTop {
    return NO;
}

#pragma mark - Update

-(void)updateFrame {
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }

    if (CGSizeEqualToSize(self.currentImage.size, CGSizeZero)) {
        return;
    }

    if (CGSizeEqualToSize(self.oldImageSize, self.imageViewFull.image.size)) {
        return;
    }

    NSLog(@"updateFrame");

    [self updateZoomBounds];
    self.zoomScale = self.minimumZoomScale;
    [self centerScrollViewContents];

    self.oldImageSize = self.imageViewFull.image.size;
}

-(void)prepareForReuse {
    self.imageViewFull.image = nil;
    self.oldImageSize = CGSizeZero;
}

#pragma mark - Private

-(CGSize)constrainedSize {
    CGSize screenSize = self.bounds.size;
    screenSize.width -= self.adjustedContentInset.left + self.adjustedContentInset.right;
    screenSize.height -= self.adjustedContentInset.top + self.adjustedContentInset.bottom;
    return screenSize;
}

-(void)updateContentSize {
    NSAssert(!CGSizeEqualToSize(self.currentImage.size, CGSizeZero), @"image size is zero");

    NSLog(@"updateContentSize");

    CGSize imageSize = CGSizeApplyAffineTransform(self.currentImage.size,
                                                  CGAffineTransformMakeScale(self.currentImage.scale/self.screenScale,
                                                                             self.currentImage.scale/self.screenScale));
    self.contentSize = imageSize;

    self.imageViewFull.bounds = CGRectMake(0.0,
                                           0.0,
                                           self.contentSize.width,
                                           self.contentSize.height);
}

-(void)updateZoomBounds {

    if (!self.currentImage) {
        return;
    }

    NSLog(@"updateZoomBounds");

    CGSize imageSize = self.currentImage.size;
    CGSize screenSize = [self constrainedSize];

    self.minimumZoomScale = [self minimumZoomScaleForImageSize:imageSize
                                                withImageScale:self.currentImage.scale
                                           andScreenSizeBounds:screenSize];

    self.maximumZoomScale = MAX(self.minimumZoomScale * 2.0, 1.0);
}

-(CGFloat)minimumZoomScaleForImageSize:(CGSize)imageSize
                        withImageScale:(CGFloat)imageScale
                   andScreenSizeBounds:(CGSize)screenSize {

    NSAssert(!CGSizeEqualToSize(imageSize, CGSizeZero), @"rect cannot be empty");

    CGFloat ratio = imageSize.width / imageSize.height;
    CGFloat deviceRatio = screenSize.width / screenSize.height;

    if (ratio > deviceRatio) {
        return screenSize.width * self.screenScale / (imageSize.width * imageScale);
    } else {
        return screenSize.height * self.screenScale / (imageSize.height * imageScale);
    }
}

#pragma mark - User Actions

-(void)doubleTapRecognized:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self setZoomScale:self.minimumZoomScale animated:YES];
}

#pragma mark - Setters/Getters

-(void)setCurrentImage:(UIImage *)currentImage {
    self.imageViewFull.image = currentImage;
    [self updateContentSize];
    [self updateFrame];
}

-(UIImage *)currentImage {
    return self.imageViewFull.image;
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

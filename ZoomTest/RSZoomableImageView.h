//
//  ZoomableScrollView.h
//  Pods
//
//  Created by Venkat Rao on 6/22/15.
//
//

#import <UIKit/UIKit.h>

@class RSZoomableImageView;

NS_ASSUME_NONNULL_BEGIN

@protocol RSZoomableImageViewDelegate <NSObject>

-(void)zoomableImageViewDidZoom:(nonnull RSZoomableImageView *)zoomableImageView;

@end

@interface RSZoomableImageView : UIScrollView

@property (nonatomic, strong) UITapGestureRecognizer * doubleTapGestureRecognizer;
@property (nonatomic, strong) UIImageView * imageViewFull;
@property (nonatomic, strong, nullable) UIImage *currentImage;

@property (nonatomic, weak) id<RSZoomableImageViewDelegate> _Nullable zoomDelegate;

-(instancetype)initWithFrame:(CGRect)frame withScreenScale:(CGFloat)screenScale;

-(void)prepareForReuse;

@end

NS_ASSUME_NONNULL_END

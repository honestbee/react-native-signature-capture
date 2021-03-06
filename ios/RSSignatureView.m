#import "RSSignatureView.h"
#import <React/RCTConvert.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PPSSignatureView.h"
#import "RSSignatureViewManager.h"

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@implementation RSSignatureView {
	CAShapeLayer *_border;
	BOOL _loaded;
	EAGLContext *_context;
	UIButton *saveButton;
	UIButton *clearButton;
	UILabel *titleLabel;
	BOOL _rotateClockwise;
	BOOL _square;
	BOOL _showNativeButtons;
	BOOL _showTitleLabel;
    BOOL _saveImageFileInExtStorage;
}

@synthesize sign;
@synthesize manager;

- (instancetype)init
{
	_showNativeButtons = YES;
	_showTitleLabel = YES;
	if ((self = [super init])) {
		_border = [CAShapeLayer layer];
		_border.strokeColor = [UIColor clearColor].CGColor;
		_border.fillColor = nil;
		_border.lineDashPattern = @[@4, @2];

		[self.layer addSublayer:_border];
	}

	return self;
}

- (void) didRotate:(NSNotification *)notification {
	int ori=1;
	UIDeviceOrientation currOri = [[UIDevice currentDevice] orientation];
	if ((currOri == UIDeviceOrientationLandscapeLeft) || (currOri == UIDeviceOrientationLandscapeRight)) {
		ori=0;
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	if (!_loaded) {

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:)
																								 name:UIDeviceOrientationDidChangeNotification object:nil];

		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

		CGSize screen = self.frame.size;

		sign = [[PPSSignatureView alloc]
						initWithFrame: CGRectMake(0, 0, screen.width, screen.height)
						context: _context];
		sign.manager = manager;

		[self addSubview:sign];

		if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {

			if (_showTitleLabel) {
				titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 24)];
				[titleLabel setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height - 120)];

				[titleLabel setText:@"x_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"];
				[titleLabel setLineBreakMode:NSLineBreakByClipping];
				[titleLabel setTextAlignment: NSTextAlignmentCenter];
				[titleLabel setTextColor:[UIColor colorWithRed:200/255.f green:200/255.f blue:200/255.f alpha:1.f]];
				//[titleLabel setBackgroundColor:[UIColor greenColor]];
				[sign addSubview:titleLabel];
			}

			if (_showNativeButtons) {
				//Save button
				saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				[saveButton setLineBreakMode:NSLineBreakByClipping];
				[saveButton addTarget:self action:@selector(onSaveButtonPressed)
				            forControlEvents:UIControlEventTouchUpInside];
				[saveButton setTitle:@"Save" forState:UIControlStateNormal];

				CGSize buttonSize = CGSizeMake(80, 55.0);

				saveButton.frame = CGRectMake(sign.bounds.size.width - buttonSize.width,
				                              0, buttonSize.width, buttonSize.height);
				[saveButton setBackgroundColor:[UIColor colorWithRed:250/255.f green:250/255.f blue:250/255.f alpha:1.f]];
				[sign addSubview:saveButton];


				//Clear button
				clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				[clearButton setLineBreakMode:NSLineBreakByClipping];
				[clearButton addTarget:self action:@selector(onClearButtonPressed)
				             forControlEvents:UIControlEventTouchUpInside];
				[clearButton setTitle:@"Reset" forState:UIControlStateNormal];

				clearButton.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
				[clearButton setBackgroundColor:[UIColor colorWithRed:250/255.f green:250/255.f blue:250/255.f alpha:1.f]];
				[sign addSubview:clearButton];
			}
		}
		else {

			if (_showTitleLabel) {
				titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.height - 80, 24)];
				[titleLabel setCenter:CGPointMake(40, self.bounds.size.height/2)];
				[titleLabel setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90))];
				[titleLabel setText:@"x_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"];
				[titleLabel setLineBreakMode:NSLineBreakByClipping];
				[titleLabel setTextAlignment: NSTextAlignmentLeft];
				[titleLabel setTextColor:[UIColor colorWithRed:200/255.f green:200/255.f blue:200/255.f alpha:1.f]];
				//[titleLabel setBackgroundColor:[UIColor greenColor]];
				[sign addSubview:titleLabel];
			}

			if (_showNativeButtons) {
				//Save button
				saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				[saveButton setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90))];
				[saveButton setLineBreakMode:NSLineBreakByClipping];
				[saveButton addTarget:self action:@selector(onSaveButtonPressed)
				            forControlEvents:UIControlEventTouchUpInside];
				[saveButton setTitle:@"Save" forState:UIControlStateNormal];

				CGSize buttonSize = CGSizeMake(55, 80.0); //Width/Height is swapped

				saveButton.frame = CGRectMake(sign.bounds.size.width - buttonSize.width, sign.bounds.size.height - buttonSize.height, buttonSize.width, buttonSize.height);
				[saveButton setBackgroundColor:[UIColor colorWithRed:250/255.f green:250/255.f blue:250/255.f alpha:1.f]];
				[sign addSubview:saveButton];

				//Clear button
				clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				[clearButton setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90))];
				[clearButton setLineBreakMode:NSLineBreakByClipping];
				[clearButton addTarget:self action:@selector(onClearButtonPressed)
				             forControlEvents:UIControlEventTouchUpInside];
				[clearButton setTitle:@"Reset" forState:UIControlStateNormal];

				clearButton.frame = CGRectMake(sign.bounds.size.width - buttonSize.width, 0, buttonSize.width, buttonSize.height);
				[clearButton setBackgroundColor:[UIColor colorWithRed:250/255.f green:250/255.f blue:250/255.f alpha:1.f]];
				[sign addSubview:clearButton];
			}
		}

	}
	_loaded = true;
	_border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
	_border.frame = self.bounds;
    sign.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}

- (void)setRotateClockwise:(BOOL)rotateClockwise {
	_rotateClockwise = rotateClockwise;
}

- (void)setSquare:(BOOL)square {
	_square = square;
}

- (void)setShowNativeButtons:(BOOL)showNativeButtons {
	_showNativeButtons = showNativeButtons;
}

- (void)setShowTitleLabel:(BOOL)showTitleLabel {
	_showTitleLabel = showTitleLabel;
}

- (void)setSaveImageFileInExtStorage:(BOOL)saveImageFileInExtStorage {
    _saveImageFileInExtStorage = saveImageFileInExtStorage;
}

- (void) onSaveButtonPressed {
	[self saveImage];
}

- (void) saveImage {
	saveButton.hidden = YES;
	clearButton.hidden = YES;
	UIImage *signImage = [self.sign signatureImage: _rotateClockwise withSquare:_square];

	saveButton.hidden = NO;
	clearButton.hidden = NO;

	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths firstObject];
	NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/signature.png"];

	// Remove if file already exists
	if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
		[[NSFileManager defaultManager] removeItemAtPath:tempPath error:&error];
		if (error) {
			NSLog(@"Error: %@", error.debugDescription);
		}
	}
    
    NSData *imageData = UIImagePNGRepresentation(signImage);
    NSString *base64Encoded = [imageData base64EncodedStringWithOptions:0];
    
    // Don't save to file system unless this prop was set to true
    if (_saveImageFileInExtStorage) {
        BOOL isSuccess = [imageData writeToFile:tempPath atomically:YES];
        if (!isSuccess) NSLog(@"Error: Failed to write image to %@", tempPath);
        self.onSave(@{
                  @"pathName": tempPath,
                  @"encoded": base64Encoded
                });
    
    }
    // Just return the base64 image if the prop was set to false or not specified
    else {
        self.onSave(@{
                  @"pathName": tempPath,
                  @"encoded": base64Encoded
                });
    }
}

-(void) onClearButtonPressed {
	[self erase];
}

-(void) erase {
	[self.sign erase];
}

@end

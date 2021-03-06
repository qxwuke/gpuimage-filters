//
//  ViewController.m
//  gpuimage-filters-demo
//
//  Created by suntongmian on 2017/7/27.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import "ViewController.h"
#import "PLSEditVideoCell.h"
#import "PLSFilterGroup.h"

/**
 * some resources from https://github.com/pili-engineering/PLShortVideoKit
 */

#define PLS_SCREEN_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define PLS_SCREEN_HEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)

@interface ViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>
@property (strong, nonatomic) PLSFilterGroup *filterGroup;
@property (strong, nonatomic) UICollectionView *editVideoCollectionView;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *filtersArray;
@property (assign, nonatomic) NSInteger filterIndex;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSString *imageNamePath;
@property (strong, nonatomic) UIButton *selectImageFromPhotoAlbumButton;
@property (strong, nonatomic) UIButton *saveCurrentFilterImageToPhotoAlbumButton;
@property (strong, nonatomic) UIButton *saveAllFilterImagesButton;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // ...
    self.view.backgroundColor = [UIColor grayColor];
    
    // ...
    self.imageName = @"liqin";
    self.image = [UIImage imageNamed:self.imageName];
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.frame = CGRectMake(0, 20, PLS_SCREEN_WIDTH, PLS_SCREEN_WIDTH);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:self.imageName];
    self.imageNamePath = path;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // ...
    self.selectImageFromPhotoAlbumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectImageFromPhotoAlbumButton.frame = CGRectMake(20, PLS_SCREEN_WIDTH + 30, 300, 45);
    [self.selectImageFromPhotoAlbumButton setTitle:@"select image from PhotoAlbum" forState:UIControlStateNormal];
    [self.selectImageFromPhotoAlbumButton setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.selectImageFromPhotoAlbumButton];
    [self.selectImageFromPhotoAlbumButton addTarget:self action:@selector(selectImageFromPhotoAlbumButtonEvent:) forControlEvents:UIControlEventTouchUpInside];

    // ...
    self.saveCurrentFilterImageToPhotoAlbumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveCurrentFilterImageToPhotoAlbumButton.frame = CGRectMake(20, PLS_SCREEN_WIDTH + 85, 300, 45);
    [self.saveCurrentFilterImageToPhotoAlbumButton setTitle:@"save current image to PhotoAlbum" forState:UIControlStateNormal];
    [self.saveCurrentFilterImageToPhotoAlbumButton setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.saveCurrentFilterImageToPhotoAlbumButton];
    [self.saveCurrentFilterImageToPhotoAlbumButton addTarget:self action:@selector(saveCurrentFilterImageToPhotoAlbumButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    // ...
    self.saveAllFilterImagesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveAllFilterImagesButton.frame = CGRectMake(20, PLS_SCREEN_WIDTH + 140, 300, 45);
    [self.saveAllFilterImagesButton setTitle:@"save all images to SandBox" forState:UIControlStateNormal];
    [self.saveAllFilterImagesButton setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.saveAllFilterImagesButton];
    [self.saveAllFilterImagesButton addTarget:self action:@selector(saveAllFilterImagesButtonEvent:) forControlEvents:UIControlEventTouchUpInside];

    // ...
    self.filterGroup = [[PLSFilterGroup alloc] init];

    // ...
    self.filtersArray = [[NSMutableArray alloc] init];
    for (NSDictionary *filterInfoDic in self.filterGroup.filtersInfo) {
        NSString *name = [filterInfoDic objectForKey:@"name"];
        NSString *colorImagePath = [filterInfoDic objectForKey:@"colorImagePath"];
        
        NSDictionary *dic = @{
                              @"name"            : name,
                              @"colorImagePath"  : colorImagePath
                              };
        
        [self.filtersArray addObject:dic];
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(50, 65);
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    _editVideoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, PLS_SCREEN_WIDTH, layout.itemSize.height) collectionViewLayout:layout];
    _editVideoCollectionView.backgroundColor = [UIColor clearColor];
    _editVideoCollectionView.showsHorizontalScrollIndicator = NO;
    _editVideoCollectionView.showsVerticalScrollIndicator = NO;
    [_editVideoCollectionView setExclusiveTouch:YES];
    [_editVideoCollectionView registerClass:[PLSEditVideoCell class] forCellWithReuseIdentifier:NSStringFromClass([PLSEditVideoCell class])];
    _editVideoCollectionView.delegate = self;
    _editVideoCollectionView.dataSource = self;
    self.editVideoCollectionView.frame = CGRectMake(0, PLS_SCREEN_HEIGHT - _editVideoCollectionView.frame.size.height - 20, _editVideoCollectionView.frame.size.width, _editVideoCollectionView.frame.size.height);
    [self.view addSubview:self.editVideoCollectionView];
    [self.editVideoCollectionView reloadData];
    
    // ...
    self.imagePickerController = [[UIImagePickerController alloc]init];
    self.imagePickerController.view.backgroundColor = [UIColor grayColor];
    self.imagePickerController.delegate = self;
//    self.imagePickerController.allowsEditing = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.filtersArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PLSEditVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PLSEditVideoCell class]) forIndexPath:indexPath];
    
    NSDictionary *filterInfoDic = self.filtersArray[indexPath.row];
    
    NSString *name = [filterInfoDic objectForKey:@"name"];
    NSString *colorImagePath = [filterInfoDic objectForKey:@"colorImagePath"];
    
    cell.iconPromptLabel.text = name;
    cell.iconImageView.image = [UIImage imageWithContentsOfFile:colorImagePath];
    
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.filterGroup.filterIndex = indexPath.row;
    
    [self refreshFilterImage];
}

- (void)refreshFilterImage {
    UIImage *outputImage = [self applyFilter:self.image];
   
    self.imageView.image = outputImage;
}

- (UIImage *)applyFilter:(UIImage *)inputImage {
    PLSGPUImageCustomFilter *filter = self.filterGroup.currentFilter;

    UIImage *outputImage;
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
    [stillImageSource addTarget:filter atTextureLocation:0];
    [filter useNextFrameForImageCapture];
    if([filter.lookupImageSource processImageWithCompletionHandler:nil] && [stillImageSource processImageWithCompletionHandler:nil]) {
        outputImage = [filter imageFromCurrentFramebuffer];
    }
    
    [stillImageSource removeAllTargets];
    [filter removeAllTargets];
    stillImageSource = nil;
    filter = nil;
    
    return outputImage;
}

#pragma mark -
#pragma mark 从相册获取图片或视频
- (void)selectImageFromPhotoAlbumButtonEvent:(id)sender {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)saveCurrentFilterImageToPhotoAlbumButtonEvent:(id)sender {
    NSString *filterName;
    UIImage *outputImage;
    
    NSLog(@"start current image to photoalbum...");
    NSLog(@"current filter name: %@", self.filterGroup.filterName);
    
    filterName = self.filterGroup.filterName;
    outputImage = [self applyFilter:self.image];
    
    UIImageWriteToSavedPhotosAlbum(outputImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);

    NSLog(@"save current to photoalbum successed.");
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"save current image to photoalbum failed." ;
    }else{
        msg = @"save current image to photoalbum successed." ;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"WARNING" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:OKAction];
    [self showViewController:alert sender:nil];
}

- (void)saveAllFilterImagesButtonEvent:(id)sender {
    NSString *filterName;
    UIImage *outputImage;
    
    NSLog(@"start to filter image...");

    for (NSInteger filterIndex = 0; filterIndex < self.filterGroup.filtersInfo.count; filterIndex++) {
        @autoreleasepool {
            self.filterGroup.filterIndex = filterIndex;
            filterName = self.filterGroup.filterName;

            outputImage = [self applyFilter:self.image];
            
            [self saveImage:outputImage filterName:filterName filterIndex:filterIndex];
        }
    }
    
    // copy filter plsfilters.json to sandbox
    NSString *bundlePath = [NSBundle mainBundle].bundlePath;
    NSString *filtersPath = [bundlePath stringByAppendingString:@"/PLShortVideoKit.bundle/colorFilter"];
    NSString *jsonPath = [filtersPath stringByAppendingString:@"/plsfilters.json"];
    [self copyMissingFile:jsonPath toPath:self.imageNamePath];
    
    NSLog(@"save all filter image successed.");
    
    NSString *msg = @"save all filter image to SandBox successed.";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"WARNING" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:OKAction];
    [self showViewController:alert sender:nil];
}

- (void)saveImage:(UIImage *)image filterName:(NSString *)filterName filterIndex:(NSInteger)filterIndex {
    NSString *path = [self.imageNamePath stringByAppendingPathComponent:filterName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // output png
    NSString *pngPath = [path stringByAppendingPathComponent:@"thumb.png"];
    // Write image to PNG
    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    
    
//    // output jpg
//    NSString  *jpgPath = [path stringByAppendingPathComponent:@"thumb.png"];
//    // Write a UIImage to JPEG with minimum compression (best quality)
//    // The value 'image' must be a UIImage object
//    // The value '1.0' represents image compression quality as value from 0.0 to 1.0
//    [UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];
    
    // copy filter colorImage to sandbox
    NSDictionary *filterInfoDic = self.filtersArray[filterIndex];
    NSString *colorImagePath = [filterInfoDic objectForKey:@"colorImagePath"];
    [self copyMissingFile:colorImagePath toPath:path];
}

/**
 *    @brief     copy colorFilter filter.png to sandbox
 *
 *    @param     sourcePath colorFilter filter.png path
 *    @param     toPath     des path
 *
 *    @return    BOOL
 */
- (BOOL)copyMissingFile:(NSString *)sourcePath toPath:(NSString *)toPath {
    BOOL retVal = YES; // If the file already exists, we'll return success…
    NSString * finalLocation = [toPath stringByAppendingPathComponent:[sourcePath lastPathComponent]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:finalLocation]) {
        retVal = [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:finalLocation error:NULL];
    }
    return retVal;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // use UIImagePickerControllerMediaType to judge photo or video
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        // OriginalImage
        UIImage* original = [info objectForKey:UIImagePickerControllerOriginalImage];
        // EditedImage
        UIImage* edit = [info objectForKey:UIImagePickerControllerEditedImage];
        // CropRect
        UIImage* crop = [info objectForKey:UIImagePickerControllerCropRect];
        // MediaURL
        NSURL* url = [info objectForKey:UIImagePickerControllerMediaURL];
        // get the metadata of photo
        NSDictionary* metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];

        self.image = [self fixOrientation:original];
        self.imageView.image = original;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

#pragma mark -- limit orientation
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

#pragma mark -- hide status bar
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark -
- (void)dealloc {

}

@end

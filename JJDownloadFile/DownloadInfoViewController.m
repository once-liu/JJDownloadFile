//
//  DownloadInfoViewController.m
//  JJDownloadFile
//
//  Created by melot on 2020/12/23.
//

#import "DownloadInfoViewController.h"

@interface DownloadInfoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;


@end

@implementation DownloadInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.progress.progress = 0.;
}

- (IBAction)downloadAction:(id)sender {
    
}

- (IBAction)cancelAction:(id)sender {
}

- (IBAction)resumeAction:(id)sender {
}


//MARK: - 小文件下载

- (void)downloadWithData {
    NSURL *URL = [NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/1510019-98355f5a157ae6ab.png?imageMogr2/auto-orient/strip|imageView2/2/w/525"];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    
    if (data) {
        self.imageView.image = [UIImage imageWithData:data];
    }
}

@end

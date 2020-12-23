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
    [self downloadWithURLSession];
}

- (IBAction)cancelAction:(id)sender {
}

- (IBAction)resumeAction:(id)sender {
}


//MARK: - 小文件下载

// 无效！dataWithContentsOfURL 取的是本地的文件路径
- (void)downloadWithData {
    NSURL *URL = [NSURL URLWithString:@"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fa1.att.hudong.com%2F62%2F02%2F01300542526392139955025309984.jpg&refer=http%3A%2F%2Fa1.att.hudong.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1611303346&t=b7d45536af3efcec7ea28ac59c63c407"];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    
    if (data) {
        self.imageView.image = [UIImage imageWithData:data];
    }
}

- (void)downloadWithURLConnection {
    NSURL *URL = [NSURL URLWithString:@"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fa1.att.hudong.com%2F62%2F02%2F01300542526392139955025309984.jpg&refer=http%3A%2F%2Fa1.att.hudong.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1611303346&t=b7d45536af3efcec7ea28ac59c63c407"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSLog(@" response: %@, error: %@", response, connectionError);
        if (data) {
            self.imageView.image = [UIImage imageWithData:data];
        }
    }];
}

- (void)downloadWithURLSession {
    NSURL *URL = [NSURL URLWithString:@"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fa1.att.hudong.com%2F62%2F02%2F01300542526392139955025309984.jpg&refer=http%3A%2F%2Fa1.att.hudong.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1611303346&t=b7d45536af3efcec7ea28ac59c63c407"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@" response: %@, error: %@", response, error);
        if (data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = [UIImage imageWithData:data];
            });
        }
    }];
    [dataTask resume];
}


//MARK: - 大文件






@end

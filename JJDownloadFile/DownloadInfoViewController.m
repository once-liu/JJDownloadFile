//
//  DownloadInfoViewController.m
//  JJDownloadFile
//
//  Created by melot on 2020/12/23.
//

#import "DownloadInfoViewController.h"

@interface DownloadInfoViewController () <NSURLConnectionDataDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, assign) NSInteger totalLength, currentLength;
@property (nonatomic, strong) NSFileHandle *fileHandle;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *resumeData;

@end

@implementation DownloadInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.progress.progress = 0.;
    
    self.totalLength = 0;
    self.currentLength = 0;
}

- (IBAction)downloadAction:(id)sender {
    [self downloadBigFileWtihURLSessionDelegate];
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

- (void)downloadBigFileWtihURLConnection {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentFilePath stringByAppendingPathComponent:@"boxue.mp4"];
    
    NSLog(@" filePath: %@", filePath);
    NSInteger currentLength = [self fileLengthForPath:filePath];
    if (currentLength) {
        self.currentLength = currentLength;
        NSLog(@" currentLength: %ld", currentLength);
    }
    
    
    NSURL *URL = [NSURL URLWithString:@"https://free-video.boxueio.com/ConstantAndVariable_Swift3-9781ed6f7bec16a5b48ea466496cfacd.mp4"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    if (self.currentLength) {
        NSString *range = [NSString stringWithFormat:@"bytes=%ld-", self.currentLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
    }
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
}

- (void)suspendDownloadBigFileWtihURLConnection {
    [self.connection cancel];
    self.connection = nil;
}


- (NSInteger)fileLengthForPath:(NSString *)filePath {
    NSInteger fileLength = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error = nil;
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:filePath error:&error];
        if (!error && fileDic) {
            fileLength = [fileDic fileSize];
        }
    }
    return fileLength;
}


//MARK: - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@" %s", __func__);
    
    self.totalLength = response.expectedContentLength;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentFilePath stringByAppendingPathComponent:@"boxue.mp4"];
    
    NSLog(@" filePath: %@", filePath);
    
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // 如果使用 NSMutableData 拼接 data。可能会使内存过大导致 OOM。
    
    // 指定数据的写入位置 -- 文件内容的最后面
    [self.fileHandle seekToEndOfFile];
    // 向沙盒写入数据
    [self.fileHandle writeData:data];
    
    self.currentLength += data.length;
    
    self.progress.progress = self.currentLength * 1.0 / self.totalLength;
    NSLog(@" currentProgress: %ld, progress: %f", self.currentLength, self.progress.progress);
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    NSLog(@" %s", __func__);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@" %s", __func__);
    
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    
    self.currentLength = 0;
    self.totalLength = 0;
}


- (void)downloadBigFileWtihURLSessionBlock {
    // 这种下载方式不能获取 progress
    NSURL *URL = [NSURL URLWithString:@"https://free-video.boxueio.com/ConstantAndVariable_Swift3-9781ed6f7bec16a5b48ea466496cfacd.mp4"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@" location: %@", location);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *filePath = [documentFilePath stringByAppendingPathComponent:@"boxue.mp4"];
        
        [fileManager moveItemAtPath:location.path toPath:filePath error:nil];
    }];
    [downloadTask resume];
}

- (void)downloadBigFileWtihURLSessionDelegate {
    NSURL *URL = [NSURL URLWithString:@"https://free-video.boxueio.com/ConstantAndVariable_Swift3-9781ed6f7bec16a5b48ea466496cfacd.mp4"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:URL];
    [downloadTask resume];
    self.downloadTask = downloadTask;
}



//MARK: - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@" location: %@", location);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentFilePath stringByAppendingPathComponent:@"boxue.mp4"];
    NSLog(@" filePath: %@", filePath);
    
    [fileManager moveItemAtPath:location.path toPath:filePath error:nil];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    self.progress.progress = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
}



@end

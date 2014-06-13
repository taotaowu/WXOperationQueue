//
//  MyTableViewControl.m
//  WXOptionQueue
//
//  Created by 吴海涛 on 14-6-12.
//  Copyright (c) 2014年 吴海涛. All rights reserved.
//

#import "MyTableViewControl.h"
#import <AFNetworking.h>

@interface MyTableViewControl ()

@end

@implementation MyTableViewControl
@synthesize pendingOperations = _pendingOperations;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Lazy instantiation 
// 2 
- (NSMutableArray *)photos
{
    if(!_photos) 
    {
        //1
        NSURL *dataSourceURL = [NSURL URLWithString:kDatasourceURLString];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:dataSourceURL];
//        _photos = [NSDictionary dictionaryWithContentsOfURL:dataSourceURL];
        //2
        AFHTTPRequestOperation *dataSource_download_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        //3
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        //4
        [dataSource_download_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            //5
            NSData *dataSource_data = (NSData*)responseObject;
            CFPropertyListRef plist = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (__bridge CFDataRef)dataSource_data, kCFPropertyListImmutable, NULL);
            NSDictionary *datasourc_dictionary = (__bridge  NSDictionary*)plist;
            //6
            NSMutableArray *records = [NSMutableArray array];
            for(NSString *key in datasourc_dictionary)
            {
                PhotoRecord *record = [[PhotoRecord alloc] init];
                record.URL = [NSURL URLWithString:[datasourc_dictionary objectForKey:key]];
                record.name = key;
                [records addObject:record];
                record = nil;
            }
            //7
            self.photos = records;
            CFRelease(plist);
            [self.tableView reloadData];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            //8
            //connection error message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            alert = nil;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        //9
        [self.pendingOperations.downloadQueue addOperation:dataSource_download_operation];
        
    }
    return _photos;
}


- (PendingOptions *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOptions alloc] init];
    }
    return _pendingOperations;
}

#pragma mark view lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.tableView.rowHeight = 80.0;
}

- (void)viewDidUnload
{
    [self setPhotos:nil];
    [super viewDidUnload];
}


- (void)didReceiveMemoryWarning
{
    [self cancelAllOperations];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    NSInteger numberOfData = self.photos.count;
    return  numberOfData;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kCellIdentifier = @"Cell Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //1
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = activityIndicatorView;
    }
    //2
    PhotoRecord *aRecord = [self.photos objectAtIndex:indexPath.row];
    //3
    if(aRecord.hasImage)
    {
        [((UIActivityIndicatorView*)cell.accessoryView) stopAnimating];
        cell.imageView.image = aRecord.image;
        cell.textLabel.text = aRecord.name;
    }else if(aRecord.isFailed)
    {
        //4
        [((UIActivityIndicatorView*)cell.accessoryView) stopAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Failed.png"];
        cell.textLabel.text = @"Fail to load";
    }else
    {
        //5
        [((UIActivityIndicatorView*)cell.accessoryView) startAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        cell.textLabel.text = @"";
        [self startOperationForPhotosRecord:aRecord atIndexPath:indexPath];
    }
    if(!tableView.dragging && !tableView.decelerating)
    {
        [self startOperationForPhotosRecord:aRecord atIndexPath:indexPath];
    }
    
    return cell;
}
//private method
//1
- (void) startOperationForPhotosRecord:(PhotoRecord*)aRecord atIndexPath:(NSIndexPath*)indexPath
{
    //2
    if(!aRecord.hasImage)
    {
        //3
        [self startImageDownloadingForeRecord:aRecord atIndexPath:indexPath];
    }
    if(!aRecord.isFailed)
    {
        [self startImageFiltrationForRecord:aRecord atIndexPath:indexPath];
    }
}

- (void)startImageDownloadingForeRecord:(PhotoRecord*)record atIndexPath:(NSIndexPath*)indexPath
{
    //1First, check for the particular indexPath to see if there is already an operation in downloadsInProgress for it. If so, ignore it.
    if(![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath])
    {
        //2 start downloading If not, create an instance of ImageDownloader by using the designated initializer, and set ListViewController as the delegate. Pass in the appropriate indexPath and a pointer to the instance of PhotoRecord, and then add it to the download queue. You also add it to downloadsInProgress to help keep track of things.
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
}
- (void)startImageFiltrationForRecord:(PhotoRecord*)record atIndexPath:(NSIndexPath*)indexPath
{
    //3Similarly, check to see if there is any filtering operations going on for the particular indexPath.
    if(![self.pendingOperations.filtrationsInProgress.allKeys containsObject:indexPath])
    {
        //4 Start filtration If not, start one by using the designated initializer.

        ImageFiltration *imageFiltration = [[ImageFiltration alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        //5 This one is a little tricky. You first must check to see if this particular indexPath has a pending download; if so, you make this filtering operation dependent on that. Otherwise, you don’t need dependency.
        ImageDownloader *dependency = [self.pendingOperations.downloadsInProgress objectForKey:indexPath];
        if(dependency)
        {
            [imageFiltration addDependency:dependency];
        }
        [self.pendingOperations.filtrationsInProgress setObject:imageFiltration forKey:indexPath];
        [self.pendingOperations.filtrationQueue addOperation:imageFiltration];
    }
}


#pragma mark - image filteration
//10
- (UIImage*) applySepiaFilterToImage:(UIImage*)unfilterImage
{
    CIImage *inputImage = [CIImage imageWithData:UIImagePNGRepresentation(unfilterImage)];
    UIImage *sepiaImage = nil;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey,inputImage,@"inputIntensity",[NSNumber numberWithFloat:0.8], nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef outputImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
    sepiaImage = [UIImage imageWithCGImage:outputImageRef];
    CGImageRelease(outputImageRef);
    return sepiaImage;
    
}
#pragma mark implement protocol
- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader
{
    //1
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    //2
    PhotoRecord *theRecord = downloader.photoRecord;
    //3
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //4
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
    
}
- (void)imageFiltrationDidFinish:(ImageFiltration *)filtration
{
    NSIndexPath *indexPath = filtration.indexPathInTableView;
    PhotoRecord *theRecord = filtration.photoRecord;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.pendingOperations.filtrationsInProgress removeObjectForKey:indexPath];
}

#pragma mark -
#pragma mark - UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //
    [self suspendAllOperations];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
    {
        //2
        [self loadImageForOnScreenCells];
        [self resumeAllOperations];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //3
    [self loadImageForOnScreenCells];
    [self resumeAllOperations];
}

#pragma mark -
#pragma mark- Cancelling , suspending, resuming queues/ operations
- (void)suspendAllOperations
{
    [self.pendingOperations.downloadQueue setSuspended:YES];
    [self.pendingOperations.filtrationQueue setSuspended:YES];
    
}

- (void)resumeAllOperations
{
    [self.pendingOperations.downloadQueue setSuspended:NO];
    [self.pendingOperations.filtrationQueue setSuspended:NO];
}

- (void)cancelAllOperations
{
    [self.pendingOperations.downloadQueue cancelAllOperations];
    [self.pendingOperations.filtrationQueue cancelAllOperations];
}

- (void)loadImageForOnScreenCells
{
    //1
    NSSet *visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
    //2
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.pendingOperations.downloadsInProgress allKeys]];
    [pendingOperations addObjectsFromArray:[self.pendingOperations.filtrationsInProgress allKeys]];
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    //3
    [toBeStarted minusSet:pendingOperations];
    //4
    [toBeCancelled minusSet:visibleRows];
    // 5
    for (NSIndexPath *anIndexPath in toBeCancelled) {
        
        ImageDownloader *pendingDownload = [self.pendingOperations.downloadsInProgress objectForKey:anIndexPath];
        [pendingDownload cancel];
        [self.pendingOperations.downloadsInProgress removeObjectForKey:anIndexPath];
        
        ImageFiltration *pendingFiltration = [self.pendingOperations.filtrationsInProgress objectForKey:anIndexPath];
        [pendingFiltration cancel];
        [self.pendingOperations.filtrationsInProgress removeObjectForKey:anIndexPath];
    }
    toBeCancelled = nil;
    
    // 6
    for (NSIndexPath *anIndexPath in toBeStarted) {
        
        PhotoRecord *recordToProcess = [self.photos objectAtIndex:anIndexPath.row];
        [self startOperationForPhotosRecord:recordToProcess atIndexPath:anIndexPath];
    }
    toBeStarted = nil;
    
    
}



- (UIStatusBarStyle)preferredStatusBarStyle
{
    NSLog(@"change status bar style");
    return UIStatusBarStyleLightContent;
}










@end

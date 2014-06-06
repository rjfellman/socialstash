//
//  DetailViewController.m
//  SocialStash
//
//  Created by Russ Fellman on 9/4/13.
//  Copyright (c) 2013 Russ Fellman. All rights reserved.
//

#import "DetailViewController.h"



@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    self.title = [[self.detailItem valueForKey:@"title"] description];

    if (self.detailItem) {
        [self.detailDescriptionLabel setText:[[self.detailItem valueForKey:@"title"] description]];
        [self.bodyTextView.layer setCornerRadius:5];
        [self.bodyTextView.layer setBorderWidth:0.5];
        [self.bodyTextView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        self.bodyTextView.text = [[self.detailItem valueForKey:@"body"] description];
        [self.bodyTextView sizeToFit];
        self.linkLabel.text = [[self.detailItem valueForKey:@"link"] description];
        self.attachedImageView.image = [UIImage imageWithData:[self.detailItem valueForKey:@"attachedImage"]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        NSString *date = [formatter stringFromDate:[self.detailItem valueForKey:@"creationDate"]];
        self.dateLabel.text = [NSString stringWithFormat:@"Created on: %@",date];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    self.tracker = [[GAI sharedInstance] defaultTracker];
    self.canDisplayBannerAds = YES;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[GAI sharedInstance] dispatch];
}

- (IBAction)share:(id)sender{
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc]
                                       initWithTitle:nil
                                       delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                       otherButtonTitles:@"Facebook", @"Twitter", @"Instagram", @"Email", @"Text", nil];
    [shareActionSheet showInView:self.view];
}

- (void)postToFacebook{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *facebookComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        facebookComposer.completionHandler = ^(SLComposeViewControllerResult result) {
            switch(result) {
                    //  This means the user cancelled without sending the Tweet
                case SLComposeViewControllerResultCancelled:
                    [self.tracker send:[NSDictionary dictionaryWithObjects:@[@"cancelled facebook post"] forKeys:@[@"facebooks_sent"]]];
                    break;
                    //  This means the user hit 'Send'
                case SLComposeViewControllerResultDone:
                    [self.tracker send:[NSDictionary dictionaryWithObjects:@[@"sent facebook post"] forKeys:@[@"facebooks_sent"]]];
                    break;
            }
        };
        [facebookComposer setInitialText:[NSString stringWithFormat:@"%@",[self.detailItem valueForKey:@"body"]]];
        [facebookComposer addURL:[NSURL URLWithString:self.linkLabel.text]];
        [facebookComposer addImage:self.attachedImageView.image];
        //[facebookComposer addURL:[self.detailItem valueForKey:@"link"]];
        [self presentViewController:facebookComposer animated:YES completion:nil];
    }
    else{
        NSLog(@"Service Unavailable");
        [self.tracker send:[NSDictionary dictionaryWithObjects:@[@"facebook unavailable"] forKeys:@[@"setup"]]];
        [[[UIAlertView alloc] initWithTitle:@"Facebook Unavailable" message:@"Please sign into Facebook in iOS settings to post to your account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
}

- (void)postToTwitter{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *twitterComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        twitterComposer.completionHandler = ^(SLComposeViewControllerResult result) {
            switch(result) {
                    //  This means the user cancelled without sending the Tweet
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Cancelled Post!");
                    [self.tracker send:[NSDictionary dictionaryWithObjects:@[@"canceled tweet"] forKeys:@[@"tweets_sent"]]];
                    break;
                    //  This means the user hit 'Send'
                case SLComposeViewControllerResultDone:
                    NSLog(@"Posted Successfully!");
                    [self.tracker send:[NSDictionary dictionaryWithObjects:@[@"sent tweet"] forKeys:@[@"tweets_sent"]]];
                    break;
            }
        };
        [twitterComposer setInitialText:[self.detailItem valueForKey:@"body"]];
        [twitterComposer addImage:self.attachedImageView.image];
        [twitterComposer addURL:[self.detailItem valueForKey:@"link"]];
        [self presentViewController:twitterComposer animated:YES completion:nil];
    }
    else{
        NSLog(@"Service Unavailable");
        [self.tracker send:[NSDictionary dictionaryWithObjects:@[@"twitter unavailable"] forKeys:@[@"setup"]]];
        [[[UIAlertView alloc] initWithTitle:@"Twitter Unavailable" message:@"Please sign into Twitter in iOS settings to post to your account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
}

- (void)postToInstagram{
    NSLog(@"Post to instagram");
    
    CGRect rect = CGRectMake(0 ,0 , 0, 0);
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIGraphicsEndImageContext();
    [self saveImage:self.attachedImageView.image withFileName:@"test" ofType:@"igo" inDirectory:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.igo"];
    
    NSURL *igImageHookFile = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"file://%@", jpgPath]];
    self.dic = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
    self.dic=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
    self.dic.UTI = @"com.instagram.photo";
    self.dic.annotation = @{@"InstagramCaption": [NSString stringWithFormat:@"%@ #socialstash", self.bodyTextView.text]};
    [self.dic presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
    
    [self.tracker send:[NSDictionary dictionaryWithObjects:@[@"shared with instagram"] forKeys:@[@"instagrams"]]];
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"igo"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"igo"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
    
}

- (void)sendInEmail{
    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
    [mail setSubject:@"One of my stashed posts from SocialStash"];
    [mail setMessageBody:[NSString stringWithFormat:@"%@\n\n\nSent from SocialStash v2.0",self.bodyTextView.text] isHTML:NO];
    [mail setMailComposeDelegate:self];
    [self presentViewController:mail animated:YES completion:^{
        
    }];
}

- (void)sendInTextMessage{
    MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
    [message setBody:[NSString stringWithFormat:@"%@\n\n\nSent from SocialStash v2.0",self.bodyTextView.text]];
    [message setMessageComposeDelegate:self];
    [self presentViewController:message animated:YES completion:^{
        
    }];
}

#pragma mark MFMailComposeDelegate methods
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result == MFMailComposeResultSent) {
        NSLog(@"Sent an email!");
        [self.tracker send:[NSDictionary dictionaryWithObjects:@[@"sent email"] forKeys:@[@"emails_sent"]]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MFMessageComposeDelegate methods
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    if (result == MessageComposeResultSent) {
        NSLog(@"Sent a text!");
        [self.tracker send:[NSDictionary dictionaryWithObjects:@[@"sent text"] forKeys:@[@"texts_sent"]]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self postToFacebook];
            break;
        case 1:
            [self postToTwitter];
            break;
        case 2:
            [self postToInstagram];
            break;
        case 3:
            [self sendInEmail];
            break;
        case 4:
            [self sendInTextMessage];
            break;
            
        default:
            break;
    }
}

@end

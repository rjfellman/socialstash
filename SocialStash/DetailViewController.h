//
//  DetailViewController.h
//  SocialStash
//
//  Created by Russ Fellman on 9/4/13.
//  Copyright (c) 2013 Russ Fellman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "GAI.h"
#import <iAd/iAd.h>

@interface DetailViewController : UIViewController<MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate, ADBannerViewDelegate>

@property (strong, nonatomic) id detailItem;
@property (nonatomic, retain) UIDocumentInteractionController *dic;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (weak, nonatomic) IBOutlet UIImageView *attachedImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (atomic, assign) id<GAITracker> tracker;


- (IBAction)postToFacebook:(id)sender;
- (IBAction)postToTwitter:(id)sender;
- (IBAction)sendInEmail:(id)sender;
- (IBAction)sendInTextMessage:(id)sender;
- (IBAction)share:(id)sender;

@end

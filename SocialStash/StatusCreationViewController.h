//
//  StatusCreationViewController.h
//  SocialStash
//
//  Created by Russ Fellman on 9/4/13.
//  Copyright (c) 2013 Russ Fellman. All rights reserved.
//

#import "GAI.h"
#import <UIKit/UIKit.h>

@class StatusCreationViewController;

@protocol StatusCreationDelegate <NSObject>

-(void)statusDidFinishCreation:(StatusCreationViewController*)statusController;
-(void)statusDidCancel;
-(void)statusDidFinishEditing:(StatusCreationViewController *)statusController;

@end

@interface StatusCreationViewController : UIViewController<UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    BOOL keyboardIsShowing;
}
@property (strong, nonatomic) IBOutlet UIButton *attachedImageButton;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextField *bodyTextField;
@property (strong, nonatomic) IBOutlet UITextField *linkTextField;
@property (strong, nonatomic) IBOutlet UITextView *bodyTextView;

@property (nonatomic, assign) BOOL isEditingStatus;

@property (nonatomic, assign) id<StatusCreationDelegate> delegate;

@property (atomic, assign) id<GAITracker> tracker;

- (IBAction)cancelPressed:(id)sender;
- (IBAction)donePressed:(id)sender;
- (IBAction)attachImage:(id)sender;


@end

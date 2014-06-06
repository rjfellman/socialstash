//
//  StatusCreationViewController.m
//  SocialStash
//
//  Created by Russ Fellman on 9/4/13.
//  Copyright (c) 2013 Russ Fellman. All rights reserved.
//

#import "StatusCreationViewController.h"

@interface StatusCreationViewController ()

@end

@implementation StatusCreationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.bodyTextField setFrame:CGRectMake(self.bodyTextField.frame.origin.x, self.bodyTextField.frame.origin.y, self.bodyTextField.frame.size.width, 250)];
    [self.bodyTextView.layer setCornerRadius:5];
    [self.bodyTextView.layer setBorderWidth:0.5];
    [self.bodyTextView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.bodyTextView setTextColor:[UIColor lightGrayColor]];
    [self.bodyTextView setText:@"Body"];
    
    self.canDisplayBannerAds = YES;
    
    self.tracker = [[GAI sharedInstance] defaultTracker];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[GAI sharedInstance] dispatch];
}

-(void)toggleViewSlideForKeyboard{
    if (!keyboardIsShowing) {
        [UIView animateWithDuration:0.4 animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 100, self.view.frame.size.width, self.view.frame.size.height)];
        }];
        keyboardIsShowing = YES;
    }
    else{
        [UIView animateWithDuration:0.4 animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 100, self.view.frame.size.width, self.view.frame.size.height)];
        }];
        keyboardIsShowing = NO;
    }
}

- (IBAction)cancelPressed:(id)sender {
    [self.delegate statusDidCancel];
}

- (IBAction)donePressed:(id)sender {
    if ([self.bodyTextView.text isEqualToString:@"Body"] || [self.bodyTextView.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please fill out the body field for your new post." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
        [self.tracker send:[NSDictionary dictionaryWithObjects:@[@"forgot to add a body"] forKeys:@[@"post_creation"]]];
    }
    if (self.isEditingStatus) {
        [self.delegate statusDidFinishEditing:self];
    }
    else{
        if ([self.titleTextField.text isEqualToString:@""]) {
            [self.titleTextField setText:@"New Post"];
            [self.tracker send:[NSDictionary dictionaryWithObjects:@[@"forgot to add a title"] forKeys:@[@"post_creation"]]];
        }
        [self.delegate statusDidFinishCreation:self];
    }
    
}

- (IBAction)attachImage:(id)sender {
    UIActionSheet *imagePickerSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [imagePickerSheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSLog(@"Camera");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self.tracker send:[NSDictionary dictionaryWithObjects:@[@"picking an image from camera"] forKeys:@[@"post_creation"]]];
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    if (buttonIndex == 1) {
        NSLog(@"Photo Library");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self.tracker send:[NSDictionary dictionaryWithObjects:@[@"picking an image from gallery"] forKeys:@[@"post_creation"]]];
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

#pragma mark UIImagePickerViewControllerDelegate methods
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [self.attachedImageButton setImage:chosenImage forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.tracker send:[NSDictionary dictionaryWithObjects:@[@"attached an image"] forKeys:@[@"post_creation"]]];
}

#pragma mark UITextFieldDelegate methods
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (!keyboardIsShowing) {
        [self toggleViewSlideForKeyboard];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (keyboardIsShowing) {
        [self toggleViewSlideForKeyboard];
    }
    [textField resignFirstResponder];
    return NO;
}

#pragma mark UITextViewDelegate methods
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (!keyboardIsShowing) {
        [self toggleViewSlideForKeyboard];
    }
    if ([textView.text isEqualToString:@"Body"]) {
        [textView setText:@""];
        [textView setTextColor:[UIColor blackColor]];
    }
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [self resignFirstResponder];
    if ([textView.text isEqualToString:@""]) {
        [textView setText:@"Body"];
        [textView setTextColor:[UIColor lightGrayColor]];
    }

    return YES;
}

@end

//
//  GKAuthDialog.m
//  PostKit
//
//  Created by georgkitz on 9/1/10.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "GKAuthDialog.h"
#import "GKPostItem.h"
#import "SMGlobals.h"
#import  <QuartzCore/QuartzCore.h>

@interface GKAuthDialog(Private)
- (void)initToolbar;
@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation GKAuthDialog

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter

@synthesize delegate = mDelegate;
@synthesize tintColor = mTintColor;

- (GKPostItem *)item{
	return mItem;
}

- (void)setItem:(GKPostItem *)value{
	SMSaveRelease(mItem);
	mItem = [value retain];
	
	
	[mWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: mItem.authorizationURL]]];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

- (void)initToolbar{
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	if(mTintColor)
		toolbar.tintColor = mTintColor;
	UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	UIBarButtonItem *btn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeView)] autorelease];
	toolbar.items = [NSArray arrayWithObjects:flex, btn,  nil];
	
	[self addSubview:toolbar];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (id)init {
	if(self = [super initWithFrame:CGRectMake(0, 20, 320, 460)]) {
		// implement your init method
		
		self.backgroundColor = [UIColor whiteColor];
		
		mWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, 416)];
		[mWebView setDelegate:self];
		
		mIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		mIndicatorView.center = CGPointMake(160, 230);
		mIndicatorView.hidden = YES;
		[mIndicatorView startAnimating];
		
		[self initToolbar];
		
		[self addSubview:mWebView];
		[self addSubview:mIndicatorView];
	}
	return self;
}

- (void)show{
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
	
	[window addSubview:self];
	
	UIView *animationView = self;
	
	animationView.alpha = 0;
	animationView.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.20];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	animationView.alpha = 1.0;
	animationView.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (void)hide{
    UIView *animationView = self;
    animationView.transform = CGAffineTransformIdentity;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(splashOutFinished)];
    animationView.alpha = 0;
    animationView.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    [UIView commitAnimations];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

- (void)splashOutFinished{
	[self removeFromSuperview];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Actions

- (void)closeView{
	[mWebView stopLoading];
	[mDelegate authDialogCanceled:self];
	[self hide];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	// release your members
	mDelegate = nil;
	SMSaveRelease(mTintColor);
	SMSaveRelease(mItem);
	SMSaveRelease(mWebView);
	SMSaveRelease(mIndicatorView);
	[super dealloc];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
	mIndicatorView.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	mIndicatorView.hidden = YES;
}

@end
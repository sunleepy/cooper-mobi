//
//  LoginViewController.m
//  Cooper
//
//  Created by sunleepy on 12-7-4.
//  Copyright (c) 2012年 codesharp. All rights reserved.
//

#import "LoginViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"

static NSString *const kKeychainItemName = @"CooperKeychain";

@implementation LoginViewController

@synthesize textUsername;
@synthesize textPassword;
@synthesize loginTableView;
@synthesize delegate;
@synthesize btnLogin;
@synthesize btnGoogleLogin;
@synthesize btnSkip;
#ifdef __ALI_VERSION__
@synthesize domainLabel;
#endif
@synthesize auth = mAuth;

#pragma mark - UI相关

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* login_btn_text = [[[SysConfig instance] keyValue] objectForKey:@"login_btn_text"];
    NSString* skip_btn_text = [[[SysConfig instance] keyValue] objectForKey:@"skip_btn_text"];
    NSString* googlelogin_btn_text = [[[SysConfig instance] keyValue] objectForKey:@"googlelogin_btn_text"];
    
#ifndef __ALI_VERSION__
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, 100, 30)];
    label1.text = @"没有账号？";
    label1.backgroundColor = [UIColor clearColor];
    label1.textColor = [UIColor grayColor];
    label1.font = [UIFont boldSystemFontOfSize:16.0f];
    [self.view addSubview:label1];
    [label1 release];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 210, 50, 30)];
    label2.text = @"请到";
    label2.backgroundColor = [UIColor clearColor];
    label2.textColor = [UIColor grayColor];
    label2.font = [UIFont boldSystemFontOfSize:16.0f];
    [self.view addSubview:label2];
    [label2 release];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(60, 210, 100, 30)];
    label3.text = @"incooper.net";
    label3.backgroundColor = [UIColor clearColor];
    label3.textColor = APP_BACKGROUNDCOLOR;
    label3.font = [UIFont boldSystemFontOfSize:16.0f];
    [self.view addSubview:label3];
    [label3 release];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(160, 210, 100, 30)];
    label4.text = @"注册！";
    label4.backgroundColor = [UIColor clearColor];
    label4.textColor = [UIColor grayColor];
    label4.font = [UIFont boldSystemFontOfSize:16.0f];
    [self.view addSubview:label4];
    [label4 release];
#endif
    
    //登录View
    self.loginTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:APP_BACKGROUNDIMAGE]];
    self.loginTableView.allowsSelection = NO;
    CGRect rect = self.loginTableView.frame;
    self.loginTableView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 120);
    self.loginTableView.delegate = self;
    self.loginTableView.dataSource = self;
    
    //登录按钮
    self.btnLogin = [[CustomButton alloc] initWithFrame:CGRectMake(160, 250, 70, 40) 
                                                  image:[UIImage imageNamed:@"btn_center.png"]];
    self.btnLogin.layer.cornerRadius = 10.0f;
    self.btnLogin.layer.masksToBounds = YES;
    [self.btnLogin addTarget:self 
                      action:@selector(login) 
            forControlEvents:UIControlEventTouchUpInside];
    [self.btnLogin setTitle:login_btn_text 
                   forState:UIControlStateNormal];
    self.btnLogin.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:self.btnLogin];
    
    //跳过按钮
    self.btnSkip = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.btnSkip.frame = CGRectMake(240, 250, 70, 40);
    self.btnSkip.layer.cornerRadius = 6.0f;
    self.btnSkip.layer.masksToBounds = YES;
    [self.btnSkip addTarget:self 
                     action:@selector(skip) 
           forControlEvents:UIControlEventTouchUpInside];
    [self.btnSkip setTitle:skip_btn_text 
                  forState:UIControlStateNormal];
    self.btnSkip.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:self.btnSkip];
    
    //使用谷歌登录
    self.btnGoogleLogin = [[CustomButton alloc] initWithFrame:CGRectMake(10, 250, 140, 40) 
                                                        image:[UIImage imageNamed:@"btn_center.png"]];
    self.btnGoogleLogin.layer.cornerRadius = 10.0f;
    self.btnGoogleLogin.layer.masksToBounds = YES;
    [self.btnGoogleLogin addTarget:self 
                            action:@selector(googleLogin) 
                  forControlEvents:UIControlEventTouchUpInside];
    [self.btnGoogleLogin setTitle:googlelogin_btn_text 
                         forState:UIControlStateNormal];
    self.btnGoogleLogin.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:self.btnGoogleLogin];
    
    //google oauth相关初始化
    googleClientId = [[[SysConfig instance] keyValue] objectForKey:@"googleClientId"];
    googleClientSecret = [[[SysConfig instance] keyValue] objectForKey:@"googleClientSecret"];
    
    GTMOAuth2Authentication *auth = nil;
    
    auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName 
                                                                 clientID:googleClientId
                                                             clientSecret:googleClientSecret];
    
    NSLog(@"persistenceResponseString:%@ \r\n serviceProvider:%@ \r\n userEmail:%@ \r\n accessToken:%@ \r\n expirationDate:%@ \r\n refreshToken:%@ \r\n code:%@ \r\n error:%@"
          , auth.persistenceResponseString
          , auth.serviceProvider
          , auth.userEmail
          , auth.accessToken
          , [auth.expirationDate description]
          , auth.refreshToken
          , auth.code
          , auth.errorString);
    self.auth = auth;
    
    if (auth.canAuthorize) {
        NSLog(@"auth success!");
    } else {
        NSLog(@"auth failed!");
    }
    
    //    [AccountService googleLogin:@"" code:@"4/7XphY2aqMy36JCy4BTFAdxgF3wKq.wne-l9DssfccuJJVnL49Cc--C5P3cQI" refreshToken:@"" state:@"login" mobi:@"true" delegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
}

-(IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}

- (void)dealloc 
{
#ifdef __ALI_VERSION__
    [self.domainLabel release];
#endif
    [textUsername release];
    [textPassword release];
    [loginTableView release];
    [btnLogin release];
    [btnGoogleLogin release];
    RELEASE(self.btnSkip);
    [mAuth release];
    [super dealloc];
}

#pragma mark - 触发自定义事件

- (void)googleLogin
{
    NSLog(@"进入google oauth登录页面");
    
    [self signOut];
    
    NSString *scope = [[[SysConfig instance] keyValue] objectForKey:@"googleScope"];
    
    NSString *keychainItemName  = kKeychainItemName;
    
    SEL finishedSel = @selector(viewController:finishedWithAuth:error:);
    
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:scope
                                                              clientID:googleClientId
                                                          clientSecret:googleClientSecret
                                                      keychainItemName:keychainItemName
                                                              delegate:self
                                                      finishedSelector:finishedSel];
    
    NSString *html = @"<html><body bgcolor=white><div align=center>正在进入google登录页面...</div></body></html>";
    viewController.initialHTMLString = html;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)signOut 
{
    if ([self.auth.serviceProvider isEqual:kGTMOAuth2ServiceProviderGoogle]) {
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
    }
    
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    
    self.auth = nil;
}

- (void)login 
{
#ifdef __ALI_VERSION__
    if (self.domainLabel.text.length > 0 
        && self.textUsername.text.length > 0
        && self.textPassword.text.length > 0) 
#else
        if(self.textUsername.text.length > 0
           && self.textPassword.text.length > 0)
#endif
        {
            //HUD = [Tools process:@"登录中" view:self.view];
            //[Tools showHUD:@"登录中" HUD:HUD];
            [Tools showHUD:@"登录中" view:self.view HUD:HUD];
            requestType = LoginValue;
#ifdef __ALI_VERSION__
            [AccountService login:self.domainLabel.text 
                         username:self.textUsername.text 
                         password:self.textPassword.text 
                         delegate:self];
#else
            [AccountService login:self.textUsername.text
                         password:self.textPassword.text
                         delegate:self];
#endif
        }
        else 
        {
            [Tools alert:@"请输入用户名和密码"];
        }
}

- (void)skip
{
    //    requestType = GoogleLoginValue;
    //    [AccountService googleLogin:@"" code:@"4/-s8utkRJ-3-zRzgIq54tYGSdcxg1.giR6or0tRtscuJJVnL49Cc9ifIjrcQI" state:@"login" delegate:self];
    //    
    //自动保存用户登录
    [[ConstantClass instance] setIsGuestUser:YES];
    [ConstantClass saveToCache];
    
    [self dismissModalViewControllerAnimated:NO];
    
    [delegate loginExit];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [Tools close:HUD];
    NSLog(@"请求响应数据: %@, %d"
          , [request responseString]
          , [request responseStatusCode]);
#ifdef __ALI_VERSION__
    if([request responseStatusCode] == 200 && [[request responseString] rangeOfString: @"window.opener.loginSuccess"].length > 0)
#else
        if([request responseStatusCode] == 200)
#endif
        {
            if(requestType == GoogleLoginValue)
            {
                NSArray* array = [request responseCookies];
                NSLog(@"array:%d",  array.count);
                
                NSDictionary *dict = [NSHTTPCookie requestHeaderFieldsWithCookies:array];
                NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:dict];
                NSHTTPCookieStorage *sharedHTTPCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                
                [sharedHTTPCookie setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
                [sharedHTTPCookie setCookie:cookie];
                
                [[ConstantClass instance] setUsername:self.auth.userEmail];
                [[ConstantClass instance] setIsGuestUser:YES];
                [ConstantClass saveToCache];
                
                [self dismissModalViewControllerAnimated:NO];
                
                [delegate loginExit]; 
            }
            else {
                NSArray* array = [request responseCookies];
                NSLog(@"array:%d",  array.count);
                
                NSDictionary *dict = [NSHTTPCookie requestHeaderFieldsWithCookies:array];
                NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:dict];
                NSHTTPCookieStorage *sharedHTTPCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                
                [sharedHTTPCookie setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
                [sharedHTTPCookie setCookie:cookie];
                
#ifdef __ALI_VERSION__
                [[ConstantClass instance] setDomain:self.domainLabel.text];
#endif
                [[ConstantClass instance] setUsername:self.textUsername.text];
                [[ConstantClass instance] setIsGuestUser:YES];
                [ConstantClass saveToCache];
                
                [self dismissModalViewControllerAnimated:NO];
                
                [delegate loginExit]; 
            }   
        }
        else if([request responseStatusCode] == 400)
        {
            [Tools alert:[request responseString]];
        }
        else
        {
            [Tools alert:@"用户名和密码不正确"];
        }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [Tools failed:HUD];
    NSLog(@"请求异常: %@",request.error);
}

- (void)addRequstToPool:(ASIHTTPRequest *)request
{
    NSLog(@"发送请求路径：%@",request.url);
}

#ifdef __ALI_VERSION__

# pragma mark - 域账号相关事件

- (void)tableViewCell:(DomainLabel *)label didEndEditingWithValue:(NSString *)value
{
    label.text = value;
}

- (void)selectDomain
{
    [domainLabel becomeFirstResponder];
}

#endif

# pragma mark - 登录TableView相关的委托事件

//获取TableView的分区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//获取在制定的分区编号下的纪录数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#ifdef __ALI_VERSION__
    return 3;
#else
    return 2;
#endif
}
//填充单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    NSString *identifier = @"BaseCell";
#ifdef __ALI_VERSION__
    if(indexPath.row == 0)
    {
        //创建域Cell
        identifier = @"DomainCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell)
            cell = [self createDomainCell:identifier];
    }
    else if(indexPath.row == 1)
    {
        //创建用户名Cell
        identifier = @"UsernameCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell)
            cell = [self createUsernameCell:identifier];   
    }
    else if(indexPath.row == 2)
    {
        //创建密码Cell
        identifier = @"PasswordCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell)
            cell = [self createPasswordCell:identifier];  
    }   
#else
    if(indexPath.row == 0)
    {
        //创建用户名Cell
        identifier = @"UsernameCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell)
            cell = [self createUsernameCell:identifier];  
    }
    else if(indexPath.row == 1)
    {
        //创建密码Cell
        identifier = @"PasswordCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell)
            cell = [self createPasswordCell:identifier]; 
    }
#endif
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.0f;
}

- (UITableViewCell*)createDomainCell:(NSString*)identifier
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    
#ifdef __ALI_VERSION__
    domainLabel = [[DomainLabel alloc] initWithFrame:CGRectMake(0, 0, 210, 30)];
    domainLabel.text = DEFAULT_DOMAIN;
    [domainLabel setBackgroundColor:[UIColor clearColor]];
    domainLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *recoginzer = [[UITapGestureRecognizer alloc] 
                                          initWithTarget:self 
                                          action:@selector(selectDomain)];
    [domainLabel addGestureRecognizer:recoginzer];
    domainLabel.delegate = self;
    [recoginzer release];
    
    cell.textLabel.text = @"域名";
    cell.accessoryView = domainLabel;
#endif
    return cell;
}

- (UITableViewCell*)createUsernameCell:(NSString*)identifier
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UsernameCell"] autorelease];
    
    CGFloat width = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 660 : 285;
    self.textUsername = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, width, 20)];  
    
    [self.textUsername setPlaceholder:@"用户名"]; 
    [self.textUsername setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.textUsername setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.textUsername setReturnKeyType:UIReturnKeyDone];
    [self.textUsername addTarget:self action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    cell.accessoryView = self.textUsername;
    
    return cell;
}

- (UITableViewCell*)createPasswordCell:(NSString*)identifier
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"PasswordCell"] autorelease];
    
    CGFloat width = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 660 : 285;
    self.textPassword = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, width, 20)]; 
    [self.textPassword setSecureTextEntry:YES];
    [self.textPassword setPlaceholder:@"密码"];
    [self.textPassword setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.textPassword setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.textPassword setReturnKeyType:UIReturnKeyDone];
    [self.textPassword addTarget:self action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    cell.accessoryView = self.textPassword;
    return cell;
}

#pragma mark - google oauth相关
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authInfo
                 error:(NSError *)error 
{
    NSLog(@"finish!");
    if (error != nil) 
    {
        NSLog(@"应用程序异常: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"];
        if ([responseData length] > 0) 
        {
            NSString *str = [[[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding] autorelease];
            NSLog(@"%@", str);
        }
        
        [Tools msg:@"登录失败！请重新尝试！" HUD:HUD];
    }
    else 
    {
        if(authInfo)
        {
            NSLog(@"persistenceResponseString:%@ \r\n serviceProvider:%@ \r\n userEmail:%@ \r\n accessToken:%@ \r\n expirationDate:%@ \r\n refreshToken:%@ \r\n code:%@ \r\n            tokenTYpe:%@ \r\n error:%@"
                  , authInfo.persistenceResponseString
                  , authInfo.serviceProvider
                  , authInfo.userEmail
                  , authInfo.accessToken
                  , [authInfo.expirationDate description]
                  , authInfo.refreshToken
                  , authInfo.code
                  , authInfo.tokenType
                  , authInfo.errorString);
            
            self.auth = authInfo;
//            [Tools showHUD:@"登录中" view:self.view HUD:HUD];
//            requestType = GoogleLoginValue;
//            [AccountService googleLogin:@"" code:@"4/7XphY2aqMy36JCy4BTFAdxgF3wKq.wne-l9DssfccuJJVnL49Cc--C5P3cQI" refreshToken:self.auth.refreshToken state:@"login" mobi:@"true" delegate:self];
        }
    }
    
}

@end

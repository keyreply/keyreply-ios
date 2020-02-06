# KeyReply
[Version](http://cocoapods.org/pods/KeyReply)
[License](http://cocoapods.org/pods/KeyReply)
[Platform](http://cocoapods.org/pods/KeyReply)

## Example
Demo application is included in the `Example` folder. To run it, clone the repo, and run `pod install` from the Example directory first.

KeyReplySDK Demo

## Adding KeyReplySDK to your app

### CocoaPods
To install KeyReplyView using [CocoaPods](http://cocoapods.org), add the following line to your `Podfile`:

```ruby
pod 'KeyReply'
```

### Manual installation
You can also add this project:
* as git submodule
* simply download and copy source files to your project

## Requirements

* Xcode 8.0 or later
* iOS 8.0 or later

## Usage

### Interface Builder
KeyReplySDK can be added to your view controller via Interface Builder:
* Drop a regular UIView to your view controller
* Set its custom class as `KEYKeyReplyView` class
* Hook it up to an IBOutlet in your view controller code
* Perform intialization step detailed below

### Add KeyReplySDK programmatically
KeyReplySDK can be initialize programmatically like regular UIView:

```objective-c
CGRect chatFrame = CGRectMake(0, 0, 320, 480);
KEYKeyReplyView * keyReplyView = [[KEYKeyReplyView alloc] initWithFrame:chatFrame];
[self.view addSubview:keyReplyView];
keyReplyView.clientId = @"5f6cc7e4e2";
[keyReplyView reload];
```

### Initialization
To use KeyReplySDK, you will need a SERVER_URL to retrieve each respective bot.  Please obtain your own SERVER_URL from KeyReply representative directly.

KeyReplySDK will not automatically load its content. It is necessary to call `reload` function whenever you want to start using it. Normally it is done in `viewDidLoad` function, after all customisations options are provided.

```objective-c
[*self*.chatView setServerSetting:@"SERVER_URL"];
[keyReplyView reload];
```

## Customizations

### Collapse on load
By default, KeyReplySDK will show expanded UI on load. This can be disabled by:

```objective-c
keyReplyView.autoOpenOnStart = NO;
[keyReplyView reload];
```

### Appearance
All customization of appearance are to be done via KeyReply's web console.

## APIs
### Setting server url

`[keyReplyView setServerSetting:@"SERVER_URL"];`

### Setting env url (webview url)

`[keyReplyView setEnvUrl:@"ENV_URL"];` 

### Setting user settings
User settings must be of type  `NSMutableDictionary` . For example: 

```objective-c
NSMutableDictionary * userDict = [[NSMutableDictionary alloc] init];
[userDict setValue:@"bot1" forKey:@"name"];
[userDict setValue:@"123" forKey:@"id"];
[keyReplyView setUserSetting:(NSMutableDictionary)];
```

### Setting Token Generator settings
Token generator must be of type  `NSMutableDictionary` . For example: 

```objective-c
NSMutableDictionary * generator = [[NSMutableDictionary alloc] init];
[generator setValue:@"enpoint_for_token_generation" forKey:@"url"];
[generator setValue:@"GET/POST" forKey:@"method"];
[generator setValue:@"data.access_token" forKey:@"accessTokenPath"];
[keyReplyView setTokenGeneratorSetting:generator];
```

### Expand/Collapse/Toggle chat window

```objective-c
[keyReplyView openChatWindow];
[keyReplyView closeChatWindow];
[keyReplyView toggleChatWindow];
```

### Setting Resize Function

Have a selector function ready, copy and change the frame parameters accordingly:

```objective-c
- (void)chatWindowResize:(NSString *)toggle{
    if([toggle isEqualToString:@"true"]) {
        self.chatView.frame = self.chatViewFrame;
    }else {
        CGRect newFrame = CGRectMake(x,y,width,height);
        self.chatView.frame = newFrame;
    }
}
```
call this method in viewDidLoad method, like so:

```objective-c
[self.chatView setChatWindowResizeFunc:@selector(chatWindowResize:) fromObject:self];
```

**This function will be called inside openChatWindow and closeChatWindow functions**

### Setting Generate JWT Function

```objective-c
[self.chatView setGenerateJWTFunc:@selector(generateJWTFunc:) fromObject:self];
```
**This function will be called when JWT token passed in is invalid**

### initialize with JWT
Take in JWT token as a `NSSTRING`.

```objective-c
[keyReplyView setInitWithJWT:(JWTToken)];
```


### Send a chat message programmatically
Chat message can be sent via KeyReplySDK UI or done programmatically as followed:

```objective-c
[keyReplyView sendMessage:@"Hello world!"];
```

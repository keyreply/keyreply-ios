# KeyReply

[![Version](https://img.shields.io/cocoapods/v/KeyReply.svg?style=flat)](http://cocoapods.org/pods/KeyReply)
[![License](https://img.shields.io/cocoapods/l/KeyReply.svg?style=flat)](http://cocoapods.org/pods/KeyReply)
[![Platform](https://img.shields.io/cocoapods/p/KeyReply.svg?style=flat)](http://cocoapods.org/pods/KeyReply)


## Example

Demo application is included in the `Example` folder. To run it, clone the repo, and run `pod install` from the Example directory first.

![KeyReplySDK Demo](https://github.com/originallyus/keyreply-ios/blob/master/example_screenshot.png?raw=true)



## Adding KeyReplySDK to your app

### CocoaPods

To install StatusAlert using [CocoaPods](http://cocoapods.org), add the following line to your `Podfile`:

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

KeyReplySDK uses a default client ID out of the box for demo purpose. Please obtain your own Client ID from KeyReply reprensentative directly.

KeyReplySDK will not automatically load its content. It is neccessary to call `reload` function whenever you want to start using it. Normally it is done in `viewDidLoad` function, after all customizations options are provided.

```objective-c
keyReplyView.clientId = @"5f6cc7e4e2";
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



## Action

### Expand/Collapse/Toggle chat window

```objective-c
[keyReplyView openChatWindow];
[keyReplyView closeChatWindow];
[keyReplyView toggleChatWindow];
```

### Send a chat message programmatically

Chat message can be sent via KeyReplySDK UI or done programmatically as followed:

```objective-c
[keyReplyView sendMessage:@"Hello world!"];
```

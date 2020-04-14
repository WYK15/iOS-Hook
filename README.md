# HookSpringBoard
## MonkeyDev Hook SpringBoard And IOKit.  
This is a [MonkeyDev](https://github.com/AloneMonkey/MonkeyDev) Project which can Hook iOS SpringBoard and IOKit   
I Hooked `applicationDidFinishLaunching` and `frontDisplayDidChange` of SpringBoard    
I Hooked `IOHIDEventSystemClientDispatchEvent` of IOkit , And Functions in IOKit are C functions,so I use MSHookFunction（you can use [fishHook](https://github.com/facebook/fishhook) to Hook C functions also)   
And I Succeed on iOS 12.4  


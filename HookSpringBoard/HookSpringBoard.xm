// See http://iphonedevwiki.net/index.php/Logos

#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <dlfcn.h>
#import "IOHIDEvent.h"
#import "IOHIDEventSystem.h"
#import "IOHIDEventSystemClient.h"
#import "IOHIDUserDevice.h"
#import "IOHIDEventSystem.h"
#import "IOHIDEvent7.h"
#import "IOHIDEventTypes7.h"
#import "IOHIDEventSystemConnection.h"
#include <substrate.h>
#include <substrate.h>


static void writeFile(NSString* filepath,NSString* content,bool isNewOne)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
     NSString *path = filepath ? filepath : @"/tmp/tNew.txt" ;
    if (isNewOne || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:[@"" dataUsingEncoding: NSUTF8StringEncoding] attributes:nil];
    }
    NSFileHandle *fielHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
    [fielHandle seekToEndOfFile];  //将节点跳到文件的末尾
    NSData* stringData  = [ [content stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
    [fielHandle writeData:stringData]; //追加写入数据
}


/*
%hook SpringBoard


+ (id)sharedInstance
{
	%log;
    
    UIAlertView *alert = [[UIAlertView alloc]
    initWithTitle:@"这是Hook"
    message:nil
    delegate:self cancelButtonTitle:@"OK"
    otherButtonTitles:nil];
    [alert show];
    
	return %orig;
}

// 有效：但是好像不处理点击事件

-(BOOL)__handleHIDEvent:(IOHIDEventRef)arg1
{
    %orig;
    UIAlertView *alert = [[UIAlertView alloc]
    initWithTitle:[NSString stringWithFormat:@"%@",arg1]
    message:nil
    delegate:self cancelButtonTitle:@"OK"
    otherButtonTitles:nil];
    [alert show];
    %log;//打印参数信息self,_com,其他参数
}


-(void)frontDisplayDidChange:(id)arg1
{
    %orig;
    UIAlertView *alert = [[UIAlertView alloc]
    initWithTitle:@"you are hooked! display changed"
    message:nil
    delegate:self cancelButtonTitle:@"OK"
    otherButtonTitles:nil];
    [alert show];
}


-  (void)applicationDidFinishLaunching:(id)application
{
    %orig;
    UIAlertView *alert = [[UIAlertView alloc]
    initWithTitle:@"这是Hook"
    message:nil
    delegate:self cancelButtonTitle:@"OK"
    otherButtonTitles:nil];
    [alert show];
}

%end
*/


// IOHIDEventAppendEvent
/*
extern "C" void IOHIDEventAppendEvent(IOHIDEventRef event, IOHIDEventRef childEvent);

void (*old_AppendEvent)(IOHIDEventRef event, IOHIDEventRef childEvent);

void newIOEvent(IOHIDEventRef event, IOHIDEventRef childEvent)
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *eventInfo1 = [NSString stringWithFormat:@"%@",event];
    [fileManager createFileAtPath:@"/tmp/tt1.txt" contents:[eventInfo1 dataUsingEncoding: NSUTF8StringEncoding] attributes:nil];
     
    old_AppendEvent(event,childEvent);
    
    NSString *eventInfo = [NSString stringWithFormat:@"%@",event];
    [fileManager createFileAtPath:@"/tmp/tt2.txt" contents:[eventInfo dataUsingEncoding: NSUTF8StringEncoding] attributes:nil];
    
    NSString *addrInfoNew = [NSString stringWithFormat:@"new: %x",newIOEvent];
    NSString *addrInfoOld = [NSString stringWithFormat:@"old: %x",old_AppendEvent];
    [fileManager createFileAtPath:@"/tmp/addr.txt" contents:[[addrInfoOld stringByAppendingString:addrInfoNew] dataUsingEncoding: NSUTF8StringEncoding] attributes:nil];
    
    
    old_AppendEvent(event,childEvent);
    
    
    //创建文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = @"/tmp/tt.txt";
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:[@"" dataUsingEncoding: NSUTF8StringEncoding] attributes:nil];
    }
    
    NSFileHandle *fielHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
    
    [fielHandle seekToEndOfFile];  //将节点跳到文件的末尾

    NSString *str = [NSString stringWithFormat:@"%@",event];

    NSData* stringData  = [str dataUsingEncoding:NSUTF8StringEncoding];

    [fielHandle writeData:stringData]; //追加写入数据
    
}

%ctor
{
     MSHookFunction(&IOHIDEventAppendEvent,&newIOEvent,&old_AppendEvent);
    
    %init
}
*/


//MGCopyAnswer

extern "C" CFTypeRef MGCopyAnswer(CFStringRef prop);

static CFTypeRef (*orig_MGCopyAnswer)(CFStringRef prop, uint32_t* outTypeCode);

CFTypeRef new_MGCopyAnswer(CFStringRef prop, uint32_t* outTypeCode) {
    
    NSString *keyStr = (__bridge NSString*) prop;
    
    
    ////////////////////////////
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = @"/tmp/tChangeSerial.txt";
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:[@"" dataUsingEncoding: NSUTF8StringEncoding] attributes:nil];
    }
    NSFileHandle *fielHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
    [fielHandle seekToEndOfFile];  //将节点跳到文件的末尾
    NSData* stringData  = [ [keyStr stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
    [fielHandle writeData:stringData]; //追加写入数据
    ////////////////////////////
    
    
    if ([keyStr isEqualToString:@"ProductVersion"]) {
        NSString *updateNumber = @"8.1.2";
        CFTypeRef refNumber = (__bridge_retained CFTypeRef)updateNumber;
        return refNumber;
    }
    
    if ([keyStr isEqualToString:@"DeviceName"]) {
        NSString *updateNumber = @"HookedName";
        CFTypeRef refNumber = (__bridge_retained CFTypeRef)updateNumber;
        return refNumber;
    }
    
    if ([keyStr isEqualToString:@"VasUgeSzVyHdB27g2XpN0g"]) {
        NSString *updateNumber = @"KF1111111111";
        return (__bridge_retained CFTypeRef)updateNumber;
        
    }
    
    if ([keyStr isEqualToString:@"UserAssignedDeviceName"]) {
        NSString *updateNumber = @"lalalalala";
        return (__bridge_retained CFTypeRef)updateNumber;
    }
    
    return orig_MGCopyAnswer(prop, outTypeCode);
}


%ctor
{
//    MSHookFunction(&IOHIDEventAppendEvent,&newIOEvent,&old_AppendEvent);

    char *dylib_path = (char*)"/usr/lib/libMobileGestalt.dylib";
    void *h = dlopen(dylib_path,RTLD_GLOBAL);
    NSString *strDylibFile = @"/usr/lib/libMobileGestalt.dylib";
    if (h) {
        MSImageRef ref = MSGetImageByName([strDylibFile UTF8String]);
        void * MGCopyAnswerFn = MSFindSymbol(ref, "_MGCopyAnswer");
        MSHookFunction((void*)((uint8_t*)MGCopyAnswerFn + 8), (void*)new_MGCopyAnswer,
                    (void**)&orig_MGCopyAnswer);
    }
    
    
}




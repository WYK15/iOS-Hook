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
    
    
    writeFile(@"/tmp/AAMGCopys.txt",keyStr,NO);
    
    
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
    
    
    if ([keyStr isEqualToString:@"UserAssignedDeviceName"]) {
        NSString *updateNumber = @"Hook-lalalala";
        return (__bridge_retained CFTypeRef)updateNumber;
    }
    
    if ([keyStr isEqualToString:@"SerialNumber"]) {
        NSString *updateNumber = @"Hook-lalalala2";
        return (__bridge_retained CFTypeRef)updateNumber;
    }
    
    return orig_MGCopyAnswer(prop, outTypeCode);
}

//hook 扫描端口获取mac地址的方法
extern "C" CFDictionaryRef CNCopyCurrentNetworkInfo(CFStringRef interfaceName);
static CFDictionaryRef (*orig_CNCopyCurrentNetworkInfo)(CFStringRef interfaceName);
CFDictionaryRef new_CNCopyCurrentNetworkInfo(CFStringRef interfaceName) {
    NSString *keyStr = (__bridge NSString *)interfaceName;

    if ([keyStr isEqualToString:@"en0"] ){

        NSDictionary *oldDic = (__bridge NSDictionary*)orig_CNCopyCurrentNetworkInfo(interfaceName);
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:oldDic];

        [dic setValue:@"exchen" forKey:@"SSID"];
        [dic setValue:@"00:60:00:00:00:00" forKey:@"BSSID"];
        [dic setValue:[@"leowang" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"SSIDDATA"];

        return (__bridge CFDictionaryRef)dic;
    }
    else{
        return orig_CNCopyCurrentNetworkInfo(interfaceName);
    }
}

extern "C" void exit(int code);
static void (*origin_exit)(int code);
void new_exit(int code) {
    origin_exit(22);
}


%ctor
{
//    MSHookFunction(&IOHIDEventAppendEvent,&newIOEvent,&old_AppendEvent);

    char *dylib_path = (char*)"/usr/lib/libMobileGestalt.dylib";
    void *h = dlopen(dylib_path,RTLD_GLOBAL);
    NSString *strDylibFile = @"/usr/lib/libMobileGestalt.dylib";
    if (h) {
        MSImageRef ref = MSGetImageByName(dylib_path);
        void * MGCopyAnswerFn = MSFindSymbol(ref, "_MGCopyAnswer");
        MSHookFunction((void*)((uint8_t*)MGCopyAnswerFn + 8), (void*)new_MGCopyAnswer,
                    (void**)&orig_MGCopyAnswer);
    }
    
    MSHookFunction((void*)CNCopyCurrentNetworkInfo,(void*)new_CNCopyCurrentNetworkInfo,(void**)&orig_CNCopyCurrentNetworkInfo);
    
    MSHookFunction((void*)&exit,(void*)&new_exit,(void**)&origin_exit);
}


%hook UIDevice

-(NSString *)systemVersion
{
    NSDate *datenow = [NSDate date];
    NSString *data = [NSString stringWithFormat:@"%@",datenow];
    
    writeFile(@"/tmp/t3.txt",data,true);
    NSString *fakeVer = @"11.1.1";
    return fakeVer;
}

-(NSString *)localizedModel {
    return @"mmmmm";
}

-(NSString *)name {
    return @"mmmmm";
}

%end



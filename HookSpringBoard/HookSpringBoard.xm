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
#import <sys/sysctl.h>


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

extern "C" int isatty(int code);
extern "C" void exit(int code);
extern "C" int ioctl(int, unsigned long, ...);

extern "C" int ptrace(int _request, pid_t _pid, caddr_t _addr, int _data);
extern "C" void* dlsym(void* __handle, const char* __symbol);
extern "C" int sysctl(int * name, u_int namelen, void * info, size_t * infosize, void * newinfo, size_t newinfosize);
extern "C" int syscall(int, ...);



static int (*origin_isatty)(int code);
static void (*origin_exit)(int code);
static int (*origin_ioctl)(int code,unsigned long code2,...);

static int (*origin_ptrace)(int _request, pid_t _pid, caddr_t _addr, int _data);
static void* (*origin_dlsym)(void* __handle, const char* __symbol);
static int (*origin_sysctl)(int * name, u_int namelen, void * info, size_t * infosize, void * newinfo, size_t newinfosize);
static int (*origin_syscall)(int code, va_list args);

int new_isatty(int code) {
    return 0;
}

void new_exit(int code) {
    
}

int my_ptrace(int _request, pid_t _pid, caddr_t _addr, int _data){
    if(_request != 31){
        return origin_ptrace(_request,_pid,_addr,_data);
    }
    
    NSLog(@"tweak : [AntiAntiDebug] - ptrace request is PT_DENY_ATTACH");
    
    return 0;
}

void* my_dlsym(void* __handle, const char* __symbol){
    if(strcmp(__symbol, "ptrace") != 0){
        return origin_dlsym(__handle, __symbol);
    }
    
    NSLog(@"tweak : [AntiAntiDebug] - dlsym get ptrace symbol");
    
    return origin_dlsym(__handle,"open");
}

typedef struct kinfo_proc _kinfo_proc;

int my_sysctl(int * name, u_int namelen, void * info, size_t * infosize, void * newinfo, size_t newinfosize){
    if(namelen == 4 && name[0] == CTL_KERN && name[1] == KERN_PROC && name[2] == KERN_PROC_PID && info && infosize && ((int)*infosize == sizeof(_kinfo_proc))){
        int ret = origin_sysctl(name, namelen, info, infosize, newinfo, newinfosize);
        struct kinfo_proc *info_ptr = (struct kinfo_proc *)info;
        if(info_ptr && (info_ptr->kp_proc.p_flag & P_TRACED) != 0){
            NSLog(@"tweak : [AntiAntiDebug] - sysctl query trace status.");
            info_ptr->kp_proc.p_flag ^= P_TRACED;
            if((info_ptr->kp_proc.p_flag & P_TRACED) == 0){
                NSLog(@"tweak : trace status reomve success!");
            }
        }
        return ret;
    }
    return origin_sysctl(name, namelen, info, infosize, newinfo, newinfosize);
}

int my_syscall(int code, va_list args){
    int request;
    va_list newArgs;
    va_copy(newArgs, args);
    if(code == 26){
#ifdef __LP64__
        __asm__(
                "ldr %w[result], [fp, #0x10]\n"
                : [result] "=r" (request)
                :
                :
                );
#else
        request = va_arg(args, int);
#endif
        if(request == 31){
            NSLog(@"tweak :[AntiAntiDebug] - syscall call ptrace, and request is PT_DENY_ATTACH");
            return 0;
        }
    }
    return origin_syscall(code, newArgs);
}

int new_ioctl(int code,unsigned long code2,...) {
    return 1;
}


%ctor
{
    MSHookFunction((void*)&isatty,(void*)&new_isatty,(void**)&origin_isatty);
    MSHookFunction((void*)&exit,(void*)&new_exit,(void**)&origin_exit);
    MSHookFunction((void*)&ioctl,(void*)&new_ioctl,(void**)&origin_ioctl);
    
    
    MSHookFunction((void*)&ptrace,(void*)&my_ptrace,(void**)&origin_ptrace);
    MSHookFunction((void*)&dlsym,(void*)&my_dlsym,(void**)&origin_dlsym);
    MSHookFunction((void*)&sysctl,(void*)&my_sysctl,(void**)&origin_sysctl);
    MSHookFunction((void*)&syscall,(void*)&my_syscall,(void**)&origin_syscall);
    
    
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




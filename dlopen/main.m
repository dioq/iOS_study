#import <Foundation/Foundation.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <unistd.h>

typedef int (*CAC_FUNC)(int, int);

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		NSString *dylib_name = @"libmymath.dylib";
		NSString *dylib_path = [NSString stringWithFormat:@"%@/%@",bundlePath,dylib_name];
		// NSLog(@"%@",another_exec_file);
		const char *dylib_path2 = [dylib_path UTF8String];

		void *handle;
		char *error;
		CAC_FUNC cac_func = NULL;

		//打开动态链接库
		handle = dlopen(dylib_path2, RTLD_LAZY);
		printf("handle = %p\n",handle);
		if (!handle) {
			fprintf(stderr, "%s\n", dlerror());
			exit(EXIT_FAILURE);
		}

		//清除之前存在的错误
		dlerror();

		//获取一个函数
		int (*cac_func1)(int,int) = dlsym(handle, "add");
		if ((error = dlerror()) != NULL)  {
			fprintf(stderr, "%s\n", error);
			exit(EXIT_FAILURE);
		}
		printf("add: %d\n", cac_func1(2,7));

		cac_func = (CAC_FUNC)dlsym(handle, "sub");
		printf("cac_func: %p\n", cac_func);
		printf("sub: %d\n", cac_func(9,2));

		cac_func = (CAC_FUNC)dlsym(handle, "mul");
		printf("mul: %d\n", cac_func(3,2));

		cac_func = dlsym(handle, "div");
		printf("div: %d\n", cac_func(8,2));

		//关闭动态链接库,关闭后该动态库就会从 当前进程中 移除
		dlclose(handle);
	}
	return 0;
}

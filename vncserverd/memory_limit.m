#import <Foundation/Foundation.h>

#define MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT 6
extern int memorystatus_control(int a, int b, int c, void *d, int e);

static __attribute__((constructor)) void raise_memory_limit(void) {
	NSLog(@"vncserverd bumping memory limit");
	if (memorystatus_control(MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT, getpid(), 100, NULL, 0) == -1) {
		NSLog(@"vncserverd failed to increase memory limit. Process will likely die");
	}
}
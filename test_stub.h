#include <stdio.h>
#include "test.h"
typedef void (*cb_f1_t)();
typedef int (*cb_f2_t)(int a);
typedef void (*cb_f3_t)(float f, int i);
typedef Result (*cb_f4_t)();
typedef Result2 (*cb_f5_t)(Result i);
typedef char* (*cb_f6_t)();


void reset_test(void);
int get_count_of_f1(void);
int get_count_of_f2(void);
int get_count_of_f3(void);
int get_count_of_f4(void);
int get_count_of_f5(void);
int get_count_of_f6(void);


void set_cb_f1(cb_f1_t func);
void set_cb_f2(cb_f2_t func);
void set_cb_f3(cb_f3_t func);
void set_cb_f4(cb_f4_t func);
void set_cb_f5(cb_f5_t func);
void set_cb_f6(cb_f6_t func);




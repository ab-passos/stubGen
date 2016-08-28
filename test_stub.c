#include <stdio.h>
//Result int, Result2 int, 

#include "test_stub.h"
static cb_f1_t cb_f1 = NULL;
static int count_of_f1 = 0;
static cb_f2_t cb_f2 = NULL;
static int count_of_f2 = 0;
static cb_f3_t cb_f3 = NULL;
static int count_of_f3 = 0;
static cb_f4_t cb_f4 = NULL;
static int count_of_f4 = 0;
static cb_f5_t cb_f5 = NULL;
static int count_of_f5 = 0;
static cb_f6_t cb_f6 = NULL;
static int count_of_f6 = 0;
static cb_f7_t cb_f7 = NULL;
static int count_of_f7 = 0;


/* reset function for stubs*/
void reset_test(void){ 
cb_f1 = NULL;
count_of_f1 = 0;
cb_f2 = NULL;
count_of_f2 = 0;
cb_f3 = NULL;
count_of_f3 = 0;
cb_f4 = NULL;
count_of_f4 = 0;
cb_f5 = NULL;
count_of_f5 = 0;
cb_f6 = NULL;
count_of_f6 = 0;
cb_f7 = NULL;
count_of_f7 = 0;
}

int get_count_of_f1(void){
   return count_of_f1;
}
int get_count_of_f2(void){
   return count_of_f2;
}
int get_count_of_f3(void){
   return count_of_f3;
}
int get_count_of_f4(void){
   return count_of_f4;
}
int get_count_of_f5(void){
   return count_of_f5;
}
int get_count_of_f6(void){
   return count_of_f6;
}
int get_count_of_f7(void){
   return count_of_f7;
}


void set_cb_f1(cb_f1_t func){
cb_f1 = func;
}
void set_cb_f2(cb_f2_t func){
cb_f2 = func;
}
void set_cb_f3(cb_f3_t func){
cb_f3 = func;
}
void set_cb_f4(cb_f4_t func){
cb_f4 = func;
}
void set_cb_f5(cb_f5_t func){
cb_f5 = func;
}
void set_cb_f6(cb_f6_t func){
cb_f6 = func;
}
void set_cb_f7(cb_f7_t func){
cb_f7 = func;
}


void f1(){
count_of_f1++;
if(cb_f1){
	 cb_f1();
}
else {
	//void
}
}

int f2(int a){
count_of_f2++;
if(cb_f2){
	 return cb_f2(a);
}
else {
	return 0;
}
}

void f3(float f, int i){
count_of_f3++;
if(cb_f3){
	 cb_f3(f, i);
}
else {
	//void
}
}

Result f4(){
count_of_f4++;
if(cb_f4){
	 return cb_f4();
}
else {
	return 0;
}
}

Result2 f5(Result i){
count_of_f5++;
if(cb_f5){
	 return cb_f5(i);
}
else {
	return 0;
}
}

char* f6(){
count_of_f6++;
if(cb_f6){
	 return cb_f6();
}
else {
	return 0;
}
}

struct MyObj f7(){
count_of_f7++;
if(cb_f7){
	 return cb_f7();
}
else {
	struct MyObj a = {0}; 
 return a;
}
}




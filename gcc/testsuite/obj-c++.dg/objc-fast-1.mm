/* APPLE LOCAL file XJR */
/* A compile-only test for insertion 'bla' comm page jumps. */
/* Developed by Ziemowit Laski  <zlaski@apple.com>  */
/* { dg-do compile { target powerpc*-*-darwin* } } */
/* { dg-options "-fnext-runtime -fobjc-gc -fobjc-fast -Wassign-intercept" } */

#include <objc/Object.h>

@interface Derived: Object {
@public
  Object *other;
}
@end

void foo(void) {
  Derived *o = [Derived new];
  o->other = 0;  /* { dg-warning "instance variable assignment has been intercepted" } */
}

/* { dg-final { scan-assembler-not "objc_msgSend" } } */
/* { dg-final { scan-assembler-not "objc_assign_ivar" } } */

/* { dg-final { scan-assembler "bla.*fffeff00" } } */
/* { dg-final { scan-assembler "bla.*fffefec0" } } */

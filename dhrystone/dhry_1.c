/*
 ****************************************************************************
 *
 *                   "DHRYSTONE" Benchmark Program
 *                   -----------------------------
 *
 *  Version:    C, Version 2.1
 *
 *  File:       dhry_1.c (part 2 of 3)
 *
 *  Date:       May 25, 1988
 *
 *  Author:     Reinhold P. Weicker
 *
 ****************************************************************************
 */

#include "dhry.h"
#include <string.h>
#include <stdlib.h>
#ifndef DHRY_ITERS
#define DHRY_ITERS 500
#endif

/* Global Variables: */

Rec_Pointer Ptr_Glob,
    Next_Ptr_Glob;
int Int_Glob;
Boolean Bool_Glob;
char Ch_1_Glob,
    Ch_2_Glob;
int Arr_1_Glob[50];
int Arr_2_Glob[50][50];

Enumeration Func_1();
/* forward declaration necessary since Enumeration may not simply be int */

#ifndef REG
Boolean Reg = false;
#define REG
/* REG becomes defined as empty */
/* i.e. no register variables   */
#else
Boolean Reg = true;
#endif

/* variables for time measurement: */

#ifdef TIMES
/* Measurements should last for 1000 cycles */
#define Too_Small_Cycles (1000)
/* Measurements should last at least about 2 seconds */
#endif
#ifdef TIME
extern long
time();
/* see library function "time"  */
#define Too_Small_Time 2
/* Measurements should last at least 2 seconds */
#endif
#ifdef MSC_CLOCK
extern clock_t clock();
#define Too_Small_Time (2 * HZ)
#endif

/* end of variables for time measurement */

void uart_putc(char c)
{
  volatile char *uart_tx = (char *)0xFFFFFFFC;
  *uart_tx = c;
}
void uart_puts(const char *str)
{
  while (*str)
  {
    uart_putc(*str++);
  }
}

void uart_puthex(unsigned int val)
{
  uart_puts("0x");

  int shift = 28;
  for (int i = 0; i < 8; i++)
  {
    unsigned int nibble = (val >> shift) & 0xF;
    uart_putc(nibble < 10 ? ('0' + nibble) : ('A' + nibble - 10));
    shift -= 4;
  }
}
void uart_putsi(const char *str, unsigned int val)
{
  uart_puts(str);
  uart_puthex(val);
}

main()
/*****/

/* main program, corresponds to procedures        */
/* Main and Proc_0 in the Ada version             */
{
  One_Fifty Int_1_Loc;
  REG One_Fifty Int_2_Loc;
  One_Fifty Int_3_Loc;
  REG char Ch_Index;
  Enumeration Enum_Loc;
  Str_30 Str_1_Loc;
  Str_30 Str_2_Loc;
  REG int Run_Index;
  REG int Number_Of_Runs;

  /* Initializations */

  Next_Ptr_Glob = (Rec_Pointer)malloc(sizeof(Rec_Type));
  Ptr_Glob = (Rec_Pointer)malloc(sizeof(Rec_Type));

  Ptr_Glob->Ptr_Comp = Next_Ptr_Glob;
  Ptr_Glob->Discr = Ident_1;
  Ptr_Glob->variant.var_1.Enum_Comp = Ident_3;
  Ptr_Glob->variant.var_1.Int_Comp = 40;
  strcpy(Ptr_Glob->variant.var_1.Str_Comp,
         "DHRYSTONE PROGRAM, SOME STRING");
  strcpy(Str_1_Loc, "DHRYSTONE PROGRAM, 1'ST STRING");

  Arr_2_Glob[8][7] = 10;
  /* Was missing in published program. Without this statement,    */
  /* Arr_2_Glob [8][7] would have an undefined value.             */
  /* Warning: With 16-Bit processors and Number_Of_Runs > 32000,  */
  /* overflow may occur for this array element.                   */

  uart_putc('\n');
  uart_puts("Dhrystone Benchmark, Version 2.1 (Language: C)\n");
  uart_putc('\n');
  if (Reg)
  {
    uart_puts("Program compiled with 'register' attribute\n");
    uart_putc('\n');
  }
  else
  {
    uart_puts("Program compiled without 'register' attribute\n");
    uart_putc('\n');
  }
#ifdef DHRY_ITERS
  Number_Of_Runs = DHRY_ITERS;
#else
  printf("Please give the number of runs through the benchmark: ");
  {
    int n;
    scanf("%d", &n);
    Number_Of_Runs = n;
  }
  uart_putc('\n');
#endif

  uart_putsi("Execution starts, ", Number_Of_Runs);
  uart_puts(" runs through Dhrystone");
  uart_putc('\n');

  /***************/
  /* Start timer */
  /***************/

#ifdef TIMES
  start_timer();
#endif

  for (Run_Index = 1; Run_Index <= Number_Of_Runs; ++Run_Index)
  {

    Proc_5();
    Proc_4();
    /* Ch_1_Glob == 'A', Ch_2_Glob == 'B', Bool_Glob == true */
    Int_1_Loc = 2;
    Int_2_Loc = 3;
    strcpy(Str_2_Loc, "DHRYSTONE PROGRAM, 2'ND STRING");
    Enum_Loc = Ident_2;
    Bool_Glob = !Func_2(Str_1_Loc, Str_2_Loc);
    /* Bool_Glob == 1 */
    while (Int_1_Loc < Int_2_Loc) /* loop body executed once */
    {
      Int_3_Loc = 5 * Int_1_Loc - Int_2_Loc;
      /* Int_3_Loc == 7 */
      Proc_7(Int_1_Loc, Int_2_Loc, &Int_3_Loc);
      /* Int_3_Loc == 7 */
      Int_1_Loc += 1;
    } /* while */
    /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
    Proc_8(Arr_1_Glob, Arr_2_Glob, Int_1_Loc, Int_3_Loc);
    /* Int_Glob == 5 */
    Proc_1(Ptr_Glob);
    for (Ch_Index = 'A'; Ch_Index <= Ch_2_Glob; ++Ch_Index)
    /* loop body executed twice */
    {
      if (Enum_Loc == Func_1(Ch_Index, 'C'))
      /* then, not executed */
      {
        Proc_6(Ident_1, &Enum_Loc);
        strcpy(Str_2_Loc, "DHRYSTONE PROGRAM, 3'RD STRING");
        Int_2_Loc = Run_Index;
        Int_Glob = Run_Index;
      }
    }
    /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
    Int_2_Loc = Int_2_Loc * Int_1_Loc;
    Int_1_Loc = Int_2_Loc / Int_3_Loc;
    Int_2_Loc = 7 * (Int_2_Loc - Int_3_Loc) - Int_1_Loc;
    /* Int_1_Loc == 1, Int_2_Loc == 13, Int_3_Loc == 7 */
    Proc_2(&Int_1_Loc);
    /* Int_1_Loc == 5 */

  } /* loop "for Run_Index" */

  /**************/
  /* Stop timer */
  /**************/
  stop_timer();

#ifdef TIMES
  User_Cycles = read_timer();
#endif
#ifdef TIME
  End_Time = time((long *)0);
#endif
#ifdef MSC_CLOCK
  End_Time = clock();
#endif

  uart_puts("Execution ends\n");
  uart_putc('\n');

  uart_puts("Final values of the variables used in the benchmark:");
  uart_putc('\n');
  uart_putsi("Int_Glob:            ", Int_Glob);
  uart_putsi("        should be:   ", 5);
  uart_putc('\n');
  uart_putsi("Bool_Glob:           ", Bool_Glob);
  uart_putsi("        should be:   ", 1);
  uart_putc('\n');
  uart_puts("Ch_1_Glob:           ");
  uart_putc(Ch_1_Glob);
  uart_puts("        should be:   ");
  uart_putc('A');
  uart_putc('\n');

  uart_puts("Ch_2_Glob:           ");
  uart_putc(Ch_2_Glob);
  uart_puts("        should be:   ");
  uart_putc('B');
  uart_putc('\n');

  uart_putsi("Arr_1_Glob[8]:       ", Arr_1_Glob[8]);
  uart_putsi("        should be:   ", 7);
  uart_putc('\n');

  uart_putsi("Arr_2_Glob[8][7]:    ", Arr_2_Glob[8][7]);
  uart_puts("        should be:   Number_Of_Runs + 10\n");
  uart_putc('\n');

  uart_puts("Ptr_Glob->\n");
  uart_putsi("  Ptr_Comp:          ", (int)Ptr_Glob->Ptr_Comp);
  uart_puts("        should be:   (implementation-dependent)\n");
  uart_putsi("  Discr:             ", Ptr_Glob->Discr);
  uart_putsi("        should be:   ", 0);
  uart_putc('\n');

  uart_putsi("  Enum_Comp:         ", Ptr_Glob->variant.var_1.Enum_Comp);
  uart_putsi("        should be:   ", 2);
  uart_putc('\n');

  uart_putsi("  Int_Comp:          ", Ptr_Glob->variant.var_1.Int_Comp);
  uart_putsi("        should be:   ", 17);
  uart_putc('\n');

  uart_puts("  Str_Comp:          ");
  uart_puts(Ptr_Glob->variant.var_1.Str_Comp);
  uart_puts("        should be:   DHRYSTONE PROGRAM, SOME STRING\n");
  uart_puts("Next_Ptr_Glob->\n");
  uart_putsi("  Ptr_Comp:          ", (int)Next_Ptr_Glob->Ptr_Comp);
  uart_puts("        should be:   (implementation-dependent), same as above\n");

  uart_putsi("  Discr:             ", Next_Ptr_Glob->Discr);
  uart_putsi("        should be:   ", 0);
  uart_putc('\n');

  uart_putsi("  Enum_Comp:         ", Next_Ptr_Glob->variant.var_1.Enum_Comp);
  uart_putsi("        should be:   ", 1);
  uart_putc('\n');

  uart_putsi("  Int_Comp:          ", Next_Ptr_Glob->variant.var_1.Int_Comp);
  uart_putsi("        should be:   ", 18);
  uart_putc('\n');

  uart_puts("  Str_Comp:          ");
  uart_puts(Next_Ptr_Glob->variant.var_1.Str_Comp);
  uart_puts("        should be:   DHRYSTONE PROGRAM, SOME STRING\n");
  uart_putc('\n');
  uart_putsi("Int_1_Loc:           ", Int_1_Loc);
  uart_putsi("        should be:   ", 5);
  uart_putc('\n');

  uart_putsi("Int_2_Loc:           ", Int_2_Loc);
  uart_putsi("        should be:   ", 13);
  uart_putc('\n');

  uart_putsi("Int_3_Loc:           ", Int_3_Loc);
  uart_putsi("        should be:   ", 7);
  uart_putc('\n');

  uart_putsi("Enum_Loc:            ", Enum_Loc);
  uart_putsi("        should be:   ", 1);
  uart_putc('\n');

  uart_puts("Str_1_Loc:           ");
  uart_puts(Str_1_Loc);
  uart_puts("        should be:   DHRYSTONE PROGRAM, 1'ST STRING\n");
  uart_putc('\n');

  uart_puts("Str_2_Loc:           ");
  uart_puts(Str_2_Loc);
  uart_puts("        should be:   DHRYSTONE PROGRAM, 2'ND STRING\n");
  uart_putc('\n');
  uart_putc('\n');

  if (User_Cycles < Too_Small_Cycles)
  {
    uart_puts("Measured time too small to obtain meaningful results\n");
    uart_puts("Please increase number of runs\n");
    uart_putc('\n');
  }
  else
  {
    uart_putsi("Total Cycles:", User_Cycles);
    uart_putc('\n');
    uart_putc('\n');
  }
}

Proc_1(Ptr_Val_Par)
    /******************/

    REG Rec_Pointer Ptr_Val_Par;
/* executed once */
{
  REG Rec_Pointer Next_Record = Ptr_Val_Par->Ptr_Comp;
  /* == Ptr_Glob_Next */
  /* Local variable, initialized with Ptr_Val_Par->Ptr_Comp,    */
  /* corresponds to "rename" in Ada, "with" in Pascal           */

  structassign(*Ptr_Val_Par->Ptr_Comp, *Ptr_Glob);
  Ptr_Val_Par->variant.var_1.Int_Comp = 5;
  Next_Record->variant.var_1.Int_Comp = Ptr_Val_Par->variant.var_1.Int_Comp;
  Next_Record->Ptr_Comp = Ptr_Val_Par->Ptr_Comp;
  Proc_3(&Next_Record->Ptr_Comp);
  /* Ptr_Val_Par->Ptr_Comp->Ptr_Comp
                      == Ptr_Glob->Ptr_Comp */
  if (Next_Record->Discr == Ident_1)
  /* then, executed */
  {
    Next_Record->variant.var_1.Int_Comp = 6;
    Proc_6(Ptr_Val_Par->variant.var_1.Enum_Comp,
           &Next_Record->variant.var_1.Enum_Comp);
    Next_Record->Ptr_Comp = Ptr_Glob->Ptr_Comp;
    Proc_7(Next_Record->variant.var_1.Int_Comp, 10,
           &Next_Record->variant.var_1.Int_Comp);
  }
  else /* not executed */
    structassign(*Ptr_Val_Par, *Ptr_Val_Par->Ptr_Comp);
} /* Proc_1 */

Proc_2(Int_Par_Ref)
    /******************/
    /* executed once */
    /* *Int_Par_Ref == 1, becomes 4 */

    One_Fifty *Int_Par_Ref;
{
  One_Fifty Int_Loc;
  Enumeration Enum_Loc;

  Int_Loc = *Int_Par_Ref + 10;
  do /* executed once */
    if (Ch_1_Glob == 'A')
    /* then, executed */
    {
      Int_Loc -= 1;
      *Int_Par_Ref = Int_Loc - Int_Glob;
      Enum_Loc = Ident_1;
    } /* if */
  while (Enum_Loc != Ident_1); /* true */
} /* Proc_2 */

Proc_3(Ptr_Ref_Par)
    /******************/
    /* executed once */
    /* Ptr_Ref_Par becomes Ptr_Glob */

    Rec_Pointer *Ptr_Ref_Par;

{
  if (Ptr_Glob != Null)
    /* then, executed */
    *Ptr_Ref_Par = Ptr_Glob->Ptr_Comp;
  Proc_7(10, Int_Glob, &Ptr_Glob->variant.var_1.Int_Comp);
} /* Proc_3 */

Proc_4() /* without parameters */
/*******/
/* executed once */
{
  Boolean Bool_Loc;

  Bool_Loc = Ch_1_Glob == 'A';
  Bool_Glob = Bool_Loc | Bool_Glob;
  Ch_2_Glob = 'B';
} /* Proc_4 */

Proc_5() /* without parameters */
/*******/
/* executed once */
{
  Ch_1_Glob = 'A';
  Bool_Glob = false;
} /* Proc_5 */

/* Procedure for the assignment of structures,          */
/* if the C compiler doesn't support this feature       */
#ifdef NOSTRUCTASSIGN
memcpy(d, s, l) register char *d;
register char *s;
register int l;
{
  while (l--)
    *d++ = *s++;
}
#endif

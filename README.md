# AutoCodeLoop

If you need to write iterative C code without for loop, this will help you.

### sample.code
```C
 #include <arm_neon.h>

void function() {
        #pragma GCC unroll($LOOP_UNROLL)
        register float64x2x3_t $FOR($0, $MR, $'_V_C$$$', $', $');
        $FOR($0, $MR, $'_V_C$$ = vld1q_f64_x3(&C[$$ * $MR]);$', $'
        $')
        int a = $L1_DIST;
}
```

to

### output
```C
#include <arm_neon.h>

void function() {
        #pragma GCC unroll(3)
        register float64x2x3_t _V_C0,_V_C1,_V_C2,_V_C3,_V_C4,_V_C5,_V_C6,_V_C7;
        _V_C0 = vld1q_f64_x3(&C[0 * 8]);
        _V_C1 = vld1q_f64_x3(&C[1 * 8]);
        _V_C2 = vld1q_f64_x3(&C[2 * 8]);
        _V_C3 = vld1q_f64_x3(&C[3 * 8]);
        _V_C4 = vld1q_f64_x3(&C[4 * 8]);
        _V_C5 = vld1q_f64_x3(&C[5 * 8]);
        _V_C6 = vld1q_f64_x3(&C[6 * 8]);
        _V_C7 = vld1q_f64_x3(&C[7 * 8]);
        int a = 100;
}
```

# Usage
## 1. Create AutoCodeLoop
follow this step
```shell
git clone https://github.com/enochjung/AutoCodeLoop.git
cd AutoCodeLoop
make
```
Then, runnable file 'acl' will be created.
## 2. Write Code
AutoCodeLoop syntax is expressed with special token `$`.
### for
```
$FOR(number_A, number_B, string_A, string_B)
```
`$FOR` writes code iteratively. This works like
```c
for (i=number_A; i<number_B; i++) {
    printf(string_A);
    if (i < number_B-1)
        printf(string_B);
}
```
### number
```
$<number>
or
$<environment variable>
```
`$<number>` or `$<environment variable>` is needed for `$FOR`. Also, it can be used for code. For example,
```C
    printf("size : $SIZE\n");
```
if you set the environment variable `SIZE` by `export SIZE=100`, it will be as follows.
```C
    printf("size : 100\n");
```

### string
```
$'<string>$'
```
`$'<string>$'` is only for '$FOR'. If you want to include `i` value into string, use `$$`. `$$` is replaced by `i` value.
## 3. Set Environment Variables & Run ACL
If you use `$<environment variable>`, you have to export the environment variables.
Then run ACL.   
Usage : `./acl <input_code> <output_code>`.

Running sample code
```shell
export LOOP_UNROLL=3
export MR=8
export L1_DIST=100
./acl sample.code output.c
```

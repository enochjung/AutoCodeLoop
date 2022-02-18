# AutoCodeLoop

If you need to write iterative code without for loop, this will help you.

### sample.code
```C
 #include <arm_neon.h>

void function() {
        #pragma GCC unroll($LOOP_UNROLL)
        register float64x2x3_t $FOR($0, $MR, $'_V_C$$$', $', $');
        $FOR($0, $MR, $'_V_C$$ = vld1q_f64_x3(&C[$$ * $MR);$', $'
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
        _V_C0 = vld1q_f64_x3(&C[0 * 8);
        _V_C1 = vld1q_f64_x3(&C[1 * 8);
        _V_C2 = vld1q_f64_x3(&C[2 * 8);
        _V_C3 = vld1q_f64_x3(&C[3 * 8);
        _V_C4 = vld1q_f64_x3(&C[4 * 8);
        _V_C5 = vld1q_f64_x3(&C[5 * 8);
        _V_C6 = vld1q_f64_x3(&C[6 * 8);
        _V_C7 = vld1q_f64_x3(&C[7 * 8);
        int a = 100;
}
```

# Usage
## 1. Create ACL
follow this step
```Shell
git clone https://github.com/enochjung/AutoCodeLoop.git
cd AutoCodeLoop
make
```
Then, runnable file 'acl' will be created.
## 2. Write Code
## 3. Set Environment Variables
## 4. Run ACL

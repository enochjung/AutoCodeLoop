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
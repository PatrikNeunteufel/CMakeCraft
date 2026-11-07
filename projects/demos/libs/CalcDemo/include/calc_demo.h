// calc_demo.h - demo library for compile_options and source packages
// (selftest phase 11). STATIC, with its own floating-point switches and a
// local header external (calcext) that travels with the source package.
#pragma once

namespace calc_demo {

// a * b + c with two roundings: the library's compile_options switch off
// FMA contraction, so the product is rounded before the sum.
double mul_add(double a, double b, double c);

// Value from the external calcext (proves that its define arrived).
int external_marker();

} // namespace calc_demo

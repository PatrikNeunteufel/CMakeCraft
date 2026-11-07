// calc_demo.cpp - see calc_demo.h
#include "calc_demo.h"
#include "calc_detail.h"

#include <calcext.h>

namespace calc_demo {

double mul_add(double a, double b, double c)
{
    return detail::product(a, b) + c;
}

int external_marker()
{
    return CALCEXT_MARKER;
}

} // namespace calc_demo

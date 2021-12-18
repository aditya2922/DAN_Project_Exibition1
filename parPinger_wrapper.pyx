
#This is a Cython file and extracts the relevant classes from the C++ header file.

# distutils: language = c++
# distutils: sources = parPinger.cpp

import numpy as np
from libcpp.vector cimport vector
ctypedef unsigned short uns16
ctypedef long double ld

cdef extern from "parPinger.hpp" namespace "pinger":
    cdef cppclass parPinger:
        parPinger(char*,double, uns16)
        vector[vector[ld]] probe()
        double get_interval()
        void set_ping_interval_sec(double)
        void set_target_ip(char *, uns16)

cdef class PyParPinger:
    cdef parPinger *thisptr      # hold a C++ instance which we're wrapping
    def __cinit__(self, char* ip = "", double ping_interval_sec = -1):
        self.thisptr = new parPinger(ip, ping_interval_sec, np.uint16(hash(ip)))
    def __dealloc__(self):
        del self.thisptr
    def probe(self):
        return self.thisptr.probe()
    def get_interval(self):
        return self.thisptr.get_interval()
    def set_ping_interval_sec(self, double value):
        self.thisptr.set_ping_interval_sec(value)
    def set_target_ip(self, char* ip):
        self.thisptr.set_target_ip(ip,np.uint16(hash(ip)))
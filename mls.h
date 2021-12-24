

#ifndef MLS_H
#define MLS_H

#include <vector>
#include <cmath>
#include <time.h>
#include <unordered_map>
#include <stdlib.h>
#include <random>
#include "aes.hpp"

using namespace std;

class mls
{
public:
    mls(int nbits = 10, bool useAES = true);
    vector<bool> get_seq();
    void setBits(int n_bits);
    int size();

private:
    unordered_map<int, vector<int>> Taps;
    int nbits;
    bool isAES;
    random_device rd; //used for generating non-deterministic random numbers
    bool goodSeq(vector<bool> seq);

    //Used in the case of AES
    uint8_t *key; //initialized with random device
    uint8_t *iv;
    struct AES_ctx ctx;

};

#endif // MLS_H

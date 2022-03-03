#include"./ART/Tree.h"
#include"./ART/Tree.cpp"
#include <iostream>
#include <chrono>
#include "tbb/tbb.h"
#include <cstdio>
#include <random>
#include <fstream>

using namespace ART_unsynchronized;

void loadKey(TID tid, Key &key) {
    // Store the key of the tuple into the key vector
    // Implementation is database specific
    key.setKeyLen(sizeof(tid));
    reinterpret_cast<uint64_t *>(&key[0])[0] = __builtin_bswap64(tid);
}

template<class T>
bool load_binary_data(T data[], int length, const std::string &file_path) {
    std::ifstream is(file_path.c_str(), std::ios::binary | std::ios::in);
    if (!is.is_open()) {
        return false;
    }
    is.read(reinterpret_cast<char *>(data), std::streamsize(length * sizeof(T)));
    is.close();

    return true;
}


int main(){
    ART_unsynchronized::Tree idx(loadKey);

    size_t data_size = 200000000;

    // prepare data
    uint64_t *keys = new uint64_t[data_size];
    std::cout << "Loading data" << std::endl;
    load_binary_data(keys, data_size, "/research/dept7/cyliu/zhicong/code/learned_index_benchmark/resources/fb_200M_uint64");

    std::cout << "Make data Unique" << std::endl;
    std::sort(keys, keys+data_size);
    auto tail = std::unique(keys, keys+data_size);
    data_size = tail - keys;
    std::random_shuffle(keys, keys+data_size);
    printf("unique key size is %d\n", data_size);

    for(auto i = 0; i < data_size; i++) {
        printf("%llu ", keys[i]);
        if(i >= 20) break;
    }
    printf("\n");

    printf("Inserting\n");

    for(int i = 0; i < data_size; i++) {
        Key key;
        loadKey(keys[i], key);
        idx.insert(key, keys[i]);

        auto val = idx.lookup(key);
        if (val != keys[i]) {
            std::cout << "Position " << i << ", Insert error, wrong key read: " << val << " expected:" << keys[i] << std::endl;
            throw;
        }
    }

    printf("Searching\n");

    for (uint64_t i = 0; i < data_size; i++) {
        Key key;
        loadKey(keys[i], key);
        auto val = idx.lookup(key);
        if (val != keys[i]) {
            std::cout << "Position " << i << ", Insert error, wrong key read: " << val << " expected:" << keys[i] << std::endl;
            throw;
        }
    }

    return 0;
}
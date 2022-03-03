#include"./src/alex.h"

int main()
{
    const int table_size = 10000000;
    alexol::Alex<uint64_t, uint64_t, alexol::AlexCompare, std::allocator < std::pair < uint64_t, uint64_t>>, false> index;

    // bulkloading
    std::pair < uint64_t, uint64_t> *key_value = new std::pair < uint64_t, uint64_t>[table_size];
    for(auto i = 0; i < table_size; i++) {
        key_value[i] = {i,i+1};
    }
    index.set_max_model_node_size(1 << 24); // (22,15,66M) (22,16,89M) (22,17,91M) (22,18,81M) (23,17,92M) (21,17,92M) (20,17,92M)
    index.set_max_data_node_size(1 << 17);
    index.bulk_load(key_value, (int) table_size);

    // range query
    const int scan_num = 10000;
    auto res = new std::pair<uint64_t, uint64_t>[scan_num];
    auto scan_size = index.range_scan_by_size(0, static_cast<uint32_t>(scan_num), res);

    uint64_t sum = 0;
    for(auto i = 0; i < scan_num; i++) {
        sum += res[i].second;
    }

    printf("The range query sum is %llu, expected result is %llu\n", sum, (scan_num+1)*(scan_num) / 2);

    return 0;
}
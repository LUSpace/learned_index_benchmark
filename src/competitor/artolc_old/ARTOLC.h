#include"./src/Tree.h"
#include"../indexInterface.h"
#include "tbb/tbb.h"

template<class KEY_TYPE, class PAYLOAD_TYPE>
        class ARTOLCInterface_OLD : public indexInterface<KEY_TYPE, PAYLOAD_TYPE> {
public:

    ARTOLCInterface_OLD() {
        if (sizeof(KEY_TYPE) == 8) {
            auto loadKey = [](TID tid, ART_OLC::Key &key) { key.setInt(*reinterpret_cast<uint64_t *>(tid)); };
            idx = new ART_OLC::Tree(loadKey);
            maxKey.setInt(~0ull);
        } else {
            auto loadKey = [](TID tid, ART_OLC::Key &key) { key.set(reinterpret_cast<char *>(tid), 31); };
            idx = new ART_OLC::Tree(loadKey);
            uint8_t m[] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                           0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                           0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                           0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
            maxKey.set((char *) m, 31);
        }
    }

    void init(Param *param = nullptr) {
    }

    void setKey(ART_OLC::Key &k, KEY_TYPE key) { k.setInt((uint64_t) key); }

    void bulk_load(std::pair <KEY_TYPE, PAYLOAD_TYPE> *key_value, size_t num, Param *param = nullptr);

    bool get(KEY_TYPE key, PAYLOAD_TYPE &val, Param *param = nullptr);

    bool put(KEY_TYPE &key, PAYLOAD_TYPE &value, Param *param = nullptr);

    bool remove(KEY_TYPE key, Param *param = nullptr);

    size_t scan(KEY_TYPE key_low_bound, size_t key_num, std::pair<KEY_TYPE, PAYLOAD_TYPE> *result,
                Param *param = nullptr) {
        auto t = idx->getThreadInfo();
        ART_OLC::Key startKey;
        setKey(startKey, key_low_bound);

        TID results[key_num];
        size_t resultCount;
        ART_OLC::Key continueKey;
        idx->lookupRange(startKey, maxKey, continueKey, results, key_num, resultCount, t);

        return resultCount;
    }

    long long memory_consumption() { return 0; }

    ~ARTOLCInterface_OLD() {
        delete idx;
    }

private:
    ART_OLC::Key maxKey;
    ART_OLC::Tree *idx;
};

template<class KEY_TYPE, class PAYLOAD_TYPE>
void ARTOLCInterface_OLD<KEY_TYPE, PAYLOAD_TYPE>::bulk_load(std::pair <KEY_TYPE, PAYLOAD_TYPE> *key_value, size_t num,
                                                        Param *param) {
//  auto func = [param, this, &key_value](const tbb::blocked_range<size_t>& r) {
//    size_t start_index = r.begin();
//    size_t end_index = r.end();
//    for (auto i = start_index; i < end_index; i++) {
//      put(key_value[i].first,  key_value[i].second, param);
//    }
//  };
//
//  tbb::parallel_for(tbb::blocked_range<size_t>(0, num), func);
//#pragma omp parallel
    for (auto i = 0; i < num; i++) {
        put(key_value[i].first, key_value[i].second, param);
    }
}

template<class KEY_TYPE, class PAYLOAD_TYPE>
bool ARTOLCInterface_OLD<KEY_TYPE, PAYLOAD_TYPE>::get(KEY_TYPE key, PAYLOAD_TYPE &val, Param *param) {
    auto t = idx->getThreadInfo();
    ART_OLC::Key k;
    setKey(k, key);
    val = static_cast<PAYLOAD_TYPE>(idx->lookup(k, t));
    return true;
}

template<class KEY_TYPE, class PAYLOAD_TYPE>
bool ARTOLCInterface_OLD<KEY_TYPE, PAYLOAD_TYPE>::put(KEY_TYPE &key, PAYLOAD_TYPE &value, Param *param) {
    auto t = idx->getThreadInfo();
    auto val = new PAYLOAD_TYPE;
    *val = value;
    ART_OLC::Key k;
    setKey(k, key);
    idx->insert(k, reinterpret_cast<uint64_t>(&val), t);
    return true;
}

template<class KEY_TYPE, class PAYLOAD_TYPE>
bool ARTOLCInterface_OLD<KEY_TYPE, PAYLOAD_TYPE>::remove(KEY_TYPE key, Param *param) {
//  index.erase(key);
    return true;
}


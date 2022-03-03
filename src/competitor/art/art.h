#include <functional>
#include"./src/src/art.h"
#include"../indexInterface.h"

template<class KEY_TYPE, class PAYLOAD_TYPE>
class ARTInterface : public indexInterface<KEY_TYPE, PAYLOAD_TYPE> {
public:

  ARTInterface() {
    int res = art_tree_init(&t);
  }

  void init(Param *param = nullptr) {
  }

  void bulk_load(std::pair <KEY_TYPE, PAYLOAD_TYPE> *key_value, size_t num, Param *param = nullptr);

  bool get(KEY_TYPE key, PAYLOAD_TYPE &val, Param *param = nullptr);

  bool put(KEY_TYPE key, PAYLOAD_TYPE value, Param *param = nullptr);

  bool remove(KEY_TYPE key, Param *param = nullptr);

  size_t scan(KEY_TYPE key_low_bound, size_t key_num, std::pair<KEY_TYPE, PAYLOAD_TYPE> *result,
              Param *param = nullptr) { return 0; }

  long long memory_consumption() { return art_tree_size(&t); }

  ~ARTInterface() {
    art_tree_destroy(&t);
  }

private:
  art_tree t;
  inline void swap_endian(uint32_t &i) {
    i = __builtin_bswap32(i);
  }
  inline void swap_endian(uint64_t &i) {
    i = __builtin_bswap64(i);
  }
};

template<class KEY_TYPE, class PAYLOAD_TYPE>
void ARTInterface<KEY_TYPE, PAYLOAD_TYPE>::bulk_load(std::pair <KEY_TYPE, PAYLOAD_TYPE> *key_value, size_t num,
                                                        Param *param) {
  for(int i = 0; i < num; i++) {
    this->put(key_value[i].first, key_value[i].second, param);
  }
}

template<class KEY_TYPE, class PAYLOAD_TYPE>
bool ARTInterface<KEY_TYPE, PAYLOAD_TYPE>::get(KEY_TYPE key, PAYLOAD_TYPE &val, Param *param) {
  swap_endian(key);
  void* val_ptr = art_search(&t, (unsigned char*) &key, sizeof(KEY_TYPE));
  if(val_ptr != nullptr) {
    val = (PAYLOAD_TYPE) val_ptr;
    return true;
  }
  return false;
}

template<class KEY_TYPE, class PAYLOAD_TYPE>
bool ARTInterface<KEY_TYPE, PAYLOAD_TYPE>::put(KEY_TYPE key, PAYLOAD_TYPE value, Param *param) {
  swap_endian(key);
  return art_insert_no_replace(&t, (unsigned char*) &key, sizeof(KEY_TYPE), (void*)value) == nullptr;
}

template<class KEY_TYPE, class PAYLOAD_TYPE>
bool ARTInterface<KEY_TYPE, PAYLOAD_TYPE>::remove(KEY_TYPE key, Param *param) {
//  index.erase(key);
  return false;
}


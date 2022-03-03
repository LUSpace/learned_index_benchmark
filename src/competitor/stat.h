#pragma once
#include <atomic>
#include <cstdio>
#include <iostream>

#ifndef STAT_H
#define STAT_H

//#define STAT_ON 1
#ifdef STAT_ON
#define STAT_TYPE
#else
#define STAT_TYPE thread_local
#endif

namespace STAT {
    struct HotStat {
        std::atomic<size_t> delete_object = 0;
        std::atomic<size_t> global_epoch_update = 0;

        static HotStat* getInstance() {
            STAT_TYPE static HotStat instance;
            return &instance;
        }

        void clear() {
            delete_object.store(0);
            global_epoch_update.store(0);
        }

        ~HotStat() {
            if(delete_object.load() > 0)
                printf("\ndelete_object: %llu", delete_object.load());
            if(global_epoch_update.load() > 0)
                printf("\nglobal_epoch_update: %llu\n", global_epoch_update.load());
        }
    };

    struct ARTOLCStat {
        std::atomic<size_t> delete_object = 0;
        std::atomic<size_t> global_epoch_update = 0;

        void clear() {
            delete_object.store(0);
            global_epoch_update.store(0);
        }

        static ARTOLCStat* getInstance() {
            STAT_TYPE static ARTOLCStat instance;
            return &instance;
        }

        ~ARTOLCStat() {
            if(delete_object.load() > 0)
                printf("\ndelete_object: %llu", delete_object.load());
            if(global_epoch_update.load() > 0)
                printf("\nglobal_epoch_update: %llu\n", global_epoch_update.load());
        }
    };

}

#endif
import numpy as np
from multiprocessing import Pool

def proc(input):
    name, a, b = input
    if a.max() > b.max():
        scale = a.max() / b.max()
        a = a.astype(np.double) / scale
        a = np.unique(np.rint(a)).astype(np.uint64)
    elif b.max() > a.max():
        scale = b.max() / a.max()
        b = b.astype(np.double) / scale
        b = np.unique(np.rint(b).astype(np.uint64))
    print(scale, a.max(), b.max())
    a = a[~np.in1d(a,b)]
    a = np.sort(np.random.choice(a, 100000000, False), None)
    b = np.sort(np.random.choice(b, 100000000, False), None)
    out = np.concatenate([a, b])
    out = np.insert(out, 0, 200000000)
    print(name, out.shape[0], out, sep='\n', end='\n\n')
    out.tofile("../resources/" + name)

covid = np.fromfile('../resources/covid_tweets_200M_uint64', dtype=np.uint64)
osm = np.fromfile('../resources/osm_cellids_200M_uint64', dtype=np.uint64)
biology = np.fromfile('../resources/biology_200M_uint64', dtype=np.uint64) 

covid = np.delete(covid, 0)
osm = np.delete(osm, 0)
biology = np.delete(biology, 0)

covid = covid - covid.min()
osm = osm - osm.min()
biology = biology - biology.min()

covid = np.sort(covid, None)
osm = np.sort(osm, None)
biology = np.sort(biology, None)

with Pool(16) as p:
    p.map(proc, [
        ('covid_osm_sd_200M_uint64', covid, osm),
        ('covid_biology_sd_200M_uint64', covid, biology),
        ('osm_covid_sd_200M_uint64', osm, covid),
        ('biology_covid_sd_200M_uint64', biology, covid)
    ])
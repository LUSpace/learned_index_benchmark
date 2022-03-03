import numpy as np
import pandas as pd
import sys
from scipy import stats
from scipy.spatial.distance import pdist
from multiprocessing import Pool
from math import log

datasets = [
	# 'wiki_ts_unique_200M_uint64',
	# 'books_200M_uint64',
	'osm_cellids_200M_uint64',
	'fb_200M_uint64',
	'biology_200M_uint64',
	# 'libraries_io_repository_dependencies_200M_uint64',
	# 'wise_all_sky_data_htm_200M_uint64',
	'planet_features_osm_id_200M_uint64',
	'covid_tweets_200M_uint64',
	# 'yago_triple_194M_uint64',
    # 'eth_gas_27M_uint64',
    # 'gnomad_46M_uint64',
    # 'stovf_vote_48M_uint64',
	# 'wiki_ts_unique_90M_uint32',
	# 'libraries_io_repository_dependencies_200M_uint32',
	# 'gnomad_46M_uint32',
	# 'stovf_vote_48M_uint32'
]

mode = sys.argv[1]

def extract_number(d):
	print(d)
	if 'uint64' not in d:
		t = np.uint32
	else:
		t = np.uint64
	a = np.fromfile('../resources/' + d, dtype=t)[1:]
	a = np.sort(a, None)
	
	if(mode == 'iqr'):
		df = pd.DataFrame(a)
		q1 = df[0].quantile(0.25)
		q3 = df[0].quantile(0.75)
		iqr = q3 - q1
		val = df[(df[0] < q1 - iqr*1.5) | (df[0] > q3 + iqr*1.5)].shape[0]
		val = val  / (df.shape[0]/1000000)
	elif(mode == 'wass-uniform'):
		p = np.arange(a.shape[0])
		val = stats.wasserstein_distance(p, a)
	elif(mode == 'kurt'):
		val = stats.kurtosis(a, fisher=False)[0]
	elif(mode == 'sparse'):
		df = pd.DataFrame(a)
		val = df.shape[0] / (df[0].max() - df[0].min())
	elif(mode == 'iqr-norm'):
		df = pd.DataFrame(a)
		q1 = df[0].quantile(0.25)
		q3 = df[0].quantile(0.75)
		iqr = q3 - q1
		val = df[(df[0] < q1 - iqr*1.5) | (df[0] > q3 + iqr*1.5)].shape[0]
		val_low = df[df[0] < q1 - iqr*1.5][0].apply(lambda v: (q1 - iqr*1.5) / v).sum()
		val_high = df[df[0] > q3 + iqr*1.5][0].apply(lambda v: v / (q3 + iqr*1.5)).sum()
		val = (val_low+val_high)  / (df.shape[0]/1000000)
	elif(mode == 'skew'):
		val = abs(stats.skew(a))
	elif(mode == 'dist'):
		p = a[::2]
		q = a[1::2]
		if(p.shape[0] > q.shape[0]):
			p = p[:-1]
		elif(p.shape[0] < q.shape[0]):
			q = q[:-1]
		# avg_dist = np.sum(np.subtract(q,p), axis=None) / a.shape[0]
		# val = np.sum(np.absolute(np.subtract(avg_dist, np.subtract(q,p))), axis=None) / a.shape[0]
		val = np.sum(np.subtract(q,p), axis=None) / a.shape[0]
	
	print(val)
	return [d, val]

with Pool(len(datasets)) as p:
	out = p.map(extract_number, datasets)
	
pd.DataFrame(out).to_csv(f'../outlier_{mode}.csv', index=False, header=['dataset', 'outlier'])

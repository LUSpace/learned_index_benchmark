from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
import numpy as np
import pandas as pd
import scipy

datasets = [
	# 'wiki_ts_unique_200M_uint64',
	'books_200M_uint64',
	'osm_cellids_200M_uint64',
	'fb_200M_uint64',
	'biology_200M_uint64',
	'libraries_io_repository_dependencies_200M_uint64',
	'wise_all_sky_data_htm_200M_uint64',
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

out = []
out2 = []

for d in datasets:
	print(d)
	if 'uint64' not in d:
		y = np.fromfile('../resources/' + d, dtype=np.uint32)[1:]
	else:
		y = np.fromfile('../resources/' + d, dtype=np.uint64)[1:]
	y = y.reshape(-1)
	y = np.sort(y) # keys
	x = np.arange(y.shape[0]) # index

	# y_re = y.reshape(-1, 1)[:10]
	# x_re = x.reshape(-1, 1)[:10]
	y_re = y.reshape(-1, 1)
	x_re = x.reshape(-1, 1)
	print(y_re)
	print(x_re)
	reg = LinearRegression(normalize=True).fit(y_re, x_re)
	reg2 = LinearRegression(normalize=True).fit(x_re, y_re)

	pred = reg.predict(y_re)
	pred2 = reg2.predict(x_re)
	error = mean_squared_error(x_re, pred)
	error2 = mean_squared_error(y_re, pred2)

	print(d, "{:.2e}".format(error))
	print(d, "{:.2e}".format(error2))
	out.append([d, error])
	out2.append([d, error2])

pd.DataFrame(out).to_csv('../mse.csv', index=False, header=None, mode='a')
pd.DataFrame(out2).to_csv('../mse2.csv', index=False, header=None, mode='a')

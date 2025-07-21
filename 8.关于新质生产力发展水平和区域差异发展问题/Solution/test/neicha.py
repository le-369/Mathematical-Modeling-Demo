import numpy as np
import pandas as pd

# 已知年份和对应的值
years = np.array([2012, 2013, 2021, 2022])
values = np.array([4164.34, 7612.12, 9976.43, 12013.1])

# 创建一个完整的年份范围
years_full = np.arange(2012, 2023)

# 使用 Pandas 的 interpolate 方法进行线性插值
df = pd.DataFrame({'Year': years, 'Value': values})
df = df.set_index('Year').reindex(years_full).interpolate(method='linear')

# 查看插值后的数据
print(df)

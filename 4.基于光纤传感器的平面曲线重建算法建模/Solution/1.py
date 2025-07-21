import numpy as np
import matplotlib.pyplot as plt

# y = -x^2 + sin(3x)+20cos(2x)
def f(x):
    return -x*x + np.sin(3*x) + 20*np.cos(2*x)

# y = e^(-(x-xc)^2/2)
def gaussian(x,xc):
    return np.exp(-(x-xc)**2/(2*(1**2)))

# get w from y' = \sum w_i\phi |x'-xc|
def calculate_weights(x_sample,y_sample):
    num = len(y_sample)
    int_matrix = np.asmatrix(np.zeros((num,num)))
    for i in range(num):
        int_matrix[i,:] = gaussian(x_sample, x_sample[i])
    w = int_matrix.I * np.asmatrix(y_sample).T      
    return w

# y' = \sum w_i\phi |x'-xc|
def calculate_rbf_value(w,x_sample,x):
    num = len(x)
    y_= np.zeros(num)
    for i in range(num):
        for k in range(len(w)):
            y_[i] = y_[i] + w[k]*gaussian(x[i],x_sample[k])
    return y_

def draw_kernels(x_samples,w):
    for i in range(len(x_samples)):
        x = x_samples[i]
        x_ = np.linspace(x-2,x+2,100)
        y_ = []
        for a in x_:
            y_.append(w[i]*gaussian(a,x))
        y_ = np.array(y_).reshape(100,-1)
        plt.plot(x_,y_,'m:')

if __name__ == '__main__':
    sample_cnt = 20
    x_start, x_end = -8, 8

    x = np.linspace(x_start,x_end,500)
    y = f(x)
    x_sample = np.linspace(x_start,x_end,sample_cnt)
    y_sample = f(x_sample)
    w = calculate_weights(x_sample,y_sample)
    y_fit = calculate_rbf_value(w,x_sample,x)

    plt.figure(1)
    plt.plot(x,y_fit,'k')
    plt.plot(x,y,'r:')
    plt.ylabel('y')
    plt.xlabel('x')
     
    plt.show()

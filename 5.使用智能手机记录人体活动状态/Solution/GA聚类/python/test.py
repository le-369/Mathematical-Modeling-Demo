import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
import warnings
warnings.filterwarnings('ignore')

# 初始化种群
def initialize_population(pop_size, num_chromosomes, num_genes, data):
    population = []
    for _ in range(pop_size):
        individual = []
        for _ in range(num_chromosomes):
            chromosome = np.random.choice(data.shape[0], num_genes, replace=False)
            individual.append(chromosome)
        population.append(np.array(individual))
    return np.array(population)

# 适应度函数
def fitness(individual, data, num_clusters=12):
    selected_data = []
    for chromosome in individual:
        selected_data.append(data.iloc[chromosome-1])
    selected_data = np.vstack(selected_data)
    kmeans = KMeans(n_clusters=num_clusters)
    kmeans.fit(selected_data)
    sse = kmeans.inertia_
    return 1e10 / (1 + sse)

# 选择操作
def select(population, fitness_scores, num_parents):
    parents_indices = np.random.choice(len(population), num_parents, p=fitness_scores/fitness_scores.sum())
    return np.squeeze(population[parents_indices])

# 交叉操作
def crossover(parent, crossover_rate=0.7):
    child = np.squeeze(parent.copy())
    if np.random.rand() < crossover_rate:
        # 随机选择两个染色体（行）进行交叉
        chrom1_idx, chrom2_idx = np.random.choice(12, 2, replace=False)
        chrom1, chrom2 = child[chrom1_idx], child[chrom2_idx]
        
        # 随机选择两个交叉点（基因）
        point1, point2 = sorted(np.random.choice(5, 2, replace=False))
        
        # 交换交叉点之间的基因片段
        temp1 = chrom1[point1:point2].copy()
        temp2 = chrom2[point1:point2].copy()
        chrom2[point1:point2] = temp1
        chrom1[point1:point2] = temp2

        # 更新child中的染色体
        child[chrom1_idx], child[chrom2_idx] = chrom1, chrom2
        
    return child

# 变异操作
def mutate(individual, mutation_rate=0.1):
    individual = np.squeeze(individual)
    if np.random.rand() < mutation_rate:
        # 随机选择两个染色体（行）进行变异
        chrom1_idx, chrom2_idx = np.random.choice(12, 2, replace=False)
        chrom1, chrom2 = individual[chrom1_idx], individual[chrom2_idx]
        
        # 随机选择一个基因进行交换
        gene1_idx, gene2_idx = np.random.choice(5, 2, replace=False)

        temp11 = chrom1[gene1_idx].copy()
        temp12 = chrom2[gene2_idx].copy()
        chrom1[gene1_idx] = temp12
        chrom2[gene2_idx] = temp11
        
        # 更新个体中的染色体
        individual[chrom1_idx], individual[chrom2_idx] = chrom1, chrom2
    
    return individual


# 遗传算法主函数
def genetic_algorithm(data, pop_size=20, num_generations=100, mutation_rate=0.1):
    num_chromosomes = 12
    num_genes = 5
    population = initialize_population(pop_size, num_chromosomes, num_genes, data)

    best_fitness_scores = []

    for generation in range(num_generations):
        fitness_scores = np.array([fitness(individual, data) for individual in population])

        # 记录当前代的最佳适应度
        best_fitness = np.max(fitness_scores)
        best_fitness_scores.append(best_fitness)

        new_population = []
        for _ in range(pop_size // 2):
            parents = select(population, fitness_scores, 1)
            child = crossover(parents)
            child = mutate(child, mutation_rate)
            new_population.extend([child])
        
        population = np.array(new_population)
    
    best_individual = population[np.argmax(fitness_scores)]
    return best_individual, best_fitness_scores

# 可视化训练过程
def plot_fitness(best_fitness_scores):
    plt.plot(best_fitness_scores)
    plt.xlabel('Generation')
    plt.ylabel('Best Fitness')
    plt.title('Genetic Algorithm Training Process')
    plt.show()

# 输出聚类结果
def output_clustering(data, best_individual, num_clusters=12):
    selected_data = []
    for chromosome in best_individual:
        selected_data.append(data.iloc[chromosome-1])
    selected_data = np.vstack(selected_data)
    kmeans = KMeans(n_clusters=num_clusters)
    kmeans.fit(selected_data)
    labels = kmeans.labels_
    
    # 输出聚类结果
    for i, chromosome in enumerate(best_individual):
        print(f"Cluster {i + 1}:")
        print(data.iloc[chromosome-1])
        print("\n")
    
    return labels

if __name__ == "__main__":
    features = pd.read_excel(r'../../问题1/features.xlsx')

    best_clustering, best_fitness_scores = genetic_algorithm(features)

    # 可视化训练过程
    plot_fitness(best_fitness_scores)

    # 输出聚类结果
    labels = output_clustering(features, best_clustering)

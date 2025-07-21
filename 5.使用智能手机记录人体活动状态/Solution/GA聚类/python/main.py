import numpy as np
from sklearn.cluster import KMeans
import pandas as pd
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
    return 1 / (1 + sse)

# 选择操作
def select(population, fitness_scores, num_parents):
    parents = np.random.choice(population.shape[0], num_parents, p=fitness_scores/fitness_scores.sum())
    return population[parents]

# 交叉操作
def crossover(parent1, parent2):
    child1, child2 = parent1.copy(), parent2.copy()
    for i in range(len(parent1)):
        if np.random.rand() < 0.5:  # 以50%的概率进行染色体交叉
            cross_point = np.random.randint(1, len(parent1[i]))
            child1[i, :cross_point], child2[i, :cross_point] = parent2[i, :cross_point], parent1[i, :cross_point]
    return child1, child2

# 变异操作
def mutate(individual, mutation_rate=0.1):
    for i in range(len(individual)):
        if np.random.rand() < mutation_rate:
            swap_indices = np.random.choice(len(individual[i]), 2, replace=False)
            individual[i, swap_indices[0]], individual[i, swap_indices[1]] = individual[i, swap_indices[1]], individual[i, swap_indices[0]]
    return individual

# 遗传算法主函数
def genetic_algorithm(data, pop_size=20, num_generations=100, mutation_rate=0.1):
    num_chromosomes = 12
    num_genes = 5
    population = initialize_population(pop_size, num_chromosomes, num_genes, data)

    for generation in range(num_generations):
        fitness_scores = np.array([fitness(individual, data) for individual in population])
        
        new_population = []
        for _ in range(pop_size // 2):
            parents = select(population, fitness_scores, 2)
            child1, child2 = crossover(parents[0], parents[1])
            child1 = mutate(child1, mutation_rate)
            child2 = mutate(child2, mutation_rate)
            new_population.extend([child1, child2])
        
        population = np.array(new_population)
    
    best_individual = population[np.argmax(fitness_scores)]
    return best_individual

if __name__=="__main__":
    features = pd.read_excel(r'../../问题1/features.xlsx')

    best_clustering = genetic_algorithm(features)
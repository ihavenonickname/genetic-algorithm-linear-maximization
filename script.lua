local math = require 'math'
local os = require 'os'
local mutation_probability = 5

local function generate_fitness_function(multipliers, constraints)
    local function multiply(solution, multipliers)
        local total = 0

        for i = 1, #solution do
            total = total + solution[i] * multipliers[i]
        end

        return total
    end

    return function(solution)
        for _, v in ipairs(solution) do
            if v <= 0 then
                return -1
            end
        end

        for _, constraint in ipairs(constraints) do
            if multiply(solution, constraint.lhs) > constraint.rhs then
                return 0
            end
        end

        return multiply(solution, multipliers)
    end
end

local function crossover(solution1, solution2)
    local max = #solution1
    local new_solution = {}

    for i = 1, max do
        if math.random(100) > mutation_probability then
            if i % 2 == 0 then
                new_solution[i] = solution1[i]
            else
                new_solution[i] = solution2[i]
            end
        else
            if math.random() > 0.5 then
                new_solution[i] = solution1[i] + 1
            else
                new_solution[i] = solution1[i] - 1
            end
        end
    end

    return new_solution
end

local function initialize_random_module()
    math.randomseed(os.time())
    for i = 1, 10 do
        math.random()
    end
end

local function update_next_generation(fitness, population)
    table.sort(population, function (solution1, solution2)
        return fitness(solution1) > fitness(solution2)
    end)

    local k = #population / 10

    for i = k, #population do
        solution1 = population[math.random(k)]
        solution2 = population[math.random(k)]
        population[i] = crossover(solution1, solution2)
    end
end

function test()
    initialize_random_module()

    local fitness = generate_fitness_function({2, 3, 4}, {
        {lhs = {2, 3, 1}, rhs = 10},
        {lhs = {2, 3, 3}, rhs = 15},
        {lhs = {1, 1, 1}, rhs = 8},
    })

    local population = {}

    for i = 1, 1000 do
        population[i] = {
            math.random(1, 10),
            math.random(1, 10),
            math.random(1, 20)
        }
    end

    for i = 1, 1000 do
        update_next_generation(fitness, population)
        print(table.concat(population[1], ", "), fitness(population[1]))
        -- print(fitness(population[1]))
    end
    print(table.concat(population[1], ", "), fitness(population[1]))
end

test()

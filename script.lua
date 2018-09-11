local math = require 'math'
local os = require 'os'
local mutation_probability = 1 / 100

local function generate_fitness_function(multipliers, constraints)
    local multipliers_count = #multipliers

    local function multiply(solution, multipliers)
        local total = 0

        for i = 1, multipliers_count do
            total = total + solution[i] * multipliers[i]
        end

        return total
    end

    return function(solution)
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
    local variation

    for i = 1, max do
        if math.random() > mutation_probability then
            if i % 2 == 0 then
                new_solution[i] = solution1[i]
            else
                new_solution[i] = solution2[i]
            end
        else
            variation = math.abs(solution1[i] - solution2[i] + 1) * 2

            if math.random() > 0.5 then
                new_solution[i] = solution1[i] + variation
            else
                new_solution[i] = solution1[i] - variation
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

function test()
    initialize_random_module()

    local fitness = generate_fitness_function({9, 14}, {
        {lhs = {60, 80}, rhs = 3200},
        {lhs = {1, 2}, rhs = 120},
        {lhs = {4, 5}, rhs = 900},
    })

    local function comparer(solution1, solution2)
        return fitness(solution1) > fitness(solution2)
    end

    local population = {}

    for i = 1, 1000 do
        population[i] = {math.random(1, 100), math.random(1, 100)}
    end

    table.sort(population, comparer)
    local c = 0
    for i = 1, #population do
        local f = fitness(population[i])
        if f > 0 then
            c = c + 1
            print(table.concat(population[i], ", "), f)
        end
    end
    print(c)
end

test()

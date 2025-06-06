using Plots
gr()

"""
This function returns the state of a cell, based on its neighborhood and the given rule number.
"""
function apply_rule(left::Int, center::Int, right::Int, rule_number::Int)::Int
    neighborhood_value = left * 4 + center * 2 + right * 1
    return (rule_number >> neighborhood_value) & 1
end

"""
This function simulates a 1D cellular automaton given an initial state, a rule number, and the number of generations.
After the simulation, it returns the history of states.
"""
function simulate_ca(initial_state::Vector{Int}, rule_number::Int, num_generations::Int)::Vector{Vector{Int}}
    if rule_number < 0 || rule_number > 255
        error("The rule number must be between 0 and 255.")
    end

    history = [initial_state]
    current_state = initial_state
    len = length(current_state)

    for generation = 1:num_generations
        next_state = zeros(Int, len)
        for i = 1:len
            left_neighbor_index = (i == 1) ? len : i - 1
            right_neighbor_index = (i == len) ? 1 : i + 1
            left = current_state[left_neighbor_index]
            center = current_state[i]
            right = current_state[right_neighbor_index]
            next_state[i] = apply_rule(left, center, right, rule_number)
        end
        push!(history, next_state)
        current_state = next_state
    end

    return history
end

"""
This function plots the history of a 1D cellular automaton simulation using the Plots.jl package.
It takes a history of states, colors for alive and dead cells, and a title for the plot.
"""
function plot_ca_history(history::Vector{Vector{Int}};
    alive_color=:black, dead_color=:white,
    title="Cellular Automaton History")

    num_generations = length(history)
    if num_generations == 0
        return
    end
    cell_count = length(history[1])

    matrix = Matrix{Int}(undef, num_generations, cell_count)

    for i = 1:num_generations
        matrix[i, :] = history[i]
    end

    colors = [dead_color, alive_color]

    p = heatmap(matrix,
        colormap=colors,
        yflip=true,
        colorbar=false,
        aspect_ratio=:auto,
        xlabel="Cells",
        ylabel="Generations",
        title=title,
        grid=false,
    )

    display(p)
end

"""
Here we define the initial state, rule number, and number of generations for the simulation.
We then simulate the cellular automaton and plot the results.
The user can modify the initial state, rule number, and number of generations as needed.
"""

initial_state_plot = zeros(Int, 101)
initial_state_plot[51] = 1

rule_number_plot = 1

num_generations_plot = 50

history = simulate_ca(initial_state_plot, rule_number_plot, num_generations_plot)

plot_ca_history(history, title="Cellular Automaton - Rule $(rule_number_plot)")
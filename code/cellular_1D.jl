using Plots
gr()

function apply_rule(left::Int, center::Int, right::Int, rule_number::Int)::Int
    neighborhood_value = left * 4 + center * 2 + right * 1
    return (rule_number >> neighborhood_value) & 1
end

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


initial_state_plot = zeros(Int, 101)
initial_state_plot[51] = 1

rule_number_plot = 1

num_generations_plot = 50

history = simulate_ca(initial_state_plot, rule_number_plot, num_generations_plot)

plot_ca_history(history, title="Cellular Automaton - Rule $(rule_number_plot)")
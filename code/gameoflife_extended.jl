using Plots
gr()

"""
This module implements the Infection Simulation referenced in the paper.
"""

struct Cell
    color::Symbol
end

"""
This function initializes a grid with 50% white, 15% red, and 35% blue cells.
It takes the number of rows and columns as parameters.
"""
function initialize_grid(rows::Int, cols::Int)::Matrix{Cell}

    grid = fill(Cell(:white), rows, cols)

    for r in 1:rows
        for c in 1:cols
            rand_val = rand()
            if rand_val < 0.5
                grid[r, c] = Cell(:white)
            elseif rand_val < 0.65
                grid[r, c] = Cell(:red)
            else
                grid[r, c] = Cell(:blue)
            end
        end
    end
    return grid
end

"""
This function counts the number of neighboring cells of each color around a cell at position (r, c) in the grid.
It wraps around the edges of the grid.
"""
function count_neighbor_colors(grid::Matrix{Cell}, r::Int, c::Int)::Dict{Symbol,Int}
    rows, cols = size(grid)
    color_counter = Dict(:black => 0, :white => 0, :red => 0, :blue => 0)

    for i in -1:1
        for j in -1:1
            if i == 0 && j == 0
                continue
            end
            nr = mod1(r + i, rows)
            nc = mod1(c + j, cols)
            color_counter[grid[nr, nc].color] += 1
        end
    end
    return color_counter
end

"""
This function updates the state of a cell based on the rules of the Infection Simulation.
It returns a new Cell object with the updated color.
"""
function update_cell(current_grid::Matrix{Cell}, r::Int, c::Int)::Cell
    color_count = count_neighbor_colors(current_grid, r, c)
    current_color = current_grid[r, c].color
    if current_color == :blue
        if (color_count[:red] == 1 || color_count[:red] == 2) && rand() < 0.2 * color_count[:red]
            return Cell(:red)
        end
        if color_count[:red] >= 3
            return Cell(:red)
        end
        if 2 <= color_count[:blue] && color_count[:blue] <= 5
            return Cell(:blue)
        else
            return Cell(:white)
        end
    elseif current_color == :red
        if color_count[:red] >= 3 && color_count[:red] <= 6 && rand() < 0.99
            return Cell(:red)
        else
            return Cell(:white)
        end
    elseif current_color == :white
        if color_count[:blue] == 3
            return Cell(:blue)
        end
    end

    return Cell(current_color)
end

"""
This function updates the entire grid by iterating through each cell and applying the update rules.
It returns a new grid with the updated cell states.
"""
function update_grid(current_grid::Matrix{Cell})::Matrix{Cell}
    rows, cols = size(current_grid)
    new_grid = fill(Cell(:white), rows, cols)

    for r in 1:rows
        for c in 1:cols
            new_grid[r, c] = update_cell(current_grid, r, c)
        end
    end
    return new_grid
end

"""
This function runs the Infection Simulation live, updating the grid and displaying it in real-time.
It takes the number of rows, columns, generations, and an optional delay as parameters.
"""
function run_game_of_life_live(rows::Int, cols::Int, generations::Int,
    delay::Float64=0.1)
    grid = initialize_grid(rows, cols)
    symbol_to_int_map = Dict(
        :black => 0,
        :white => 1,
        :red => 2,
        :blue => 3
    )
    plot_colors = [
        colorant"black",
        colorant"white",
        colorant"red",
        colorant"blue"
    ]
    num_categories = length(plot_colors)
    categorical_palette = cgrad(plot_colors, num_categories, categorical=true)
    plot_clims = (-0.5, num_categories - 0.5)

    println("Starting Conway's Game of Life simulation...")


    for gen in 1:generations
        println("Generation: $gen / $generations")
        display_grid = [symbol_to_int_map[cell.color] for cell in grid]
        current_plot = heatmap(display_grid,
            color=categorical_palette,
            clims=plot_clims,
            aspect_ratio=:equal,
            legend=false,
            ticks=false,
            framestyle=:none,
            title="Conway's Game of Life - Generation $gen")
        display(current_plot)
        grid = update_grid(grid)
        sleep(delay)
    end
    println("Simulation completed after $generations generations.")
end

"""
This function creates a GIF of the Infection Simulation.
It takes the number of rows, columns, generations, frames per second and the filename as parameters.
"""
function create_game_of_life_gif(rows::Int, cols::Int, generations::Int, fps::Int=10,
    filename::String="game_of_life.gif")

    grid = initialize_grid(rows, cols)
    println("Starting GIF creation for Conway's Game of Life...")

    symbol_to_int_map = Dict(
        :black => 0,
        :white => 1,
        :red => 2,
        :blue => 3
    )
    plot_colors = [
        colorant"black",
        colorant"white",
        colorant"red",
        colorant"blue"
    ]
    num_categories = length(plot_colors)
    categorical_palette = cgrad(plot_colors, num_categories, categorical=true)
    plot_clims = (-0.5, num_categories - 0.5)

    anim = Animation()

    for gen in 1:generations

        display_grid = [symbol_to_int_map[cell.color] for cell in grid]
        current_plot = heatmap(display_grid,
            color=categorical_palette,
            clims=plot_clims,
            aspect_ratio=:equal,
            legend=false,
            ticks=false,
            framestyle=:none,
            title="Conway's Game of Life - Generation $gen")

        frame(anim, current_plot)

        grid = update_grid(grid)

        if gen == generations
            println("All generations processed for the GIF.")
        end
    end

    println("Saving GIF to '$filename' (with $fps FPS)...")
    try
        gif(anim, filename, fps=fps)
        println("GIF successfully saved: $filename")
    catch e
        println("Error saving the GIF: $e")
        println("Ensure the GR backend is functioning correctly.")
    end
end

"""
Here we define the parameters for the Infection Simulation.
You can adjust the grid size, number of generations, and animation delay as needed.
"""

grid_rows = 100
grid_cols = 100
num_generations = 1000
animation_delay = 0.01

run_game_of_life_live(grid_rows, grid_cols, num_generations, animation_delay)
# create_game_of_life_gif(grid_rows, grid_cols, num_generations, floor(Int, 1 / animation_delay), "infection_simulation.gif")
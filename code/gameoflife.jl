using Plots
gr()

"""
This function returns a grid (matrix) initialized with random live cells based on the specified density.
It takes the number of rows, columns, and an optional density parameter (default is 0.3).
"""
function initialize_grid(rows::Int, cols::Int, density::Float64=0.3)::Matrix{Bool}
    grid = falses(rows, cols)
    for r in 1:rows
        for c in 1:cols
            if rand() < density
                grid[r, c] = true
            end
        end
    end
    return grid
end

"""
This function counts the number of live neighbors around a cell at position (r, c) in the grid.
It wraps around the edges of the grid.
"""
function count_live_neighbors(grid::Matrix{Bool}, r::Int, c::Int)::Int
    rows, cols = size(grid)
    count = 0

    for i in -1:1
        for j in -1:1
            if i == 0 && j == 0
                continue
            end
            nr = mod1(r + i, rows)
            nc = mod1(c + j, cols)
            if grid[nr, nc]
                count += 1
            end
        end
    end
    return count
end

"""
This function updates the state of a cell based on the rules of Conway's Game of Life.
It returns true if the cell is alive in the next generation, false otherwise.
"""
function update_cell(current_grid::Matrix{Bool}, r::Int, c::Int)::Bool
    live_neighbors = count_live_neighbors(current_grid, r, c)
    is_alive = current_grid[r, c]

    if is_alive
        return live_neighbors == 2 || live_neighbors == 3
    else
        return live_neighbors == 3
    end
end

"""
This function updates the entire grid based on the current state of the grid.
It iterates through each cell and applies the update rules.
"""
function update_grid(current_grid::Matrix{Bool})::Matrix{Bool}
    rows, cols = size(current_grid)

    new_grid = falses(rows, cols)

    for r in 1:rows
        for c in 1:cols
            new_grid[r, c] = update_cell(current_grid, r, c)
        end
    end
    return new_grid
end

"""
This function runs a live simulation of Conway's Game of Life.
It takes the number of rows, columns, generations, delay between generations, and an optional density parameter.
It displays the grid at each generation using a heatmap.
"""
function run_game_of_life_live(rows::Int, cols::Int, generations::Int,
    density::Float64=0.3, delay::Float64=0.1)
    grid = initialize_grid(rows, cols, density)

    println("Starting Conway's Game of Life simulation...")

    for gen in 1:generations
        println("Generation: $gen / $generations")

        display_grid = Int.(grid)
        current_plot = heatmap(display_grid,
            c=cgrad([:white, :black]),
            aspect_ratio=:equal,
            legend=false,
            ticks=false,
            framestyle=:none,
            title="Conway's Game of Life - Generation $gen")
        display(current_plot)

        grid = update_grid(grid)

        sleep(delay)

        if gen == generations
            println("Simulation completed after $generations generations.")
        end
    end
end

"""
This function also runs Conway's Game of Life but creates a GIF of the generations instead of displaying them live.
It takes the number of rows, columns, generations, filename for the GIF, frames per second (fps), and an optional density parameter.
"""
function create_game_of_life_gif(rows::Int, cols::Int, generations::Int, density::Float64=0.3,
    fps::Int=10,
    filename::String="game_of_life.gif",
)

    grid = initialize_grid(rows, cols, density)
    println("Starting GIF creation for Conway's Game of Life...")

    anim = Animation()

    for gen in 1:generations
        println("Processing generation: $gen / $generations for GIF...")
        display_grid = Int.(grid)
        current_plot = heatmap(display_grid,
            c=cgrad([:white, :black]),
            aspect_ratio=:equal,
            legend=false,
            ticks=false,
            framestyle=:none,
            title="Conway's Game of Life - Generation $gen")

        frame(anim, current_plot)

        grid = update_grid(grid)
    end
    println("All generations processed for the GIF.")
    println("Saving GIF to '$filename' (with $fps FPS)...")
    try
        gif(anim, filename, fps=fps)
        println("GIF successfully saved: $filename")
    catch e
        println("Error saving the GIF: $e")
    end
end

"""
Here we define the parameters for the Game of Life simulation.
You can adjust the grid size, number of generations, animation delay, and initial density of live cells.
"""

grid_rows = 60
grid_cols = 80
num_generations = 100
animation_delay = 0.01
initial_density = 0.25

"""
Here you can choose to run the live simulation or create a GIF.
"""

run_game_of_life_live(grid_rows, grid_cols, num_generations, initial_density, animation_delay)
# create_game_of_life_gif(grid_rows, grid_cols, num_generations, initial_density, floor(Int, 1 / animation_delay))
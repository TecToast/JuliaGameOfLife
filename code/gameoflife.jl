using Plots
gr()

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


function update_cell(current_grid::Matrix{Bool}, r::Int, c::Int)::Bool
    live_neighbors = count_live_neighbors(current_grid, r, c)
    is_alive = current_grid[r, c]

    if is_alive
        return live_neighbors == 2 || live_neighbors == 3
    else
        return live_neighbors == 3
    end
end

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

function run_game_of_life_live(rows::Int, cols::Int, generations::Int,
    delay::Float64=0.1, density::Float64=0.3)
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


function create_game_of_life_gif(rows::Int, cols::Int, generations::Int,
    filename::String="game_of_life.gif",
    fps::Int=10,
    density::Float64=0.3)

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


grid_rows = 60
grid_cols = 80
num_generations = 100
animation_delay = 0.01
initial_density = 0.25


# run_game_of_life_live(grid_rows, grid_cols, num_generations, animation_delay, initial_density)
create_game_of_life_gif(grid_rows, grid_cols, num_generations)
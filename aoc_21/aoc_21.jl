module aoc_21

export IngredientList, read_input
export ingredients, allergies

const ingredients_r = r"([a-z\s]*)\(contains ([a-z,\s]*)\)"

struct IngredientList
    ingredients::Set{String}
    allergies::Set{String}
end

ingredients(list::IngredientList) = list.ingredients
allergies(list::IngredientList) = list.allergies

import Base.intersect
function intersect(s::IngredientList, lists::IngredientList...)
    i = intersect( s.ingredients, ingredients.(lists)... )
    a = intersect( s.allergies, allergies.(lists)... )
    IngredientList( i, a )
end

const IngredientLists = Set{IngredientList}

function read_input(filename="input.txt")
    lines = readlines(filename)
    lists = IngredientLists()
    # count = 0
    for line in lines
        m = match(ingredients_r, line)
        ingredients = split(strip(m.captures[1])," ")
        # count += length(ingredients)
        allergies = split(strip(m.captures[2]),", ")
        push!(lists, IngredientList(Set(ingredients), Set(allergies)) )
    end
    # println(count)
    lists
end

function build_map(lists::IngredientLists)
    allergies_to_lists = Dict{String,IngredientLists}()
    for list in lists
        for allergy in list.allergies
            current_lists = get(allergies_to_lists, allergy, IngredientLists())
            push!(current_lists, list)
            allergies_to_lists[ allergy ] = current_lists
        end
    end
    allergies_to_lists
end

function constrain(lists::IngredientLists,
                   allergies_to_lists::Dict{String,IngredientLists} = build_map(lists))
    ingredients_to_allergies = Dict{String,String}()

    change = true

    #while( length(ingredients_to_allergies) < length(allergies_to_lists) )
    while( change )

    change = false

    for (allergy, lists) in allergies_to_lists
        intersection = intersect(lists...) 
        if length(intersection.ingredients) == 1 && first(intersection.allergies) == allergy
            ingredient = first(intersection.ingredients)
            ingredients_to_allergies[ ingredient ] = allergy
            # pop!.( ingredients.(lists), ingredient, nothing )
            # pop!.( allergies.(lists), allergy, nothing )
            pop!( allergies_to_lists, allergy )
            for list in Iterators.flatten( values(allergies_to_lists) )
                pop!( list.ingredients, ingredient, nothing )
                pop!( list.allergies, allergy, nothing )
            end
            change = true
        end
    end

    # println(ingredients_to_allergies)

    end

    for (allergy, lists) in allergies_to_lists
        # remaining_ingredient_list = intersect(lists...)
        # allergies_to_lists[ allergy ] = Set([ remaining_ingredient_list ])
        # [pop!.( ingredients.(lists) , ingredient, nothing) for ingredient in ingredients(remaining_ingredient_list)]
    end

    (lists, ingredients_to_allergies, allergies_to_lists)
end

function solve(input = read_input())
    out = constrain( deepcopy(input) )
    allergens = keys( out[2] )
    # allergens = union( keys(out[2]), ingredients.( first.( values( out[3] ) ) ) ... )
    input_a = [input...]
    [ pop!.( ingredients.(input_a) , allergen, nothing ) for allergen in allergens]
    count = sum(length.(ingredients.(input_a)))
    list_of_allergens = join(first.( sort( collect(out[2]) , by=p->p.second) ),",")
    (count, list_of_allergens)
    # 2262
end

part1() = solve()[1]
part2() = solve()[2]

end
module aoc_22
    using DataStructures

    export read_input, play!, score, part1

    player_r = r"Player (\d):"

    const Decks = Tuple{Deque{Int},Deque{Int}}

    function read_input(filename = "input.txt")
        decks = (Deque{Int}(), Deque{Int}())
        lines = readlines(filename)
        player = 0
        for line in lines
            if isempty(line)
                player = 0
                continue
            end
            if player == 0
                m = match(player_r ,line)
                player = parse(Int, m.captures[1])
                continue
            end
            push!( decks[ player ], parse( Int, line ) )
        end
        decks
    end

    function play!( decks::Decks = read_input() )
        while !any( isempty.(decks) )
            cards = popfirst!.(decks)
            if(>( cards ... ))
                push!.( (decks[1],) , cards )
            else
                push!.( (decks[2],) , reverse(cards) )
            end
            # @info "Turn"
            # println( decks[1] )
            # println( decks[2] )
        end
        decks
    end

    function score( decks::Decks )
        winner = decks[ [ .~isempty.(decks)... ] ][1]
        sum(winner .* (length(winner):-1:1))
    end

    part1( input = read_input() ) = score( play!() )

    # Part 2
    # const previous_decks = Set{ Decks }()
    # game_counter = 1
    # recurrence = false

    function play2!( decks::Decks = read_input(), game_counter = Ref(0) )
        # previous_decks = Vector{ Decks }()
        previous_decks = Vector{ UInt64 }()

        game_counter[] += 1
        this_game = game_counter[]
        #if game_counter[] % 1000 == 0
        #    @info "Game $(game_counter[])"
        #end

        #    @info "Start"
        #    println( decks[1] )
        #    println( decks[2] )

        round_counter = 1

        while !any( isempty.(decks) )
            # @info "Round $round_counter of Game $this_game"
            # println( decks[1] )
            # println( decks[2] )
            decks_hash = hash(decks)
            if decks_hash in previous_decks
                # @info "Player 1 wins game $this_game due to recurrence!"
                # global recurrence = true
                empty!( decks[2] )
                return decks
            else
                push!( previous_decks, decks_hash )
            end
            cards = popfirst!.(decks)

            decks_longer_than_cards = length.(decks) .>= cards

            if( all( decks_longer_than_cards) )
                # @info "Subgame!"
                sub_deck = (Deque{Int}(), Deque{Int}())
                push!.( (sub_deck[1],), collect(decks[1])[1:cards[1]] )
                push!.( (sub_deck[2],), collect(decks[2])[1:cards[2]] )
                subgame_decks = play2!( sub_deck, game_counter )
                # if recurrence
                #    empty!( decks[2] )
                #    return decks
                # end
                winner = findfirst( .~isempty.(subgame_decks) )
                if winner == 2
                    cards = reverse(cards)
                end
                push!.( (decks[ winner ],), cards )
                # @info "Player $winner wins round $round_counter in game $this_game"
                continue
            end

            if(>( cards ... ))
                push!.( (decks[1],) , cards )
                # @info "Player 1 wins round in game $this_game"
            else
                push!.( (decks[2],) , reverse(cards) )
                # @info "Player 2 wins round game $this_game"
            end
            # println( decks[1] )
            # println( decks[2] )
            # sleep( 1 )
            round_counter += 1
        end
        return decks
    end

    function part2( input = read_input() )
        # global recurrence = false
        # empty!(previous_decks)
        game_counter = Ref(0)
        s = score( play2!( input, game_counter ) )
        # @info "Game counter: $(game_counter[])"
        return s
        # 30498
    end

    function __init__()
        input = read_input()
        println( part1( input ) )
        println( part2( input ) )
    end
end
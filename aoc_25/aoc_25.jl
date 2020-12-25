module aoc_25
    using Test

    export transformer, demo_card_public_key, demo_door_public_key
    export transform_subject, input
    export test_part1
    const transformer = 20201227

    const input = (6270530, 14540258)

#= The card transforms the subject number of 7 according to the card's secret loop size. The result is called the card's public key.
The door transforms the subject number of 7 according to the door's secret loop size. The result is called the door's public key.
The card and door use the wireless RFID signal to transmit the two public keys (your puzzle input) to the other device. Now, the card has the door's public key, and the door has the card's public key. Because you can eavesdrop on the signal, you have both public keys, but neither device's loop size.
The card transforms the subject number of the door's public key according to the card's loop size. The result is the encryption key.
The door transforms the subject number of the card's public key according to the door's loop size. The result is the same encryption key as the card calculated. =#

    const demo_card_public_key = 5764801
    const demo_door_public_key = 17807724

    function transform_subject(subject, max_loop_size, divisor = transformer; value::Int = 1)
        #out = Vector{Int}(undef, max_loop_size )
        for loop_size = 1:max_loop_size
            value *= subject
            value = rem( value, divisor )
            #out[ loop_size ] = value
        end
        value
    end

    export get_loop_numbers
    function get_loop_numbers(public_key::Int; subject = 7)
        loop_size = 0
        value = 1
        n = 1
        while true
            value *= subject
            value = rem( value, transformer )
            if value == public_key
                loop_size = n
                break
            end
            n += 1
        end
        n
    end
    function get_loop_numbers(public_key_1, public_key_2; subject = 7)
        if public_key_1 == public_key_2
            loop_size = get_loop_numbers(public_key_1)
            return loop_size, loop_size
        end
        loop_size_1 = 0
        loop_size_2 = 0
        value = Int(1)
        n = 1
        while loop_size_1 == 0 || loop_size_2 == 0
            value *= subject
            value = rem( value, transformer )
            if value == public_key_1
                loop_size_1 = n
            elseif value == public_key_2
                loop_size_2 = n
            end
            n += 1
        end
        loop_size_1, loop_size_2
    end

    export part1
    function part1()
        loop_sizes = get_loop_numbers.(input)
        encryption_key = transform_subject.(reverse(input), loop_sizes)
        encryption_key[1]
    end

    function test_part1()
        @test 8 == get_loop_numbers( demo_card_public_key )
        @test 11 == get_loop_numbers( demo_door_public_key )
        @test 16311885 == part1()
    end

end
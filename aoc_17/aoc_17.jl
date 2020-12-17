module aoc_17
    export read_input

    const instruction_r = r"([a-z]*) ([+\-]*[0-9]*)"

    const nop = UInt8(0)
    const acc = UInt8(1)
    const jmp = UInt8(2)

    const code_dict = Dict("nop" => nop, "acc" => acc, "jmp" => jmp)

    struct Instruction
        code::UInt8
        value::Int64
    end

    function read_input(filename)
        lines = readlines(filename)
        parse_instruction.(lines)
    end

    function parse_instruction(line::AbstractString)
        m = match(instruction_r , line)
        Instruction(
            code_dict[ m.captures[1] ],
            parse(Int64, m.captures[2] )
        )
    end

    function evaluate(in::Vector{Instruction}, accumulator = 0, i = 1, evaluated = falses( size(in) ))
        while !evaluated[i]
            evaluated[i] = true
            println("i: {$i}")
            if in[i].code == nop
                i += 1
            elseif in[i].code == acc
                accumulator += in[i].value
                i += 1
            elseif in[i].code == jmp
                i += in[i].value
            end
        end
        return accumulator
    end
    function evaluate_and_fix(in::Vector{Instruction}, accumulator = 0, i = 1, evaluated = falses( size(in) ), switched = false)
        last = length(in)
        while i <= last && !evaluated[i]
            evaluated[i] = true
            # println("i: {$i}")
            if in[i].code == nop || in[i].code == jmp
                # nop
                if in[i].code == nop || !switched
                    nop_eval = evaluate_and_fix(in, accumulator, i + 1, copy(evaluated), switched || in[i].code == jmp)
                    if nop_eval[1]
                        @info "Switched", in[i].code == jmp, i
                        return nop_eval
                    end
                end
                # jmp
                if in[i].code == jmp || !switched
                    jmp_eval = evaluate_and_fix(in, accumulator, i + in[i].value, copy(evaluated), switched || in[i].code == nop)
                    if jmp_eval[1]
                        @info "Switched", in[i].code == nop, i
                        return jmp_eval
                    end
                end
            elseif in[i].code == acc
                accumulator += in[i].value
                i += 1
            end
        end
        if i <= last
            #@info "Failed at ", i
            return (false, accumulator)
        else
            return (true, accumulator)
        end
    end

end
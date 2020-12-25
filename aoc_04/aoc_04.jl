module aoc_04
    using Test
    export read_input, part1, part2
    export test_part1, test_part2, test
    export input, demo
    export required_keys

    const input_r = r"([a-z]*):(\S*)"

# byr (Birth Year)
# iyr (Issue Year)
# eyr (Expiration Year)
# hgt (Height)
# hcl (Hair Color)
# ecl (Eye Color)
# pid (Passport ID)
# cid (Country ID)

    const required_keys = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]

    function read_input(filename = "input.txt")
        lines = readlines(filename)
        # for line in eachline(filename)
        passports = Vector{Dict{String,String}}()
        data = Vector{Pair{String,String}}()
        for line in lines
            if isempty(line)
                push!(passports, Dict(data))
                empty!(data)
            else
                append!(data, [m.captures[1] => m.captures[2] for m in eachmatch(input_r, line)])
            end
        end
        push!(passports, Dict(data))
        # [parse_line(line) for line in eachline(filename)]
        passports
    end

    function parse_line(line)
    end

    const input = read_input("input.txt")
    const demo = read_input("demo.txt")

    function part1(input = input)
        N = length(required_keys)
        sum([sum(in.(required_keys,(keys(passport),))) == N for passport in input])
    end

    function test_part1()
        part1( demo )
    end

# byr (Birth Year) - four digits; at least 1920 and at most 2002.
# iyr (Issue Year) - four digits; at least 2010 and at most 2020.
# eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
# hgt (Height) - a number followed by either cm or in:
# If cm, the number must be at least 150 and at most 193.
# If in, the number must be at least 59 and at most 76.
# hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
# ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
# pid (Passport ID) - a nine-digit number, including leading zeroes.
# cid (Country ID) - ignored, missing or not.

    function validate(pair::Pair)
        key = pair.first
        value = pair.second
        try

        if key == "byr"
            1920 <= parse(Int,value) <= 2002
        elseif key == "iyr"
            2010 <= parse(Int,value) <= 2020
        elseif key == "eyr"
            2020 <= parse(Int,value) <= 2030
        elseif key == "hgt"
            m = match(r"(\d*)(in|cm)$",value)
            if isnothing(m)
                return false
            end
            height = parse(Int,m.captures[1])
            if m.captures[2] == "cm"
                150 <= height <= 193
            elseif m.captures[2] == "in"
                59 <= height <= 76
            else
                false
            end
        elseif key == "hcl"
            occursin(r"\#[0-9a-f]{6}", value)
        elseif key == "ecl"
            value ∈ ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
        elseif key == "pid"
            occursin(r"^[0-9]{9}$",value)
        elseif key == "cid"
            false
        else
            println(key)
            false
        end

        catch e
            println(e)
            println(key)
            println(value)
        end
    end

    function part2(input = input)
        N = length(required_keys)
        sum([sum(in.(required_keys,(keys(passport),))) == N && sum(validate.(collect(passport))) >= N for passport in input])
    end

    function test_part2()
        @test part2( demo ) == 2
        @test validate("byr" => "2002")
        @test !validate("byr" => "2003")
        @test validate("hgt" => "60in")
        @test validate("hgt" => "190cm")
        @test !validate("hgt" => "190in")
        @test !validate("hgt" => "190")
        @test validate("hcl" => "#123abc")
        @test !validate("hcl" => "#123abz")
        @test !validate("hcl" => "123abz")
        @test validate("ecl" => "brn")
        @test !validate("ecl" => "wat")
        @test validate("pid" => "000000001")
        @test !validate("pid" => "0123456789")
        @test part2( read_input("invalid.txt") ) == 0
        @test part2( read_input("valid.txt") ) == 4
        @test part2() == 101
    end

    function test()
        test_part1()
        test_part2()
    end
end
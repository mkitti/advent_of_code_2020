module aoc_19

export SimpleRule, SeriesRule, CompoundRule, LoopingRule

abstract type AbstractRule end

struct SimpleRule <: AbstractRule
    rule::Regex
end
struct SeriesRule <: AbstractRule
    rules::Vector{Int}
end
struct CompoundRule <: AbstractRule
    rules::Tuple{SeriesRule,SeriesRule}
end
struct LoopingRule <: AbstractRule
    rule::CompoundRule
end

import Base.|
|(a::Regex, b::Regex) = Regex( "(?:" * a.pattern * ")" * "|" * "(?:" * b.pattern * ")" )

const rules_dict = Dict{Int,AbstractRule}()

Regex(r::SimpleRule) = r.rule
Regex(r::SeriesRule) = *( Regex.( [ rules_dict[i] for i in r.rules])... )
Regex(r::CompoundRule) = Regex(r.rules[1]) | Regex(r.rules[2])
function Regex(r::LoopingRule, n)
    inner = r.rule
    if rules_dict[ inner.rules[2].rules[end] ] == r
        # Rule 8: sub-rule can repeat
        first_rule = Regex(inner.rules[1])
        return Regex( "(?:" * first_rule.pattern * ")+" )
    elseif rules_dict[ inner.rules[2].rules[2] ] == r
        # Rule 11: sub-rules must repeat exactly n times, iterate over n
        first_rule = Regex( rules_dict[ inner.rules[1].rules[1] ])
        last_rule = Regex( rules_dict[ inner.rules[1].rules[2] ])
        out = Regex( "(?:" * first_rule.pattern * "){$n}" * "(?:" * last_rule.pattern * "){$n}" )
        return out
    end
end
n = Ref(1) # global ref
Regex(r::LoopingRule) = Regex(r,n[])

import Base.*
*(a::AbstractRule, b::AbstractRule) = SimpleRule( Regex(a) * Regex(b) )

const rule_r = r"([0-9]*):"

const rule_content_r = r"([\d\s$]+)(\|)?([\d\s$]*)"

const simple_rule_r = r"\"([a-z]+)\""

function read_input(filename, clear_rules = true)
    if clear_rules
        empty!(rules_dict)
    end
    lines = readlines(filename)
    # rules_dict = Dict{Int,AbstractRule}()
    signal = Vector{String}()
    for line in lines
        if isempty(line)
            continue
        end
        rule_m = match(rule_r , line)
        if isnothing(rule_m)
            # not a rule
            push!(signal,line)
        else
            rule_no = parse(Int,rule_m.captures[1])
            offset = length(rule_m.match) + 1
            simple_m = match(simple_rule_r, line, offset)
            if isnothing(simple_m)
                content_m = match(rule_content_r, line, offset)
                if content_m.captures[2] == "|"
                    # Compound rule
                    a = SeriesRule( parse.(Int, split( content_m.captures[1] ) ) )
                    b = SeriesRule( parse.(Int, split( content_m.captures[3] ) ) )
                    rules_dict[ rule_no ] = CompoundRule( (a,b) )
                    if rule_no in vcat(a.rules,b.rules)
                        rules_dict[ rule_no ] = LoopingRule( rules_dict[ rule_no ] )
                    end
                else
                    # Series rule
                    rules_dict[ rule_no ] = SeriesRule( parse.(Int, split( content_m.captures[1] ) ) )
                end
            else
                # Simple Rule
                rules_dict[ rule_no ] = SimpleRule( Regex(simple_m.captures[1]) )
            end
        end
    end
    signal
end

function part1()
    data = read_input("input.txt")
    r = Regex("^" * Regex( rules_dict[0] ).pattern * "\$")
    sum( endswith.(data, r) )
    # 102
end

function part2()
    data = read_input("input.txt")
    read_input("newrules.txt",false)
    total = 0
    for i = 1:5
        global n[] = i
        r = Regex("^" * Regex( rules_dict[0] ).pattern * "\$")
        total += sum( endswith.(data,r) )
    end
    total
    # 318
end

end
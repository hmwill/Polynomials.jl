# Polynomials
#
# Representation of polynomials rings, polynomials, and supporting functions
#
# The Polynomials package is licensed under the MIT Expat License:
#
# Copyright (c) 2013: Hans-Martin Will.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Possible terms orders
abstract TermOrder
abstract Lexicographic <: TermOrder
abstract GradedLexicographic <: TermOrder
abstract GradedReverseLexicographic <: TermOrder

# A polynomial ring, which is obtained by adjoining a set of variables (symbols)
# to a given base ring
type PolynomialRing{C <: Number, O <: TermOrder}

    variables::Array{Symbol}
    idxmap::Dict{Symbol, Int}
    
    function PolynomialRing(variables::Array{Symbol})
        idxmap = [ variables[i] => i for i = 1:length(variables) ]
        
        if length(idxmap) != length(variables)
            throw (ArgumentError())
        end
        
        new(copy(variables), idxmap)
    end
end

PolynomialRing{C <: Number}(::Type{C}, variables::Array{Symbol}) = PolynomialRing{C, Lexicographic}(variables)
PolynomialRing{C <: Number, O <: TermOrder}(::Type{C}, variables::Array{Symbol}, ::Type{O}) = PolynomialRing{C, O}(variables)

export setvars
function setvars(rg::PolynomialRing)
	args = Array(Any, length(rg.variables))
	for i = 1:length(rg.variables)
		v = rg.variables[i]
		sym = v:rg
		args[i] = :(($v) = $sym)
	end
	Expr(:block, args...)
end

# Extend the predefined function
import Base.showcompact
function showcompact{C <: Number, O <: TermOrder}(io::IO, rg::PolynomialRing{C, O})
    showcompact(io, C)
    variables = rg.variables
    
    if length(variables) > 0
        print(io, "[", variables[1])
        for index = 2:length(variables)
            print(",", variables[index])
        end
        print(io, "]")
    end

    print(io, " ")
    showcompact(io, O)
end

# Extend the predefined function
import Base.show
function show(io::IO, rg::PolynomialRing)
    showcompact(io, typeof(rg))
    variables = rg.variables

    if length(variables) > 0
        print(io, "[", variables[1])
        for index = 2:length(variables)
            print(",", variables[index])
        end
        print(io, "]")
    end
end

# A term within a given polynomial ring
immutable Term{Coeff}
    coeff::Coeff
    exp::Array{Int}
end

termorder(left::Term, right::Term, ::Type{Lexicographic}) = lexcmp(left.exp, right.exp)

function termorder(left::Term, right::Term, ::Type{GradedLexicographic})
    @assert false #TODO
end

function termorder(left::Term, right::Term, ::Type{GradedReverseLexicographic})
    @assert false #TODO
end

-{C <: Number}(term::Term{C}) = Term{C}(-term.coeff, term.exp)
*{C <: Number}(left::Term{C}, right::Term{C}) = Term{C}(left.coeff * right.coeff, left.exp + right.exp)

# An ordered series of terms arranged based on a given term-order
immutable Polynomial{C <: Number, O <: TermOrder}
    ring::PolynomialRing{C}
    terms::Array{Term{C}}
    #order::TermOrder
end

function inject{C <: Number, O <: TermOrder}(rg::PolynomialRing{C, O}, val::C)
    if val == zero(C)
        Polynomial{C, O}(rg, Array(Term{C}, 0))
    else
        Polynomial{C, O}(rg, [Term{C}(val, fill(0, length(rg.variables)))])
    end
end

function inject{C <: Number, O <: TermOrder}(rg::PolynomialRing{C, O}, var::Symbol)
    index = rg.idxmap[var]
    exp = fill(0, length(rg.variables))
    exp[index] = 1
    Polynomial{C, O}(rg, [Term{C}(one(C), exp)])
end

colon{C <: Number, O <: TermOrder}(val, rg::PolynomialRing{C, O}) = inject(rg, convert(C, val))
colon{C <: Number, O <: TermOrder}(var::Symbol, rg::PolynomialRing{C, O}) = inject(rg, var)

-{C <: Number, O <: TermOrder}(poly::Polynomial{C, O}) = 
    length(poly.terms) > 0 ? 
        Polynomial{C, O}(poly.ring, map(t::Term{C} -> -t, poly.terms)::Array{Term{C}}) :
        Polynomial{C, O}(poly.ring, Array(Term{C}, 0))

=={C <: Number, O <: TermOrder}(left::Polynomial{C, O}, right::Polynomial{C, O}) = left.ring == right.ring && left.terms == right.terms
!={C <: Number, O <: TermOrder}(left::Polynomial{C, O}, right::Polynomial{C, O}) = !(left == right)    

function plusminus_{C <: Number, O <: TermOrder}(left::Polynomial{C, O}, right::Polynomial{C, O}, op::Function)
    if left.ring != right.ring
        throw (ArgumentError())
    end
    
    # Process the term lists from high to low term order to merge terms based on exponent structure
    termsl = left.terms
    termsr = right.terms
    numl = length(termsl)
    numr = length(termsr)
    
    result = Array(Term{C}, numl + numr)
    
    idxl = 1
    idxr = 1
    idxs = 1
    
    # do the merge
    while idxl <= numl && idxr <= numr
        terml = termsl[idxl]
        termr = termsr[idxr]
        compare = termorder(terml, termr, O)
        
        if compare == 0 
            coeff = op(terml.coeff, termr.coeff)
            
            if coeff != zero(C)
                result[idxs] = Term{C}(coeff, terml.exp)
                idxs += 1
            end
            
            idxl += 1
            idxr += 1
        elseif compare > 0 
            result[idxs] = terml
            idxs += 1
            idxl += 1
        else
            result[idxs] = termr
            idxs += 1
            idxr += 1
        end
    end
    
    while idxl <= numl
        result[idxs] = termsl[idxl]
        idxs += 1
        idxl += 1
    end
    
    while idxr <= numr 
        term = termsr[idxr]
        result[idxs] = Term{C}(op(zero(C), term.coeff), term.exp)
        idxs += 1
        idxr += 1
    end
    
    # generate the result
    Polynomial{C, O}(left.ring, result[1:(idxs - 1)])
end

+(left::Polynomial, right::Polynomial) = plusminus_(left, right, +)
-(left::Polynomial, right::Polynomial) = plusminus_(left, right, -)
+{C <: Number, O <: TermOrder}(left::Polynomial{C, O}, right::Number) = plusminus_(left, inject(left.ring, convert(C, right)), +)
-{C <: Number, O <: TermOrder}(left::Polynomial{C, O}, right::Number) = plusminus_(left, inject(left.ring, convert(C, right)), -)
+{C <: Number, O <: TermOrder}(left::Number, right::Polynomial{C, O}) = plusminus_(inject(right.ring, convert(C, left)), right, +)
-{C <: Number, O <: TermOrder}(left::Number, right::Polynomial{C, O}) = plusminus_(inject(right.ring, convert(C, left)), right, -)

function *{C <: Number, O <: TermOrder}(left::Polynomial{C, O}, right::Polynomial{C, O})
    if left.ring != right.ring
        throw (ArgumentError())
    end

    termsl = left.terms
    termsr = right.terms
    
    if length(termsl) == 0 || length(termsr) == 0
        return Polynomial{C, O}(left.ring, Array(Term{C}, 0))
    end
    
    # ensure that the right polynomial does not have more terms than the left one
    if length(termsl) < length(termsr)
        swap = termsl
        termsl = termsr
        termsr = swap
        swap2 = left
        left = right
        right = swap2
    end
    
    result = left * termsr[1]
    
    for j = 2:length(termsr)
        result = result + left * termsr[j]
    end
    
    return result
end

function *{C <: Number, O <: TermOrder}(left::Polynomial{C, O}, right::Term{C})
    terms = Array(Term{C}, length(left.terms))
    
    for i = 1:length(left.terms)
        terms[i] = left.terms[i] * right
    end
    
    Polynomial{C, O}(left.ring, terms)
end

*{C <: Number, O <: TermOrder}(left::Polynomial{C, O}, right::Number) = left * inject(left.ring, convert(C, right))
*{C <: Number, O <: TermOrder}(left::Number, right::Polynomial{C, O}) = inject(right.ring, convert(C, left)) * right

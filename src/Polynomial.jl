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

# A polynomial ring, which is obtained by adjoining a set of variables (symbols)
# to a given base ring
type PolynomialRing{C <: Number}

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

PolynomialRing{C <: Number}(::Type{C}, variables::Array{Symbol}) = PolynomialRing{C}(variables)

# Extend the predefined function
import Base.showcompact
function showcompact{C <: Number}(io::IO, rg::PolynomialRing{C})
    showcompact(io, C)
    variables = rg.variables
    
    if length(variables) > 0
        print(io, "[", variables[1])
        for index = 2:length(variables)
            print(",", variables[index])
        end
        print(io, "]")
    end
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

# A term order 
abstract TermOrder

# An ordered series of terms arranged based on a given term-order
type Polynomial{Coeff}
    ring::PolynomialRing{Coeff}
    terms::Array{Term{Coeff}}
    #order::TermOrder
end

function inject{C <: Number}(rg::PolynomialRing{C}, val::C)
    if val == zero(C)
        Polynomial{C}(rg, Array(Term{C}, 0))
    else
        Polynomial{C}(rg, [Term{C}(val, fill(0, length(rg.variables)))])
    end
end

function inject{C <: Number}(rg::PolynomialRing{C}, var::Symbol)
    index = rg.idxmap[var]
    exp = fill(0, length(rg.variables))
    exp[index] = 1
    Polynomial{C}(rg, [Term{C}(one(C), exp)])
end

colon{C <: Number}(val, rg::PolynomialRing{C}) = inject(rg, convert(C, val))
colon{C <: Number}(var::Symbol, rg::PolynomialRing{C}) = inject(rg, var)

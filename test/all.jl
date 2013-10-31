# Polynomials
#
# Unit test wrapper
#
# The Polynomial package is licensed under the MIT Expat License:
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

using Polynomials; 

@assert isdefined(:Polynomials); 
@assert typeof(Polynomials) === Module

@assert isdefined(:Polynomial); 
@assert typeof(Polynomial) === DataType

@assert isdefined(:PolynomialRing); 
@assert typeof(PolynomialRing) === DataType

rg = PolynomialRing{BigInt}([:x, :y, :z])

# Test simple embeddings

poly = 1:rg
@assert length(poly.terms) == 1
@assert poly.terms[1].coeff == one(BigInt)
@assert sum(poly.terms[1].exp) == 0

poly = 0:rg
@assert length(poly.terms) == 0

poly = :x:rg
@assert length(poly.terms) == 1
@assert poly.terms[1].coeff == one(BigInt)
@assert poly.terms[1].exp[rg.idxmap[:x]] == 1
@assert sum(poly.terms[1].exp) == 1

poly = :y:rg
@assert length(poly.terms) == 1
@assert poly.terms[1].coeff == one(BigInt)
@assert poly.terms[1].exp[rg.idxmap[:y]] == 1
@assert sum(poly.terms[1].exp) == 1

poly = :z:rg
@assert length(poly.terms) == 1
@assert poly.terms[1].coeff == one(BigInt)
@assert poly.terms[1].exp[rg.idxmap[:z]] == 1
@assert sum(poly.terms[1].exp) == 1

# Test negation

poly = -(1:rg)
@assert length(poly.terms) == 1
@assert poly.terms[1].coeff == -one(BigInt)
@assert sum(poly.terms[1].exp) == 0

poly = -(0:rg)
@assert poly == (0:rg)

poly = -(:x:rg)
@assert length(poly.terms) == 1
@assert poly.terms[1].coeff == -one(BigInt)
@assert poly.terms[1].exp[rg.idxmap[:x]] == 1
@assert sum(poly.terms[1].exp) == 1

poly = -(:y:rg)
@assert length(poly.terms) == 1
@assert poly.terms[1].coeff == -one(BigInt)
@assert poly.terms[1].exp[rg.idxmap[:y]] == 1
@assert sum(poly.terms[1].exp) == 1

poly = -(:z:rg)
@assert length(poly.terms) == 1
@assert poly.terms[1].coeff == -one(BigInt)
@assert poly.terms[1].exp[rg.idxmap[:z]] == 1
@assert sum(poly.terms[1].exp) == 1


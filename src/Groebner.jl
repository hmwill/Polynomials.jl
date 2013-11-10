# Polynomials
#
# Groebner bases and supporting functions
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

abstract GrobenerBasis

# given a collection of polynomials in a ring, which are associated with a
# specific term order, build the corresponding Groebner basis
type GroebnerBasis{C <: Number, O <: TermOrder}
	ring::PolynomialRing{C, O}
	poly::Array{Polynomial{C, O}}
end

ldterm(poly::Polynomial) = poly.terms[1]

function divides(left::Term, right::Term) 
	@assert length(left.exp) == length(right.exp)
	
	for i = 1:length(left.exp)
		if left.exp[i] < right.exp[i]
			return false
		end
	end
	
	return true
end

function reduce{C <: Number, O <: TermOrder}(poly::Polynomial{C, O}, red::Polynomial{C, O})
	lterm = ldterm(poly)
	rterm = ldterm(red)
	
	if termorder(lterm, rterm, O) < 0 || !divides(lterm, rterm)
		return poly
	else
		rfactor = Term{C}(lterm.coeff, lterm.exp - rterm.exp)
		return poly * rterm.coeff - red * rfactor
	end
end

function reduce{C <: Integer, O <: TermOrder}(poly::Polynomial{C, O}, red::Polynomial{C, O})
	lterm = ldterm(poly)
	rterm = ldterm(red)
	
	if termorder(lterm, rterm, O) < 0 || !divides(lterm, rterm)
		return poly
	else
		scoeff = lcm(lterm.coeff, rterm.coeff)
		rfactor = Term{C}(div(scoeff, rterm.coeff), lterm.exp - rterm.exp)
		return poly * div(scoeff, lterm.coeff) - red * rfactor
	end
end

function spoly{C <: Number, O <: TermOrder}(left::Polynomial{C, O}, right::Polynomial{C, O})
	lterm = ldterm(left)
	rterm = ldterm(right)
	sexp = max(lterm.exp, rterm.exp)
	lfactor = Term{C}(rterm.coeff, sexp - lterm.exp)
	rfactor = Term{C}(lterm.coeff, sexp - rterm.exp)
	return left * lfactor - right * rfactor
end

function spoly{C <: Integer, O <: TermOrder}(left::Polynomial{C, O}, right::Polynomial{C, O})
	lterm = ldterm(left)
	rterm = ldterm(right)
	sexp = max(lterm.exp, rterm.exp)
	scoeff = lcm(lterm.coeff, rterm.coeff)
	lfactor = Term{C}(div(scoeff, lterm.coeff), sexp - lterm.exp)
	rfactor = Term{C}(div(scoeff, rterm.coeff), sexp - rterm.exp)
	return left * lfactor - right * rfactor
end

function reduce_{C <: Number, O <: TermOrder}(poly::Polynomial{C, O}, polys::Array{Polynomial{C, O}})
	z = 0:poly.ring
	for index = 1:length(polys)
		if poly == z
			return poly
		end
		
		poly = reduce(poly, polys[index])
	end
	
	return poly
end

# Buchberger's algorithm
function buchberger{C <: Number, O <: TermOrder}(polynomials::Array{Polynomial{C, O}})
	# need to sort polynomials according to term order
	gb = polynomials
	q = Deque{tuple(Polynomial{C, O}, Polynomial{C, O})}()

	for i = 1:length(gb)-1, j = i+1:length(gb)
		pair = (polynomials[i], polynomials[j])
		push!(q, pair)
	end
	
	while !isempty(q)
		(left, right) = shift!(q)
		s = spoly(left, right)
		r = reduce_(s, gb)
		println("Reducing:", left, " and ", right, " to ", r, " spoly=", s)
	
		if r != 0:r.ring
			# enqueue pairing of new polynomial with all existing ones
			for g in gb
				pair = (g, r)
				push!(q, pair)
			end
			
			# and add it to the basis
			gb = [gb, r]			
		end	
	end
	
	gb
end

# Reduction of a polynomial modulo a Groebner basis
function reduce{C <: Number, O <: TermOrder}(poly::Polynomial{C, O}, gb::GroebnerBasis{C, O})
	if poly.ring != gb.ring
		throw (ArgumentError())
	else
		reduce_(poly, gb.poly)
	end
end

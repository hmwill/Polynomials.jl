# Polynomials

[![Build Status](https://travis-ci.org/hmwill/Polynomials.jl.png)](https://travis-ci.org/hmwill/Polynomials.jl)

A starter package to do commutative algebra with Julia. Specifically, this package will contain the following:

- User-definable polynomial rings
- Polynomials (of course) incl. common ring operators
- Common algorithms, such as lcm, gdc
- Gröbner bases and supporting algorithms
- Characteristic sets and Wu-Ritt elimination (and variations) for equation solving

## Installation

The easiest way to use this package is to simply install it from git using the Julia
package manager:

	julia> Pkg.clone("git@github.com:hmwill/Polynomials.jl.git")

Once the package has been installed, it can be simply referenced or imported into
the current namespace. For example, we simply use

	julia> using Polynomials

to make the definitions inside this package available in the current namespace.
	
## Using Polynomials

### Creating a Polynomial Ring

All polynomial operations implemented in this package are performed within the context
of a `PolynomialRing`. A polynomial ring is defined by specifying a base coefficient type
and a list of symbols that are to be adjoined to the coefficient ring. For example,

	julia> rg = PolynomialRing(BigInt, [:x, :y])
	
creates a ring that adjoins the symbols `x` and `y` to the ring of big integers. The `colon` 
operator is overloaded to provide a notation for embedding values into this ring. For example,

	julia> 0:rg

represents the zero of our ring. Similarly,

	julia> 1:rg

represents the one of our polynomial ring. In the same fashion,

	julia> :x:rg

denotes the `x` variable, and 

	julia> :y:rg

denotes the `y` variable. If we are working with a single ring, a more convenient notation
can be done by directly importing the symbols of the ring into the current namespace.
This can be accomplished using

	julia> setvars(rg) |> eval

The function`setvars(rg)` creates a quoted expression that defines for each variable of the
ring a corresponding Julia language variable. By evaluating this quoted expression in our
current environment, those definitions are added to it. For example, after these previous lines, `x` and `y` can be used directly to refer to polynomials representing the variables
of the polynomial ring. It is then possible to simply write

	julia> 2x+5y+4

to specify a specific polynomial that is an element of the ring `rg`. Observe that the coefficient values `2`, `4` and `4` have been implicitly converted to the coefficient type
of the ring `rg`, which is `BigInt`.
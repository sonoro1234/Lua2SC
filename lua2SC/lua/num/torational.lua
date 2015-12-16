--[[/*
** find rational approximation to given real number
** David Eppstein / UC Irvine / 8 Aug 1993
**
** With corrections from Arno Formella, May 2008
**
** usage: a.out r d
**   r is real number to approx
**   d is the maximum denominator allowed
**
** based on the theory of continued fractions
** if x = a1 + 1/(a2 + 1/(a3 + 1/(a4 + ...)))
** then best approximation is found by truncating this series
** (with some adjustments in the last term).
**
** Note the fraction can be recovered as the first column of the matrix
**  ( a1 1 ) ( a2 1 ) ( a3 1 ) ...
**  ( 1  0 ) ( 1  0 ) ( 1  0 )
** Instead of keeping the sequence of continued fraction terms,
** we just keep the last partial product of these matrices.
*/
--]]
function GCD(a,b)
	local r
	if a < b then b,a = a,b end
	while true do
		r = a%b
		if r == 0 then return b end
		--print(a,b,r)
		a,b = b,r
	end
end
--always gives reduced fractions, dont need GCD
function torational(x,maxden)
    local startx = x 
    -- initialize matrix */
    local m00, m11 = 1,1;
    local m01, m10 = 0,0;

    -- loop finding terms until denom gets too big */
	local t
	local ai = math.floor(x)
    while (m10 *  ai + m11 <= maxden) do
		print(ai)
		t = m00 * ai + m01;
		m01 = m00;
		m00 = t;
		t = m10 * ai + m11;
		m11 = m10;
		m10 = t;
		if(x == ai) then break end    -- AF: division by zero 
		x = 1/(x - ai);
		if(x >0x7FFFFFFF) then break end  -- AF: representation failure
		ai = math.floor(x)
    end 

    -- now remaining x is between 0 and 1/ai */
    -- approx as either 0 or 1/m where m is max that will fit in maxden */
    -- first try zero */
  -- print( string.format("%d/%d, error = %e\n", m[0][0], m[1][0],startx - ( m[0][0] /  m[1][0])));
	return m00,m10,startx - ( m00 /  m10)

    -- now try other possibility */
    --ai = (maxden - m[1][1]) / m[1][0];
    --m[0][0] = m[0][0] * ai + m[0][1];
    --m[1][0] = m[1][0] * ai + m[1][1];
    --print(string.format("%d/%d, error = %e\n", m[0][0], m[1][0], startx - ( m[0][0] / m[1][0])));
end

--print(torational(2*5*7/(11*3*13),10000))
--print(torational((3/2)^12,1e3))
--print(GCD(1e17*13,1e17*11))
--[[
local N,M = torational(math.pi,1000)
local gcd = MCD(N,M)
print(N,M)
print(N/gcd,M/gcd)
--]]
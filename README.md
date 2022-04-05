# L-test

L-test of disinformation
Copyright Dr Keith Reid Cailleach Computing Ltd
MIT license

This repo is under construction.
It shares and explains the L-test, which is a proposed test for disinformation accepted in abstract to UK June 2022 clinical informatics conference. 
The code here is code in Julia, written under TDD. There is also an Excel spreadsheet and soon a JavaScript version.

The basic idea is as follows:

- if you have an expectation (say normal 50% 50% coin tosses) then new events, including series of events, are more or less surprising in a way which can be measured using bits
- bits are binary digits
- if a series of insitutions report accurately, in a field where there is some sort of trend, cut the accurate reports in half
- going out fom the lowest point near the origin or root, order them odd and even
- odd and even points should not be wildly suprising in terms of each other, and a Mann Whitney U test should show a fairly high number close to say 0.75
- the informatin from this is not large
- that is oberved so far in Star Wrs characer data, and restraint data, and in the prime counting function
- then add some null claims, or low claims, and see how that distorts the Mann Whitney U dissimilarity information, "dis-information" for short
- the increase in information is measure of disinformation, called the L-test for the shape of graph and for the name Lewis as in Seni's Law, with kind permission; it does not stand for 'lie'.
- L-test can intuitively be understood as equating to a flaes claim of successive head tosses in normal coins, or more interstingly to me, in terms of the prime counting function
- see the graph png for screen shot of julia running the code and doing a nice graph
- 

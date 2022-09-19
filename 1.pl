% Purpose of this file: Solving math puzzle for COMP30020 2022 sem2 project1
%       with the help of CLPFD libary of swipl
%
%
%%%% Introduction:
% This file implements a math puzzle solver with clpfd library 
% A math puzzle can be represented by a matrix of nested 2D lists and it needs
% to satisfy following constraints: 
%       1. It is a square matrix
%       2. Each grid is a digit between 1-9
%       3. all grid on the diagonal line from upper left to lower right
%               has the same value(except the most upper left one)
%       4. each row and each column has no repeated digits
%       5. The headings of each row and column holds the sum of product of
%               all the digits in the row/column
%       Note:
%       1)The headings are not considered to be part of row or column
%               and they can be filled with a number larger than 9
%       2) The most upper left grid is not meaningful       
%
%
%%%% This is an example of valid math puzzle:
%  |  0| 14| 10| 35|
%  | 14|  7|  2|  1|
%  | 15|  3|  7|  5|
%  | 18|  4|  1|  7|
%
%
%%%% How does this program solve math puzzle?
%       1. Ensure the matrix is a square matrix(same length of row and column)
%       2. Peel the headings off, leave only the "inner grids", e.g.
%               The puzzle above becomes
%                |7 |  2|  1|
%                |3 |  7|  5|
%                |4 |  1|  7|
%               This makes it easier to perform following steps 
%               (I will refer this as "inner grids" below)
%       3. Ensure the diagonal of "inner grids" consists of the same digits 
%       4. Ensure each row and column of "inner grids" has digit 1-9
%       5. Ensure each row of "inner grids" has distinct digits
%       6. Ensure each column of "inner grids" has distinct digits
%       7. Ensure the headings are either the sum or the product of the rows
%               of "inner grids"
%       8. Ensure the headings are either the sum or the product of the columns
%               of "inner grids
%
%
%%%% How to use this program? 
% The main entry of this program is the puzzle_solution(+Puzzle) predicate
% Activate swipl shell, load this file, and run like below
%%%% sample input 1 
% Puzzle = [[0,14,10,35],[14,_,_,_],[15,_,_,_],[28,_,1,_]],
%       puzzle_solution(Puzzle).
%
%%%% sample output 1
% Puzzle = [[0, 14, 10, 35], [14, 7, 2, 1], [15, 3, 7, 5], [28, 4, 1, 7]] ;
% false.
%
%
%%%% sample input 2
% Puzzle = [[0,12,6],[5,_,_],[7,_,_]], puzzle_solution(Puzzle).    
%
%%%% sample output 2
% Puzzle = [[0, 12, 6], [5, 3, 2], [7, 4, 3]] ;
% false.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is swipl's constraint logic programming library
% This program is built on this
:- use_module(library(clpfd)).

% This is swipl's list operations library
% nth0/3 from this lib is used in the program
:- use_module(library(lists)). 

% puzzle_solution(+Puzzle). 
% This is the main entry point of this program
% It takes a math puzzle and unifies it to satisfy constraints
% It returns true if input is a valid math puzzle, false otherwise
% It returns a filled math puzzle if input is incomplete and can be solved
puzzle_solution(Puzzle) :-
        %%%% 1. ensure square matrix
        maplist(same_length(Puzzle), Puzzle), 

        %%%% 2. peel headers off and only keep inner grids,
        % The <Inner> is used later  
        peel(Puzzle, Inner), 

        %%%% 3. Ensure identical grids on diagonal by calling check_dia/1
        % pass the inner grids as first argument (+List)
        % pass 0 as (+Index)
        % get the first element on the first row of Inner grids
        % and pass it as third argument (+Prev)
        nth0(0, Inner, FirstRow), 
        nth0(0, FirstRow, FirstElem), 
        check_dia(Inner, 0, FirstElem), 

        %%%% 4. Ensure each inner grids only has digits 1-9
        % by calling append/2 to flatten the 2D list to 1D list
        % and use ins from clpfd to ensures every elements is in 1-9
        append(Inner, Flat),
        Flat ins 1..9,
        
        %%%% 5. Ensure inner grids have distinct row
        % by calling the all_distinct/1 on each row with maplist/2
        maplist(all_distinct, Inner),
        
        %%%% 6. Ensure inner grids have distinct columns
        % transpose/2 matrix to swap rows and columns
        % then call all_distinct on the rows of transposed matrix
        transpose(Inner, InnerColumns),
        maplist(all_distinct, InnerColumns),
        
        %%%% 7. Ensure headings are either sum or product of each rows
        % since first row is the heading row and doesn't count 
        % we only check on the rest of rows
        [_|Rs] = Puzzle, 
        maplist(check_sum_product, Rs), 

        %%%% 8. Ensure headings are either sum or product of columns 
        % since first column is the heading column and doesn't count
        % we only check on the rest of columns
        transpose(Puzzle, Columns), 
        [_|Cs] = Columns, 
        maplist(check_sum_product, Cs), 

        %%%% This is only for solving puzzle with multiple solutions
        % which is not actually needed in this assignment since the test will
        % only based on at most one solution puzzle
        maplist(label, Puzzle).  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove_first(+List, -List)
% It removes the first element of a list
remove_first([_|Rs], Rs). 

% peel(+Puzzle, -Inner)
% It takes a puzzle as input and remove the headings
% It operates by calling remove_first/1 on the whole puzzle to remove
% first row, and then call remove_first/1 on the rest rows, this removes
% all the start of elements of the rest rows
peel(Puzzle, Inner) :- 
        remove_first(Puzzle, K), 
        maplist(remove_first, K, Inner). 


% check_dia(+List, +Index, +Prev)
% It holds if the elements on the diagonal are identical
% It takes a list, the index and previous element, and checks if the indexed
% element on the first row of list is identical to the previous element, then
% increase the index and recursively call next row of the list. 
% In order to use this in main program, I initiate it with the whole puzzle
% as +List, 0 as +Index, first element of the first row as +Prev
check_dia([], _, _). 
check_dia([R|Rs], Index, Prev) :- 
        nth0(Index, R, Prev), 
        Index1 is Index + 1, 
        check_dia(Rs, Index1, Prev).  

% product_list(+List, +Product)
% It takes a list and a number, holds if the product of list is equal to this
% number
product_list([R], R). 
product_list([R|Rs], Product) :- 
        product_list(Rs, Product1), 
        Product #= Product1*R.  

% check_sum_product(+List)
% It holds if the first element of the list is the sum or product of the 
% remaining list, it uses the sum/3 from clpfd and the product_list/1
% written by me
check_sum_product([R|Rs]) :- 
        sum(Rs, #=, R);  
        product_list(Rs, R). 
         




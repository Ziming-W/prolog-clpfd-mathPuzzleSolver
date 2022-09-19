# prolog-clpfd-mathPuzzleSolver
## Purpose of this file:
Solving math puzzle for COMP30020 2022 sem2 project1 with the help of CLPFD libary of swipl

## Introduction:
This file implements a math puzzle solver with clpfd library  
A math puzzle can be represented by a matrix of nested 2D lists and it needs 
to satisfy following constraints:  
1. It is a square matrix  
2. Each grid is a digit between 1-9  
3. all grid on the diagonal line from upper left to lower right has the same value(except the most upper left one)  
4. each row and each column has no repeated digits  
5. The headings of each row and column holds the sum of product of all the digits in the row/column  
Note:   
1. The headings are not considered to be part of row or column and they can be filled with a number larger than 9  
2. The most upper left grid is not meaningful       
  
  
This is an example of valid math puzzle:  
```
    |  0| 14| 10| 35|  
    | 14|  7|  2|  1|  
    | 15|  3|  7|  5|  
    | 18|  4|  1|  7|  
```

## How does this program solve math puzzle?
1. Ensure the matrix is a square matrix(same length of row and column)
2. Peel the headings off, leave only the "inner grids", e.g.  
The puzzle above becomes
```
 |7 |  2|  1|  
 |3 |  7|  5|  
 |4 |  1|  7|  
```
This makes it easier to perform following steps   
(I will refer this as "inner grids" below)    
3. Ensure the diagonal of "inner grids" consists of the same digits   
4. Ensure each row and column of "inner grids" has digit 1-9  
5. Ensure each row of "inner grids" has distinct digits  
6. Ensure each column of "inner grids" has distinct digits  
7. Ensure the headings are either the sum or the product of the roof "inner grids"  
8. Ensure the headings are either the sum or the product of thcolumns of "inner grids  

## How to use this program? 
The main entry of this program is the ```puzzle_solution(+Puzzle)``` predicate  
Activate swipl shell, load this file, and run like below  
### sample input 1 
    Puzzle = [[0,14,10,35],[14,_,_,_],[15,_,_,_],[28,_,1,_]], puzzle_solution(Puzzle).  
### sample output 1
    Puzzle = [[0, 14, 10, 35], [14, 7, 2, 1], [15, 3, 7, 5], [28, 4, 1, 7]] ;  
    false.
### sample input 2
    Puzzle = [[0,12,6],[5,_,_],[7,_,_]], puzzle_solution(Puzzle).    
### sample output 2
    Puzzle = [[0, 12, 6], [5, 3, 2], [7, 4, 3]] ;  
    false.
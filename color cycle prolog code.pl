% Define the possible colors
color(red).
color(yellow).
color(blue).

rows(X,Rows) :-
    Rows is X.

columns(X,Columns) :-
    Columns is X.

% Input:
rows(4).
columns(4).

% Color information
color((0,0), yellow).
color((0,1), yellow).
color((0,2), yellow).
color((0,3), red).
color((1,0), blue).
color((1,1), yellow).
color((1,2), blue).
color((1,3), yellow).
color((2,0), blue).
color((2,1), blue).
color((2,2), blue).
color((2,3), yellow).
color((3,0), blue).
color((3,1), blue).
color((3,2), blue).
color((3,3), yellow).

% Predicate to find adjacent nodes for a given node
find_adjacent_nodes(Node, Rows, Cols, AdjNodes) :-
    (   Node = (Row, Col),
        findall(AdjNode, adjacent_node((Row, Col), Rows, Cols, AdjNode), AdjNodes)
    ;   AdjNodes = []
    ).

% Predicate to find adjacent node for a given node at a specific position (excluding diagonals)
adjacent_node((Row, Col), Rows, Cols, AdjNode) :-
    neighbor_offset(OffsetRow, OffsetCol),
    NewRow is Row + OffsetRow,
    NewCol is Col + OffsetCol,
    NewRow >= 0, NewRow < Rows,
    NewCol >= 0, NewCol < Cols,
    AdjNode = (NewRow, NewCol).

% Predicate to define horizontal and vertical neighbor offsets
neighbor_offset(0, 1). % Right
neighbor_offset(0, -1). % Left
neighbor_offset(1, 0). % Down
neighbor_offset(-1, 0). % Up

% Dynamic predicate to store hi value
:- dynamic hi/1.
hi(-1).

% Predicate to modify hi by adding 100 to its value
modify_hi :-
    retract(hi(Val)),
    NewVal is Val + 100,
    asserta(hi(NewVal)).
    
% BFS traversal
bfs_traversal(Start) :-
    rows(Rows),
    columns(Cols),
    bfs_traversal([Start], [], [], Rows, Cols).

bfs_traversal([], _, _, _, _) :-
    hi(Val),
    (Val = -1 -> writeln('No cycles found'); true), !.

bfs_traversal([Node | Rest], Visited, _, Rows, Cols) :-
    (   Node = (Row, Col),
        \+ member(Node, Visited) ->
        check_adjacent_colors(Node),
        find_adjacent_nodes(Node, Rows, Cols, AdjNodes),
        append(Rest, AdjNodes, Queue),
        bfs_traversal(Queue, [Node | Visited], [], Rows, Cols)
    ;   bfs_traversal(Rest, Visited, [], Rows, Cols)
    ).

check_adjacent_colors((Row, Col)) :-
    color((Row, Col), Color),
    rows(Rows),
    columns(Columns),
    (   NextRow is Row + 1,
        NextCol is Col + 1,
        NextRow < Rows,
        NextCol < Columns ->
        color((NextRow, Col), NextColor1),
        color((Row, NextCol), NextColor2),
        color((NextRow, NextCol), NextColor3),
        (   Color = NextColor1, NextColor1 = NextColor2, NextColor2 = NextColor3 ->
            format('Cycle found within nodes ~w, ~w, ~w, ~w with color: ~w~n', [(Row, Col),(Row, NextCol), (NextRow, Col),  (NextRow, NextCol), Color]),
            modify_hi
        ;   true
        )
    ;   true
    ).

%example query
% bfs_traversal((0,0)).
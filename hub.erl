%
% hub.erl
%

-module (hub).

-include("nnn.hrl").

-define (UNITS_MODULE,units).

-export ([
	  run/0,
	  get_unit/1,
	  test/0,
	  vector_to_index/1,
	  index_to_vector/1,
	  get_random_vector/1,
	  pow/2
	]).  

start_units(0,G) ->
    G;
start_units(N,G) ->
    G.

index_to_vector(1,I)->
    [I];
index_to_vector(P,I)->
    io:format("P: ~p I: ~p~n",[P,I]),
    D = I div P,
    R = I rem P,
    lists:append( index_to_vector(P div ?NNN_EXTEND,R) , [D]).
    
index_to_vector(I)->
    P=pow(?NNN_EXTEND,?NNN_DIMENSION-1),
    index_to_vector(P,I).

    
    
 
run() ->
    G=ets:new(?UNITS_MODULE,[set,public,named_table]),
    io:format("Staring units~n",[]),
    R=start_units(5,G),
    io:format("Reslt: ~p~n",[R]).




get_unit(N) ->
    [{_,Unit}]=ets:lookup(?UNITS_MODULE,N),
    Unit.

vector_to_index([T],D)->
    T*D;
vector_to_index([H|T],D) ->
    vector_to_index(T,D*?NNN_EXTEND)+H*D.

vector_to_index([H|T])->
    vector_to_index([H|T],1).

pow(_X,0)->
    1;
pow(X,Y) when Y > 0->
    X*pow(X,Y-1).



get_random_vector(0,Max) ->
    [];
get_random_vector(N,Max) ->
    [trunc(rand:uniform()*Max*2-Max)|get_random_vector(N-1,Max)].


get_random_vector(Max) ->
    get_random_vector(?NNN_DIMENSION,Max). 

    





test()->
    run(),
    U = get_unit(1),
%    U ! {set_input,1,{1,0.52}},
%    U ! {set_input,1,{2,1.2}},
    U ! {stim,{1,0.3}},
    U ! {stim,{2,0.4}},
    U ! status,
    U.
    
    
    
    

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
	  index_to_vector/1
	]).  

start_units(0,G) ->
    G;
start_units(N,G) ->
    Pid=unit:start(N),
    ets:insert(G,{N,Pid}),
    start_units(N-1,G).

  
run() ->
    G=ets:new(?UNITS_MODULE,[set,public,named_table]),
    io:format("Staring units~n",[]),
    R=start_units(5,G),
    io:format("Reslt: ~p~n",[R]).




get_unit(N) ->
    [{_,Unit}]=ets:lookup(?UNITS_MODULE,N),
    Unit.

vector_to_index([V])->
    V;
vector_to_index([H|T]) ->
    vector_to_index(T)+H.

index_to_vector(I)->
    ok.







test()->
    run(),
    U = get_unit(1),
%    U ! {set_input,1,{1,0.52}},
%    U ! {set_input,1,{2,1.2}},
    U ! {stim,{1,0.3}},
    U ! {stim,{2,0.4}},
    U ! status,
    U.
    
    
    
    

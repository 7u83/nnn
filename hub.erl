%
% hub.erl
%

-module (hub).

-define (UNITS,units).

-export ([
	  run/0,
	  get_unit/1
	]).  

start_units(0,G) ->
    G;
start_units(N,G) ->
%    io:format("Starting unit ~p~n",[N]),
    Pid=unit:start(N),
    ets:insert(G,{N,Pid}),
%    io:format("Map: ~p~n",[MapNew]),
    start_units(N-1,G).
  
run() ->
    G=ets:new(?UNITS,[set,public,named_table]),
    io:format("Staring units~n",[]),
    R=start_units(10,G),
    io:format("Reslt: ~p~n",[R]).


get_unit(N) ->
    [{_,Unit}]=ets:lookup(?UNITS,N),
    Unit.



    

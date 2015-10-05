
%
% hub.erl
%

-module (hub).

-define (UNITS_MODULE,units).

-export ([
	  run/0,
	  get_unit/1,
	  test/0
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
    G=ets:new(?UNITS_MODULE,[set,public,named_table]),
    io:format("Staring units~n",[]),
    R=start_units(10000,G),
    io:format("Reslt: ~p~n",[R]).


get_unit(N) ->
    [{_,Unit}]=ets:lookup(?UNITS_MODULE,N),
    Unit.


test()->
    run(),
    U = get_unit(1),
%    U ! {set_input,1,{1,0.52}},
%    U ! {set_input,1,{2,1.2}},
    U ! {set_input,1,0.3},
    U ! {set_input,1,0.4},

    U.
    
    
    
    

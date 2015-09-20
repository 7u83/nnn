%
% hub.erl
%

-module (hub).

-export ([
	  run/0
	]).  

start_units(0,Map) ->
    Map;
start_units(N,Map) ->
%    io:format("Starting unit ~p~n",[N]),
    Pid=unit:start(N),
    MapNew=maps:put(N,Pid,Map),
%    io:format("Map: ~p~n",[MapNew]),
    start_units(N-1,MapNew).
  
run() ->
    io:format("Staring units~n",[]),
    R=start_units(100,maps:new()),
    io:format("Reslt: ~p~n",[R]).

get_unit() ->
	ok.


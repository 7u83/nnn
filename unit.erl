% 
% unit.erl
%

-module (unit).

-export ([
		start/1,
		run/1
	]).

fire([])->
	ok.
fire([H|Tail],Level) ->
	H ! Level,	
	fire(Tail).


add_output(Output,Outputs,true) ->
	Outputs;
add_output(Output,Outputs,false) ->
	[Output|Outputs].
add_output(Output,Outputs) ->
	add_output(Output,Outputs,lists:member(Output,Outputs)).
	

run(Inputs,Outputs,Level) ->
	io:format("Inputs ~p~nOutputs ~p~nLevel ~p~n",[Inputs,Outputs,Level]),
	receive
		{connect,Output} ->
			run (Inputs,add_output(Output,Outputs),Level); 

		{stim,Input} -> 
				
			io:format("Fired from ~d ~n",Input)
	end,
	run(Inputs,Outputs,Level).
	

run1() ->
    run(maps:new(),[],0).

-define (RATE,0.7).

hebb (I,O) ->
    ?RATE * I * O.

run(Id,Inputs,Outputs,Output)->
    receive
	hello ->
	    io:format("Hello~n",[]);
	conn ->
	    io:format("Connection~n",[]);
	{hebb,I,O} ->
	    H = hebb(I,O),
	    io:format("Hebb: ~p~n",[H])
    end,
    run(Id).

run(Id) ->
    run(Id,[],[],0.0).



start(Id) ->
    spawn(?MODULE,run,[Id]).

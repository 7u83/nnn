% 
% unit.erl
%

-module (unit).

-export ([
	  start/1,
	  run/1,
	  input_function/1
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


input_function([])->
    0.0;
input_function([H|T]) ->
    {Weight,Input}=H,
    Input * Weight + input_function(T).

run(Id,Inputs,Outputs,Output)->
    receive
	hello ->
	    io:format("Hello~n",[]);
	conn ->
	    io:format("Connection~n",[]);
	{hebb,I,O} ->
	    H = hebb(I,O),
	    io:format("Hebb: ~p~n",[H]);
	show_inputs ->
	    io:format("Inputs: ~p~n",[Inputs]);

	{set,N,Val} ->
	    {W,OldVal} = maps:get(N,Inputs,{0,0}),
	    NewInputs = maps:put(N,{W,Val},Inputs),
	    run(Id,NewInputs,Outputs,Output);
	{set_input,N,Val} ->
	    io:format("Set Input ~p ~p ~n",[N,Val]),
 

	    NewInputs=maps:put(N,Val,Inputs),
	    run(Id,NewInputs,Outputs,Output);
	ifunc ->
	    Values = maps:values(Inputs),
	    io:format("Values ~p~n",[Values]),
	    R = input_function(Values),
	    io:format("IFUNC: ~p~n",[R])

        end,
    io:format("Run again~n",[]),
    run(Id,Inputs,Outputs,Output).

run(Id) ->
    Inputs = maps:new(),
    run(Id,Inputs,[],0.0).

start(Id) ->
    spawn(?MODULE,run,[Id]).

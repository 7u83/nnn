% 
% unit.erl
%

-module (unit).

-export ([
	  start/1,
	  run/1,
	  input_function/1,
	  output_function/1
	 ]).

-record (ufields,
	 {
	   id,
	   inputs,
	   outputs
	 }
	).


fire([],Level)->
	ok;
fire([H|Tail],Level) ->
	H ! Level,	
	fire(Tail,Level).


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




input_function(Map) when is_map(Map) ->
    Values = maps:values(Map),
     input_function(Values);
input_function([])->
    0.0;
input_function([H|T]) ->
    {Weight,Input}=H,
    Input * Weight + input_function(T).



output_function(I)->
    if 
	I<0.5 ->
	    0;
	true ->
	    1
    end.


init_weight(_N)->
    rand:uniform().

set_weight(N,Inputs,Weight) when is_float(Weight) ->
    {_W,V}=maps:get(N,Inputs,{0,0}),
    maps:put(N,Inputs,{Weight,V}).

set_input(N,Inputs,{W,Value})->
    maps:put(N,{W,Value},Inputs);
set_input(N,Inputs,Value) ->
    {W,V} = maps:get(N,Inputs,{init_weight(N),0}),
    set_input(N,Inputs,{W,Value}).



run(Id,Inputs,Outputs,Output) when is_map(Inputs)->
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
	    NewInputs= set_input(N,Inputs,Val),
	    I = input_function(NewInputs),
	    O = output_function(I),
	    fire (Outputs,O),

	    io:format("Inputs result fire ~p, in, ~p ~p~n",[O,I,NewInputs]),
	    
	    run(Id,NewInputs,Outputs,Output);



	ifunc ->
	    Values = maps:values(Inputs),
	    io:format("Values ~p~n",[Values]),
	    R = input_function(Values),
	    io:format("IFUNC: ~p~n",[R]);
	do ->
	    I = input_function(Inputs)
		
	    

        end,
    io:format("Run again~n",[]),
    run(Id,Inputs,Outputs,Output).

run(Id) ->
    Inputs = maps:new(),
    run(Id,Inputs,[],0.0).

start(Id) ->
    spawn(?MODULE,run,[Id]).

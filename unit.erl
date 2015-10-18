% 
% unit.erl
%

-module (unit).

-export ([
	  start/1,
	  run/1,
	  in_func/1,
	  out_func/1
	 ]).

-record (uf,
	 {
	   id,
	   inputs,
	   outputs,
	   weights,
	   level=0.0
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


in_func(Map) when is_map(Map) ->
    in_func(maps:values(Map));
in_func([])->
    0.0;
in_func([H|T]) ->
    {Weight,Value}=H,
    Value * Weight + in_func(T).


out_func(I)->
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


adjust(Inputs)->
    ok.

adjust(R,OutVal) when is_record(R,uf)->
    R.

get_weight(R,Input) ->
    maps:get(Input,R#uf.weights,rand:uniform()).


send_to(R,Output,Value) ->
    Output ! {stim,R#uf.id,Value}.

send(_Source,[]) ->
    ok;
send(Source,[Output|Tail]) ->
    send_to(Source,Output,1),
    send(Source,Tail).




fire(R) ->
    io:format("Firing~n"),
    send(R#uf.id,R#uf.outputs),
    R#uf{
      level=0.0
      }.

stim(R,Input,Value) ->
    Level = R#uf.level+get_weight(R,Input)*Value,
    if 
	Level < 0.5 ->
	    R#uf{
	      level = Level
	     };
	true ->
	    fire(R)
    end.
		

    
%    R1=R#uf{
%	   inputs = set_input(Input,R#uf.inputs,Value)
%	  },
%    InVal = in_func(R1#uf.inputs),
%    OutVal = out_func(InVal),
   
%    io:format("Inval,OutVal: ~p,~p~n",[InVal,OutVal]),

%   R1.
    
    
    


run(R) when is_record(R,uf) ->
    io:format("Current level: ~p",[R#uf.level]),
    receive
	status ->
	    % Print unit status
	    io:format("--- Status for unit ~p ---~n",[R#uf.id]),
	    io:format("Inputs: ~p~n",[R#uf.inputs]),
	    io:format("Outputs: ~p~n",[R#uf.outputs]),
	    run(R);
	hello ->
	    io:format("Hello World~n"),
	    run(R);
	{stim,Input,Value} ->
	    io:format("Stim detected~n"),
	    run(stim(R,Input,Value))
    end;
run(Id) when is_integer(Id) ->
    Record = #uf{
		id = Id, 
		inputs=maps:new(),
		weights = maps:new(),
		outputs=[]
	       },
    io:format("Starting unit ~p~n",[Record#uf.id]),
    run(Record).




start(Id) when is_integer(Id) ->
    spawn(?MODULE,run,[Id]).

-module(hello_handler).
-behaviour(cowboy_handler).
-export([init/2]).

-include_lib("opentelemetry_api/include/opentelemetry.hrl").
-include_lib("opentelemetry/include/otel_span.hrl").
-include_lib("opentelemetry_api/include/otel_tracer.hrl").

-define(TRACER_ID, ?MODULE).

init(Req, State) ->

    ?with_span(<<"operation">>, #{},
        fun(_Ctx) ->
            method_1(),
            {ok, cowboy_req:reply(200, #{}, <<"Hello World from Erlang!\n">>, Req), State}
        end).

method_1() ->
    %io:fwrite("method_1 method.~n"),
    ?with_span(<<"method_1">>, #{},
        fun(_ChildCtx) ->
            timer:sleep(1000),
            method_2(_ChildCtx) % <- Invoke the method with the context
        end).

method_2(_SpanCtx) ->
    %io:fwrite("method_2 method.~n"),
    ?add_event(<<"Nice operation!">>, [{<<"bogons">>, 100}]),
    ?set_attributes([{another_key, <<"yes">>}]),

    %% start an active span and run an anonymous function
    ?with_span(<<"method_2">>, #{}, 
                fun(_ChildSpanCtx) ->
                      timer:sleep(500),
                      ?set_attributes([{lemons_key, <<"sweet">>}]),
                      ?add_event(<<"Sub span event!">>, []),
                      ok % <- Return a value, like ok, to signify successful completion
                end).

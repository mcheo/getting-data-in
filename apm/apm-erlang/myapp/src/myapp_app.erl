%%%-------------------------------------------------------------------
%% @doc myapp public API
%% @end
%%%-------------------------------------------------------------------

-module(myapp_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_Type, _Args) ->
    application:ensure_all_started(opentelemetry),

    Dispatch = cowboy_router:compile([
        {'_', [{"/", hello_handler, []}]}
    ]),

    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
    myapp_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
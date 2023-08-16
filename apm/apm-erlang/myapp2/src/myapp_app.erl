%%%-------------------------------------------------------------------
%% @doc myapp public API
%% @end
%%%-------------------------------------------------------------------

-module(myapp_app).

-export([start_all/0, start/0, stop/1]).


start_all() ->
    application:ensure_all_started(tls_certificate_check),
    application:ensure_all_started(cowboy),
    application:ensure_all_started(opentelemetry),
    application:ensure_all_started(opentelemetry_exporter),
    start().

start() ->

    Dispatch = cowboy_router:compile([
        {'_', [{"/", hello_handler, []}]}
    ]),

    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 9090}],
        #{env => #{dispatch => Dispatch}}
    ),
    myapp_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
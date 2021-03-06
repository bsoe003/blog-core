:- module(bc_data, [
    bc_data_open/1, % +File
    bc_data_close/0
]).

:- use_module(library(docstore)).
:- use_module(library(debug)).

:- use_module(bc_data_config).
:- use_module(bc_data_user).
:- use_module(bc_data_migrate).

%! bc_data_open(+File) is det.
%
% Opens the docstore database file.
% Inserts the initial data.

bc_data_open(File):-
    ds_open(File),
    bc_init,
    debug(bc_data, 'opened docstore file ~p', [File]).

%! bc_data_close is det.
%
% Closes the docstore database.

bc_data_close:-
    ds_close,
    debug(bc_data, 'closed docstore file', []).

% Sets up initial values.
% Inserts the default admin user.

bc_init:-
    bc_data_migrate(
        bc_initial_config,
        'Inserts the initial config',
        bc_initial_config),
    bc_data_migrate(
        bc_initial_user,
        'Inserts the initial user',
        bc_initial_user),
    bc_data_migrate(
        bc_add_language,
        'Adds language to posts',
        bc_add_language),
    bc_data_migrate(
        bc_smtp_settings,
        'Adds SMTP settings',
        bc_smtp_settings).

% Inserts the initial config.

bc_initial_config:-
    bc_config_set(title, 'Untitled site').

bc_smtp_settings:-
    bc_config_set(smtp_enabled, false),
    bc_config_set(smtp_host, 'localhost'),
    bc_config_set(smtp_user, 'user'),
    bc_config_set(smtp_password, 'password'),
    bc_config_set(smtp_auth, 'login').

% Inserts the initial user.

bc_initial_user:-
    bc_user_save_initial(user{
        fullname: 'Admin',
        username: 'admin@example.com',
        password: 'admin',
        type: admin,
        files: true,
        link: ""
    }).

% Adds and sets language for
% entries.

bc_add_language:-
    ds_col_add_key(entry, language, en),
    bc_config_set(default_language, en).

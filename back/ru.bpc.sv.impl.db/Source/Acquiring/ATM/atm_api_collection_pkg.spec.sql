create or replace package atm_api_collection_pkg is

    procedure start_collection (
        o_id                    out com_api_type_pkg.t_medium_id
        , i_terminal_id         in com_api_type_pkg.t_short_id
        , i_start_date          in date
        , i_start_auth_id       in com_api_type_pkg.t_long_id
        , o_coll_number         out com_api_type_pkg.t_short_id
    );
    
    procedure end_collection (
        i_id                    in com_api_type_pkg.t_medium_id
        , i_end_date            in date
        , i_end_auth_id         in com_api_type_pkg.t_long_id
    );

end;
/

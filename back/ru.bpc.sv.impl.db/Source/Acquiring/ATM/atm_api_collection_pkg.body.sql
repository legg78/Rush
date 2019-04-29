create or replace package body atm_api_collection_pkg is

    procedure start_collection (
        o_id                    out com_api_type_pkg.t_medium_id
        , i_terminal_id         in com_api_type_pkg.t_short_id
        , i_start_date          in date
        , i_start_auth_id       in com_api_type_pkg.t_long_id
        , o_coll_number         out com_api_type_pkg.t_short_id
    ) is
    begin
        o_id := atm_collection_seq.nextval;
        
        select nvl(max(collection_number), 0) + 1
          into o_coll_number
          from atm_collection
         where terminal_id = i_terminal_id;
        
        insert into atm_collection (
            id
            , terminal_id
            , start_date
            , start_auth_id
            , collection_number
        ) values ( 
            o_id
            , i_terminal_id
            , i_start_date
            , i_start_auth_id
            , o_coll_number
        );
    end;
    
    procedure end_collection (
        i_id                    in com_api_type_pkg.t_medium_id
        , i_end_date            in date
        , i_end_auth_id         in com_api_type_pkg.t_long_id
    ) is
    begin
        update atm_collection
        set
            end_date        = i_end_date
            , end_auth_id   = i_end_auth_id
        where
            id = i_id
            and end_auth_id is null;
    end;

end;
/

create or replace package body iss_ui_bin_index_range_pkg is

    procedure add_iss_bin_index_range (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_bin_id                  in com_api_type_pkg.t_short_id
        , i_index_range_id          in com_api_type_pkg.t_short_id
    ) is
        l_algorithm                 com_api_type_pkg.t_dict_value;
        l_low_value                 com_api_type_pkg.t_large_id;
        l_high_value                com_api_type_pkg.t_large_id;
    begin
        o_id := iss_bin_index_range_seq.nextval;
        o_seqnum := 1;
        
        insert into iss_bin_index_range_vw (
            id
            , seqnum
            , bin_id
            , index_range_id
        ) values (
            o_id
            , o_seqnum
            , i_bin_id
            , i_index_range_id
        );
            
        select t.algorithm
             , t.low_value
             , t.high_value
          into l_algorithm
             , l_low_value
             , l_high_value
          from rul_name_index_range_vw t
         where t.id = i_index_range_id;
        
        if l_algorithm in (
            rul_api_const_pkg.ALGORITHM_TYPE_RNGS
          , rul_api_const_pkg.ALGORITHM_TYPE_RNGR)
        then
            rul_ui_name_pool_pkg.add_pool(
                i_index_range_id => i_index_range_id
              , i_low_value      => l_low_value
              , i_high_value     => l_high_value
            );
        else
            rul_ui_name_pool_pkg.check_cross(
                i_index_range_id => i_index_range_id
              , i_low_value      => l_low_value
              , i_high_value     => l_high_value
            );
        end if;

    end add_iss_bin_index_range;

    procedure modify_iss_bin_index_range (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_bin_id                  in com_api_type_pkg.t_short_id
        , i_index_range_id          in com_api_type_pkg.t_short_id
    ) is
    begin
        update iss_bin_index_range_vw
           set seqnum = io_seqnum
             , bin_id = i_bin_id
             , index_range_id = i_index_range_id
         where id = i_id;
            
        io_seqnum := io_seqnum + 1;

    end modify_iss_bin_index_range;

    procedure remove_iss_bin_index_range (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        update iss_bin_index_range_vw
           set seqnum = i_seqnum
         where id = i_id;
            
        delete from iss_bin_index_range_vw
         where id = i_id;

    end remove_iss_bin_index_range;

end iss_ui_bin_index_range_pkg;
/

create or replace package fcl_prc_cycle_counter_pkg is

    procedure process (
        i_cycle_type        in      com_api_type_pkg.t_dict_value   default null
        , i_cycle_date_type in      com_api_type_pkg.t_dict_value   
        , i_inst_id         in      com_api_type_pkg.t_short_id   
    );

end;
/

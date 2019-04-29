create or replace package body aup_api_atm_pkg is

    procedure add_atm_tech (
        i_terminal_id               in com_api_type_pkg.t_short_id
      , i_tech_id                   in com_api_type_pkg.t_uuid
      , i_message_type              in com_api_type_pkg.t_tiny_id
      , i_last_oper_id              in com_api_type_pkg.t_long_id
    ) is
    begin
        insert into aup_atm_tech_vw (
              terminal_id
            , time_mark
            , tech_id
            , message_type
            , last_oper_id 
        ) values (
              i_terminal_id
            , systimestamp
            , i_tech_id
            , i_message_type
            , i_last_oper_id
        );
    end;

    procedure add_atm_status (
        i_tech_id                   in com_api_type_pkg.t_uuid
      , i_device_id                 in com_api_type_pkg.t_dict_value
      , i_device_status             in com_api_type_pkg.t_exponent
      , i_error_severity            in com_api_type_pkg.t_name
      , i_diag_status               in com_api_type_pkg.t_exponent
      , i_supplies_status           in com_api_type_pkg.t_dict_value
    ) is
        l_id                           com_api_type_pkg.t_long_id;
    begin
        l_id := aup_atm_status_seq.nextval;
        insert into aup_atm_status_vw (
              id
            , tech_id
            , time_mark
            , device_id
            , device_status
            , error_severity
            , diag_status
            , supplies_status 
        ) values (
              l_id
            , i_tech_id
            , systimestamp
            , i_device_id
            , i_device_status
            , i_error_severity
            , i_diag_status
            , i_supplies_status
        );
    end;

    function get_atm_disp_condition(
        i_auth_id                   in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_full_desc
    is
        l_condition           com_api_type_pkg.t_full_desc;
    begin
        select listagg(d.disp_number
                  || ':'
                  || d.face
                  || ' '
                  || nvl (c.name, d.currency)
                  || ' ('
                  || d.note_dispensed
                  || ')', ' / ') within group (order by d.disp_number) 
          into l_condition
          from aup_atm l
             , aup_atm_disp d
             , com_currency c
         where l.auth_id = i_auth_id
           and l.message_type = 40
           and d.auth_id = l.auth_id
           and d.tech_id = l.tech_id
           and c.code(+) = d.currency;     

        return l_condition;              
    end;

end;
/

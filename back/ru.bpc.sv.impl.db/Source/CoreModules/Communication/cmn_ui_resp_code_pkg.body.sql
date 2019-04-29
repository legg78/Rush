create or replace package body cmn_ui_resp_code_pkg as
/*********************************************************
 *  Communication - response code mapping  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 26.03.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: CMN_UI_RESP_CODE_PKG <br />
 *  @headcom
 **********************************************************/

procedure check_unique(
    i_resp_code         in      com_api_type_pkg.t_dict_value
  , i_resp_reason       in      com_api_type_pkg.t_dict_value
  , i_standard          in      com_api_type_pkg.t_tiny_id
  , i_device_code       in      com_api_type_pkg.t_dict_value
) is
    l_count                     simple_integer := 0;
begin
    select
        count(a.id)
    into
        l_count
    from
        cmn_resp_code_vw a
    where
        a.resp_code = i_resp_code
    and
        a.standard_id = i_standard
    and
        a.device_code_out = i_device_code
    and
        a.resp_reason = i_resp_reason;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'RESP_CODE_NOT_UNIQUE'
          , i_env_param1 => i_resp_code
          , i_env_param2 => nvl(i_resp_reason, 'null')
          , i_env_param3 => i_standard
          , i_env_param4 => i_device_code
        );
    end if;
end check_unique;

procedure add_resp_code(
    o_resp_code_id         out  com_api_type_pkg.t_short_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_standard          in      com_api_type_pkg.t_tiny_id
  , i_resp_code         in      com_api_type_pkg.t_dict_value
  , i_device_code_in    in      com_api_type_pkg.t_dict_value
  , i_device_code_out   in      com_api_type_pkg.t_dict_value
  , i_resp_reason       in      com_api_type_pkg.t_dict_value
) is
begin
    if i_device_code_out is not null then
        check_unique(
            i_resp_code    => i_resp_code
          , i_resp_reason  => i_resp_reason
          , i_standard     => i_standard
          , i_device_code  => i_device_code_out
        );
    end if;

    select cmn_resp_code_seq.nextval into o_resp_code_id from dual;

    o_seqnum := 1;

    insert into cmn_resp_code_vw(
        id
      , seqnum
      , standard_id
      , resp_code
      , device_code_in
      , device_code_out
      , resp_reason
    ) values (
        o_resp_code_id
      , o_seqnum
      , i_standard
      , i_resp_code
      , i_device_code_in
      , i_device_code_out
      , i_resp_reason
    );
end;

procedure modify_resp_code(
    i_resp_code_id      in      com_api_type_pkg.t_short_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_device_code_in    in      com_api_type_pkg.t_dict_value
  , i_device_code_out   in      com_api_type_pkg.t_dict_value
  , i_resp_reason       in      com_api_type_pkg.t_dict_value
) is
begin

    for rec in (
        select
            a.standard_id
          , a.resp_code
        from
            cmn_resp_code_vw a
        where
            a.id = i_resp_code_id)
    loop
        if i_device_code_out is not null then
            check_unique(
                i_resp_code    => rec.resp_code
              , i_resp_reason  => i_resp_reason
              , i_standard     => rec.standard_id
              , i_device_code  => i_device_code_out
            );
        end if;

        update cmn_resp_code_vw
           set seqnum          = io_seqnum
             , device_code_in  = i_device_code_in
             , device_code_out = i_device_code_out
             , resp_reason     = i_resp_reason
         where id              = i_resp_code_id;

        io_seqnum := io_seqnum + 1;
    end loop;
end;

procedure remove_resp_code(
    i_resp_code_id      in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update cmn_resp_code_vw
       set seqnum = i_seqnum
     where id     = i_resp_code_id;

    delete from cmn_resp_code_vw where id = i_resp_code_id;
end;

end;
/

create or replace package body atm_ui_dispenser_pkg as
/********************************************************* 
 * User Interface for ATM dispenser <br>
 * Created by Fomichev A.(fomichev@bpc.ru)  at 17.10.2011  <br>
 * Last changed by $Author$ <br>
 * $LastChangedDate::                           $  <br>
 * Revision: $LastChangedRevision$ <br>
 * Module: atm_ui_dispenser_pkg<br>
 * @headcom
 **********************************************************/
procedure add_dispenser(
    o_id                   out  com_api_type_pkg.t_medium_id
  , i_terminal_id      in       com_api_type_pkg.t_short_id
  , i_disp_number      in       com_api_type_pkg.t_tiny_id
  , i_face_value       in       com_api_type_pkg.t_money
  , i_currency         in       com_api_type_pkg.t_curr_code
  , i_denomination_id  in       com_api_type_pkg.t_curr_code
  , i_dispenser_type   in       com_api_type_pkg.t_dict_value
) is
begin
    atm_api_dispenser_pkg.add_dispenser(
        o_id              => o_id
      , i_terminal_id     => i_terminal_id
      , i_disp_number     => i_disp_number
      , i_face_value      => i_face_value
      , i_currency        => i_currency
      , i_denomination_id => i_denomination_id
      , i_dispenser_type  => i_dispenser_type 
    );
end;

procedure modify_dispenser(
    i_id               in       com_api_type_pkg.t_medium_id
  , i_terminal_id      in       com_api_type_pkg.t_short_id
  , i_disp_number      in       com_api_type_pkg.t_tiny_id
  , i_face_value       in       com_api_type_pkg.t_money
  , i_currency         in       com_api_type_pkg.t_curr_code
  , i_denomination_id  in       com_api_type_pkg.t_curr_code
  , i_dispenser_type   in       com_api_type_pkg.t_dict_value
) is
begin
    atm_api_dispenser_pkg.modify_dispenser(
        i_id              => i_id
      , i_terminal_id     => i_terminal_id
      , i_disp_number     => i_disp_number
      , i_face_value      => i_face_value
      , i_currency        => i_currency
      , i_denomination_id => i_denomination_id
      , i_dispenser_type  => i_dispenser_type
    );
end;

procedure remove_dispenser(
    i_id  in      com_api_type_pkg.t_medium_id
) is
begin
    atm_api_dispenser_pkg.remove_dispenser(
        i_id    => i_id
    );
end;

procedure modify_disp_stat(
    i_dispenser_id          in      com_api_type_pkg.t_medium_id
  , i_note_dispensed        in      com_api_type_pkg.t_tiny_id
  , i_note_remained         in      com_api_type_pkg.t_tiny_id
  , i_note_rejected         in      com_api_type_pkg.t_tiny_id
  , i_note_loaded           in      com_api_type_pkg.t_tiny_id      default null
  , i_cassette_status       in      com_api_type_pkg.t_dict_value
) is
begin
    merge into atm_dispenser_dynamic a
    using (
           select i_dispenser_id id
                , i_note_dispensed note_dispensed
                , i_note_remained note_remained
                , i_note_rejected note_rejected
                , i_note_loaded note_loaded
                , i_cassette_status cassete_status
             from dual
          ) b
       on (a.id = b.id)
    when matched then
        update
           set a.note_dispensed = b.note_dispensed
             , a.note_remained  = b.note_remained
             , a.note_rejected  = b.note_rejected
             , a.note_loaded    = nvl(b.note_loaded, a.note_loaded)
             , a.cassette_status = cassete_status
    when not matched then
        insert (
            id
          , note_dispensed
          , note_remained
          , note_rejected
          , note_loaded
          , cassette_status
        ) values (
            b.id
          , b.note_dispensed
          , b.note_remained
          , b.note_rejected
          , b.note_loaded
          , b.cassete_status
        );
end;

procedure modify_disp_stat(
    i_dispenser_id_tab      in      com_api_type_pkg.t_number_tab
  , i_note_dispensed_tab    in      com_api_type_pkg.t_number_tab
  , i_note_remained_tab     in      com_api_type_pkg.t_number_tab
  , i_note_rejected_tab     in      com_api_type_pkg.t_number_tab
  , i_note_loaded_tab       in      com_api_type_pkg.t_number_tab
  , i_cassette_status_tab    in      com_api_type_pkg.t_dict_tab
) is
    begin
        trc_log_pkg.debug (
            i_text          => 'Request to update dispensers status [#1][#2][#3][#4][#5][#6]'
            , i_env_param1  => i_dispenser_id_tab.count
            , i_env_param2  => i_note_dispensed_tab.count
            , i_env_param3  => i_note_remained_tab.count
            , i_env_param4  => i_note_rejected_tab.count
            , i_env_param5  => i_note_loaded_tab.count
            , i_env_param6  => i_cassette_status_tab.count
        );

        for i in 1 .. i_dispenser_id_tab.count loop
            trc_log_pkg.debug (
                i_text          => 'Status data [#6]: id=[#1] dispenced=[#2] remained=[#3] rejected=[#4] loaded=[#5]'
                , i_env_param1  => i_dispenser_id_tab(i)
                , i_env_param2  => i_note_dispensed_tab(i)
                , i_env_param3  => i_note_remained_tab(i)
                , i_env_param4  => i_note_rejected_tab(i)
                , i_env_param5  => i_note_loaded_tab(i)
                , i_env_param6  => i
            );
        end loop;

        forall i in 1 .. i_dispenser_id_tab.count
            merge into
                atm_dispenser_dynamic a
            using (
                select
                    i_dispenser_id_tab(i)       id
                    , i_note_dispensed_tab(i)   note_dispensed
                    , i_note_remained_tab(i)    note_remained
                    , i_note_rejected_tab(i)    note_rejected
                    , i_note_loaded_tab(i)      note_loaded
                    , i_cassette_status_tab(i)  cassette_status
                from
                    dual
            ) b
            on (
                a.id = b.id
            )
            when matched then
                update
                set
                    a.note_dispensed    = b.note_dispensed
                    , a.note_remained   = b.note_remained
                    , a.note_rejected   = b.note_rejected
                    , a.note_loaded     = nvl(b.note_loaded, a.note_loaded)
                    , a.cassette_status = b.cassette_status
            when not matched then
                insert (
                    id
                    , note_dispensed
                    , note_remained
                    , note_rejected
                    , note_loaded
                    , cassette_status
                ) values (
                    b.id
                    , b.note_dispensed
                    , b.note_remained
                    , b.note_rejected
                    , b.note_loaded
                    , b.cassette_status
            );

        trc_log_pkg.debug (
            i_text          => 'Update dispensers status done'
        );
    end;

procedure change_dispenser_status(
    i_dispenser_id          in      com_api_type_pkg.t_medium_id
  , i_cassette_status       in      com_api_type_pkg.t_dict_value
) is
begin
    for rec in (
        select
            note_dispensed
          , note_remained
          , note_rejected
          , note_loaded
        from
            atm_dispenser_dynamic
        where id = i_dispenser_id
        )
    loop
        modify_disp_stat(
            i_dispenser_id    => i_dispenser_id
          , i_note_dispensed  => rec.note_dispensed
          , i_note_remained   => rec.note_remained
          , i_note_rejected   => rec.note_rejected
          , i_note_loaded     => rec.note_loaded
          , i_cassette_status => i_cassette_status
        );
        return;
    end loop;

    modify_disp_stat(
        i_dispenser_id    => i_dispenser_id
      , i_note_dispensed  => null
      , i_note_remained   => null
      , i_note_rejected   => null
      , i_note_loaded     => null
      , i_cassette_status => i_cassette_status
    );

end;


end;
/

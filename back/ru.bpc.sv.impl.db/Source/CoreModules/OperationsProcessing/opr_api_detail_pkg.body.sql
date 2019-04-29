create or replace package body opr_api_detail_pkg is

function get_oper_detail(
    i_oper_id            in     com_api_type_pkg.t_long_id
) return opr_api_type_pkg.t_oper_detail_tab is
    l_out_object_tab            opr_api_type_pkg.t_oper_detail_tab;
begin

    select id
         , oper_id
         , entity_type
         , object_id
      bulk collect
      into l_out_object_tab
      from opr_oper_detail
     where oper_id = i_oper_id;

    return l_out_object_tab;

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => 'No details for the operation [#1]'
          , i_env_param1 => i_oper_id
        );
end get_oper_detail;

procedure set_oper_detail(
    i_oper_id            in     com_api_type_pkg.t_long_id
  , i_object_tab         in     opr_api_type_pkg.t_oper_detail_tab
  , i_date               in     date
) is
begin

    trc_log_pkg.debug(i_text => 'start set_oper_detail');

    if i_object_tab.count > 0 then
        for i in 1 .. i_object_tab.count loop

            insert into opr_oper_detail(
                id
              , oper_id
              , object_id
              , entity_type
            ) values(
                com_api_id_pkg.get_id(opr_oper_detail_seq.nextval, i_date)
              , i_oper_id
              , i_object_tab(i).object_id
              , i_object_tab(i).entity_type
            );
        end loop;

        trc_log_pkg.debug(
            i_text       => 'Added [#1] details for the operation [#2]'
          , i_env_param1 => sql%rowcount
          , i_env_param2 => i_oper_id
        );
    end if;
end set_oper_detail;

procedure set_oper_detail(
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
) is
begin
    trc_log_pkg.debug(
        i_text          => 'set_oper_detail: i_oper_id [#1], i_entity_type [#2], i_object_id [#3]'
      , i_env_param1    => i_oper_id
      , i_env_param2    => i_entity_type
      , i_env_param3    => i_object_id
    );

    insert into opr_oper_detail(
        id
      , oper_id
      , object_id
      , entity_type
    ) values(
        com_api_id_pkg.get_id(opr_oper_detail_seq.nextval, com_api_sttl_day_pkg.get_sysdate)
      , i_oper_id
      , i_object_id
      , i_entity_type
    );

exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end set_oper_detail;

procedure remove_oper_detail(
    i_id_tab             in     com_api_type_pkg.t_long_tab
) is
begin
    forall i in 1 .. i_id_tab.count
        delete opr_oper_detail
         where id = i_id_tab(i);

    trc_log_pkg.debug(
        i_text       => 'Deleted [#1] details'
      , i_env_param1 => sql%rowcount
    );
end remove_oper_detail;

procedure remove_oper_detail(
    i_oper_id            in     com_api_type_pkg.t_long_id
) is
begin

    delete opr_oper_detail
     where oper_id  = i_oper_id;

    if sql%rowcount = 0 then
        trc_log_pkg.debug(
            i_text       => 'remove operation details: for operation [#1] is not exists'
          , i_env_param1 => i_oper_id
        );
    else
        trc_log_pkg.debug(
            i_text       => 'remove operation details: for operation [#1] deleted [#2] details'
          , i_env_param1 => i_oper_id
          , i_env_param2 => sql%rowcount
        );
    end if;
end remove_oper_detail;

end opr_api_detail_pkg;
/

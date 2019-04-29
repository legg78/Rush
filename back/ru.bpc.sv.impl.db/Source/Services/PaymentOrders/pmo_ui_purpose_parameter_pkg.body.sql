create or replace package body pmo_ui_purpose_parameter_pkg as
/************************************************************
 * UI for Payment Order Purpose Parameters<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 14.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_UI_PURPOSE_PARAMETER_PKG <br />
 * @headcom
 ************************************************************/

procedure add(
    o_id                       out com_api_type_pkg.t_short_id
  , o_seqnum                   out com_api_type_pkg.t_seqnum
  , i_param_id              in     com_api_type_pkg.t_short_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_order_stage           in     com_api_type_pkg.t_dict_value
  , i_display_order         in     com_api_type_pkg.t_tiny_id
  , i_is_mandatory          in     com_api_type_pkg.t_boolean
  , i_is_template_fixed     in     com_api_type_pkg.t_boolean
  , i_is_editable           in     com_api_type_pkg.t_boolean
  , i_data_type             in     com_api_type_pkg.t_dict_value
  , i_default_value_char    in     com_api_type_pkg.t_name
  , i_default_value_num     in     com_api_type_pkg.t_rate
  , i_default_value_date    in     date
  , i_param_function        in     com_api_type_pkg.t_name          default null

) is
    l_default_value     com_api_type_pkg.t_name;
    l_check_cnt         com_api_type_pkg.t_count := 0;
begin
    if i_param_function is not null then
        select count(*)
          into l_check_cnt
          from user_procedures u
         where subprogram_id > 0
           and object_name || nvl2(procedure_name, '.', '') || procedure_name = upper(i_param_function);

        if l_check_cnt = 0 then
            com_api_error_pkg.raise_error(
                i_error       => 'PROCEDURE_NOT_FOUND'
              , i_env_param1  => i_param_function
            );
        end if;
    end if;

    o_id     := pmo_purpose_parameter_seq.nextval;
    o_seqnum := 1;

    if i_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        l_default_value := to_char( i_default_value_num
                                  , com_api_const_pkg.NUMBER_FORMAT
                                  );
    elsif i_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        l_default_value := to_char( i_default_value_date
                                  , com_api_const_pkg.DATE_FORMAT
                                  );
    else
         l_default_value := i_default_value_char;
    end if;

    insert into pmo_purpose_parameter_vw(
        id
      , seqnum
      , param_id
      , purpose_id
      , order_stage
      , display_order
      , is_mandatory
      , is_template_fixed
      , is_editable
      , default_value
      , param_function
    ) values (
        o_id
      , o_seqnum
      , i_param_id
      , i_purpose_id
      , i_order_stage
      , i_display_order
      , i_is_mandatory
      , i_is_template_fixed
      , i_is_editable
      , l_default_value
      , i_param_function
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'PURPOSE_PARAMETER_ALREADY_EXISTS'
          , i_env_param1 => get_text ('pmo_parameter', 'label', i_param_id, com_ui_user_env_pkg.get_user_lang)
          , i_env_param2 => i_purpose_id
        );
end;

procedure modify(
    i_id                    in     com_api_type_pkg.t_short_id
  , io_seqnum               in out com_api_type_pkg.t_seqnum
  , i_param_id              in     com_api_type_pkg.t_short_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_order_stage           in     com_api_type_pkg.t_dict_value
  , i_display_order         in     com_api_type_pkg.t_tiny_id
  , i_is_mandatory          in     com_api_type_pkg.t_boolean
  , i_is_template_fixed     in     com_api_type_pkg.t_boolean
  , i_is_editable           in     com_api_type_pkg.t_boolean
  , i_data_type             in     com_api_type_pkg.t_dict_value
  , i_default_value_char    in     com_api_type_pkg.t_name
  , i_default_value_num     in     com_api_type_pkg.t_rate
  , i_default_value_date    in     date
  , i_param_function        in     com_api_type_pkg.t_name          default null
) is
    l_default_value     com_api_type_pkg.t_name;
    l_check_cnt         com_api_type_pkg.t_count := 0;
begin
    if i_param_function is not null then
        select count(*)
          into l_check_cnt
          from user_procedures u
         where subprogram_id > 0
           and object_name || nvl2(procedure_name, '.', '') || procedure_name = upper(i_param_function);

        if l_check_cnt = 0 then
            com_api_error_pkg.raise_error(
                i_error       => 'PROCEDURE_NOT_FOUND'
              , i_env_param1  => i_param_function
            );
        end if;
    end if;

    if i_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        l_default_value := to_char( i_default_value_num
                                  , com_api_const_pkg.NUMBER_FORMAT
                                  );
    elsif i_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        l_default_value := to_char( i_default_value_date
                                  , com_api_const_pkg.DATE_FORMAT
                                  );
    else
         l_default_value := i_default_value_char;
    end if;

    update
        pmo_purpose_parameter_vw a
    set
        a.seqnum                 = io_seqnum
      , a.param_id               = i_param_id
      , a.purpose_id             = i_purpose_id
      , a.order_stage            = i_order_stage
      , a.display_order          = i_display_order
      , a.is_mandatory           = i_is_mandatory
      , a.is_template_fixed      = i_is_template_fixed
      , a.is_editable            = i_is_editable
      , a.default_value          = l_default_value
      , a.param_function         = i_param_function
    where
        a.id = i_id;

    io_seqnum := io_seqnum + 1;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'PURPOSE_PARAMETER_ALREADY_EXISTS'
          , i_env_param1 => get_text ('pmo_parameter', 'label', i_param_id, com_ui_user_env_pkg.get_user_lang)
          , i_env_param2 => i_purpose_id
        );

end;

procedure remove(
    i_id              in     com_api_type_pkg.t_short_id
  , i_seqnum          in     com_api_type_pkg.t_seqnum
) is
begin
    update
        pmo_purpose_parameter_vw a
    set
        a.seqnum = i_seqnum
    where
        a.id = i_id;

    delete
        pmo_purpose_parameter_vw a
    where
        a.id = i_id;

end;


procedure add_value(
    o_id                       out com_api_type_pkg.t_medium_id
  , i_purp_param_id         in     com_api_type_pkg.t_short_id
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_data_type             in     com_api_type_pkg.t_dict_value
  , i_value_char            in     com_api_type_pkg.t_name
  , i_value_num             in     com_api_type_pkg.t_rate
  , i_value_date            in     date
) is
    l_param_value com_api_type_pkg.t_name;
begin

    if i_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        l_param_value := to_char( i_value_num
                                  , com_api_const_pkg.NUMBER_FORMAT
                                  );
    elsif i_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        l_param_value := to_char( i_value_date
                                  , com_api_const_pkg.DATE_FORMAT
                                  );
    else
         l_param_value := i_value_char;
    end if;

    o_id := pmo_purp_param_value_seq.nextval;
    insert into pmo_purp_param_value_vw(
        id
      , purp_param_id
      , entity_type
      , object_id
      , param_value
    ) values (
        o_id
      , i_purp_param_id
      , i_entity_type
      , i_object_id
      , l_param_value
    );
end add_value;

procedure modify_value(
    i_id                    in     com_api_type_pkg.t_medium_id
  , i_data_type             in     com_api_type_pkg.t_dict_value
  , i_value_char            in     com_api_type_pkg.t_name
  , i_value_num             in     com_api_type_pkg.t_rate
  , i_value_date            in     date
) is
    l_param_value com_api_type_pkg.t_name;
begin


    if i_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        l_param_value := to_char( i_value_num
                                  , com_api_const_pkg.NUMBER_FORMAT
                                  );
    elsif i_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        l_param_value := to_char( i_value_date
                                  , com_api_const_pkg.DATE_FORMAT
                                  );
    else
         l_param_value := i_value_char;
    end if;

    update
        pmo_purp_param_value_vw a
    set
        a.param_value = l_param_value
    where
        a.id = i_id;

end modify_value;

procedure remove_value(
    i_id                    in     com_api_type_pkg.t_medium_id
) is
begin
    delete
        pmo_purp_param_value_vw a
    where
        a.id = i_id;
end remove_value;

end pmo_ui_purpose_parameter_pkg;
/

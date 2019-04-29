create or replace package body app_ui_dependence_pkg as
/********************************************************* 
 *  UI for Dependence in application <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 01.02.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: app_ui_dependence_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
function get_property_value(
    i_depend_id         in      com_api_type_pkg.t_tiny_id
  , i_element_name      in      com_api_type_pkg.t_name
  , i_char_value        in      com_api_type_pkg.t_name         default null
  , i_number_value      in      number                          default null
  , i_date_value        in      date                            default null
) return com_api_type_pkg.t_name is
    l_value             com_api_type_pkg.t_name;
    l_cursor            sys_refcursor;
    l_condition         com_api_type_pkg.t_name;
begin
    begin
        select condition
          into l_condition
          from app_dependence
         where id = i_depend_id;
        
    exception
        when no_data_found then
            null;
    end;

    if i_char_value is not null then
        l_value := i_char_value;
    elsif  i_number_value is not null then
        l_value := 'to_number(''' || 
                    to_char(i_number_value, com_api_const_pkg.NUMBER_FORMAT) || ''', ''' || 
                    com_api_const_pkg.NUMBER_FORMAT || ''')';
    elsif  i_date_value is not null then
        l_value := 'to_date(''' || 
                    to_char(i_date_value, com_api_const_pkg.DATE_FORMAT) || ''', ''' || 
                    com_api_const_pkg.DATE_FORMAT || ''')';
    end if;

    l_condition := 'select ' || replace(upper(l_condition), ':'||upper(i_element_name), l_value) || ' from dual';
    
    begin
        open l_cursor for l_condition;
        fetch l_cursor into l_value;
        close l_cursor;
    exception
        when others then
            com_api_error_pkg.raise_error(
                i_error             => 'APP_DEPENDENCE_CONDITION_EXEC_ERROR'
              , i_env_param1        => substr(sqlerrm, 1, 200)
              , i_env_param2        => substr(l_condition, 1, 200)
            );
    end;

    return l_value;
end;

function get_property_value_b(
    i_depend_id         in      com_api_type_pkg.t_tiny_id
  , i_element_name      in      com_api_type_pkg.t_name
  , i_char_value        in      com_api_type_pkg.t_name             default null
  , i_number_value      in      number                          default null
  , i_date_value        in      date                            default null
) return com_api_type_pkg.t_boolean is
    l_result            com_api_type_pkg.t_boolean;
begin
    l_result := 
        to_number(
            get_property_value(
                i_depend_id         => i_depend_id
              , i_element_name      => i_element_name
              , i_char_value        => i_char_value
              , i_number_value      => i_number_value
              , i_date_value        => i_date_value
            )
        );
        
    if l_result not in (com_api_const_pkg.FALSE, com_api_const_pkg.TRUE) then
        l_result := com_api_const_pkg.FALSE;
    end if;

    return l_result;

end;

function get_property_value_n(
    i_depend_id         in      com_api_type_pkg.t_tiny_id
  , i_element_name      in      com_api_type_pkg.t_name
  , i_char_value        in      com_api_type_pkg.t_name         default null
  , i_number_value      in      number                          default null
  , i_date_value        in      date                            default null
) return number is
    l_result            number;
begin
    l_result := 
        to_number(
            get_property_value(
                i_depend_id         => i_depend_id
              , i_element_name      => i_element_name
              , i_char_value        => i_char_value
              , i_number_value      => i_number_value
              , i_date_value        => i_date_value
            )
          , com_api_const_pkg.NUMBER_FORMAT
        );

    return l_result;

end;

function get_property_value_d(
    i_depend_id         in      com_api_type_pkg.t_tiny_id
  , i_element_name      in      com_api_type_pkg.t_name
  , i_char_value        in      com_api_type_pkg.t_name         default null
  , i_number_value      in      number                          default null
  , i_date_value        in      date                            default null
) return date is
    l_result            date;
begin
    l_result := 
        to_date(
            get_property_value(
                i_depend_id         => i_depend_id
              , i_element_name      => i_element_name
              , i_char_value        => i_char_value
              , i_number_value      => i_number_value
              , i_date_value        => i_date_value
            )
          , com_api_const_pkg.DATE_FORMAT
        );

    return l_result;

end;

function get_parent_entity(
    i_parent_struct_id  in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_name is
    l_result com_api_type_pkg.t_name;
begin
    select min(e.name)
      into l_result 
      from app_structure s
         , app_element_all_vw e
     where s.id   = i_parent_struct_id
       and e.id   = s.element_id;

    return
    case l_result
    when 'APPLICATION' then app_api_const_pkg.ENTITY_TYPE_APPLICATION
    when 'MERCHANT'    then acq_api_const_pkg.ENTITY_TYPE_MERCHANT
    when 'TERMINAL'    then acq_api_const_pkg.ENTITY_TYPE_TERMINAL
    when 'FEE'         then fcl_api_const_pkg.ENTITY_TYPE_FEE
    when 'CYCLE'       then fcl_api_const_pkg.ENTITY_TYPE_CYCLE
    when 'LIMIT'       then fcl_api_const_pkg.ENTITY_TYPE_LIMIT
    when 'ACCOUNT'     then acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
    when 'PERSON'      then com_api_const_pkg.ENTITY_TYPE_PERSON
    when 'COMPANY'     then com_api_const_pkg.ENTITY_TYPE_COMPANY

    else l_result
    end;
end;

procedure add(
    o_id                   out  com_api_type_pkg.t_short_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_struct_id         in      com_api_type_pkg.t_short_id
  , i_depend_struct_id  in      com_api_type_pkg.t_short_id
  , i_dependence        in      com_api_type_pkg.t_dict_value
  , i_condition         in      com_api_type_pkg.t_name
  , i_affected_zone     in      com_api_type_pkg.t_dict_value
) is
begin
    o_id := app_dependence_seq.nextval;
    o_seqnum := 1;

    insert into app_dependence_vw(
        id
      , seqnum
      , struct_id
      , depend_struct_id
      , dependence
      , condition
      , affected_zone
    ) values (
        o_id
      , o_seqnum
      , i_struct_id
      , i_depend_struct_id
      , i_dependence
      , i_condition
      , i_affected_zone
    );

end;

procedure modify(
    i_id                in      com_api_type_pkg.t_short_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_struct_id         in      com_api_type_pkg.t_short_id
  , i_depend_struct_id  in      com_api_type_pkg.t_short_id
  , i_dependence        in      com_api_type_pkg.t_dict_value
  , i_condition         in      com_api_type_pkg.t_name
  , i_affected_zone     in      com_api_type_pkg.t_dict_value
) is
begin
    update app_dependence_vw
       set seqnum           = io_seqnum
         , struct_id        = i_struct_id
         , depend_struct_id = i_depend_struct_id
         , dependence       = i_dependence
         , condition        = i_condition
         , affected_zone    = i_affected_zone
     where id               = i_id;

    io_seqnum := io_seqnum + 1;
end;

procedure remove(
    i_id                in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update app_dependence_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete app_dependence_vw
     where id     = i_id;
end;

end;
/

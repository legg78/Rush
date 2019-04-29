create or replace package body pmo_api_parameter_pkg as
/************************************************************
 * UI for Payment Order parameters <br />
 * Created by Fomichev A.(fomichev@bpcbt.com)  at 31.10.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: pmo_api_parameter_pkg <br />
 * @headcom
 ************************************************************/

procedure get_purp_param_value(
    i_param_name in     com_api_type_pkg.t_name
  , i_purpose_id in     com_api_type_pkg.t_short_id
  , o_value         out varchar2
) is
begin
    select min(param_value)
      into o_value
      from pmo_parameter_vw p
         , pmo_purpose_parameter_vw pp
         , pmo_purp_param_value_vw v
     where p.param_name  = i_param_name
       and p.data_type   = com_api_const_pkg.DATA_TYPE_CHAR
       and p.id          = pp.param_id
       and pp.purpose_id = i_purpose_id
       and pp.param_id   = v.purp_param_id;
    trc_log_pkg.debug('get_purp_param_value: param_name ='||i_param_name||', purpose_id='||i_purpose_id||', value='||o_value);
end;

procedure get_purp_param_value(
    i_param_name in     com_api_type_pkg.t_name
  , i_purpose_id in     com_api_type_pkg.t_short_id
  , o_value         out number
) is
begin
    select min(param_value)
      into o_value
      from pmo_parameter_vw p
         , pmo_purpose_parameter_vw pp
         , pmo_purp_param_value_vw v
     where p.param_name  = i_param_name
       and p.data_type   = com_api_const_pkg.DATA_TYPE_NUMBER
       and p.id          = pp.param_id
       and pp.purpose_id = i_purpose_id
       and pp.param_id   = v.purp_param_Id;
    trc_log_pkg.debug('get_purp_param_value: param_name ='||i_param_name||', purpose_id='||i_purpose_id||', value='||o_value);
end;

procedure get_purp_param_value(
    i_param_name in     com_api_type_pkg.t_name
  , i_purpose_id in     com_api_type_pkg.t_short_id
  , o_value         out date
) is
begin
    select min(param_value)
      into o_value
      from pmo_parameter_vw p
         , pmo_purpose_parameter_vw pp
         , pmo_purp_param_value_vw v
     where p.param_name  = i_param_name
       and p.data_type   = com_api_const_pkg.DATA_TYPE_DATE
       and p.id          = pp.param_id
       and pp.purpose_id = i_purpose_id
       and pp.param_id   = v.purp_param_Id;

    trc_log_pkg.debug('get_purp_param_value: param_name ='||i_param_name||', purpose_id='||i_purpose_id||', value='||o_value);
end;

function get_purp_param_char(
    i_param_name in     com_api_type_pkg.t_name
  , i_purpose_id in     com_api_type_pkg.t_short_id
) return varchar2 is
l_value  com_api_type_pkg.t_name;
begin
    get_purp_param_value(
        i_param_name  => i_param_name
      , i_purpose_id  => i_purpose_id
      , o_value       => l_value
    );

    return l_value;    
end;

function get_purp_param_num(
    i_param_name in     com_api_type_pkg.t_name
  , i_purpose_id in     com_api_type_pkg.t_short_id
) return number is
l_value  number;
begin
    get_purp_param_value(
        i_param_name  => i_param_name
      , i_purpose_id  => i_purpose_id
      , o_value       => l_value
    );
    return l_value;
end;

function get_purp_param_date(
    i_param_name in     com_api_type_pkg.t_name
  , i_purpose_id in     com_api_type_pkg.t_short_id
) return  date is
l_value   date;
begin
    get_purp_param_value(
        i_param_name  => i_param_name
      , i_purpose_id  => i_purpose_id
      , o_value       => l_value
    );
    
    return l_value;
end;

function get_pmo_parameter_id(
    i_param_name        in     com_api_type_pkg.t_name
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id
is
    l_parameter_id          com_api_type_pkg.t_short_id;
begin
    begin
        begin
            select p.id
              into l_parameter_id
              from pmo_parameter p
             where p.param_name = upper(i_param_name);
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'PARAM_NOT_FOUND'
                  , i_env_param1  => i_param_name
                  , i_env_param2  => i_inst_id
                  , i_mask_error  => i_mask_error
                );
            when too_many_rows then
                com_api_error_pkg.raise_error(
                    i_error       => 'TOO_MANY_RECORDS_FOUND'
                  , i_mask_error  => i_mask_error
                );
        end;
    exception
        when com_api_error_pkg.e_application_error then
            if nvl(i_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.FALSE then
                raise;
            end if;
    end;

    return l_parameter_id;
end get_pmo_parameter_id;

end;
/

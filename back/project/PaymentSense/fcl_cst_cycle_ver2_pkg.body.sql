create or replace package body fcl_cst_cycle_ver2_pkg as
/*********************************************************
 *  The package with user-exits for shift's cycles processing <br />
 *
 *  Created by A. Alalykin (alalykin@bpcbt.com) at 24.03.2014 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate: 2014-03-24 12:28:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: fcl_cst_cycle_ver2_pkg <br />
 *  @headcom
 **********************************************************/

/**********************************************************
 * Custom processing for a user cycle's shift.
 * It returns NULL if no appropriate cycle's shift is found
 **********************************************************/

CYCLE_STTL_FREQ_SHIFT_TYPE       constant com_api_type_pkg.t_dict_value  := 'CSHT5000';
CYCLE_STTL_FREQ_ATTR_NAME        constant com_api_type_pkg.t_name        := 'CST_SETTLEMENT_HOURS';

function shift_date(
    i_date              in date
  , i_shift_type        in com_api_type_pkg.t_dict_value
  , i_shift_sign        in com_api_type_pkg.t_sign
  , i_length_type       in com_api_type_pkg.t_dict_value
  , i_shift_length      in com_api_type_pkg.t_tiny_id
  , i_forward           in com_api_type_pkg.t_boolean
  , i_start_date        in date default null
  , i_object_params     in com_api_type_pkg.t_param_tab
) return date
is
    l_current_hour         com_api_type_pkg.t_tiny_id;
    l_result_date          date;
    l_sttl_hours           com_api_type_pkg.t_name;
begin
    case i_shift_type
        when CYCLE_STTL_FREQ_SHIFT_TYPE then
            case i_length_type
                when fcl_api_const_pkg.CYCLE_LENGTH_HOUR then
                    -- get settlement hours

                    l_sttl_hours := prd_api_product_pkg.get_attr_value_char(
                                        i_entity_type => i_object_params('ENTITY_TYPE')
                                      , i_object_id   => i_object_params('OBJECT_ID')
                                      , i_attr_name   => CYCLE_STTL_FREQ_ATTR_NAME
                                    );

                    trc_log_pkg.debug(
                        i_text       => 'Process custom shift for object_id[#1] entity_type[#2] sttl_hours[#3]'
                      , i_env_param1 => i_object_params('OBJECT_ID')
                      , i_env_param2 => i_object_params('ENTITY_TYPE')
                      , i_env_param3 => l_sttl_hours
                    );

                    if i_forward = com_api_const_pkg.TRUE then
                        l_current_hour := extract(hour from cast(i_start_date as timestamp));
                        l_result_date  := trunc(i_start_date, 'dd');

                        for rec in (with hour_set as
                                        (select to_number(regexp_substr(
                                                              l_sttl_hours, '\d+', 1, level)
                                                         ) hr
                                          from dual
                                        connect by regexp_substr(l_sttl_hours,'\d+', 1, level) is not null)
                                       select h.hr set_hour
                                             , max(h.hr) over(partition by null) set_max
                                             , min(h.hr) over(partition by null) set_min
                                         from hour_set h
                                         order by set_hour)
                        loop
                            if l_current_hour = rec.set_hour and l_current_hour < rec.set_max then
                                continue;

                            elsif l_current_hour < rec.set_hour and l_current_hour < rec.set_max then
                                l_result_date := l_result_date + 1/24 * rec.set_hour;
                                exit;

                            elsif l_current_hour >= rec.set_hour and l_current_hour >= rec.set_max then
                                l_result_date := l_result_date + 1 + 1 / 24 * rec.set_min;
                                exit;

                            end if;

                        end loop;

                    else
                        null;

                    end if;

                else
                    com_api_error_pkg.raise_error(
                        i_error => 'CYCLE_LENGTH_TYPE_NOT_DEFINED'
                    );
            end case;

        else
            com_api_error_pkg.raise_error(
                i_error => 'CYCLE_SHIFT_TYPE_NOT_DEFINED'
            );
    end case;

    return null;
end;

/**********************************************************
 * Custom processing when e_application_error raised
 * possibillty to modify next_date of processed cycle
 **********************************************************/
procedure on_application_error(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , io_next_date        in out  date
) is
begin
    null;
end;

end;
/

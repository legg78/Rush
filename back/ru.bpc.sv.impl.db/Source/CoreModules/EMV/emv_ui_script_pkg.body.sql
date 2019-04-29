create or replace package body emv_ui_script_pkg is
/************************************************************
 * User interface for EMV script<br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 12.12.2012 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: emv_ui_script_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_script (
        o_id                    out com_api_type_pkg.t_long_id
        , i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_type                in com_api_type_pkg.t_dict_value
        , i_status              in com_api_type_pkg.t_dict_value
        , i_param_tab           in com_param_map_tpt
    ) is
        l_script_type           emv_api_type_pkg.t_emv_script_type_rec;
        l_length                com_api_type_pkg.t_tiny_id;
        l_data                  com_api_type_pkg.t_name;
        l_status                com_api_type_pkg.t_dict_value;
        
        function get_char_value (
            i_param_name        in com_api_type_pkg.t_name
        ) return com_api_type_pkg.t_name is
            l_result            com_api_type_pkg.t_name;
        begin
            select
                case when char_value is not null then char_value
                else null
                end
            into
                l_result
            from
                table(cast(i_param_tab as com_param_map_tpt))
            where
                name = i_param_name;

            return l_result;
        exception
            when no_data_found then
                return null;
        end;

        function get_date_value (
            i_param_name        in com_api_type_pkg.t_name
        ) return date is
            l_result            date;
        begin
            select
                case when date_value is not null then date_value
                else null
                end
            into
                l_result
            from
                table(cast(i_param_tab as com_param_map_tpt))
            where
                name = i_param_name;

            return l_result;
        exception
            when no_data_found then
                return null;
        end;

        function get_number_value (
            i_param_name        in com_api_type_pkg.t_name
        ) return number is
            l_result            number;
        begin
            select
                case when number_value is not null then number_value
                else null
                end
            into
                l_result
            from
                table(cast(i_param_tab as com_param_map_tpt))
            where
                name = i_param_name;

            return l_result;
        exception
            when no_data_found then
                return null;
        end;
    begin
        l_script_type := emv_api_script_type_pkg.get_script_type (
            i_type  => i_type
        );
        
        case l_script_type.type
            when emv_api_const_pkg.SCRIPT_TYPE_PIN_CHANGE then
                l_data := get_char_value('PIN_BLOCK');
                l_length := prs_api_util_pkg.dec2hex(nvl(length(l_data), 0)/2);
            
            else
                l_length := 0;
        end case;
        
        l_status := nvl(i_status, emv_api_const_pkg.SCRIPT_STATUS_WAITING);

        -- get script status
        begin
            select
                emv_api_const_pkg.SCRIPT_STATUS_OVERLOADED
            into
                l_status
            from
                emv_script_vw s
            where
                s.object_id = i_object_id
                and s.entity_type = i_entity_type
                and s.status in (emv_api_const_pkg.SCRIPT_STATUS_WAITING, emv_api_const_pkg.SCRIPT_STATUS_PROCESSING)
                and s.type_id = l_script_type.id
                and rownum = 1;
        exception
            when no_data_found then
                null;
        end;
        
        o_id := emv_script_seq.nextval;

        insert into emv_script_vw (
            id
            , object_id
            , entity_type
            , type_id
            , status
            , class_byte
            , instruction_byte
            , parameter1
            , parameter2
            , length
            , data
            , change_date
        ) values (
            o_id
            , i_object_id
            , i_entity_type
            , l_script_type.id
            , l_status
            , l_script_type.class_byte
            , l_script_type.instruction_byte
            , l_script_type.parameter1
            , l_script_type.parameter2
            , l_length
            , l_data
            , get_sysdate
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'DUPLICATE_EMV_SCRIPT'
                , i_env_param1  => i_object_id
                , i_env_param2  => i_entity_type
                , i_env_param3  => i_type
                , i_env_param4  => i_status
            );
    end;

    procedure remove_script (
        i_id                    in com_api_type_pkg.t_long_id
    ) is
    begin
        delete from
            emv_script_vw
        where
            id = i_id;
    end;

end;
/

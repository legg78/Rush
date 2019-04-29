create or replace package body csm_api_utl_pkg is
/*************************************************************
 * API for case utilities <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com)  at 17.01.2018
 * Module: CSM_API_UTL_PKG
 * @headcom
**************************************************************/
ENV_PARAM_COUNT        constant pls_integer := 4;
SIZEOF_T_TEXT          constant pls_integer := 4000; -- sizeof(com_api_type_pkg.t_text)

function get_case_comment(
    i_action            in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_text
is
    l_result            com_api_type_pkg.t_lob_data; -- uses a longest available string type to escape variable's overflow
    l_env_param         com_api_type_pkg.t_full_desc;
    l_description       com_api_type_pkg.t_full_desc := i_description;
    l_pos               pls_integer;
    i                   com_api_type_pkg.t_count := 1;
begin
    if i_action is null then
        return i_description;
    end if;

    l_result := 
        com_api_label_pkg.get_label_text(
            i_name              => i_action
          , i_text_field_name   => com_api_const_pkg.TEXT_IN_DESCRIPTION
          , i_lang              => i_lang
        );

    while i <= ENV_PARAM_COUNT
      and instr(l_result, '#') > 0
      and lengthb(l_result) < SIZEOF_T_TEXT
    loop
        l_pos := instr(l_description, '";');
        if l_pos = 0 then
            l_env_param     := trim(both '"' from l_description);
            l_result        := replace(l_result, '#'||i, nvl(com_api_dictionary_pkg.get_article_text(to_char(l_env_param)), 'UNDEFINED'));
            l_description   := null;
        else
            l_env_param     := trim(both '"' from substr(l_description, 1, l_pos));
            l_result        := replace(l_result, '#'||i, nvl(com_api_dictionary_pkg.get_article_text(to_char(l_env_param)), 'UNDEFINED'));
            l_description   := substr(l_description, l_pos + 3);
        end if;
        i := i + 1;
    end loop;
    
    return substrb(l_result, 1, SIZEOF_T_TEXT);
end get_case_comment;

function is_mcom_enabled(
    i_network_id        in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_tiny_id
  , i_host_id           in      com_api_type_pkg.t_tiny_id       default null
  , i_standard_id       in      com_api_type_pkg.t_tiny_id       default null
) return com_api_type_pkg.t_boolean is
    l_result        com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_host_id       com_api_type_pkg.t_tiny_id := i_host_id;
    l_standard_id   com_api_type_pkg.t_tiny_id := i_standard_id;
    l_param_tab     com_api_type_pkg.t_param_tab;
begin

    if nvl(i_network_id, -1) != cmp_api_const_pkg.MC_NETWORK then
       return null;
    end if;

    if l_host_id is null then
        l_host_id       := net_api_network_pkg.get_default_host(i_network_id => i_network_id);
    end if;
    if l_standard_id is null then
        l_standard_id   := net_api_network_pkg.get_offline_standard(i_network_id => i_network_id);
    end if;
    l_result := 
        nvl(cmn_api_standard_pkg.get_number_value(
                i_inst_id       => i_inst_id
              , i_standard_id   => l_standard_id
              , i_object_id     => l_host_id
              , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name    => 'MASTERCOM_ENABLED'
              , i_param_tab     => l_param_tab
            )
            , com_api_type_pkg.FALSE
        );
    return l_result;

end is_mcom_enabled;

function is_mcom_enabled(
    i_oper_id        in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean is
    l_result         com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_inst_id        com_api_type_pkg.t_tiny_id;
    l_network_id     com_api_type_pkg.t_tiny_id;
begin
    csm_ui_case_pkg.get_case_network(
        i_oper_id     => i_oper_id
      , o_inst_id     => l_inst_id
      , o_network_id  => l_network_id
    );

    l_result := csm_api_utl_pkg.is_mcom_enabled(
        i_inst_id    => l_inst_id
      , i_network_id => l_network_id
    );

    return l_result;
end;

end;
/

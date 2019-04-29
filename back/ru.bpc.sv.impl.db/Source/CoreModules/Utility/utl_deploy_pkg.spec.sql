create or replace package utl_deploy_pkg as
/**********************************************************
 * Deploy utilites <br/>
 * Created by Filimonov A.(filimonov@bpc.ru)  at 05.08.2010 <br/>
 * Module: UTL_DEPLOY_PKG
 * @headcom
 **********************************************************/

-- Supported types for syncronyzation of sequnces (range examples are provided for maxvalue 9999).
-- For all types below ranges are provided for user/configurable tables only,
-- for all others cases range [1000; 9999] is used.
-- Custom configuration within the Core are used to prevent IDs intersection
-- for core custom functionality and client groups custom functionality.
--
-- Core configuration, range [1000; 4999]
INSTANCE_TYPE_CORE              constant    com_api_type_pkg.t_sign       :=  1;
-- Custom configuration, range [5000; 5999]
INSTANCE_TYPE_CUSTOM1           constant    com_api_type_pkg.t_sign       :=  5;
-- Custom configuration, range [6000; 6999]
INSTANCE_TYPE_CUSTOM2           constant    com_api_type_pkg.t_sign       :=  6;
-- Production configuration, range [7000; 9999]
INSTANCE_TYPE_PRODUCTION        constant    com_api_type_pkg.t_sign       :=  7;
-- Custom configuration within the Core, range [-5999; -5000]
INSTANCE_TYPE_CORE_CUSTOM1      constant    com_api_type_pkg.t_sign       := -5;
-- Custom configuration within the Core, range [-6999; -6000]
INSTANCE_TYPE_CORE_CUSTOM2      constant    com_api_type_pkg.t_sign       := -6;

procedure enable_dbms_output;

procedure disable_dbms_output;


function get_entity_table(
    i_entity_type         in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_oracle_name  result_cache;

function check_column(
    i_table_name          in     com_api_type_pkg.t_oracle_name
  , i_column_name         in     com_api_type_pkg.t_oracle_name := 'SPLIT_HASH'
) return com_api_type_pkg.t_tiny_id      result_cache;

procedure create_audit_triggers;

procedure move_tablespaces;

procedure refresh_mviews;

procedure refresh_mviews(
    i_name                in     com_api_type_pkg.t_oracle_name
);

procedure sync_superuser(
    i_is_active           in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
);

procedure after_deploy(
    i_instance_type       in     com_api_type_pkg.t_tiny_id default INSTANCE_TYPE_PRODUCTION
);

/*
 * Synchronization of sequences in according to passed value of parameter i_instance_type.
 * INSTANCE_TYPE_CORE
 *     for all user tables in UTL_TABLE corresponding sequences are set to maximum
 *     value of ID (primary key field) but not greater than INSTANCE_TYPE_CUSTOM1
 * INSTANCE_TYPE_CUSTOM1 / INSTANCE_TYPE_CUSTOM2
 *     for all user tables in UTL_TABLE corresponding sequences are set to maximum
 *     value of ID from interval [INSTANCE_TYPE_CUSTOM1; INSTANCE_TYPE_PRODUCTION - 1].
 * INSTANCE_TYPE_PRODUCTION
 *     for all user tables in UTL_TABLE corresponding sequences are set to maximum
 *     value of ID without any restrictions
 */
procedure sync_sequences (
    i_instance_type       in     com_api_type_pkg.t_tiny_id default INSTANCE_TYPE_PRODUCTION
  , i_soft                in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_debug_output        in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
);

-- recompile invalid packages after sequences re-creation
procedure recompile_invalid_packages;

-- Convert DB for usage encoded PANs (enable tokenization)
procedure encode_card_numbers;

-- Convert DB for usage real PANs (disable tokenization)
procedure decode_card_numbers;

-- Regenerate com_split_map
procedure generate_com_split_map;

-- Procedure to run all deployment checks
procedure run_all_checks;

/*
 * Procedure based on anonymous block (file com_i18.chck.sql).
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of first 10 records via raise_application_error in com_i18.chck.sql)
 * @i_remove - if value is true then there is a need to delete garbage records from com_i18n
*/
procedure com_i18_chck (
    i_remove              in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
);

/*
 * Procedure based on anonymous block (file adt_entity.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in adt_entity.chck.sql)
*/
procedure adt_entity_chck;

/*
 * Procedure based on anonymous block (file cmn_parameter_value.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in cmn_parameter_value.chck.sql)
*/
procedure cmn_parameter_value_chck;

/*
 * Procedure based on anonymous block (file utl_table.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in utl_table.chck.sql)
*/
procedure utl_table_chck;

/*
 * Procedure based on anonymous block (file app_dependence.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in app_dependence.chck.sql)
*/
procedure app_dependence_chck;

/*
 * Procedure based on anonymous block (file app_structure.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in app_structure.chck.sql)
*/
procedure app_structure_chck;

/*
 * Procedure based on anonymous block (file rul_mod_scale_param.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in rul_mod_scale_param.chck.sql)
*/
procedure rul_mod_scale_param_chck;

/*
 * Procedure based on anonymous block (file rul_proc_param.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in rul_proc_param.chck.sql)
*/
procedure rul_proc_param_chck;

/*
 * Procedure based on anonymous block (file com_label.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in com_label.chck.sql)
*/
procedure com_label_chck;

/*
 * Procedure based on anonymous block (com_lov.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in com_lov.chck.sql)
*/
procedure com_lov_chck;

/*
 * Procedure based on anonymous block (com_parameter_duplicates.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in com_parameter_duplicates.chck.sql)
*/
procedure com_parameter_duplicates_chck;

/*
 * Print the sections from privileges which does not exist.
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in com_lov.chck.sql)
 */
procedure acm_section_chck;

/*
 * Print the deploying scripts with empty body.
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in com_lov.chck.sql)
 */
procedure script_body_chck;

/*
 * Launch deploying scripts for 'before_run' level.
 */
procedure before_run(
    i_applying_type       in     com_api_type_pkg.t_dict_value
);

/*
 * Launch deploying scripts for 'after_run' level.
 */
procedure after_run(
    i_applying_type       in     com_api_type_pkg.t_dict_value
);

end utl_deploy_pkg;
/

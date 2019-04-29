create or replace package prc_ui_group_pkg is
/*************************************************************
 * UI for grouping processes <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 04.10.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                          $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PRC_UI_GROUP_PKG <br />
 * @headcom
 *************************************************************/

/*
 * Create group processes
 * @param o_id         Group process identifier
 * @param i_short_desc  Short group description
 * @param i_full_desc   Full group description
 * @param i_lang        Language code
 * @param i_semaphore_name    Unique semaphore name
 */
procedure add_group (
    o_id                    out com_api_type_pkg.t_tiny_id
    , i_semaphore_name      in com_api_type_pkg.t_semaphore_name
    , i_short_desc          in com_api_type_pkg.t_short_desc
    , i_full_desc           in com_api_type_pkg.t_full_desc
    , i_lang                in com_api_type_pkg.t_dict_value
);

/*
 * Modify group processes
 * @param i_id         Group process identifier
 * @param i_short_desc  Short group description
 * @param i_full_desc   Full group description
 * @param i_lang        Language code
 * @param i_semaphore_name    Unique semaphore name
 */ 
procedure modify_group (
    i_id                    in com_api_type_pkg.t_tiny_id
    , i_semaphore_name      in com_api_type_pkg.t_semaphore_name
    , i_short_desc          in com_api_type_pkg.t_short_desc
    , i_full_desc           in com_api_type_pkg.t_full_desc
    , i_lang                in com_api_type_pkg.t_dict_value
);

/*
 * Remove group
 * @param i_id Group identifier
 */
procedure remove_group (
    i_id                    in com_api_type_pkg.t_tiny_id
);

/*
 * Add process in group
 * @param i_group_id  Group process identifier
 * @param i_process_id   Process identifier
 */
procedure add_group_process (
    o_id                    out com_api_type_pkg.t_short_id
    , i_group_id            in com_api_type_pkg.t_tiny_id
    , i_process_id          in com_api_type_pkg.t_short_id
);

/*
 * Remove process from group
 * @param i_id Record identifier
 */
procedure remove_group_process (
    i_id                    in com_api_type_pkg.t_short_id
);
end;
/

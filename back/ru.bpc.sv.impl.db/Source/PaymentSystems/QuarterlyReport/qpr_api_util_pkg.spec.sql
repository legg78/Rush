create or replace package qpr_api_util_pkg is
/*********************************************************
 *  Issuer reports API <br />
 *  Created by Maslov I  at 06.05.2013 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: qpr_api_util_pkg <br />
 *  @headcom
 **********************************************************/

    procedure clear_values;

    procedure init_rec (
        i_item                    in com_api_type_pkg.t_short_id
    );

    procedure clear_table(
        i_year                    in com_api_type_pkg.t_tiny_id
        , i_start_date            in date
        , i_end_date              in date
        , i_report_type           in com_api_type_pkg.t_tiny_id
        , i_report_name           in com_api_type_pkg.t_name       := null
        , i_inst_id               in com_api_type_pkg.t_inst_id    default NULL
    );
    
    procedure insert_param(
        i_param_name              in com_api_type_pkg.t_name
        , i_group_name            in com_api_type_pkg.t_name
        , i_report_name           in com_api_type_pkg.t_name
        , i_year                  in com_api_type_pkg.t_tiny_id
        , i_month_num             in com_api_type_pkg.t_tiny_id
        , i_cmid                  in com_api_type_pkg.t_rrn
        , i_value_1               in com_api_type_pkg.t_money      default null
        , i_value_2               in com_api_type_pkg.t_money      default null
        , i_value_3               in com_api_type_pkg.t_money      default null
        , i_curr_code             in com_api_type_pkg.t_curr_code  default null
        , i_mcc                   in com_api_type_pkg.t_tiny_id    default null
        , i_card_type             in com_api_type_pkg.t_name       default null
        , i_inst_id               in com_api_type_pkg.t_inst_id    default null
        , i_bin                   in com_api_type_pkg.t_name       default null
        , i_group_parent_name     in com_api_type_pkg.t_name       default null
        , i_card_type_id          in com_api_type_pkg.t_tiny_id    default null
        , i_card_type_feature     in com_api_type_pkg.t_dict_value default null
    );
    
    procedure save_values ;           

end;
/

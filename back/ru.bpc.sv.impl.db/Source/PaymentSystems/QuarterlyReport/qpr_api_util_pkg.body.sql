create or replace package body qpr_api_util_pkg is
/*********************************************************
 *  Issuer reports API <br />
 *  Created by Maslov I  at 06.05.2013 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: qpr_api_util_pkg <br />
 *  @headcom
 **********************************************************/

    g_id                   com_api_type_pkg.t_number_tab;
    g_year                 com_api_type_pkg.t_tiny_tab;
    g_month_num            com_api_type_pkg.t_tiny_tab;
    g_cmid                 com_api_type_pkg.t_cmid_tab;
    g_value_1              com_api_type_pkg.t_money_tab;
    g_value_2              com_api_type_pkg.t_money_tab;
    g_value_3              com_api_type_pkg.t_money_tab;
    g_curr_code            com_api_type_pkg.t_curr_code_tab;
    g_mcc                  com_api_type_pkg.t_mcc_tab;
    g_card_type            com_api_type_pkg.t_name_tab;
    g_inst_id              com_api_type_pkg.t_inst_id_tab;
    g_bin                  com_api_type_pkg.t_name_tab;
    g_param_name           com_api_type_pkg.t_name_tab;
    g_group_name           com_api_type_pkg.t_name_tab;
    g_group_parent_name    com_api_type_pkg.t_name_tab;
    g_report_name          com_api_type_pkg.t_name_tab;
    g_card_type_id         com_api_type_pkg.t_tiny_tab;
    g_card_type_feature    com_api_type_pkg.t_dict_tab;

    procedure clear_values  is
    begin
        g_year.delete;
        g_month_num.delete;
        g_cmid.delete;
        g_value_1.delete;
        g_value_2.delete;
        g_value_3.delete;
        g_curr_code.delete;
        g_mcc.delete;
        g_card_type.delete;
        g_inst_id.delete;
        g_bin.delete;
        g_param_name.delete;
        g_group_name.delete;
        g_group_parent_name.delete;
        g_report_name.delete;
        g_id.delete;
        g_card_type_id.delete;
        g_card_type_feature.delete;
    end;

    procedure init_rec (
        i_item                    in com_api_type_pkg.t_short_id
    ) is
    begin
        g_id(i_item)                  := null;
        g_year(i_item)                := null;
        g_month_num(i_item)           := null;
        g_cmid(i_item)                := null;
        g_value_1(i_item)             := null;
        g_value_2(i_item)             := null;
        g_value_3(i_item)             := null;
        g_curr_code(i_item)           := null;
        g_mcc(i_item)                 := null;
        g_card_type(i_item)           := null;
        g_inst_id(i_item)             := null;
        g_bin(i_item)                 := null;
        g_param_name(i_item)          := null;
        g_group_name(i_item)          := null;
        g_group_parent_name(i_item)   := null;
        g_report_name(i_item)         := null;
        g_card_type_id(i_item)        := null;
        g_card_type_feature(i_item)   := null;
    end;

    procedure clear_table(
        i_year                    in com_api_type_pkg.t_tiny_id
        , i_start_date            in date
        , i_end_date              in date
        , i_report_type           in com_api_type_pkg.t_tiny_id
        , i_report_name           in com_api_type_pkg.t_name       := null
        , i_inst_id               in com_api_type_pkg.t_inst_id    default NULL
    ) is
        l_start_mounth            com_api_type_pkg.t_tiny_id;
        l_end_mounth              com_api_type_pkg.t_tiny_id;
    begin
        l_start_mounth := to_number(to_char(i_start_date, 'mm'));
        l_end_mounth := to_number(to_char(i_end_date, 'mm'));
        
        delete from qpr_param_value
         where year = i_year
           and month_num between l_start_mounth and l_end_mounth
           and (inst_id = i_inst_id or i_inst_id is null)
           and param_group_id in (
                select qgr.id
                  from qpr_param_group qgr
                     , qpr_group grp
                     , qpr_group_report grr
                     , qpr_group qrg2
                 where qgr.group_id = grp.id
                   and grp.id = grr.id
                   and grr.report_type = i_report_type
                   and (grr.report_name = i_report_name or i_report_name is null)
                   and nvl(grp.id_parent, grp.id) = qrg2.id
                );
    end;

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
    ) is
        i                          pls_integer;
    begin
        i := g_id.count + 1;
        init_rec(i);

        g_year(i)                  := i_year;
        g_month_num(i)             := i_month_num;
        g_cmid(i)                  := i_cmid;
        g_value_1(i)               := i_value_1;
        g_value_2(i)               := i_value_2;
        g_value_3(i)               := i_value_3;
        g_curr_code(i)             := i_curr_code;
        g_mcc(i)                   := i_mcc;
        g_card_type(i)             := i_card_type;
        g_inst_id(i)               := i_inst_id;
        g_bin(i)                   := i_bin;
        g_param_name(i)            := i_param_name;
        g_group_name(i)            := i_group_name;
        g_group_parent_name(i)     := i_group_parent_name;
        g_report_name(i)           := i_report_name;
        g_card_type_id(i)          := i_card_type_id;
        g_card_type_feature(i)     := i_card_type_feature;
    end;

    procedure save_values is
        l_rows_affected number := 0;
    begin
        for i in 1 .. g_id.count loop
            if instr(g_param_name(i), '.') > 0 then
                insert into qpr_param_value (
                    id
                    , id_param_value
                    , year
                    , month_num
                    , param_group_id
                    , cmid
                    , value_1
                    , value_2
                    , value_3
                    , curr_code
                    , mcc
                    , card_type
                    , inst_id
                    , bin
                    , card_type_id
                    , card_type_feature
                )
                select
                    qpr_param_values_seq.nextval
                    , qar.id
                    , g_year(i)
                    , g_month_num(i)
                    , qgr.id
                    , g_cmid(i)
                    , g_value_1(i)
                    , g_value_2(i)
                    , g_value_3(i)
                    , g_curr_code(i)
                    , lpad(g_mcc(i), 4, '0')
                    , g_card_type(i)
                    , g_inst_id(i)
                    , g_bin(i)
                    , g_card_type_id(i)
                    , g_card_type_feature(i)
                 from qpr_param_group qgr
                    , qpr_param qar
                    , qpr_group grp
                    , qpr_group_report grr
                where qgr.param_id = qar.id
                  and qgr.group_id = grp.id
                  and grp.id = grr.id
                  and upper(grr.report_name) = upper(g_report_name(i))
                  and qar.id = substr(g_param_name(i), 1, instr(g_param_name(i), '.') - 1)
                  and grp.id = substr(g_group_name(i), 1, instr(g_group_name(i), '.') - 1);
            else
                insert into qpr_param_value (
                    id
                    , id_param_value
                    , year
                    , month_num
                    , param_group_id
                    , cmid
                    , value_1
                    , value_2
                    , value_3
                    , curr_code
                    , mcc
                    , card_type
                    , inst_id
                    , bin
                    , card_type_id
                    , card_type_feature
                )
                select
                    qpr_param_values_seq.nextval
                    , qar.id
                    , g_year(i)
                    , g_month_num(i)
                    , qgr.id
                    , g_cmid(i)
                    , g_value_1(i)
                    , g_value_2(i)
                    , g_value_3(i)
                    , g_curr_code(i)
                    , lpad(g_mcc(i), 4, '0')
                    , g_card_type(i)
                    , g_inst_id(i)
                    , g_bin(i)
                    , g_card_type_id(i)
                    , g_card_type_feature(i)
                 from qpr_param_group qgr
                    , qpr_param qar
                    , qpr_group grp
                    , qpr_group_report grr
                where qgr.param_id = qar.id
                  and qgr.group_id = grp.id
                  and grp.id = grr.id
                  and upper(grr.report_name) = upper(g_report_name(i))
                  and upper(qar.param_name) = upper(g_param_name(i))
                  and grp.id = substr(g_group_name(i), 1, instr(g_group_name(i), '.') - 1);
            end if;
        end loop;
        clear_values;

    end;

end;
/

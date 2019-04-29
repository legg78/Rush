create or replace package body cst_woo_report_pkg as

procedure batch_file_rpt(
    o_xml                  out clob
  , i_report_id         in     com_api_type_pkg.t_dict_value
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
  , i_date_start        in     date                             default null
  , i_date_end          in     date                             default null
)
 is
    l_date_start        date;
    l_date_end          date;
    l_lang              com_api_type_pkg.t_dict_value;
    l_rpt_title         com_api_type_pkg.t_name;

    l_header            xmltype;
    l_detail            xmltype;
    l_result            xmltype;

begin

    l_lang := nvl(i_lang, get_user_lang);

    l_date_start:= nvl(i_date_start, trunc(get_sysdate));

    l_date_end := nvl(i_date_end, trunc(get_sysdate) + 1 - interval '1' second);

    trc_log_pkg.debug (
              i_text        => 'cst_woo_report_pkg.batch_file_rpt [#1][#2][#3][#4]'
            , i_env_param1  => i_report_id
            , i_env_param2  => l_lang
            , i_env_param3  => to_char(l_date_start, 'dd.mm.yyyy hh24:mi:ss')
            , i_env_param4  => to_char(l_date_end, 'dd.mm.yyyy hh24:mi:ss')
    );

    l_rpt_title := 'REPORT FOR FAILED TRANSACTIONS OF BATCH FILE ' || i_report_id;

    -- header
    select xmlelement(
               "header"
             , xmlelement("p_report_title", l_rpt_title)
             , xmlelement("p_date_start", to_char(l_date_start, 'dd/mm/yyyy'))
             , xmlelement("p_date_end", to_char(l_date_end, 'dd/mm/yyyy'))
           )
      into l_header
      from dual;


    begin
    -- details
    select xmlelement(
               "details"
             , xmlagg(
                   xmlelement(
                       "detail"
                     , xmlelement("run_date"    , to_char(to_date(t.file_date, 'yyyymmdd'), 'dd/mm/yyyy'))
                     , xmlelement("cif_no"      , t.cif_num)
                     , xmlelement("branch_code" , t.agent_id)
                     , xmlelement("w_bank_code" , t.wdr_bank_code)
                     , xmlelement("w_acct_num"  , t.wdr_acct_num)
                     , xmlelement("d_bank_code" , t.dep_bank_code)
                     , xmlelement("d_acct_num"  , t.dep_acct_num)
                     , xmlelement("d_currency"  , t.dep_curr_code)
                     , xmlelement("d_amount"    , t.dep_amount)
                     , xmlelement("b_content"   , t.brief_content)
                     , xmlelement("work_type"   , t.work_type)
                     , xmlelement("err_code"    , t.err_code)
                     , xmlelement("sv_account"  , t.sv_account)
                   )
               )
            )
      into l_detail
      from (
            --Query to get data for batch file 65
            select to_char(file_date, 'yyyymmdd') as file_date
                 , cif_num
                 , agent_id
                 , wdr_bank_code
                 , wdr_acct_num
                 , dep_bank_code
                 , dep_acct_num
                 , dep_curr_code
                 , dep_amount
                 , brief_content
                 , work_type
                 , err_code
                 , null as sv_account
              from cst_woo_mapping_f64f65
             where map_status = 1
               and file_date between l_date_start and l_date_end
               and '65' = i_report_id

            union all

            --Query to get data for batch file 68
            select file_date
                 , cif_num
                 , branch_code
                 , wdr_bank_code
                 , wdr_acct_num
                 , dep_bank_code
                 , dep_acct_num
                 , dep_curr_code
                 , dep_amount
                 , brief_content
                 , work_type
                 , err_code
                 , sv_crd_acct
              from cst_woo_import_f68
             where err_code <> '00000000'
               and to_date(file_date, 'yyyymmdd') between l_date_start and l_date_end
               and '68' = i_report_id

            union all

            --Query to get data for batch file 73
            select to_char(file_date, 'yyyymmdd')
                 , cif_num
                 , agent_id
                 , wdr_bank_code
                 , wdr_acct_num
                 , dep_bank_code
                 , dep_acct_num
                 , dep_curr_code
                 , dep_amount
                 , brief_content
                 , work_type
                 , err_code
                 , null as sv_account
              from cst_woo_mapping_f72f73
             where map_status = 1
               and file_date between l_date_start and l_date_end
               and '72' = i_report_id

            union all

            --Query to get data for batch file 136
            select file_date
                 , cif_num
                 , branch_code
                 , wdr_bank_code
                 , wdr_acct_num
                 , dep_bank_code
                 , dep_acct_num
                 , dep_curr_code
                 , dep_amount
                 , brief_content
                 , work_type
                 , err_code
                 , sv_crd_acct
              from cst_woo_import_f136
             where err_code <> '00000000'
               and to_date(file_date, 'yyyymmdd') between l_date_start and l_date_end
               and '136' = i_report_id

            union all

            --Query to get data for batch file 138
            select file_date
                 , cif_num
                 , branch_code
                 , wdr_bank_code
                 , wdr_acct_num
                 , dep_bank_code
                 , dep_acct_num
                 , dep_curr_code
                 , dep_amount
                 , brief_content
                 , work_type
                 , err_code
                 , sv_crd_acct
              from cst_woo_import_f138
             where err_code <> '00000000'
               and rcn_status = 0
               and import_date > get_sysdate - 30
               and to_date(file_date, 'yyyymmdd') between l_date_start and l_date_end
               and '138' = i_report_id
            ) t
    ;

    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'No data for batch file ' || i_report_id
            );
    end;

    select xmlelement(
               "report"
             , l_header
             , l_detail
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text => 'cst_woo_report_pkg.batch_file_rpt -> Finished'
    );

end batch_file_rpt;

end cst_woo_report_pkg;
/

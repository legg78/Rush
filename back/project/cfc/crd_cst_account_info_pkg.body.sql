create or replace package body crd_cst_account_info_pkg as
/************************************************************
* UI specific procedures for a credit service <br />
* Created by Kolodkina Y.(kolodkina@bpcbt.com) at 30.03.2015 <br />
* Last changed by $Author$ <br />
* $LastChangedDate$ <br />
* Module: CRD_CST_ACCOUNT_INFO_PKG <br />
* @headcom
************************************************************/

function get_add_parameters (
    i_account_id  in     com_api_type_pkg.t_account_id
  , i_product_id  in     com_api_type_pkg.t_short_id    default null
  , i_service_id  in     com_api_type_pkg.t_short_id    default null
  , i_split_hash  in     com_api_type_pkg.t_tiny_id     default null
  , i_inst_id     in     com_api_type_pkg.t_inst_id     default null
  , i_param_tab   in     com_api_type_pkg.t_param_tab
) return com_api_type_pkg.t_lob_data
is
    l_text               com_api_type_pkg.t_name;
    l_cur_sql            com_api_type_pkg.t_lob_data   := '';
    l_lang               com_api_type_pkg.t_dict_value := get_user_lang();
    l_bucket             scr_api_type_pkg.t_scr_bucket_rec;
    l_customer_id        com_api_type_pkg.t_medium_id;
begin
    select customer_id
      into l_customer_id
      from acc_account
     where id = i_account_id;

    l_bucket :=
        cst_cfc_com_pkg.get_current_revised_bucket(
            i_customer_id => l_customer_id
          , i_account_id  => i_account_id
        );

    if l_bucket.revised_bucket is not null and l_bucket.expir_date is not null then
        null;
        -- there should be using of function to get current delinquency bucket
    end if;

    if l_bucket.revised_bucket is not null and l_bucket.expir_date is not null then
        l_text := l_bucket.revised_bucket || ' (expires at ' || to_char(l_bucket.expir_date, 'dd/mm/yyyy') || ')';
    end if;

    l_cur_sql := l_cur_sql || 'select ''' || cst_cfc_api_const_pkg.REVISED_BUCKET || ''', '''
              || com_api_label_pkg.get_label_text(cst_cfc_api_const_pkg.REVISED_BUCKET, l_lang) || ''', '''
              || nvl(l_text, 'N/A') || ''' from dual ';


    return l_cur_sql;
end;

end;
/

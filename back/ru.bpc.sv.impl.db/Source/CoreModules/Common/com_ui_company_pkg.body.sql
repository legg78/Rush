create or replace package body com_ui_company_pkg as
/*********************************************************
*  Company <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 09.09.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_UI_COMPANY_PKG <br />
*  @headcom
**********************************************************/

procedure add_company(
    o_id                     out  com_api_type_pkg.t_short_id
  , o_seqnum                 out  com_api_type_pkg.t_short_id
  , i_company_short_name  in      com_api_type_pkg.t_multilang_value_tab
  , i_company_full_name   in      com_api_type_pkg.t_multilang_desc_tab
  , i_embossed_name       in      com_api_type_pkg.t_name
  , i_incorp_form         in      com_api_type_pkg.t_dict_value
) is
begin
    com_api_company_pkg.add_company(
        o_id                 => o_id
      , o_seqnum             => o_seqnum
      , i_company_short_name => i_company_short_name
      , i_company_full_name  => i_company_full_name
      , i_embossed_name      => i_embossed_name
      , i_incorp_form        => i_incorp_form
      , i_inst_id            => ost_api_institution_pkg.get_sandbox
    );
end;

procedure modify_company(
    i_id                  in      com_api_type_pkg.t_short_id
  , io_seqnum             in out  com_api_type_pkg.t_seqnum
  , i_company_short_name  in      com_api_type_pkg.t_multilang_value_tab
  , i_company_full_name   in      com_api_type_pkg.t_multilang_desc_tab
  , i_embossed_name       in      com_api_type_pkg.t_name
  , i_incorp_form         in      com_api_type_pkg.t_dict_value
) is
begin
    com_api_company_pkg.modify_company(
        i_id                 => i_id
      , io_seqnum            => io_seqnum
      , i_company_short_name => i_company_short_name
      , i_company_full_name  => i_company_full_name
      , i_embossed_name      => i_embossed_name
      , i_incorp_form        => i_incorp_form
    );
end modify_company;

procedure remove_company(
    i_id                  in      com_api_type_pkg.t_short_id
  , i_seqnum              in      com_api_type_pkg.t_seqnum
) is
begin
    com_api_company_pkg.remove_company(
        i_id     => i_id
      , i_seqnum => i_seqnum
    );
end remove_company;

function get_company_name(
    i_company_id        in      com_api_type_pkg.t_short_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_name is
    l_result            com_api_type_pkg.t_name;
    l_lang              com_api_type_pkg.t_dict_value;
begin
    if i_company_id is null then
        return null;
    end if;

    l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang);

    l_result := com_api_i18n_pkg.get_text(
                    i_table_name  => 'COM_COMPANY'
                  , i_column_name => 'LABEL'
                  , i_object_id   => i_company_id
                  , i_lang        => l_lang
                );

    return l_result;
    
end get_company_name;

end com_ui_company_pkg;
/

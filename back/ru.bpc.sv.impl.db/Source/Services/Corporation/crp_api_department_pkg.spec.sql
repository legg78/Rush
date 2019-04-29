create or replace package crp_api_department_pkg is
/*********************************************************
*  Corporation - Departments <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 07.10.2011 <br />
*  Last changed by $Author: krukov $ <br />
*  $LastChangedDate: 2010-04-27 17:29:49 +0400#$ <br />
*  Revision: $LastChangedRevision: 11321 $ <br />
*  Module: CRP_API_DEPARTMENT_PKG <br />
*  @headcom
**********************************************************/
    
procedure get_customer_compamy (
    i_customer_id             in     com_api_type_pkg.t_medium_id
  , o_company_id                 out com_api_type_pkg.t_short_id
);
    
procedure add_department (
    o_id                         out com_api_type_pkg.t_short_id
  , i_parent_id               in     com_api_type_pkg.t_short_id
  , i_corp_customer_id        in     com_api_type_pkg.t_medium_id
  , i_corp_contract_id        in     com_api_type_pkg.t_medium_id
  , i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_lang                    in     com_api_type_pkg.t_dict_value
  , i_label                   in     com_api_type_pkg.t_name
);

procedure modify_department (
    i_id                      in     com_api_type_pkg.t_short_id
  , i_parent_id               in     com_api_type_pkg.t_short_id
  , i_corp_customer_id        in     com_api_type_pkg.t_medium_id
  , i_corp_contract_id        in     com_api_type_pkg.t_medium_id
  , i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_lang                    in     com_api_type_pkg.t_dict_value
  , i_label                   in     com_api_type_pkg.t_name
);

procedure remove_department (
    i_id                      in     com_api_type_pkg.t_short_id
  , i_transfer_id             in     com_api_type_pkg.t_short_id
);

end;
/

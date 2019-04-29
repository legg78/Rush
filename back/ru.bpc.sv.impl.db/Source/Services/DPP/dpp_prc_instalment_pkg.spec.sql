create or replace package dpp_prc_instalment_pkg as
/*********************************************************
*  API for DPP instalments process <br />
*  Created by  E. Kryukov(krukov@bpc.ru)  at 07.09.2011 <br />
*  Module: DPP_PRC_INSTALMENT_PKG <br />
*  @headcom
**********************************************************/

procedure process(
    i_inst_id                in     com_api_type_pkg.t_inst_id
  , i_credit_bunch_type_id   in     com_api_type_pkg.t_tiny_id  default dpp_api_const_pkg.BUNCH_TYPE_ID_OVERDRAFT_REGSTR
  , i_over_bunch_type_id     in     com_api_type_pkg.t_tiny_id  default dpp_api_const_pkg.BUNCH_TYPE_ID_OVERLIMIT_REGSTR
  , i_intr_bunch_type_id     in     com_api_type_pkg.t_tiny_id  default dpp_api_const_pkg.BUNCH_TYPE_ID_OVERDRAFT_REGSTR
  , i_lending_bunch_type_id  in     com_api_type_pkg.t_tiny_id  default null
);

end;
/

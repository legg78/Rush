create or replace package aap_api_product_pkg as

/*********************************************************
*  Application API for acquiring <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 14.09.2009 <br />
*  Last changed by $Author: Fomichev $ <br />
*  $LastChangedDate:: 2010-06-07 16:20:00 +0400#$ <br />
*  Revision: $LastChangedRevision: 2432 $ <br />
*  Module: AAP_API_PRODUCT_PKG <br />
*  @headcom
**********************************************************/



-- process product  definition when creating merchant, terminal, etc
procedure process_product(
    i_product_id           in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_inst_id              in            com_api_type_pkg.t_inst_id
);

-- processing changing of product for merchant, terminal, etc
procedure change_product(
    i_old_product_id       in            com_api_type_pkg.t_long_id
  , i_new_product_id       in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_inst_id              in            com_api_type_pkg.t_inst_id
);

end;
/

create or replace package itf_api_naming_pkg as
/**********************************************************
 * ITF for name pool<br/>
 * Created by Gogolev I. (i.gogolev@bpcbt.com) at 21.03.2017<br/>
 * Last changed by $Author: $<br/>
 * $LastChangedDate: 21.03.2017 $<br/>
 * Revision: $LastChangedRevision: $<br/>
 * Module: ITF_API_NAMING_PKG
 * @headcom
 **********************************************************/
 
procedure import_pool_value(
    i_index_range_id   in     com_api_type_pkg.t_short_id
  , i_value            in     com_api_type_pkg.t_large_id
);

procedure import_pool_values(
    i_index_range_id   in     com_api_type_pkg.t_short_id
  , i_values_tab       in     com_api_type_pkg.t_large_tab
);
 
end itf_api_naming_pkg;
/

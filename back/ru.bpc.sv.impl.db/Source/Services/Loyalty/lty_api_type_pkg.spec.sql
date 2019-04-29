create or replace package lty_api_type_pkg as

/*
 * Types for loyalty bonus <br />
 * Created by Kopachev D.(kopachev@bpc.ru)  at 18.11.2009 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2010-06-30 15:04:48 +0400#$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: LTY_API_TYPE_PKG <br />
 * @headcom
 */
 
type t_bonus_rec is record(
    id            com_api_type_pkg.t_long_id
  , amount        com_api_type_pkg.t_money
  , start_date    date
  , expire_date   date
  , fee_type      com_api_type_pkg.t_dict_value
);

type t_bonus_tab is table of t_bonus_rec index by binary_integer;
  
end;
/

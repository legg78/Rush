create or replace package cst_cab_api_statement_pkg as

/************************************************************
* Credit Statement report for Cathay bank <br />
* $LastChangedDate::  01.08.2018#$ <br />
* Module: cst_cab_api_statement_pkg <br />
* @headcom
************************************************************/

procedure export_credit_statements(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date
  , i_card_number           in      com_api_type_pkg.t_card_number      default null
  , i_account_number        in      com_api_type_pkg.t_account_number   default null
);

end;
/

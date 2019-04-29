CREATE OR REPLACE PACKAGE cst_aua_api_report_pkg is
/*********************************************************
 *  Issuer reports API <br />
 *  Created by Sidorik R.(sidorik@bpcbt.com)  at 14.02.2018 <br />
 *  Last changed by $Author: sidorik $ <br />
 *  $LastChangedDate:: 2018-02-14 15:26:00 +0200#$ <br />
 *  Revision: $LastChangedRevision: 00000 $ <br />
 *  Module: cst_aua_api_report_pkg <br />
 *  @headcom
 **********************************************************/

function get_header (
    i_inst_id                      in com_api_type_pkg.t_inst_id
    , i_start_date                 in date
    , i_end_date                   in date
    , i_lang                       in com_api_type_pkg.t_dict_value
    , i_date_format                in com_api_type_pkg.t_name         default 'YYYY-MM-DD'
    , i_acq_bin                    in com_api_type_pkg.t_name         default null
) return xmltype;
----------------------------------------------------------------
procedure mastercard_fpd (
    o_xml                          out clob
    , i_inst_id                    in com_api_type_pkg.t_inst_id default null
    , i_start_date                 in date
    , i_end_date                   in date
    , i_lang                       in com_api_type_pkg.t_dict_value
);
----------------------------------------------------------------
procedure mastercard_spd (
    o_xml                          out clob
    , i_inst_id                    in com_api_type_pkg.t_inst_id default null
    , i_start_date                 in date
    , i_end_date                   in date
    , i_lang                       in com_api_type_pkg.t_dict_value
);
----------------------------------------------------------------
procedure dcc_transaction_daily (
    o_xml                          out clob
    , i_inst_id                    in com_api_type_pkg.t_inst_id default null
    , i_sttl_date                  in date
    , i_lang                       in com_api_type_pkg.t_dict_value
);
----------------------------------------------------------------
procedure dcc_transaction_month (
    o_xml                          out clob
    , i_inst_id                    in com_api_type_pkg.t_inst_id default null
    , i_start_date                 in date
    , i_end_date                   in date
    , i_lang                       in com_api_type_pkg.t_dict_value
);
----------------------------------------------------------------
procedure visa_atm_transaction_extended (
    o_xml                          out clob
    , i_inst_id                    in com_api_type_pkg.t_inst_id default null
    , i_start_date                 in date
    , i_end_date                   in date
    , i_lang                       in com_api_type_pkg.t_dict_value
);
----------------------------------------------------------------
procedure visa_atm_transaction (
    o_xml                          out clob
    , i_inst_id                    in com_api_type_pkg.t_inst_id default null
    , i_start_date                 in date
    , i_end_date                   in date
    , i_lang                       in com_api_type_pkg.t_dict_value
);
----------------------------------------------------------------

end cst_aua_api_report_pkg;
/

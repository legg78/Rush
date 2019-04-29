CREATE OR REPLACE PACKAGE cst_aua_acq_report_pkg is
/*********************************************************
 *  Issuer reports API <br />
 *  Created by Sidorik R.(sidorik@bpcbt.com)  at 14.02.2018 <br />
 *  Last changed by $Author: sidorik $ <br />
 *  $LastChangedDate:: 2018-02-14 15:26:00 +0200#$ <br />
 *  Revision: $LastChangedRevision: 00000 $ <br />
 *  Module: cst_aua_acq_report_pkg <br />
 *  @headcom
 **********************************************************/

function get_header (
    i_inst_id                      in com_api_type_pkg.t_inst_id
    , i_start_date                 in date
    , i_end_date                   in date
    , i_lang                       in com_api_type_pkg.t_dict_value
    , i_date_format                in com_api_type_pkg.t_name         default 'dd.mm.yyyy'
    , i_sysdate_format             in com_api_type_pkg.t_name         default 'dd.mm.yyyy hh24:mi:ss'
) return xmltype;
----------------------------------------------------------------
procedure acq_transaction (
    o_xml                          out clob
    , i_inst_id                    in com_api_type_pkg.t_inst_id
    , i_start_date                 in date                                default null
    , i_end_date                   in date                                default null
    , i_tran_curr                  in com_api_type_pkg.t_curr_code        default null
    , i_merchant_number            in com_api_type_pkg.t_merchant_number  default null
    , i_terminal_number            in com_api_type_pkg.t_terminal_number  default null
    , i_terminal_type              in com_api_type_pkg.t_dict_value       default null
    , i_lang                       in com_api_type_pkg.t_dict_value       default null
);
----------------------------------------------------------------
procedure atm_report (
    o_xml                          out clob
    , i_inst_id                    in com_api_type_pkg.t_inst_id default null
    , i_start_date                 in date
    , i_end_date                   in date
    , i_lang                       in com_api_type_pkg.t_dict_value
);
----------------------------------------------------------------

end cst_aua_acq_report_pkg;
/

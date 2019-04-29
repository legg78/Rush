create or replace package mcw_api_migs_pkg is
/**********************************************************
 * API for MasterCard Internet Gateway System <br />
 * This gateway supported not only cards of the MasterCard IPS <br />
 * but cards of others IPS such as Visa, JCB, Amex, etc <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 13.12.2016 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: MCW_API_MIGS_PKG
 * @headcom
 **********************************************************/
g_dcf_fin_messages         mcw_api_migs_type_pkg.t_fin_message_compleat_tab;

procedure parse_dcf_record_exec(
    i_record_number        in com_api_type_pkg.t_short_id
  , i_record_type          in mcw_api_migs_type_pkg.t_dcf_record_type
  , i_record_str           in com_api_type_pkg.t_exponent
  , i_incom_sess_file_id   in com_api_type_pkg.t_long_id
);

procedure parse_dcf_6200_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6220_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6221_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6222_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6223_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6224_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6225_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6226_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6227_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6228_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6282_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6229_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6230_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6231_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6232_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6233_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6234_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6235_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6236_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6237_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6238_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6239_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure parse_dcf_6240_record(
    i_record_str           in com_api_type_pkg.t_exponent
);

procedure extend_fin_message;

procedure extend_fin_detail;

function get_record_type(
    i_record_str           in com_api_type_pkg.t_exponent
) return mcw_api_migs_type_pkg.t_dcf_record_type;

procedure check_duplication_operation(
    i_operate          in opr_api_type_pkg.t_oper_rec
);

procedure fin_message_operate_mapping(
    i_header_index     in mcw_api_migs_type_pkg.t_index
  , i_detail_index     in mcw_api_migs_type_pkg.t_index
  , o_operate         out opr_api_type_pkg.t_oper_rec
  , o_iss_part        out opr_api_type_pkg.t_oper_part_rec
  , o_acq_part        out opr_api_type_pkg.t_oper_part_rec
  , o_auth_data       out aut_api_type_pkg.t_auth_rec
);

procedure internal_matching(
    i_operation_id     in com_api_type_pkg.t_long_id
);

end mcw_api_migs_pkg;
/

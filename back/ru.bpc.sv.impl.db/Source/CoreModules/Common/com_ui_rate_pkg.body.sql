create or replace package body com_ui_rate_pkg is
/************************************************************
 * UI for rates <br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 23.04.2010  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: COM_UI_RATE_PKG <br />
 * @headcom
 ************************************************************/
procedure set_rate (
    o_id               out  com_api_type_pkg.t_short_id
  , o_seqnum           out  com_api_type_pkg.t_tiny_id
  , o_count            out  number               
  , i_src_currency  in      com_api_type_pkg.t_curr_code
  , i_dst_currency  in      com_api_type_pkg.t_curr_code
  , i_rate_type     in      com_api_type_pkg.t_dict_value
  , i_inst_id       in      com_api_type_pkg.t_inst_id
  , i_eff_date      in      date
  , i_rate          in      number
  , i_inverted      in      com_api_type_pkg.t_boolean
  , i_src_scale     in      number
  , i_dst_scale     in      number
  , i_exp_date      in      date
) is
begin
    com_api_rate_pkg.set_rate (
        o_id            => o_id
      , o_seqnum        => o_seqnum
      , o_count         => o_count
      , i_src_currency  => i_src_currency
      , i_dst_currency  => i_dst_currency
      , i_rate_type     => i_rate_type
      , i_inst_id       => i_inst_id
      , i_eff_date      => i_eff_date
      , i_rate          => i_rate
      , i_inverted      => i_inverted
      , i_src_scale     => i_src_scale
      , i_dst_scale     => i_dst_scale
      , i_exp_date      => i_exp_date
    );
end;

function check_rate (
    i_src_currency  in     com_api_type_pkg.t_curr_code
  , i_dst_currency  in     com_api_type_pkg.t_curr_code
  , i_rate_type     in     com_api_type_pkg.t_dict_value
  , i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_eff_date      in     date
  , i_rate          in     number
  , i_inverted      in     com_api_type_pkg.t_boolean
  , i_src_scale     in     number
  , i_dst_scale     in     number
  , o_message          out com_api_type_pkg.t_text
) return com_api_type_pkg.t_boolean is
begin
    return com_api_rate_pkg.check_rate (
        i_src_currency  => i_src_currency
      , i_dst_currency  => i_dst_currency
      , i_rate_type     => i_rate_type
      , i_inst_id       => i_inst_id
      , i_eff_date      => i_eff_date
      , i_rate          => i_rate
      , i_inverted      => i_inverted
      , i_src_scale     => i_src_scale
      , i_dst_scale     => i_dst_scale
      , o_message       => o_message
    );
end;

procedure invalidate_rate (
    i_id       in      com_api_type_pkg.t_short_id
  , io_seqnum  in out  com_api_type_pkg.t_tiny_id
) is
begin
    update com_rate_vw
       set status = com_api_rate_pkg.RATE_STATUS_INVALID
         , seqnum = io_seqnum
     where id     = i_id;

    io_seqnum := io_seqnum + 1;
end; 


end;
/

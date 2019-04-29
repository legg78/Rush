create or replace package mup_api_dispute_pkg is
/********************************************************* 
 *  MasterCard dispute API  <br /> 
 *  Created by Kopachev (kopachev@bpcbt.com)  at 11.04.2013 <br /> 
 *  Last changed by $Author: truschelev $ <br /> 
 *  $LastChangedDate:: 2015-10-20 18:05:00 +0300#$ <br /> 
 *  Revision: $LastChangedRevision: 59935 $ <br /> 
 *  Module: mup_api_dispute_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

    e_need_original_record exception;

    procedure gen_member_fee (
        o_fin_id                  out com_api_type_pkg.t_long_id
        , i_network_id            in com_api_type_pkg.t_tiny_id
        , i_de004                 in mup_api_type_pkg.t_de004
        , i_de049                 in mup_api_type_pkg.t_de049
        , i_de025                 in mup_api_type_pkg.t_de025
        , i_de003                 in mup_api_type_pkg.t_de003
        , i_de072                 in mup_api_type_pkg.t_de072
        , i_de073                 in mup_api_type_pkg.t_de073
        , i_de093                 in mup_api_type_pkg.t_de093
        , i_de094                 in mup_api_type_pkg.t_de094
        , i_de002                 in mup_api_type_pkg.t_de002
        , i_original_fin_id       in com_api_type_pkg.t_long_id := null
    );

    procedure gen_retrieval_fee (
        o_fin_id                  out com_api_type_pkg.t_long_id
        , i_original_fin_id       in com_api_type_pkg.t_long_id
        , i_de004                 in mup_api_type_pkg.t_de004 := null
        , i_de030_1               in mup_api_type_pkg.t_de030s := null
        , i_de049                 in mup_api_type_pkg.t_de049 := null
        , i_de072                 in mup_api_type_pkg.t_de072 := null
        , i_p0149_1               in mup_api_type_pkg.t_p0149_1 := null
        , i_p0149_2               in mup_api_type_pkg.t_p0149_2 := null
    );

    procedure gen_retrieval_request (
        o_fin_id                  out com_api_type_pkg.t_long_id
        , i_original_fin_id       in com_api_type_pkg.t_long_id
        , i_de025                 in mup_api_type_pkg.t_de025
        , i_p0228                 in mup_api_type_pkg.t_p0228
    );

    procedure update_dispute_id (
        i_id                      in com_api_type_pkg.t_long_id
        , i_dispute_id            in com_api_type_pkg.t_long_id
    );

    procedure fetch_dispute_id (
        i_fin_cur                 in sys_refcursor
        , o_fin_rec               out mup_api_type_pkg.t_fin_rec
    );

    procedure sync_dispute_id (
        io_fin_rec                in out nocopy mup_api_type_pkg.t_fin_rec
        , o_dispute_id            out com_api_type_pkg.t_long_id
        , o_dispute_rn            out com_api_type_pkg.t_long_id
    );

    procedure assign_dispute_id (
        io_fin_rec                in out nocopy mup_api_type_pkg.t_fin_rec
        , o_auth                  out aut_api_type_pkg.t_auth_rec
        , i_need_repeat           in  com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE
    );

    procedure assign_dispute_id (
        io_fin_rec                in out nocopy mup_api_type_pkg.t_fin_rec
    );

    procedure gen_chargeback_fee (
        i_original_fin_id         in com_api_type_pkg.t_long_id
        , i_de004                 in mup_api_type_pkg.t_de004
        , i_de049                 in mup_api_type_pkg.t_de049
        , i_de072                 in mup_api_type_pkg.t_de072
        , o_fin_id                out com_api_type_pkg.t_long_id
    );

    procedure gen_second_presentment_fee (
        i_original_fin_id         in com_api_type_pkg.t_long_id
        , i_de004                 in mup_api_type_pkg.t_de004
        , i_de049                 in mup_api_type_pkg.t_de049
        , i_de072                 in mup_api_type_pkg.t_de072
        , o_fin_id                out com_api_type_pkg.t_long_id
    );

    procedure gen_fee_return (
        i_original_fin_id         in com_api_type_pkg.t_long_id
        , i_de004                 in mup_api_type_pkg.t_de004
        , i_de049                 in mup_api_type_pkg.t_de049
        , i_de025                 in mup_api_type_pkg.t_de025
        , i_de072                 in mup_api_type_pkg.t_de072
        , i_de073                 in mup_api_type_pkg.t_de073
        , o_fin_id                out com_api_type_pkg.t_long_id
    );

    procedure gen_fee_resubmition (
        i_original_fin_id         in com_api_type_pkg.t_long_id
        , i_de004                 in mup_api_type_pkg.t_de004
        , i_de049                 in mup_api_type_pkg.t_de049
        , i_de025                 in mup_api_type_pkg.t_de025
        , i_de072                 in mup_api_type_pkg.t_de072
        , i_de073                 in mup_api_type_pkg.t_de073
        , o_fin_id                out com_api_type_pkg.t_long_id
    );

    procedure gen_fee_second_return (
        i_original_fin_id         in com_api_type_pkg.t_long_id
        , i_de004                 in mup_api_type_pkg.t_de004
        , i_de049                 in mup_api_type_pkg.t_de049
        , i_de025                 in mup_api_type_pkg.t_de025
        , i_de072                 in mup_api_type_pkg.t_de072
        , i_de073                 in mup_api_type_pkg.t_de073
        , o_fin_id                out com_api_type_pkg.t_long_id
    );

    procedure load_auth (
        i_id                    in com_api_type_pkg.t_long_id
        , io_auth               in out nocopy aut_api_type_pkg.t_auth_rec
    );

end;
/

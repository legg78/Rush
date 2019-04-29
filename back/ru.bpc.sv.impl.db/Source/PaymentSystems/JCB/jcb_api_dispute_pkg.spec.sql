create or replace package jcb_api_dispute_pkg is
/********************************************************* 
 *  JCB dispute API  <br /> 
 *  Created by Kopachev (kopachev@bpcbt.com)  at 11.04.2013 <br /> 
 *  Last changed by $Author: truschelev $ <br /> 
 *  $LastChangedDate:: 2015-10-20 18:05:00 +0300#$ <br /> 
 *  Revision: $LastChangedRevision: 59935 $ <br /> 
 *  Module: jcb_api_dispute_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

    e_need_original_record exception;

    procedure update_dispute_id (
        i_id                      in com_api_type_pkg.t_long_id
        , i_dispute_id            in com_api_type_pkg.t_long_id
    );

    procedure fetch_dispute_id (
        i_fin_cur                 in sys_refcursor
        , o_fin_rec               out jcb_api_type_pkg.t_fin_rec
    );

    procedure sync_dispute_id (
        io_fin_rec                in out nocopy jcb_api_type_pkg.t_fin_rec
        , o_dispute_id            out com_api_type_pkg.t_long_id
        , o_dispute_rn            out com_api_type_pkg.t_long_id
    );

    procedure assign_dispute_id (
        io_fin_rec                in out nocopy jcb_api_type_pkg.t_fin_rec
        , o_auth                  out aut_api_type_pkg.t_auth_rec
        , i_need_repeat           in  com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE
    );

    procedure assign_dispute_id (
        io_fin_rec                in out nocopy jcb_api_type_pkg.t_fin_rec
    );

    procedure load_auth (
        i_id                    in com_api_type_pkg.t_long_id
        , io_auth               in out nocopy aut_api_type_pkg.t_auth_rec
    );

end;
/

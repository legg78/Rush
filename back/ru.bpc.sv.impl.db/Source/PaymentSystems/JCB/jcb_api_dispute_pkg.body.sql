create or replace package body jcb_api_dispute_pkg is
/********************************************************* 
 *  JCB dispute API  <br /> 
 *  Created by Kopachev (kopachev@bpcbt.com)  at 11.04.2013 <br /> 
 *  Last changed by $Author: truschelev $ <br /> 
 *  $LastChangedDate:: 2015-10-20 18:02:00 +0300#$ <br /> 
 *  Revision: $LastChangedRevision: 59935 $ <br /> 
 *  Module: jcb_api_dispute_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

    procedure update_dispute_id (
        i_id                      in com_api_type_pkg.t_long_id
        , i_dispute_id            in com_api_type_pkg.t_long_id
    ) is
    begin
        update
            jcb_fin_message
        set
            dispute_id = i_dispute_id
        where
            id = i_id;
            
        update 
            opr_operation     
        set
            dispute_id = i_dispute_id
        where
            id = i_id;            
    end;

    procedure fetch_dispute_id (
        i_fin_cur                 in sys_refcursor
        , o_fin_rec               out jcb_api_type_pkg.t_fin_rec
    ) is
        l_fin_tab               jcb_api_type_pkg.t_fin_tab;
    begin
        savepoint fetch_dispute_id;

        if i_fin_cur%isopen then
            fetch i_fin_cur bulk collect into l_fin_tab;

            for i in 1..l_fin_tab.count loop
                if i = 1 then
                    if l_fin_tab(i).dispute_id is null then
                        l_fin_tab(i).dispute_id := dsp_api_shared_data_pkg.get_id;
                        update_dispute_id (
                            i_id            => l_fin_tab(i).id
                            , i_dispute_id  => l_fin_tab(i).dispute_id
                        );
                    end if;

                    o_fin_rec := l_fin_tab(i);
                else
                    if l_fin_tab(i).dispute_id is null then
                        update_dispute_id (
                            i_id            => l_fin_tab(i).id
                            , i_dispute_id  => o_fin_rec.dispute_id
                        );

                    elsif l_fin_tab(i).dispute_id != o_fin_rec.dispute_id then
                        trc_log_pkg.debug (
                            i_text => 'TOO_MANY_DISPUTES_FOUND'
                        );
                        o_fin_rec := null;
                        rollback to savepoint fetch_dispute_id;
                        return;

                    end if;

                end if;
            end loop;

            if l_fin_tab.count = 0 then
                trc_log_pkg.debug (
                    i_text  => 'NO_DISPUTE_FOUND'
                );
                o_fin_rec := null;
                rollback to savepoint fetch_dispute_id;
            end if;
        end if;
    exception
        when others then
            rollback to savepoint fetch_dispute_id;
            raise;
    end;

    procedure sync_dispute_id (
        io_fin_rec                in out nocopy jcb_api_type_pkg.t_fin_rec
        , o_dispute_id            out com_api_type_pkg.t_long_id
        , o_dispute_rn            out com_api_type_pkg.t_long_id
    ) is
    begin
        if io_fin_rec.dispute_id is null then
            io_fin_rec.dispute_id := dsp_api_shared_data_pkg.get_id;

            update_dispute_id (
                i_id            => io_fin_rec.id
                , i_dispute_id  => io_fin_rec.dispute_id
            );
        end if;

        o_dispute_id := io_fin_rec.dispute_id;
        o_dispute_rn := io_fin_rec.id;
    end;

    procedure load_auth (
        i_id                    in com_api_type_pkg.t_long_id
        , io_auth               in out nocopy aut_api_type_pkg.t_auth_rec
    ) is
    begin
        select
            min(o.id) id
            , min(o.sttl_type) sttl_type
            , min(o.match_status) match_status
            , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.inst_id, null)) iss_inst_id
            , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.network_id, null)) iss_network_id
            , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.inst_id, null)) acq_inst_id
            , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.network_id, null)) acq_network_id
        into
            io_auth.id
            , io_auth.sttl_type
            , io_auth.match_status
            , io_auth.iss_inst_id
            , io_auth.iss_network_id
            , io_auth.acq_inst_id
            , io_auth.acq_network_id
        from
            opr_operation o
            , opr_participant p
            , opr_card c
        where
            o.id = i_id
            and p.oper_id = o.id
            and p.oper_id = c.oper_id(+)
            and p.participant_type = c.participant_type(+);
    end;

    procedure assign_dispute_id (
        io_fin_rec                in out nocopy jcb_api_type_pkg.t_fin_rec
        , o_auth                  out aut_api_type_pkg.t_auth_rec
        , i_need_repeat           in  com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE
    ) is
        l_original_fin_rec        jcb_api_type_pkg.t_fin_rec;
        l_need_original_rec       com_api_type_pkg.t_boolean;
    begin
        trc_log_pkg.debug (
            i_text          => 'assign_dispute_id start'
        );

        io_fin_rec.dispute_id := null;
        l_need_original_rec   := com_api_type_pkg.TRUE;

        if io_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_PRESENTMENT
           and io_fin_rec.de024 = jcb_api_const_pkg.FUNC_CODE_FIRST_PRES
           and io_fin_rec.is_reversal = com_api_type_pkg.FALSE
        then
            jcb_api_fin_pkg.get_original_fin (
                i_mti        => jcb_api_const_pkg.MSG_TYPE_PRESENTMENT
                , i_de002    => io_fin_rec.de002
                , i_de024    => jcb_api_const_pkg.FUNC_CODE_FIRST_PRES
                , i_de031    => io_fin_rec.de031
                , i_id       => io_fin_rec.id
                , o_fin_rec  => l_original_fin_rec
            );
            
            if l_original_fin_rec.id is not null then
                io_fin_rec.dispute_id := l_original_fin_rec.dispute_id;
            end if;
            l_need_original_rec := com_api_type_pkg.FALSE;

        elsif(
                io_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_PRESENTMENT
                and io_fin_rec.de024 = jcb_api_const_pkg.FUNC_CODE_FIRST_PRES
                and io_fin_rec.is_reversal = com_api_type_pkg.TRUE
            ) or
            (
                io_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_PRESENTMENT
                and io_fin_rec.de024 != jcb_api_const_pkg.FUNC_CODE_FIRST_PRES
            ) or
            (
                io_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_CHARGEBACK
            ) or
            (
                io_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                and io_fin_rec.de024 = jcb_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
            ) 
        then
            jcb_api_fin_pkg.get_original_fin (
                i_mti        => jcb_api_const_pkg.MSG_TYPE_PRESENTMENT
                , i_de002    => io_fin_rec.de002
                , i_de024    => jcb_api_const_pkg.FUNC_CODE_FIRST_PRES
                , i_de031    => io_fin_rec.de031
                , o_fin_rec  => l_original_fin_rec
            );
            if l_original_fin_rec.id is not null then
                io_fin_rec.dispute_id := l_original_fin_rec.dispute_id;
                io_fin_rec.inst_id    := l_original_fin_rec.inst_id;
                io_fin_rec.network_id := l_original_fin_rec.network_id;
                
                load_auth (
                    i_id       => l_original_fin_rec.id
                    , io_auth  => o_auth
                );
            end if;

        elsif
            io_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_FEE
            and io_fin_rec.de024 = jcb_api_const_pkg.FUNC_CODE_FEE_COLLECTION
        then
            jcb_api_fin_pkg.get_original_fee (
                i_mti        => io_fin_rec.mti
                , i_de002    => io_fin_rec.de002
                , i_de024    => jcb_api_const_pkg.FUNC_CODE_FIRST_PRES--io_fin_rec.de024
                , i_de031    => io_fin_rec.de031
                , i_de094    => io_fin_rec.de093
                , i_p3201    => io_fin_rec.p3201
                , o_fin_rec  => l_original_fin_rec
            );
            
            if l_original_fin_rec.id is not null then
                io_fin_rec.dispute_id := l_original_fin_rec.dispute_id;
                io_fin_rec.inst_id    := l_original_fin_rec.inst_id;
                io_fin_rec.network_id := l_original_fin_rec.network_id;
                
                load_auth (
                    i_id       => l_original_fin_rec.id
                    , io_auth  => o_auth
                );
            end if;

        else
            trc_log_pkg.debug (
                i_text          => 'No neccesseriry to assign dispute_id. [#1]'
                , i_env_param1  => io_fin_rec.id
            );
            l_need_original_rec := com_api_type_pkg.FALSE;

        end if;

        trc_log_pkg.debug (
            i_text          => 'io_fin_rec.dispute_id = ' || io_fin_rec.dispute_id || ', l_need_original_rec=' || l_need_original_rec || ', i_need_repeat='|| i_need_repeat
        );

        if io_fin_rec.dispute_id is not null then
            trc_log_pkg.debug (
                i_text          => 'Dispute id assigned [#1][#2]'
                , i_env_param1  => io_fin_rec.id
                , i_env_param2  => io_fin_rec.dispute_id
            );

        elsif io_fin_rec.dispute_id is null
              and l_need_original_rec = com_api_type_pkg.TRUE
              and i_need_repeat       = com_api_type_pkg.TRUE
        then
            trc_log_pkg.debug (
                i_text          => 'Need repeat for dispute id'
            );
            raise e_need_original_record;

        elsif io_fin_rec.dispute_id is null
              and l_need_original_rec = com_api_type_pkg.FALSE
        then      
            trc_log_pkg.debug (
                i_text          => 'No dispute needed'
            );
            
        else
            io_fin_rec.status := jcb_api_const_pkg.MSG_STATUS_INVALID;

            trc_log_pkg.debug (
                i_text          => 'The dispute is need, but not found. Set message status = invalid'
            );
        end if;
    exception
        when others then
            raise;
    end;

    procedure assign_dispute_id (
        io_fin_rec                in out nocopy jcb_api_type_pkg.t_fin_rec
    ) is
        l_auth                    aut_api_type_pkg.t_auth_rec;
    begin
        assign_dispute_id (
            io_fin_rec  => io_fin_rec
            , o_auth    => l_auth
        );
    end;


end;
/

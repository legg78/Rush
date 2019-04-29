create or replace package body acq_api_mcc_selection_pkg as
/*********************************************************
 *  API for MCC selection <br />
 *  Created by Krukov E.(krukov@bpcbt.com)  at 13.12.2011 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: ACQ_API_MCC_SELECTION_PKG  <br />
 *  @headcom
 **********************************************************/

function get_mcc (
    i_oper_type                 in com_api_type_pkg.t_dict_value
    , i_mcc_template_id         in com_api_type_pkg.t_medium_id
    , i_purpose_id              in com_api_type_pkg.t_short_id
    , i_oper_reason             in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_mcc is
    cursor l_mcc is
        select
            m.mcc
            , m.oper_type
            , m.mcc_template_id
            , m.purpose_id
            , m.oper_reason
        from
            acq_mcc_selection_vw m
        where
            nvl(i_oper_type, '%') like m.oper_type
            and nvl(i_mcc_template_id, 0) = nvl(m.mcc_template_id, 0)
            and nvl(i_purpose_id, 0) = nvl(m.purpose_id, 0)
            and nvl(i_oper_reason, '%') like m.oper_reason
        order by
            m.priority;

begin
    for rec_mcc in l_mcc loop
        return rec_mcc.mcc;
    end loop;
    
    return null;
exception
    when others then
        if l_mcc%isopen then
            close l_mcc;
        end if;
        raise;
end;

end;
/

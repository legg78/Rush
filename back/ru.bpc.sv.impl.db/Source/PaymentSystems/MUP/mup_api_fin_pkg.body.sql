create or replace package body mup_api_fin_pkg is
/*********************************************************
 *  API for MasterCard finance message  <br />
 *  Created by Khougaev (khougaev@bpcbt.com)  at 05.11.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: mup_api_fin_pkg <br />
 *  @headcom
 **********************************************************/

g_no_original_id_tab    mup_api_type_pkg.t_fin_tab;

FIN_COLUMN_LIST         constant com_api_type_pkg.t_text :=

  'f.rowid'||
', f.id'||     
', f.inst_id'||
', f.network_id'||
', f.file_id'||
', f.status'||
', f.impact'||
', f.is_incoming'||
', f.is_reversal'||
', f.is_rejected'||
', f.is_fpd_matched'||
', f.is_fsum_matched'||
', f.dispute_id'||
', f.dispute_rn'||
', f.fpd_id'||
', f.fsum_id'||
', f.mti'||
', iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as de002'||
', f.de003_1'||
', f.de003_2'||
', f.de003_3'||
', f.de004'||
', f.de005'||
', f.de006'||
', f.de009'||
', f.de010'||
', f.de012'||
', f.de014'||
', f.de022_1'||
', f.de022_2'||
', f.de022_3'||
', f.de022_4'||
', f.de022_5'||
', f.de022_6'||
', f.de022_7'||
', f.de022_8'||
', f.de022_9'||
', f.de022_10'||
', f.de022_11'||
', f.de023'||
', f.de024'||
', f.de025'||
', f.de026'||
', f.de030_1'||
', f.de030_2'||
', f.de031'||
', f.de032'||
', f.de033'||
', f.de037'||
', f.de038'||
', f.de040'||
', f.de041'||
', f.de042'||
', f.de043_1'||
', f.de043_2'||
', f.de043_3'||
', f.de043_4'||
', f.de043_5'||
', f.de043_6'||
', f.de049'||
', f.de050'||
', f.de051'||
', f.de054'||
', f.de055'||
', f.de063'||
', f.de071'||
', f.de072'||
', f.de073'||
', f.de093'||
', f.de094'||
', f.de095'||
', f.de100'||
', f.p0025_1'||
', f.p0025_2'||
', null p0105'||
', f.p0137'||
', f.p0146'||
', f.p0146_net'||
', f.p0148'||
', f.p0149_1'||
', f.p0149_2'||
', f.p0165'||
', f.p0176'||
', f.p0190'||
', f.p0198'||
', f.p0228'||
', f.p0261'||
', f.p0262'||
', f.p0265'||
', f.p0266'||
', f.p0267'||
', f.p0268_1'||
', f.p0268_2'||
', f.p0375'||
', f.p2002'||
', f.p2063'||
', f.p2072_1'||
', f.p2072_2'||
', f.p2158_1'||
', f.p2158_2'||
', f.p2158_3'||
', f.p2158_4'||
', f.p2158_5'||
', f.p2158_6'||
', f.p2159_1'||
', f.p2159_2'||
', f.p2159_3'||
', f.p2159_4'||
', f.p2159_5'||
', f.p2159_6'||
', f.p2175_1'||
', f.p2175_2'||
', f.p2097_1'||
', f.p2097_2'||
', f.emv_9f26'||
', f.emv_9f27'||
', f.emv_9f10'||
', f.emv_9f37'||
', f.emv_9f36'||
', f.emv_95'||
', f.emv_9a'||
', f.emv_9c'||
', f.emv_9f02'||
', f.emv_5f2a'||
', f.emv_82'||
', f.emv_9f1a'||
', f.emv_9f03'||
', f.emv_9f34'||
', f.emv_9f33'||
', f.emv_9f35'||
', f.emv_9f1e'||
', f.emv_9f53'||
', f.emv_84'||
', f.emv_9f09'||
', f.emv_9f41'||
', f.emv_9f4c'||
', f.emv_91'||
', f.emv_8a'||
', f.emv_71'||
', f.emv_72'||
', f.is_collection'||
', null activity_type'||
', null orig_transfer_agent_id'||
', f.p2001_1'||
', f.p2001_2'||
', f.p2001_3'||
', f.p2001_4'||
', f.p2001_5'||
', f.p2001_6'||
', f.p2001_7'
;

function get_card_replenishment_arn(
    i_acquirer_bin  in     com_api_type_pkg.t_bin
  , i_oper_date     in     date
  , i_de037         in     mup_api_type_pkg.t_de037
) return varchar2 is
    l_result varchar2(23);
begin
    l_result := 
        substr(to_char(i_oper_date, 'MMDDhh24miss'), 5, 1)
     || substr(i_acquirer_bin, 1, 6)
     || substr(i_de037, 1, 4)
     || substr(to_char(i_oper_date, 'MMDDhh24miss'), 6, 3)
     || substr(i_de037, 5, 8)
     ;

  return l_result || com_api_checksum_pkg.get_luhn_checksum(l_result);
end;

procedure get_processing_date (
    i_id                  in com_api_type_pkg.t_long_id
  , i_is_fpd_matched      in com_api_type_pkg.t_boolean
  , i_is_fsum_matched     in com_api_type_pkg.t_boolean
  , i_file_id             in com_api_type_pkg.t_short_id
  , o_p0025_2            out mup_api_type_pkg.t_p0025_2
) is
begin
    if i_is_fpd_matched = com_api_type_pkg.TRUE then

        select mup_api_file_pkg.extract_file_date (
                   i_p0105  => f.p0105
               )
          into o_p0025_2
          from mup_fin m
             , mup_fpd d
             , mup_file f
         where m.id = i_id
           and d.id = m.fpd_id
           and d.file_id = f.id;

   elsif i_is_fsum_matched = com_api_type_pkg.TRUE then

        select mup_api_file_pkg.extract_file_date (
                   i_p0105  => f.p0105
               )
          into o_p0025_2
          from mup_fin m
             , mup_fsum s
             , mup_file f
         where m.id = i_id
           and s.id = m.fsum_id
           and s.file_id = f.id;

    elsif i_file_id is not null then

        select mup_api_file_pkg.extract_file_date (
                   i_p0105  => f.p0105
               )
          into o_p0025_2
          from mup_file f
         where f.id = i_file_id;

    else
        o_p0025_2 := get_sysdate;
    end if;
exception
    when no_data_found then
        o_p0025_2 := get_sysdate;
end get_processing_date;

function estimate_messages_for_upload (
    i_network_id            in com_api_type_pkg.t_tiny_id
  , i_cmid                  in mup_api_type_pkg.t_de033
  , i_inst_code             in com_api_type_pkg.t_dict_value := null
  , i_start_date            in date                          := null
  , i_end_date              in date                          := null
  , i_include_affiliate     in com_api_type_pkg.t_boolean    := com_api_const_pkg.FALSE
  , i_inst_id               in com_api_type_pkg.t_inst_id    := null
  , i_collection_only       in com_api_type_pkg.t_boolean    := null
) return number is
    l_result                number;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_collection_only       com_api_type_pkg.t_boolean  := nvl(i_collection_only, 0);
begin
    if i_include_affiliate = com_api_const_pkg.TRUE
        and i_inst_id is not null
    then
        l_host_id     := net_api_network_pkg.get_default_host(i_network_id);
        l_standard_id := net_api_network_pkg.get_offline_standard(
                             i_host_id => l_host_id
                         );

        if nvl(i_inst_code, mup_api_const_pkg.UPLOAD_FORWARDING) = mup_api_const_pkg.UPLOAD_FORWARDING then
            select /*+ INDEX(f, mup_fin_status_CLMS10_ndx)*/
                   count(*)
              into l_result
              from mup_fin f
                 , opr_operation o
                 , (select distinct v.param_value forw_inst_id
                      from cmn_parameter p
                         , net_api_interface_param_val_vw v
                         , net_member m
                         , net_interface i
                     where p.name           = mup_api_const_pkg.FORW_INST_ID
                       and p.standard_id    = l_standard_id
                       and p.id             = v.param_id
                       and m.id             = v.consumer_member_id
                       and v.host_member_id = l_host_id
                       and m.id             = i.consumer_member_id
                       and v.interface_id   = i.id
                       and (i.msp_member_id in (select id
                                                  from net_member
                                                 where network_id = i_network_id
                                                   and inst_id    = i_inst_id
                                               )
                            or m.inst_id = i_inst_id
                           )
                    ) p
             where decode(f.status, NET_API_CONST_PKG.CLEARING_MSG_STATUS_READY, f.de033, null) = p.forw_inst_id
               and f.split_hash in (select split_hash from com_api_split_map_vw)
               and f.is_incoming = 0
               and f.id = o.id
               and f.network_id = i_network_id
               and nvl(f.is_collection, 0) = l_collection_only
               and (f.de012 between nvl(i_start_date, trunc(f.de012)) and nvl(i_end_date, trunc(f.de012)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_type_pkg.FALSE
                 or o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_type_pkg.TRUE
                 or f.de012 is null and i_start_date is null and i_end_date is null);
        else
            select /*+ INDEX(f, mup_fin_status_CLMS10_ndx)*/
                   count(*)
              into l_result
              from mup_fin f
                 , opr_operation o
                 , (select distinct v.param_value cmid
                      from cmn_parameter p
                         , net_api_interface_param_val_vw v
                         , net_member m
                         , net_interface i
                     where p.name           = mup_api_const_pkg.CMID
                       and p.standard_id    = l_standard_id
                       and p.id             = v.param_id
                       and m.id             = v.consumer_member_id
                       and v.host_member_id = l_host_id
                       and m.id             = i.consumer_member_id
                       and v.interface_id   = i.id
                       and (i.msp_member_id in (select id
                                                  from net_member
                                                 where network_id = i_network_id
                                                   and inst_id    = i_inst_id
                                               )
                            or m.inst_id = i_inst_id
                           )
                    ) p
             where decode(f.status, NET_API_CONST_PKG.CLEARING_MSG_STATUS_READY, f.de094, null) = p.cmid
               and f.split_hash in (select split_hash from com_api_split_map_vw)
               and f.is_incoming = 0
               and f.id = o.id
               and f.network_id = i_network_id
               and nvl(f.is_collection, 0) = l_collection_only
               and (f.de012 between nvl(i_start_date, trunc(f.de012)) and nvl(i_end_date, trunc(f.de012)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_type_pkg.FALSE
                 or o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_type_pkg.TRUE
                 or f.de012 is null and i_start_date is null and i_end_date is null);
        end if;
    else
        if nvl(i_inst_code, mup_api_const_pkg.UPLOAD_FORWARDING) = mup_api_const_pkg.UPLOAD_FORWARDING then
            select /*+ INDEX(f, mup_fin_status_CLMS10_ndx)*/
                   count(*)
              into l_result
              from mup_fin f
                 , opr_operation o
             where decode(f.status, 'CLMS0010', f.de033, null) = i_cmid -- net_api_const.CLEARING_MSG_STATUS_READY
               and f.split_hash  in (select split_hash from com_api_split_map_vw)
               and f.is_incoming  = 0
               and f.inst_id      = i_inst_id
               and f.id           = o.id
               and f.network_id   = i_network_id
               and nvl(f.is_collection, 0) = l_collection_only
               and (
                      (f.de012 between nvl(i_start_date, trunc(f.de012)) and nvl(i_end_date, trunc(f.de012)) + 1 - com_api_const_pkg.ONE_SECOND
                       and f.is_reversal = com_api_type_pkg.FALSE)
                   or
                      (o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                       and f.is_reversal = com_api_type_pkg.TRUE)
                   or 
                      (f.de012 is null and i_start_date is null and i_end_date is null)
               );
        else
            select /*+ INDEX(f, mup_fin_status_CLMS10_ndx)*/
                   count(*)
              into l_result
              from mup_fin f
                 , opr_operation o
             where decode(f.status, 'CLMS0010', f.de094, null) = i_cmid -- net_api_const.CLEARING_MSG_STATUS_READY
               and f.split_hash in (select split_hash from com_api_split_map_vw)
               and f.is_incoming  = 0
               and f.inst_id      = i_inst_id
               and f.id           = o.id
               and f.network_id   = i_network_id
               and nvl(f.is_collection, 0) = l_collection_only
               and (
                      (f.de012 between nvl(i_start_date, trunc(f.de012)) and nvl(i_end_date, trunc(f.de012)) + 1 - com_api_const_pkg.ONE_SECOND
                       and f.is_reversal = com_api_type_pkg.FALSE)
                   or
                      (o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                       and f.is_reversal = com_api_type_pkg.TRUE)
                   or 
                      (f.de012 is null and i_start_date is null and i_end_date is null)
               );
        end if;
    end if;

    trc_log_pkg.debug(
        i_text         => 'estimate_messages_for_upload: count [#1]'
      , i_env_param1   => l_result
    );

    return l_result;
end estimate_messages_for_upload;

procedure enum_messages_for_upload (
    o_fin_cur               in out sys_refcursor
  , i_network_id            in com_api_type_pkg.t_tiny_id
  , i_cmid                  in mup_api_type_pkg.t_de033
  , i_inst_code             in com_api_type_pkg.t_dict_value := null
  , i_start_date            in date                          := null
  , i_end_date              in date                          := null
  , i_include_affiliate     in com_api_type_pkg.t_boolean    := com_api_const_pkg.FALSE
  , i_inst_id               in com_api_type_pkg.t_inst_id    := null
  , i_collection_only       in com_api_type_pkg.t_boolean    := null
) is
    WHERE_PLACEHOLDER       constant varchar2(100) := '##WHERE##';
    DATE_PLACEHOLDER        constant varchar2(100) := '##DATE##';

    l_cursor                com_api_type_pkg.t_text;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_param_name            com_api_type_pkg.t_name;
    l_collection_only       com_api_type_pkg.t_boolean  := nvl(i_collection_only, 0);
begin
    if i_include_affiliate = com_api_const_pkg.TRUE
        and i_inst_id is not null
    then
        l_host_id     := net_api_network_pkg.get_default_host(i_network_id);
        l_standard_id := net_api_network_pkg.get_offline_standard(
                             i_host_id => l_host_id
                         );
        if nvl(i_inst_code, mup_api_const_pkg.UPLOAD_FORWARDING) = mup_api_const_pkg.UPLOAD_FORWARDING then
            l_param_name := mup_api_const_pkg.FORW_INST_ID;
        else
            l_param_name := mup_api_const_pkg.CMID;
        end if;

        l_cursor := '
select /*+ INDEX(f, mup_fin_status_CLMS10_ndx)*/
    ' || FIN_COLUMN_LIST || '
from
    mup_fin f
    , mup_card c
    , opr_operation o
    , (select distinct v.param_value cmid
         from cmn_parameter p
            , net_api_interface_param_val_vw v
            , net_member m
            , net_interface i
        where p.name           = :l_param_name
          and p.standard_id    = :l_standard_id
          and p.id             = v.param_id
          and m.id             = v.consumer_member_id
          and v.host_member_id = :l_host_id
          and m.id             = i.consumer_member_id
          and v.interface_id   = i.id
          and (i.msp_member_id in (select id
                                     from net_member
                                    where network_id = :i_network_id
                                      and inst_id    = :i_inst_id
                                  )
               or m.inst_id = :i_inst_id
              )
       ) cmid
where ' || WHERE_PLACEHOLDER || '
    and f.split_hash in (select split_hash from com_api_split_map_vw)
    and f.network_id = :i_network_id
    and f.is_incoming = 0
    and f.id = o.id
    and f.id = c.id(+) ' || DATE_PLACEHOLDER || '
                and nvl(f.is_collection, 0) = ' || l_collection_only || '
order by
    f.id
for update of
    f.status';

        l_cursor := replace (
            l_cursor
          , WHERE_PLACEHOLDER
          , case
            when nvl(i_inst_code, mup_api_const_pkg.UPLOAD_FORWARDING) = mup_api_const_pkg.UPLOAD_FORWARDING then
                'decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', f.de033, null) = cmid.cmid'
            else
                'decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', f.de094, null) = cmid.cmid'
            end
        );
        l_cursor := replace (
            l_cursor
          , DATE_PLACEHOLDER
          , case
            when i_start_date is not null or i_end_date is not null then
                ' and (f.de012 between nvl(:i_start_date, trunc(f.de012)) and nvl(:i_end_date, trunc(f.de012)) + 1 - (1/86400) and f.is_reversal = ' || com_api_type_pkg.FALSE || ' or
o.host_date between nvl(:i_start_date, trunc(o.host_date)) and nvl(:i_end_date, trunc(o.host_date)) + 1 - (1/86400) and f.is_reversal = ' || com_api_type_pkg.TRUE || ') '
            else
                ' '
            end
        );
        if i_start_date is not null or i_end_date is not null then
            open o_fin_cur for l_cursor using l_param_name, l_standard_id, l_host_id, i_network_id, i_inst_id, i_inst_id, i_network_id, i_start_date, i_end_date, i_start_date, i_end_date;
        else
            open o_fin_cur for l_cursor using l_param_name, l_standard_id, l_host_id, i_network_id, i_inst_id, i_inst_id, i_network_id;
        end if;
    else
        l_cursor := '
select /*+ INDEX(f, mup_fin_status_CLMS10_ndx)*/
    ' || FIN_COLUMN_LIST || '
from
    mup_fin f
    , mup_card c
    , opr_operation o
where ' || WHERE_PLACEHOLDER || '
    and f.split_hash in (select split_hash from com_api_split_map_vw)
    and f.network_id = :i_network_id
    and f.is_incoming = 0
    and f.inst_id = :i_inst_id
    and f.id = o.id
    and f.id = c.id(+) ' || DATE_PLACEHOLDER || '
                and nvl(f.is_collection, 0) = ' || l_collection_only || '
order by
    f.id
for update of
    f.status';

        l_cursor := replace (
            l_cursor
          , WHERE_PLACEHOLDER
          , case
            when nvl(i_inst_code, mup_api_const_pkg.UPLOAD_FORWARDING) = mup_api_const_pkg.UPLOAD_FORWARDING then
                'decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', f.de033, null) = :i_cmid'
            else
                'decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', f.de094, null) = :i_cmid'
            end
        );
        l_cursor := replace (
            l_cursor
          , DATE_PLACEHOLDER
          , case
            when i_start_date is not null or i_end_date is not null then
                ' and (f.de012 between nvl(:i_start_date, trunc(f.de012)) and nvl(:i_end_date, trunc(f.de012)) + 1 - (1/86400) and f.is_reversal = ' || com_api_type_pkg.FALSE || ' or
o.host_date between nvl(:i_start_date, trunc(o.host_date)) and nvl(:i_end_date, trunc(o.host_date)) + 1 - (1/86400) and f.is_reversal = ' || com_api_type_pkg.TRUE || ') '
            else
                ' '
            end
        );
        trc_log_pkg.debug(l_cursor);
        if i_start_date is not null or i_end_date is not null then
            open o_fin_cur for l_cursor using i_cmid, i_network_id, i_inst_id, i_start_date, i_end_date, i_start_date, i_end_date;
        else
            open o_fin_cur for l_cursor using i_cmid, i_network_id, i_inst_id;
        end if;
    end if;
end enum_messages_for_upload;

procedure get_fin (
    i_id                    in com_api_type_pkg.t_long_id
  , o_fin_rec              out mup_api_type_pkg.t_fin_rec
  , i_mask_error            in com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE
) is
    l_fin_cur               sys_refcursor;
    l_statemet              com_api_type_pkg.t_text;
begin
    l_statemet := '
select
' || FIN_COLUMN_LIST || '
from
mup_fin f
, mup_card c
where
f.id = :i_id
and f.id = c.id(+)';
    open l_fin_cur for l_statemet using i_id;
    fetch l_fin_cur into o_fin_rec;
    close l_fin_cur;

    if o_fin_rec.id is null then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error (
                i_error         => 'FINANCIAL_MESSAGE_NOT_FOUND'
                , i_env_param1  => i_id
            );
        else
            trc_log_pkg.error (
                i_text          => 'FINANCIAL_MESSAGE_NOT_FOUND'
                , i_env_param1  => i_id
            );
        end if;
    end if;
exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;
        raise;
end get_fin;

procedure get_fin (
    i_mti                   in mup_api_type_pkg.t_mti
  , i_de024                 in mup_api_type_pkg.t_de024
  , i_is_reversal           in com_api_type_pkg.t_boolean
  , i_dispute_id            in com_api_type_pkg.t_long_id
  , o_fin_rec              out mup_api_type_pkg.t_fin_rec
  , i_mask_error            in com_api_type_pkg.t_boolean
) is
    l_fin_cur               sys_refcursor;
    l_statemet              com_api_type_pkg.t_text;
begin
    l_statemet := '
select
' || FIN_COLUMN_LIST || '
from
mup_fin f
, mup_card c
where
f.mti = :i_mti
and f.de024 = :i_de024
and f.is_reversal = :i_is_reversal
and f.dispute_id = :i_dispute_id
and f.id = c.id(+)';

    open l_fin_cur for l_statemet using i_mti, i_de024, i_is_reversal, i_dispute_id;
    fetch l_fin_cur into o_fin_rec;
    close l_fin_cur;

    if o_fin_rec.id is null then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error (
                i_error         => 'FINANCIAL_MESSAGE_NOT_FOUND'
                , i_env_param2  => i_mti
                , i_env_param3  => i_de024
                , i_env_param4  => i_is_reversal
            );
        else
            trc_log_pkg.error (
                i_text          => 'FINANCIAL_MESSAGE_NOT_FOUND'
                , i_env_param1  => null
                , i_env_param2  => i_mti
                , i_env_param3  => i_de024
                , i_env_param4  => i_is_reversal
            );
        end if;
    end if;
exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;
        raise;
end get_fin;

procedure get_original_fin (
    i_mti                   in mup_api_type_pkg.t_mti
  , i_de002                 in mup_api_type_pkg.t_de002
  , i_de024                 in mup_api_type_pkg.t_de024
  , i_de031                 in mup_api_type_pkg.t_de031
  , i_id                    in com_api_type_pkg.t_long_id := null
  , o_fin_rec              out mup_api_type_pkg.t_fin_rec
) is
    l_fin_cur               sys_refcursor;
    l_statemet              com_api_type_pkg.t_text;
begin
    l_statemet := '
select
' || FIN_COLUMN_LIST || '
from
mup_fin f
, mup_card c
where
f.mti = :i_mti
and f.de024 = :i_de024
and c.card_number = :i_de002
and f.de031 = :i_de031
and f.is_reversal = :i_is_reversal
and f.id = c.id(+)
and (f.id = :id or :id is null)
order by
f.dispute_id
for update';

    open l_fin_cur for l_statemet
    using
        i_mti
      , i_de024
      , iss_api_token_pkg.encode_card_number(i_card_number => i_de002)
      , i_de031
      , com_api_type_pkg.FALSE
      , i_id
      , i_id;

    mup_api_dispute_pkg.fetch_dispute_id (
        i_fin_cur    => l_fin_cur
        , o_fin_rec  => o_fin_rec
    );

    close l_fin_cur;
exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;

        raise;
end get_original_fin;

procedure get_original_fee (
    i_mti                   in mup_api_type_pkg.t_mti
  , i_de002                 in mup_api_type_pkg.t_de002
  , i_de024                 in mup_api_type_pkg.t_de024
  , i_de031                 in mup_api_type_pkg.t_de031
  , i_de094                 in mup_api_type_pkg.t_de094   := null
  , i_p0137                 in mup_api_type_pkg.t_p0137   := null
  , o_fin_rec              out mup_api_type_pkg.t_fin_rec
) is
    l_fin_cur               sys_refcursor;
    l_statemet              com_api_type_pkg.t_text;
begin
    l_statemet := '
select
' || FIN_COLUMN_LIST || '
from
mup_fin f
, mup_card c
where
f.mti = :i_mti
and f.de024 in ('''||mup_api_const_pkg.FUNC_CODE_MEMBER_FEE||''','''||mup_api_const_pkg.FUNC_CODE_SYSTEM_FEE||''')
and c.card_number = :i_de002
and f.de031 = :i_de031
and f.is_reversal = :i_is_reversal
and f.de094 = :i_de094
and f.p0137 = :i_p0137
and f.id = c.id(+)
order by
f.dispute_id';

    open l_fin_cur for l_statemet
    using
        i_mti
      , iss_api_token_pkg.encode_card_number(i_card_number => i_de002)
      , i_de031
      , com_api_type_pkg.FALSE
      , i_de094
      , i_p0137;
    fetch l_fin_cur into o_fin_rec;
    close l_fin_cur;

exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;
        raise;
end get_original_fee;

procedure pack_message (
    i_fin_rec  in     mup_api_type_pkg.t_fin_rec
  , i_file_id  in     com_api_type_pkg.t_short_id
  , i_de071    in     mup_api_type_pkg.t_de071
  , i_charset  in     com_api_type_pkg.t_oracle_name
  , o_raw_data    out varchar2
) is
    l_pds_tab                   mup_api_type_pkg.t_pds_tab;
    l_standard_version_id       com_api_type_pkg.t_tiny_id;
begin
    l_standard_version_id := cmn_api_standard_pkg.get_current_version(
        i_network_id => i_fin_rec.network_id
    );

    mup_api_pds_pkg.read_pds (
        i_msg_id      => i_fin_rec.id
      , o_pds_tab     => l_pds_tab
    );
    mup_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0025
      , i_pds_body    => mup_api_pds_pkg.format_p0025(
                             i_p0025_1 => i_fin_rec.p0025_1
                           , i_p0025_2 => i_fin_rec.p0025_2
                         )
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0137
      , i_pds_body    => i_fin_rec.p0137
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0148
      , i_pds_body    => i_fin_rec.p0148
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0149
      , i_pds_body    => mup_api_pds_pkg.format_p0149(
                             i_p0149_1 => i_fin_rec.p0149_1
                           , i_p0149_2 => i_fin_rec.p0149_2
                         )
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab  => l_pds_tab
      , i_pds_tag   => mup_api_const_pkg.PDS_TAG_2158
      , i_pds_body  => mup_api_pds_pkg.format_p2158(
                           i_p2158_1  => i_fin_rec.p2158_1
                         , i_p2158_2  => i_fin_rec.p2158_2
                         , i_p2158_3  => i_fin_rec.p2158_3
                         , i_p2158_4  => i_fin_rec.p2158_4
                         , i_p2158_5  => i_fin_rec.p2158_5
                         , i_p2158_6  => i_fin_rec.p2158_6
                       )
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0165
      , i_pds_body    => i_fin_rec.p0165
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0176
      , i_pds_body    => i_fin_rec.p0176
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0190
      , i_pds_body    => i_fin_rec.p0190
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0198
      , i_pds_body    => i_fin_rec.p0198
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0228
      , i_pds_body    => i_fin_rec.p0228
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0261
      , i_pds_body    => i_fin_rec.p0261
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0262
      , i_pds_body    => i_fin_rec.p0262
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0265
      , i_pds_body    => i_fin_rec.p0265
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0266
      , i_pds_body    => i_fin_rec.p0266
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0267
      , i_pds_body    => i_fin_rec.p0267
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0268
      , i_pds_body    => mup_api_pds_pkg.format_p0268(
                             i_p0268_1 => i_fin_rec.p0268_1
                           , i_p0268_2 => i_fin_rec.p0268_2
                         )
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_0375
      , i_pds_body    => i_fin_rec.p0375
    );

    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_2072
      , i_pds_body    => mup_api_pds_pkg.format_p2072(
                             i_p2072_1 => i_fin_rec.p2072_1
                           , i_p2072_2 => i_fin_rec.p2072_2
                         )
    );

    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_2175
      , i_pds_body    => mup_api_pds_pkg.format_p2175(
                             i_p2175_1 => i_fin_rec.p2175_1
                           , i_p2175_2 => i_fin_rec.p2175_2
                           , i_standard_version_id  => l_standard_version_id
                         )
    );
    if l_standard_version_id >= mup_api_const_pkg.MUP_STANDARD_VERSION_ID_18Q4 then
        mup_api_pds_pkg.set_pds_body(
            io_pds_tab    => l_pds_tab
          , i_pds_tag     => mup_api_const_pkg.PDS_TAG_2097
          , i_pds_body    => mup_api_pds_pkg.format_p2097(
                                 i_p2097_1              => i_fin_rec.p2097_1
                               , i_p2097_2              => i_fin_rec.p2097_2
                               , i_standard_version_id  => l_standard_version_id
                             )
        );
    end if;

    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_2002
      , i_pds_body    => i_fin_rec.p2002
    );
    mup_api_pds_pkg.set_pds_body (
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mup_api_const_pkg.PDS_TAG_2063
      , i_pds_body    => i_fin_rec.p2063
    );

    mup_api_msg_pkg.pack_message (
        o_raw_data        => o_raw_data
      , i_pds_tab         => l_pds_tab
      , i_mti             => i_fin_rec.mti
      , i_de002           => i_fin_rec.de002
      , i_de003_1         => i_fin_rec.de003_1
      , i_de003_2         => i_fin_rec.de003_2
      , i_de003_3         => i_fin_rec.de003_3
      , i_de004           => i_fin_rec.de004
      , i_de005           => i_fin_rec.de005
      , i_de006           => i_fin_rec.de006
      , i_de009           => i_fin_rec.de009
      , i_de010           => i_fin_rec.de010
      , i_de012           => i_fin_rec.de012
      , i_de014           => i_fin_rec.de014
      , i_de022_1         => i_fin_rec.de022_1
      , i_de022_2         => i_fin_rec.de022_2
      , i_de022_3         => i_fin_rec.de022_3
      , i_de022_4         => i_fin_rec.de022_4
      , i_de022_5         => i_fin_rec.de022_5
      , i_de022_6         => i_fin_rec.de022_6
      , i_de022_7         => i_fin_rec.de022_7
      , i_de022_8         => i_fin_rec.de022_8
      , i_de022_9         => i_fin_rec.de022_9
      , i_de022_10        => i_fin_rec.de022_10
      , i_de022_11        => i_fin_rec.de022_11
      , i_de023           => i_fin_rec.de023
      , i_de024           => i_fin_rec.de024
      , i_de025           => i_fin_rec.de025
      , i_de026           => i_fin_rec.de026
      , i_de030_1         => i_fin_rec.de030_1
      , i_de030_2         => i_fin_rec.de030_2
      , i_de031           => i_fin_rec.de031
      , i_de032           => i_fin_rec.de032
      , i_de033           => i_fin_rec.de033
      , i_de037           => i_fin_rec.de037
      , i_de038           => i_fin_rec.de038
      , i_de040           => i_fin_rec.de040
      , i_de041           => i_fin_rec.de041
      , i_de042           => i_fin_rec.de042
      , i_de043_1         => i_fin_rec.de043_1
      , i_de043_2         => i_fin_rec.de043_2
      , i_de043_3         => i_fin_rec.de043_3
      , i_de043_4         => i_fin_rec.de043_4
      , i_de043_5         => i_fin_rec.de043_5
      , i_de043_6         => i_fin_rec.de043_6
      , i_de049           => i_fin_rec.de049
      , i_de050           => i_fin_rec.de050
      , i_de051           => i_fin_rec.de051
      , i_de054           => i_fin_rec.de054
      , i_de055           => i_fin_rec.de055
      , i_de063           => i_fin_rec.de063
      , i_de071           => i_de071
      , i_de072           => i_fin_rec.de072
      , i_de073           => i_fin_rec.de073
      , i_de093           => i_fin_rec.de093
      , i_de094           => i_fin_rec.de094
      , i_de095           => i_fin_rec.de095
      , i_de100           => i_fin_rec.de100
      , i_charset         => i_charset
    );
end pack_message;

procedure mark_ok_uploaded (
    i_rowid                 in com_api_type_pkg.t_rowid_tab
  , i_id                    in com_api_type_pkg.t_number_tab
  , i_de071                 in com_api_type_pkg.t_number_tab
  , i_file_id               in com_api_type_pkg.t_number_tab
) is
begin
    forall i in 1 .. i_rowid.count
        update mup_fin
           set status      = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
             , is_rejected = com_api_type_pkg.FALSE
             , de071       = i_de071(i)
             , file_id     = i_file_id(i)
         where rowid = i_rowid(i);

    opr_api_clearing_pkg.mark_uploaded (
        i_id_tab            => i_id
    );
end mark_ok_uploaded;

procedure mark_error_uploaded (
    i_rowid                 in com_api_type_pkg.t_rowid_tab
) is
begin
    forall i in 1 .. i_rowid.count
        update mup_fin
           set status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOAD_ERR
         where rowid  = i_rowid(i);
end mark_error_uploaded;

procedure flush_job is
begin
    null;
end flush_job;

procedure cancel_job is
begin
    null;
end cancel_job;

function get_cashback_amount(
    i_de054                 in com_api_type_pkg.t_name
  , i_oper_curr             in com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_money is
    idx                     pls_integer;
    l_add_type              com_api_type_pkg.t_curr_code;
    l_add_curr              com_api_type_pkg.t_curr_code;
    l_oper_cashback_amount  com_api_type_pkg.t_money;
    l_sub_str               varchar2(20);
begin
    idx         := 1;
    l_sub_str   := substr(i_de054, idx, 20);
    while idx < length(i_de054) loop

        l_add_type  := substr(l_sub_str, 3, 2);
        idx := idx + 20;
        if l_add_type = '40' then
            l_add_curr := substr(l_sub_str, 5, 3);

            if l_add_curr = i_oper_curr then
                l_oper_cashback_amount := to_number(substr(l_sub_str, 9));
            end if;

            return l_oper_cashback_amount;
        else
            l_sub_str   := substr(i_de054, idx, 20);
        end if;

    end loop;

    return l_oper_cashback_amount;
end get_cashback_amount;

function get_original_id (
    i_fin_rec               in mup_api_type_pkg.t_fin_rec
) return com_api_type_pkg.t_long_id is
    l_original_id           com_api_type_pkg.t_long_id;
    l_mti                   mup_api_type_pkg.t_mti;
    l_de024_1               mup_api_type_pkg.t_de024;
    l_de024_2               mup_api_type_pkg.t_de024;
    l_split_hash            com_api_type_pkg.t_inst_id;
begin
    l_split_hash := com_api_hash_pkg.get_split_hash(i_fin_rec.de002);

    if i_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
       and i_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_FIRST_PRES
       and i_fin_rec.is_reversal = com_api_type_pkg.TRUE
       and i_fin_rec.dispute_id is not null
    then
        l_mti := i_fin_rec.mti;

        select min(id)
          into l_original_id
          from mup_fin
         where split_hash  = l_split_hash
           and mti         = l_mti
           and de024       = i_fin_rec.de024
           and is_reversal = com_api_type_pkg.FALSE
           and dispute_id  = i_fin_rec.dispute_id;

    else
        if i_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
           and i_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
        then
            l_mti := mup_api_const_pkg.MSG_TYPE_PRESENTMENT;
            l_de024_1 := mup_api_const_pkg.FUNC_CODE_FIRST_PRES;
            l_de024_2 := mup_api_const_pkg.FUNC_CODE_FIRST_PRES;

        elsif i_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_CHARGEBACK
            and i_fin_rec.de024 in (mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                                  , mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART)
        then
            l_mti := mup_api_const_pkg.MSG_TYPE_PRESENTMENT;
            l_de024_1 := mup_api_const_pkg.FUNC_CODE_FIRST_PRES;
            l_de024_2 := mup_api_const_pkg.FUNC_CODE_FIRST_PRES;

        elsif i_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
            and i_fin_rec.de024 in (mup_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
                                  , mup_api_const_pkg.FUNC_CODE_SECOND_PRES_PART)
        then
            l_mti := mup_api_const_pkg.MSG_TYPE_CHARGEBACK;
            l_de024_1 := mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL;
            l_de024_2 := mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART;

        elsif i_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_CHARGEBACK
            and i_fin_rec.de024 in (mup_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
                                  , mup_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART)
        then
            l_mti := mup_api_const_pkg.MSG_TYPE_PRESENTMENT;
            l_de024_1 := mup_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL;
            l_de024_2 := mup_api_const_pkg.FUNC_CODE_SECOND_PRES_PART;

        elsif i_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_FEE
            and i_fin_rec.de024 in (mup_api_const_pkg.FUNC_CODE_MEMBER_FEE)
        then
            l_mti := mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
            l_de024_1 := mup_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST;
            l_de024_2 := mup_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST;

        elsif i_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_FEE
            and i_fin_rec.de024 in (mup_api_const_pkg.FUNC_CODE_FEE_RETURN)
        then
            l_mti := mup_api_const_pkg.MSG_TYPE_FEE;
            l_de024_1 := mup_api_const_pkg.FUNC_CODE_MEMBER_FEE;
            l_de024_2 := mup_api_const_pkg.FUNC_CODE_MEMBER_FEE;

        elsif i_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
           and i_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_ADJUSTMENT
        then
            l_mti       := mup_api_const_pkg.MSG_TYPE_PRESENTMENT;
            l_de024_1   := mup_api_const_pkg.FUNC_CODE_FIRST_PRES;
            l_de024_2   := mup_api_const_pkg.FUNC_CODE_FIRST_PRES;
        end if; 

        if l_mti is not null then
            select min(id)
              into l_original_id
              from mup_fin
             where split_hash = l_split_hash
               and mti        = l_mti
               and de024     in (l_de024_1, l_de024_2)
               and de031      = i_fin_rec.de031;
        end if;
    end if;

    trc_log_pkg.debug (
        i_text         => 'get_original_id [#1]'
      , i_env_param1   => l_original_id
    );

    if l_original_id is null and l_mti is not null then
        g_no_original_id_tab(g_no_original_id_tab.count + 1) := i_fin_rec;
    end if;

    return l_original_id;
end get_original_id;

procedure create_operation(
    i_fin_rec             in     mup_api_type_pkg.t_fin_rec
  , i_standard_id         in     com_api_type_pkg.t_tiny_id
  , i_auth                in     aut_api_type_pkg.t_auth_rec   := null
  , i_status              in     com_api_type_pkg.t_dict_value := null
  , i_incom_sess_file_id  in     com_api_type_pkg.t_long_id    := null
  , i_host_id             in     com_api_type_pkg.t_tiny_id    := null
  , i_client_id_type      in     com_api_type_pkg.t_dict_value := null
  , i_client_id_value     in     com_api_type_pkg.t_name       := null
) is
    l_iss_inst_id                com_api_type_pkg.t_inst_id;
    l_acq_inst_id                com_api_type_pkg.t_inst_id;
    l_card_inst_id               com_api_type_pkg.t_inst_id;
    l_iss_network_id             com_api_type_pkg.t_tiny_id;
    l_acq_network_id             com_api_type_pkg.t_tiny_id;
    l_card_network_id            com_api_type_pkg.t_tiny_id;
    l_card_type_id               com_api_type_pkg.t_tiny_id;
    l_card_country               com_api_type_pkg.t_country_code;
    l_bin_currency               com_api_type_pkg.t_curr_code;
    l_sttl_currency              com_api_type_pkg.t_curr_code;
    l_msg_type                   com_api_type_pkg.t_dict_value;
    l_sttl_type                  com_api_type_pkg.t_dict_value;
    l_status                     com_api_type_pkg.t_dict_value;
    l_match_status               com_api_type_pkg.t_dict_value;
    l_match_id                   com_api_type_pkg.t_long_id;
    l_terminal_type              com_api_type_pkg.t_dict_value;
    l_oper_type                  com_api_type_pkg.t_dict_value;
    l_oper_id                    com_api_type_pkg.t_long_id;
    l_original_id                com_api_type_pkg.t_long_id;
    l_proc_mode                  com_api_type_pkg.t_dict_value;
    l_oper_cashback_amount       com_api_type_pkg.t_money;
    l_terminal_number            com_api_type_pkg.t_terminal_number;

    l_operation                  opr_api_type_pkg.t_oper_rec;
    l_participant                opr_api_type_pkg.t_oper_part_rec;
    l_iss_part                   opr_api_type_pkg.t_oper_part_rec;
    l_acq_part                   opr_api_type_pkg.t_oper_part_rec;
    l_oper_reason                com_api_type_pkg.t_dict_value;
    l_merchant                   acq_api_type_pkg.t_merchant;

    l_oper_request_amount        com_api_type_pkg.t_money;
    l_oper_amount                com_api_type_pkg.t_money;
    l_oper_currency              com_api_type_pkg.t_curr_code;
begin
    l_oper_id     := i_fin_rec.id;
    l_original_id := get_original_id(i_fin_rec => i_fin_rec);
    l_status      := nvl(i_status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY);

    opr_api_operation_pkg.get_operation(
        i_oper_id    => l_original_id
      , o_operation  => l_operation
    );

    if i_fin_rec.is_reversal = com_api_type_pkg.TRUE
       and i_fin_rec.is_incoming = com_api_type_pkg.FALSE
    then

        l_sttl_type := l_operation.sttl_type;
        l_oper_type := l_operation.oper_type;
        l_msg_type  := l_operation.msg_type;

        opr_api_operation_pkg.get_participant(
            i_oper_id            => l_original_id
          , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ISSUER
          , o_participant        => l_participant
        );

        l_iss_inst_id         := l_participant.inst_id;
        l_iss_network_id      := l_participant.network_id;
        l_iss_part.split_hash := l_participant.split_hash;
        l_card_type_id        := l_participant.card_type_id;
        l_card_country        := l_participant.card_country;
        l_card_inst_id        := l_participant.card_inst_id;
        l_card_network_id     := l_participant.card_network_id;

        opr_api_operation_pkg.get_participant(
            i_oper_id            => l_original_id
          , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
          , o_participant        => l_participant
        );

        l_acq_inst_id          := l_participant.inst_id;
        l_acq_network_id       := l_participant.network_id;
        l_acq_part.merchant_id := l_participant.merchant_id;
        l_acq_part.terminal_id := l_participant.terminal_id;
        l_acq_part.split_hash  := l_participant.split_hash;

    elsif (
              i_fin_rec.mti        =  mup_api_const_pkg.MSG_TYPE_FEE
              and i_fin_rec.de024 in (mup_api_const_pkg.FUNC_CODE_MEMBER_FEE
                                    , mup_api_const_pkg.FUNC_CODE_FEE_RETURN)
              and (i_auth.id is null or i_fin_rec.is_incoming = com_api_type_pkg.FALSE)
          )
          or
          (
              i_fin_rec.mti        = mup_api_const_pkg.MSG_TYPE_FEE
              and i_fin_rec.de024  = mup_api_const_pkg.FUNC_CODE_SYSTEM_FEE
              and i_auth.id       is null
              and i_fin_rec.p0190 is not null
          )
    then

        iss_api_bin_pkg.get_bin_info(
            i_card_number       => i_fin_rec.de002
          , o_iss_inst_id       => l_iss_inst_id
          , o_iss_network_id    => l_iss_network_id
          , o_card_inst_id      => l_card_inst_id
          , o_card_network_id   => l_card_network_id
          , o_card_type         => l_card_type_id
          , o_card_country      => l_card_country
          , o_bin_currency      => l_bin_currency
          , o_sttl_currency     => l_sttl_currency
        );

        if l_card_inst_id is null then
            l_iss_inst_id    := net_api_network_pkg.get_inst_id(i_fin_rec.network_id);
            l_iss_network_id := i_fin_rec.network_id;
        end if;

        l_acq_inst_id        := i_fin_rec.inst_id;
        l_acq_network_id     := ost_api_institution_pkg.get_inst_network(l_acq_inst_id);

        l_card_inst_id       := l_iss_inst_id;
        l_card_network_id    := l_iss_network_id;

        if l_oper_type is null then
            l_oper_type := net_api_map_pkg.get_oper_type(
                               i_network_oper_type => i_fin_rec.de003_1 || nvl(i_fin_rec.de026, '____')
                             , i_standard_id       => i_standard_id
                             , i_mask_error        => com_api_type_pkg.FALSE
                           );
        end if;

        begin
            net_api_sttl_pkg.get_sttl_type(
                i_iss_inst_id      => l_iss_inst_id
              , i_acq_inst_id      => l_acq_inst_id
              , i_card_inst_id     => l_card_inst_id
              , i_iss_network_id   => l_iss_network_id
              , i_acq_network_id   => l_acq_network_id
              , i_card_network_id  => l_card_network_id
              , i_acq_inst_bin     => nvl(i_fin_rec.de032, i_fin_rec.de033)
              , o_sttl_type        => l_sttl_type
              , o_match_status     => l_match_status
              , i_oper_type        => l_oper_type
            );
        exception
            when others then
                trc_log_pkg.error(
                    i_text          => sqlerrm
                );

                l_status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;

                update mup_fin
                   set status =  mup_api_const_pkg.MSG_STATUS_INVALID
                 where id = i_fin_rec.id;

                trc_log_pkg.debug(
                    i_text          => 'Set message status is invalid and save operation'
                );
        end;

    -- original operation was not found
    elsif i_auth.id is null
          and i_fin_rec.status = mcw_api_const_pkg.MSG_STATUS_INVALID
          and (i_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
               or
               i_fin_rec.de024 = mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST)
    then
        --acq part
        l_acq_inst_id := i_fin_rec.inst_id;

        if l_acq_network_id is null then
            l_acq_network_id := ost_api_institution_pkg.get_inst_network(l_acq_inst_id);
        end if;

        --iss part
        l_iss_network_id := i_fin_rec.network_id;

        if l_iss_inst_id is null then
            l_iss_inst_id    := net_api_network_pkg.get_inst_id(l_iss_network_id);
        end if;

        trc_log_pkg.debug(
            i_text    => 'l_acq_inst_id ['    || l_acq_inst_id
                   || '], l_acq_network_id [' || l_acq_network_id
                   || '], l_iss_inst_id ['    || l_iss_inst_id
                   || '], l_iss_network_id [' || l_iss_network_id || ']'
        );

        l_status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;

        trc_log_pkg.debug(
            i_text          => 'Message status is invalid. Save operation in status for manual processing'
        );

        if l_oper_type is null then
            l_oper_type := net_api_map_pkg.get_oper_type(
                               i_network_oper_type => i_fin_rec.de003_1 || nvl(i_fin_rec.de026, '____')
                             , i_standard_id       => i_standard_id
                             , i_mask_error        => com_api_type_pkg.FALSE
                           );
        end if;

        begin
            net_api_sttl_pkg.get_sttl_type(
                i_iss_inst_id      => l_iss_inst_id
              , i_acq_inst_id      => l_acq_inst_id
              , i_card_inst_id     => l_card_inst_id
              , i_iss_network_id   => l_iss_network_id
              , i_acq_network_id   => l_acq_network_id
              , i_card_network_id  => l_card_network_id
              , i_acq_inst_bin     => nvl(i_fin_rec.de032, i_fin_rec.de033)
              , o_sttl_type        => l_sttl_type
              , o_match_status     => l_match_status
              , i_oper_type        => l_oper_type
            );
        exception
            when others then
                trc_log_pkg.error(
                    i_text          => sqlerrm
                );
        end;

    elsif i_auth.id is null then
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => i_fin_rec.de002
          , o_iss_inst_id      => l_iss_inst_id
          , o_iss_network_id   => l_iss_network_id
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_card_type        => l_card_type_id
          , o_card_country     => l_card_country
          , o_bin_currency     => l_bin_currency
          , o_sttl_currency    => l_sttl_currency
        );

        if l_card_inst_id is null then --????
            l_iss_inst_id    := i_fin_rec.inst_id;
            l_iss_network_id := ost_api_institution_pkg.get_inst_network(i_fin_rec.inst_id);
        end if;

        l_acq_network_id     := i_fin_rec.network_id;
        l_acq_inst_id        := net_api_network_pkg.get_inst_id(i_fin_rec.network_id);

        if l_oper_type is null then
            l_oper_type := net_api_map_pkg.get_oper_type(
                               i_network_oper_type => i_fin_rec.de003_1 || nvl(i_fin_rec.de026, '____')
                             , i_standard_id       => i_standard_id
                             , i_mask_error        => com_api_type_pkg.FALSE
                           );
        end if;

        begin
            net_api_sttl_pkg.get_sttl_type(
                i_iss_inst_id      => l_iss_inst_id
              , i_acq_inst_id      => l_acq_inst_id
              , i_card_inst_id     => l_card_inst_id
              , i_iss_network_id   => l_iss_network_id
              , i_acq_network_id   => l_acq_network_id
              , i_card_network_id  => l_card_network_id
              , i_acq_inst_bin     => nvl(i_fin_rec.de032, i_fin_rec.de033)
              , o_sttl_type        => l_sttl_type
              , o_match_status     => l_match_status
              , i_oper_type        => l_oper_type
            );
        exception
            when others then
                trc_log_pkg.error(
                    i_text          => sqlerrm
                );

                l_status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;

                update mup_fin
                   set status = mup_api_const_pkg.MSG_STATUS_INVALID
                 where id = i_fin_rec.id;

                trc_log_pkg.debug(
                    i_text          => 'Set message status is invalid and save operation'
                );
        end;

    else
        l_sttl_type      := i_auth.sttl_type;
        l_iss_inst_id    := i_auth.iss_inst_id;
        l_iss_network_id := i_auth.iss_network_id;
        l_acq_inst_id    := i_auth.acq_inst_id;
        l_acq_network_id := i_auth.acq_network_id;
        l_match_status   := i_auth.match_status;

        -- dispute is found for reversal presentment and original presentment is matched
        if i_fin_rec.dispute_id is not null then
            opr_api_clearing_pkg.match_reversal(
                i_oper_id           => l_oper_id
              , i_is_reversal       => i_fin_rec.is_reversal
              , i_network_refnum    => i_fin_rec.de031
              , i_oper_amount       => nvl(i_fin_rec.de004, i_fin_rec.de030_1)
              , i_oper_currency     => nvl(i_fin_rec.de049, i_fin_rec.p0149_1)
              , i_card_number       => i_fin_rec.de002
              , i_inst_id           => l_iss_inst_id
              , io_match_status     => l_match_status
              , io_match_id         => l_match_id
            );
        end if;

    end if;

    -- Operation type and message type are not defined by a financial message in case of reversal operation,
    -- fields' values of an original operation are used instead of this
    if l_msg_type is null then
        l_msg_type := net_api_map_pkg.get_msg_type(
                          i_network_msg_type   => i_fin_rec.mti || i_fin_rec.de024 || case when i_fin_rec.de025 in ('1403', '1404') then i_fin_rec.de025 else null end
                        , i_standard_id        => i_standard_id
                        , i_mask_error         => com_api_type_pkg.FALSE
                      );
    end if;

    if l_oper_type is null then
        l_oper_type := net_api_map_pkg.get_oper_type(
                           i_network_oper_type => i_fin_rec.de003_1 || nvl(i_fin_rec.de026, '____')
                         , i_standard_id       => i_standard_id
                         , i_mask_error        => com_api_type_pkg.FALSE
                       );
    end if;

    l_terminal_type :=
        case i_fin_rec.de022_8
            when '1' then acq_api_const_pkg.TERMINAL_TYPE_ATM
            when '2' then acq_api_const_pkg.TERMINAL_TYPE_INFO_KIOSK    
            when '3' then acq_api_const_pkg.TERMINAL_TYPE_POS
            when '4' then acq_api_const_pkg.TERMINAL_TYPE_EPOS
            when '5' then acq_api_const_pkg.TERMINAL_TYPE_MOBILE
            else null
        end;

    if i_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
        and i_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_FIRST_PRES
    then
        if iss_api_card_pkg.get_card_id(i_card_number => i_fin_rec.de002) is null
            and i_fin_rec.is_reversal = com_api_const_pkg.FALSE
        then
            l_proc_mode := aut_api_const_pkg.AUTH_PROC_MODE_CARD_ABSENT;
            l_status    := opr_api_const_pkg.OPERATION_STATUS_MANUAL;

            trc_log_pkg.warn(
                i_text         => 'CARD_NOT_FOUND'
              , i_env_param1   => iss_api_card_pkg.get_card_mask(i_fin_rec.de002)
              , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id    => l_oper_id
            );
        end if;

        if i_fin_rec.is_reversal = com_api_const_pkg.TRUE then
            opr_api_operation_pkg.get_operation(
                i_oper_id       => l_original_id
              , o_operation     => l_operation
            );
            l_terminal_type := l_operation.terminal_type;
            -- inherit terminal_number from original operation to support long terminal_number version
            l_terminal_number      := l_operation.terminal_number;
        end if;
    end if;

    -- if second presentment or chargeback operation
    if (
           i_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
           and i_fin_rec.de024 in (mup_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
                                 , mup_api_const_pkg.FUNC_CODE_SECOND_PRES_PART)
       )
       or
       (
           i_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_CHARGEBACK
           and i_fin_rec.de024 in (mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                                 , mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                                 , mup_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
                                 , mup_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART)
       )
       or
       (
           i_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
           and i_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_ADJUSTMENT
       )
    then
        opr_api_operation_pkg.get_operation(
            i_oper_id             => l_original_id
          , o_operation           => l_operation
        );
        opr_api_operation_pkg.get_participant(
            i_oper_id            => l_operation.id
          , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ISSUER
          , o_participant        => l_participant
        );

        if      i_fin_rec.de024         = mup_api_const_pkg.FUNC_CODE_ADJUSTMENT
            and i_fin_rec.is_incoming   = com_api_const_pkg.FALSE
        then
            l_oper_reason   := mup_api_const_pkg.OPER_REASON_DEBIT_ADJUSTMENT;
        end if;

        l_iss_part.split_hash := l_participant.split_hash;
        l_card_inst_id        := nvl(l_card_inst_id, l_participant.card_inst_id);
        l_card_network_id     := nvl(l_card_network_id, l_participant.card_network_id);

        opr_api_operation_pkg.get_participant(
            i_oper_id            => l_operation.id
          , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
          , o_participant        => l_participant
        );

        l_acq_part.merchant_id := l_participant.merchant_id;
        l_acq_part.terminal_id := l_participant.terminal_id;
        l_acq_part.split_hash  := l_participant.split_hash;
        l_terminal_type        := l_operation.terminal_type;
        -- inherit terminal_number from original operation to support long terminal_number version
        l_terminal_number      := l_operation.terminal_number;
    end if;

    l_merchant.merchant_number := i_fin_rec.de042;
    l_merchant.merchant_name   := i_fin_rec.de043_1;
    l_merchant.id              := l_acq_part.merchant_id;

    l_oper_amount              := nvl(i_fin_rec.de004, i_fin_rec.de030_1);
    l_oper_currency            := nvl(i_fin_rec.de049, i_fin_rec.p0149_1);

    if i_fin_rec.mti       = mup_api_const_pkg.MSG_TYPE_FEE
       and i_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_SYSTEM_FEE
    then
        l_oper_reason := i_fin_rec.de025;

        if i_fin_rec.de025 in ('7400', '7401', '7402', '7403') then
            l_oper_request_amount := l_oper_amount;
        end if;

        if i_fin_rec.p0190 is not null then
            -- try to find an merchant by partner_id_code 
            l_merchant := 
                acq_api_merchant_pkg.get_merchant(
                    i_partner_id_code => i_fin_rec.p0190
                  , i_inst_id         => l_acq_inst_id
                  , i_mask_error      => com_api_const_pkg.TRUE
                );

            if l_merchant.id is null then
                l_status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;

                update mup_fin
                   set status =  mup_api_const_pkg.MSG_STATUS_INVALID
                 where id     = i_fin_rec.id;

                trc_log_pkg.debug(
                    i_text          => 'Set message status is invalid and save operation'
                );
            end if;
         end if;
    elsif   i_fin_rec.mti   = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
        and i_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_ADJUSTMENT
    then
        l_oper_reason := mup_api_const_pkg.OPER_REASON_DEBIT_ADJUSTMENT;
    else
        l_oper_reason := null;
    end if;

    trc_log_pkg.debug (
        i_text         => 'create_operation: oper_id [#1], merchant_id [#2], terminal_id [#3]'
      , i_env_param1   => l_oper_id
      , i_env_param2   => l_acq_part.merchant_id
      , i_env_param3   => l_acq_part.terminal_id
    );

    opr_api_create_pkg.create_operation(
        io_oper_id              => l_oper_id
      , i_session_id            => get_session_id
      , i_status                => l_status
      , i_status_reason         => null
      , i_sttl_type             => l_sttl_type
      , i_msg_type              => l_msg_type
      , i_oper_type             => l_oper_type
      , i_oper_reason           => l_oper_reason
      , i_is_reversal           => i_fin_rec.is_reversal
      , i_original_id           => l_original_id
      , i_oper_request_amount   => l_oper_request_amount
      , i_oper_amount           => l_oper_amount
      , i_oper_currency         => l_oper_currency
      , i_oper_cashback_amount  => l_oper_cashback_amount
      , i_sttl_amount           => i_fin_rec.de005
      , i_sttl_currency         => i_fin_rec.de050
      , i_oper_date             => i_fin_rec.de012
      , i_host_date             => null
      , i_terminal_type         => l_terminal_type
      , i_mcc                   => i_fin_rec.de026
      , i_originator_refnum     => i_fin_rec.de037
      , i_network_refnum        => i_fin_rec.de031
      , i_acq_inst_bin          => nvl(i_fin_rec.de032, i_fin_rec.de033)
      , i_merchant_number       => l_merchant.merchant_number -- i_fin_rec.de042
      , i_terminal_number       => nvl(l_terminal_number, i_fin_rec.de041)
      , i_merchant_name         => l_merchant.merchant_name    -- i_fin_rec.de043_1
      , i_merchant_street       => i_fin_rec.de043_2
      , i_merchant_city         => i_fin_rec.de043_3
      , i_merchant_region       => i_fin_rec.de043_5
      , i_merchant_country      => com_api_country_pkg.get_country_code_by_name(i_fin_rec.de043_6, com_api_type_pkg.FALSE)
      , i_merchant_postcode     => i_fin_rec.de043_4
      , i_dispute_id            => i_fin_rec.dispute_id
      , i_match_status          => l_match_status
      , i_match_id              => l_match_id
      , i_proc_mode             => l_proc_mode
      , i_incom_sess_file_id    => i_incom_sess_file_id
      , i_fee_amount            => i_fin_rec.p0146_net
      , i_fee_currency          => i_fin_rec.de050
    );

    opr_api_create_pkg.add_participant(
        i_oper_id           => l_oper_id
      , i_msg_type          => l_msg_type
      , i_oper_type         => l_oper_type
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_host_date         => null
      , i_inst_id           => l_iss_inst_id
      , i_network_id        => l_iss_network_id
      , i_customer_id       => iss_api_card_pkg.get_customer_id(i_fin_rec.de002)
      , i_client_id_type    => nvl(i_client_id_type, opr_api_const_pkg.CLIENT_ID_TYPE_CARD)
      , i_client_id_value   => nvl(i_client_id_value, i_fin_rec.de002)
      , i_card_id           => iss_api_card_pkg.get_card_id(i_fin_rec.de002)
      , i_card_type_id      => l_card_type_id
      , i_card_expir_date   => null
      , i_card_seq_number   => i_fin_rec.de023
      , i_card_number       => i_fin_rec.de002
      , i_card_mask         => iss_api_card_pkg.get_card_mask(i_fin_rec.de002)
      , i_card_hash         => com_api_hash_pkg.get_card_hash(i_fin_rec.de002)
      , i_card_country      => l_card_country
      , i_card_inst_id      => l_card_inst_id
      , i_card_network_id   => l_card_network_id
      , i_account_id        => null
      , i_account_number    => null
      , i_account_amount    => null
      , i_account_currency  => null
      , i_auth_code         => i_fin_rec.de038
      , i_split_hash        => l_iss_part.split_hash
      , i_without_checks    => com_api_const_pkg.TRUE
    );

    opr_api_create_pkg.add_participant(
        i_oper_id           => l_oper_id
      , i_msg_type          => l_msg_type
      , i_oper_type         => l_oper_type
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
      , i_host_date         => null
      , i_inst_id           => l_acq_inst_id
      , i_network_id        => l_acq_network_id
      , i_merchant_id       => l_merchant.id -- l_acq_part.merchant_id
      , i_terminal_id       => l_acq_part.terminal_id
      , i_terminal_number   => nvl(l_terminal_number, i_fin_rec.de041)
      , i_split_hash        => l_acq_part.split_hash
      , i_without_checks    => com_api_const_pkg.TRUE
    );
end create_operation;

procedure put_message (
    i_fin_rec               in mup_api_type_pkg.t_fin_rec
) is
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_impact                coM_api_type_pkg.t_sign;
begin
    l_split_hash := com_api_hash_pkg.get_split_hash(i_fin_rec.de002);

    if i_fin_rec.impact is null then
        l_impact :=
            mup_utl_pkg.get_message_impact(
                i_mti           => i_fin_rec.mti
              , i_de024         => i_fin_rec.de024
              , i_de003_1       => i_fin_rec.de003_1
              , i_is_reversal   => i_fin_rec.is_reversal
              , i_is_incoming   => i_fin_rec.is_incoming
            );
    else
        l_impact := i_fin_rec.impact;
    end if;

    insert into mup_fin (
          id
        , split_hash
        , inst_id
        , network_id
        , file_id
        , status
        , impact
        , is_incoming
        , is_reversal
        , is_rejected
        , is_fpd_matched
        , is_fsum_matched
        , dispute_id
        , dispute_rn
        , fpd_id
        , fsum_id
        , mti
        , de003_1
        , de003_2
        , de003_3
        , de004
        , de005
        , de006
        , de009
        , de010
        , de012
        , de014
        , de022_1
        , de022_2
        , de022_3
        , de022_4
        , de022_5
        , de022_6
        , de022_7
        , de022_8
        , de022_9
        , de022_10
        , de022_11
        , de023
        , de024
        , de025
        , de026
        , de030_1
        , de030_2
        , de031
        , de032
        , de033
        , de037
        , de038
        , de040
        , de041
        , de042
        , de043_1
        , de043_2
        , de043_3
        , de043_4
        , de043_5
        , de043_6
        , de049
        , de050
        , de051
        , de054
        , de055
        , de063
        , de071
        , de072
        , de073
        , de093
        , de094
        , de095
        , de100
        , p0025_1
        , p0025_2
        , p0137
        , p0146
        , p0146_net
        , p0148
        , p0149_1
        , p0149_2
        , p0165
        , p0176
        , p0190
        , p0198
        , p0228
        , p0261
        , p0262
        , p0265
        , p0266
        , p0267
        , p0268_1
        , p0268_2
        , p0375
        , p2002
        , p2063
        , p2072_1
        , p2072_2
        , p2158_1
        , p2158_2
        , p2158_3
        , p2158_4
        , p2158_5
        , p2158_6
        , p2159_1
        , p2159_2
        , p2159_3
        , p2159_4
        , p2159_5
        , p2159_6
        , p2097_1 
        , p2097_2 
        , p2175_1 
        , p2175_2 
        , emv_9f26
        , emv_9f27
        , emv_9f10
        , emv_9f37
        , emv_9f36
        , emv_95
        , emv_9a
        , emv_9c
        , emv_9f02
        , emv_5f2a
        , emv_82
        , emv_9f1a
        , emv_9f03
        , emv_9f34
        , emv_9f33
        , emv_9f35
        , emv_9f1e
        , emv_9f53
        , emv_84
        , emv_9f09
        , emv_9f41
        , emv_9f4c       
        , emv_91
        , emv_8a
        , emv_71
        , emv_72
        , is_collection
        , p2001_1 
        , p2001_2 
        , p2001_3 
        , p2001_4 
        , p2001_5 
        , p2001_6 
        , p2001_7 
    ) values (
        i_fin_rec.id
        , l_split_hash
        , i_fin_rec.inst_id
        , i_fin_rec.network_id
        , i_fin_rec.file_id
        , i_fin_rec.status
        , l_impact
        , i_fin_rec.is_incoming
        , i_fin_rec.is_reversal
        , i_fin_rec.is_rejected
        , i_fin_rec.is_fpd_matched
        , i_fin_rec.is_fsum_matched
        , i_fin_rec.dispute_id
        , i_fin_rec.dispute_rn
        , i_fin_rec.fpd_id
        , i_fin_rec.fsum_id
        , i_fin_rec.mti
        , i_fin_rec.de003_1
        , i_fin_rec.de003_2
        , i_fin_rec.de003_3
        , i_fin_rec.de004
        , i_fin_rec.de005
        , i_fin_rec.de006
        , i_fin_rec.de009
        , i_fin_rec.de010
        , i_fin_rec.de012
        , i_fin_rec.de014
        , i_fin_rec.de022_1
        , i_fin_rec.de022_2
        , i_fin_rec.de022_3
        , i_fin_rec.de022_4
        , i_fin_rec.de022_5
        , i_fin_rec.de022_6
        , i_fin_rec.de022_7
        , i_fin_rec.de022_8
        , i_fin_rec.de022_9
        , i_fin_rec.de022_10
        , i_fin_rec.de022_11
        , i_fin_rec.de023
        , i_fin_rec.de024
        , i_fin_rec.de025
        , i_fin_rec.de026
        , i_fin_rec.de030_1
        , i_fin_rec.de030_2
        , i_fin_rec.de031
        , i_fin_rec.de032
        , i_fin_rec.de033
        , i_fin_rec.de037
        , i_fin_rec.de038
        , i_fin_rec.de040
        , i_fin_rec.de041
        , i_fin_rec.de042
        , i_fin_rec.de043_1
        , i_fin_rec.de043_2
        , i_fin_rec.de043_3
        , i_fin_rec.de043_4
        , i_fin_rec.de043_5
        , i_fin_rec.de043_6
        , i_fin_rec.de049
        , i_fin_rec.de050
        , i_fin_rec.de051
        , i_fin_rec.de054
        , i_fin_rec.de055
        , i_fin_rec.de063
        , i_fin_rec.de071
        , i_fin_rec.de072
        , i_fin_rec.de073
        , i_fin_rec.de093
        , i_fin_rec.de094
        , i_fin_rec.de095
        , i_fin_rec.de100
        , i_fin_rec.p0025_1
        , i_fin_rec.p0025_2
        , i_fin_rec.p0137
        , i_fin_rec.p0146
        , i_fin_rec.p0146_net
        , i_fin_rec.p0148
        , i_fin_rec.p0149_1
        , i_fin_rec.p0149_2
        , i_fin_rec.p0165
        , i_fin_rec.p0176
        , i_fin_rec.p0190
        , i_fin_rec.p0198
        , i_fin_rec.p0228
        , i_fin_rec.p0261
        , i_fin_rec.p0262
        , i_fin_rec.p0265
        , i_fin_rec.p0266
        , i_fin_rec.p0267
        , i_fin_rec.p0268_1
        , i_fin_rec.p0268_2
        , i_fin_rec.p0375
        , i_fin_rec.p2002
        , i_fin_rec.p2063
        , i_fin_rec.p2072_1
        , i_fin_rec.p2072_2
        , i_fin_rec.p2158_1
        , i_fin_rec.p2158_2
        , i_fin_rec.p2158_3
        , i_fin_rec.p2158_4
        , i_fin_rec.p2158_5
        , i_fin_rec.p2158_6
        , i_fin_rec.p2159_1
        , i_fin_rec.p2159_2
        , i_fin_rec.p2159_3
        , i_fin_rec.p2159_4
        , i_fin_rec.p2159_5
        , i_fin_rec.p2159_6
        , i_fin_rec.p2097_1
        , i_fin_rec.p2097_2
        , i_fin_rec.p2175_1
        , i_fin_rec.p2175_2
        , i_fin_rec.emv_9f26
        , i_fin_rec.emv_9f27
        , i_fin_rec.emv_9f10
        , i_fin_rec.emv_9f37
        , i_fin_rec.emv_9f36
        , i_fin_rec.emv_95
        , i_fin_rec.emv_9a
        , i_fin_rec.emv_9c
        , i_fin_rec.emv_9f02
        , i_fin_rec.emv_5f2a
        , i_fin_rec.emv_82
        , i_fin_rec.emv_9f1a
        , i_fin_rec.emv_9f03
        , i_fin_rec.emv_9f34
        , i_fin_rec.emv_9f33
        , i_fin_rec.emv_9f35
        , i_fin_rec.emv_9f1e
        , i_fin_rec.emv_9f53
        , i_fin_rec.emv_84
        , i_fin_rec.emv_9f09
        , i_fin_rec.emv_9f41
        , i_fin_rec.emv_9f4c       
        , i_fin_rec.emv_91
        , i_fin_rec.emv_8a
        , i_fin_rec.emv_71
        , i_fin_rec.emv_72
        , i_fin_rec.is_collection
        , i_fin_rec.p2001_1
        , i_fin_rec.p2001_2
        , i_fin_rec.p2001_3
        , i_fin_rec.p2001_4
        , i_fin_rec.p2001_5
        , i_fin_rec.p2001_6
        , i_fin_rec.p2001_7
    );

    insert into mup_card (
        id
      , card_number
    ) values (
        i_fin_rec.id
      , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.de002)
    );
end put_message;

procedure get_emv_data(
    io_fin_rec              in out nocopy mup_api_type_pkg.t_fin_rec
  , i_mask_error            in            com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_emv_data              in            com_api_type_pkg.t_text
  , o_emv_tag_tab              out        com_api_type_pkg.t_tag_value_tab
) is
    l_data                  com_api_type_pkg.t_name;
    l_is_binary             com_api_type_pkg.t_boolean := emv_api_tag_pkg.is_binary();
begin
    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.get_emv_data: l_is_binary [' || l_is_binary
                                      || '], i_mask_error [' || i_mask_error
                                      || '], i_emv_data [' || i_emv_data || ']'
    );

    emv_api_tag_pkg.parse_emv_data(
        i_emv_data       => i_emv_data
      , i_is_binary      => l_is_binary
      , o_emv_tag_tab    => o_emv_tag_tab
    );

    io_fin_rec.emv_9f26 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F26' -- mandatory
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f02 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F02'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f27 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F27' -- mandatory
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f10 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F10'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f36 := emv_api_tag_pkg.get_tag_value(
        i_tag            => '9F36' -- mandatory
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_95 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '95'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_82 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '82' -- mandatory
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    l_data := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9A' -- mandatory
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    if l_data is not null and ltrim(l_data, '0') is not null then
        if substr(l_data, 5, 2) = '00' then
            io_fin_rec.emv_9a := to_date(substr(l_data, 1, 4)||'01', mup_api_const_pkg.DE073_DATE_FORMAT);
        else
            io_fin_rec.emv_9a := to_date(l_data, mup_api_const_pkg.DE073_DATE_FORMAT);
        end if;
    end if;
    io_fin_rec.emv_9c := emv_api_tag_pkg.get_tag_value(
        i_tag            => '9C' -- mandatory
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f37 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F37' -- mandatory
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_5f2a := emv_api_tag_pkg.get_tag_value (
        i_tag            => '5F2A' -- mandatory
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f33 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F33'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f34 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F34'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f1a := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F1A' -- mandatory
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f35 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F35'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );

    io_fin_rec.emv_9f53 := emv_api_tag_pkg.get_tag_value(
        i_tag            => '9F53'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f1e := emv_api_tag_pkg.get_tag_value(
        i_tag            => '9F1E'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );

    -- Some EMV tags should be ALWAYS stored in binary form, even when EMV data is a HEX-digit string
    if l_is_binary = com_api_const_pkg.TRUE then
        io_fin_rec.emv_9f53 := prs_api_util_pkg.hex2bin(i_hex_string => io_fin_rec.emv_9f53);
        io_fin_rec.emv_9f1e := prs_api_util_pkg.hex2bin(i_hex_string => io_fin_rec.emv_9f1e);
    end if;

    io_fin_rec.emv_84 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '84'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f09 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F09'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f03 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F03'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f41 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F41'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );

    io_fin_rec.emv_9f4c := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F4C'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => com_api_const_pkg.TRUE
    );

    io_fin_rec.emv_91 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '91'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => com_api_const_pkg.TRUE
    );

    io_fin_rec.emv_8a := emv_api_tag_pkg.get_tag_value (
        i_tag            => '8A'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => com_api_const_pkg.TRUE
    );

    io_fin_rec.emv_71 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '71'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => com_api_const_pkg.TRUE
    );

    io_fin_rec.emv_72 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '72'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => com_api_const_pkg.TRUE
    );

    -- check all mandatory tags for field C055
    if io_fin_rec.emv_9f02 is null then
        io_fin_rec.emv_9f26 := null;
        io_fin_rec.emv_9f27 := null;
        io_fin_rec.emv_9f10 := null;
        io_fin_rec.emv_9f36 := null;
        io_fin_rec.emv_95 := null;
        io_fin_rec.emv_82 := null;
        io_fin_rec.emv_9a := null;
        io_fin_rec.emv_9c := null;
        io_fin_rec.emv_9f37 := null;
        io_fin_rec.emv_5f2a := null;
        io_fin_rec.emv_9f33 := null;
        io_fin_rec.emv_9f34 := null;
        io_fin_rec.emv_9f1a := null;
        io_fin_rec.emv_9f35 := null;
        io_fin_rec.emv_9f53 := null;
        io_fin_rec.emv_84 := null;
        io_fin_rec.emv_9f09 := null;
        io_fin_rec.emv_9f03 := null;
        io_fin_rec.emv_9f1e := null;
        io_fin_rec.emv_9f41 := null;
        io_fin_rec.emv_9f4c := null;
        io_fin_rec.emv_91 := null;
        io_fin_rec.emv_8a := null;
        io_fin_rec.emv_71 := null;
        io_fin_rec.emv_72 := null;
    end if;

exception
    when others then -- removed EMV parsing when loading because it is not necessary
        trc_log_pkg.debug(
            i_text        => lower($$PLSQL_UNIT) || '.get_emv_data FAILED with [#1]; dumping o_emv_tag_tab...'
          , i_env_param1  => sqlerrm
        );
        emv_api_tag_pkg.dump_tag_table(
            i_emv_tag_tab    => o_emv_tag_tab
          , i_is_debug_only  => com_api_type_pkg.FALSE
        );
end get_emv_data;

function set_de054 (
    i_amount                in com_api_type_pkg.t_money
  , i_currency              in com_api_type_pkg.t_curr_code
  , i_type                  in com_api_type_pkg.t_dict_value
) return mup_api_type_pkg.t_de054 is
    l_result                mup_api_type_pkg.t_de054;
begin
    if i_amount > 0 then
        l_result := '00'
                  || i_type
                  || i_currency
                  || 'D'
                  || lpad(i_amount, 12, '0');
    end if;
    return l_result;
end set_de054;

procedure create_from_auth (
    i_auth_rec        in     aut_api_type_pkg.t_auth_rec
  , i_id              in     com_api_type_pkg.t_long_id
  , i_inst_id         in     com_api_type_pkg.t_inst_id    := null
  , i_network_id      in     com_api_type_pkg.t_tiny_id    := null
  , i_status          in     com_api_type_pkg.t_dict_value := null
  , i_collection_only in     com_api_type_pkg.t_boolean    := null
) is
    l_fin_rec                mup_api_type_pkg.t_fin_rec;
    l_stage                  varchar2(100);
    l_standard_id            com_api_type_pkg.t_tiny_id;
    l_host_id                com_api_type_pkg.t_tiny_id;
    l_acquirer_bin           com_api_type_pkg.t_rrn;
    l_param_tab              com_api_type_pkg.t_param_tab;
    l_emv_tag_tab            com_api_type_pkg.t_tag_value_tab;
    l_tag_id                 com_api_type_pkg.t_short_id;
    l_card_data_input_mode   com_api_type_pkg.t_dict_value;
    l_crdh_auth_method       com_api_type_pkg.t_dict_value;
    l_crdh_auth_entity       com_api_type_pkg.t_dict_value;
    l_current_version        com_api_type_pkg.t_tiny_id;
    l_standard_version_id    com_api_type_pkg.t_tiny_id;

    procedure correct_de22s(i_standard_version_id in com_api_type_pkg.t_tiny_id)
    is
        l_tag_value         com_api_type_pkg.t_text;
        l_is_chip_card      com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    begin
        if l_fin_rec.de022_1 in ('C', 'D', 'E', 'M', '5') then
            l_is_chip_card := com_api_type_pkg.TRUE;
        end if;

        -- de022_1
        l_fin_rec.de022_1 := case l_fin_rec.de022_1
                                when 'V' then '0'
                                when '5' then '4'
                                when 'M' then case when l_fin_rec.de022_4 in ('1', '3') then '9' else 'B' end
                                when 'D' then '5'
                                when 'B' then '7'
                                when 'C' then '8'
                                else l_fin_rec.de022_1
                             end;

        -- de022_2
        if l_fin_rec.de022_2 = '6' then
            l_fin_rec.de022_2 := '9';
        end if;            

        -- de022_3
        if l_fin_rec.de022_3 = '2' then
            if i_standard_version_id >= mup_api_const_pkg.MUP_STANDARD_VERSION_ID_19Q2 then
                l_fin_rec.de022_3 := '0';
            else
                l_fin_rec.de022_3 := '9';
            end if;
        end if;

        -- de022_4
        if i_standard_version_id >= mup_api_const_pkg.MUP_STANDARD_VERSION_ID_19Q2 then
            if l_fin_rec.de022_4 in ('1', '2') then
                l_fin_rec.de022_4 := '1';

            elsif l_fin_rec.de022_4 in ('3', '4', '5') then
                l_fin_rec.de022_4 := '2';

            elsif l_fin_rec.de022_4 in ('6', '7', '9', 'A', 'B', 'U') then
                l_fin_rec.de022_4 := '0';

            end if;
        
        else
            if l_fin_rec.de022_4 in ('1', '2', 'A') then
                l_fin_rec.de022_4 := '1';

            elsif l_fin_rec.de022_4 in ('B', '3', '4', '2') then
                l_fin_rec.de022_4 := '2';

            elsif l_fin_rec.de022_4 in ('5', '6', '9') then
                l_fin_rec.de022_4 := '9';

            elsif l_fin_rec.de022_4 in ('U') then
                l_fin_rec.de022_4 := '0';

            end if;
        end if;

        trc_log_pkg.debug('correct_de22s: old value l_fin_rec.de022_6 = ' || l_fin_rec.de022_6 );

        -- de022_6       
            l_tag_id    := aup_api_tag_pkg.find_tag_by_reference('DF8A71');
            l_tag_value := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

            trc_log_pkg.debug('correct_de22s: value of TAG DF8A71 = ' || l_tag_value);

            l_fin_rec.de022_6 := case
                                     when l_tag_value = 'C'             then '81'
                                     when l_card_data_input_mode = 'C'  then '05'
                                     when l_card_data_input_mode = 'M'  then '07'
                                     when l_card_data_input_mode = 'E'  then '10'
                                     when l_card_data_input_mode = 'W'  then '82'
                                     when l_card_data_input_mode = 'P'  
                                          and i_standard_version_id < mup_api_const_pkg.MUP_STANDARD_VERSION_ID_19Q2
                                     then '90'
                                     when l_card_data_input_mode = 'A'  then '91'
                                     when l_card_data_input_mode = 'F'  then 'F5'
                                     when l_card_data_input_mode = 'R'  then 'F7'

                                     when l_card_data_input_mode in ('S', '9', '5', '7')
                                     then '81'

                                     when l_card_data_input_mode = '1'
                                          or (l_fin_rec.de003_1 in ('27','28') and l_fin_rec.de022_5 = '1')
                                          or (l_fin_rec.de026   != '6538'      and l_fin_rec.de022_5 = '2')
                                     then '01'

                                     when l_card_data_input_mode in ('2', 'B')
                                     then case
                                              when l_is_chip_card = com_api_type_pkg.TRUE
                                              then '80'
                                              else '90'
                                          end

                                     else '01'
                                 end;

        trc_log_pkg.debug('correct_de22s: new value l_fin_rec.de022_6 = ' || l_fin_rec.de022_6 );

        -- de022_7
        case 
            when l_fin_rec.de022_6 in ('90', '91', '07') and l_fin_rec.de022_8 = '0' 
            then l_fin_rec.de022_7  := '7';
            when l_crdh_auth_method  = '3'                               -- Off-line PIN
            then l_fin_rec.de022_7  := '8';
            when l_crdh_auth_method  = '1' and l_crdh_auth_entity = '1'  -- Off-line PIN
            then l_fin_rec.de022_7  := '8';
            when l_crdh_auth_method  = '1' and l_crdh_auth_entity = '5'  -- On-line PIN
            then l_fin_rec.de022_7  := '1';          
            when l_crdh_auth_method  = '5' and l_crdh_auth_entity = '4'  -- Signature
            then l_fin_rec.de022_7  := '5';         
            when l_crdh_auth_method in ('Q', 'R', '9', 'S', 'W', 'X')
            then l_fin_rec.de022_7  := '0';
            else l_fin_rec.de022_7  := null;
        end case;
        l_fin_rec.de022_7 := nvl(l_fin_rec.de022_7, l_crdh_auth_method);

        -- de022_8
        if i_auth_rec.terminal_operating_env in ('F2240002', 'F2240004') then
            l_fin_rec.de022_8 := '2';

        elsif l_fin_rec.de022_8 in ('2') then
            l_fin_rec.de022_8 := '1';

        elsif l_fin_rec.de022_8 in ('8') then
            l_fin_rec.de022_8 := '2';

        elsif l_fin_rec.de022_8 in ('7') then
            l_fin_rec.de022_8 := '4';

        elsif l_fin_rec.de022_8 in ('4', '5', '6') then
            l_fin_rec.de022_8 := '5';
        end if;

        -- de022_9
        case
            when l_fin_rec.de022_9 in ('2','4') then
                case l_crdh_auth_method
                    when '1'
                    then l_fin_rec.de022_9 := '1';  -- CAT1 Authomated Dispensing Machine
                    else l_fin_rec.de022_9 := '2';  -- CAT2 Self-Service Terminal
                end case;
            when l_fin_rec.de022_9  = '0'
            then l_fin_rec.de022_9 := '0';          -- Not a CAT
            else l_fin_rec.de022_9 := '0';          -- Not a CAT
        end case;

        if i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then
            l_fin_rec.de022_9 := '0';
        end if;

        -- de022_10
        if l_fin_rec.de022_6 in ('81') then            
            
            l_fin_rec.de022_10 := 
            case 
                when l_crdh_auth_method in ('9', '0')   --E-commerce, non-secure
                    then '3'
                when l_crdh_auth_method in ('W', 'X')   --E-commerce, attempted
                    then '1'
                when l_crdh_auth_method in ('S')        --E-commerce, secure
                    then '2'
                else '3'         
            end;
        else
            l_fin_rec.de022_10 := '0';
        end if;

    end correct_de22s;

begin
    l_stage := 'start';
    l_current_version := 
        cmn_api_standard_pkg.get_current_version(
            i_network_id => nvl(i_network_id, i_auth_rec.iss_network_id)
        );

    if i_auth_rec.is_reversal = com_api_type_pkg.TRUE then
        flush_job;

        -- find presentment and make reversal
        get_fin (
            i_id          => i_auth_rec.original_id
          , o_fin_rec     => l_fin_rec
        );

        update mup_fin
           set status = case when status in (net_api_const_pkg.CLEARING_MSG_STATUS_READY)
                              and de004 = i_auth_rec.oper_amount
                             then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                             else status
                        end
         where rowid = l_fin_rec.row_id
     returning case when status in (net_api_const_pkg.CLEARING_MSG_STATUS_PENDING)
                      or i_auth_rec.oper_amount = 0
                    then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                    else nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY)
                     end
          into l_fin_rec.status;

        l_fin_rec.p0025_1 := mup_api_const_pkg.REVERSAL_PDS_REVERSAL;

        if l_current_version < mup_api_const_pkg.MUP_STANDARD_VERSION_ID_18Q4 then
            get_processing_date (
                i_id               => l_fin_rec.id
              , i_is_fpd_matched   => l_fin_rec.is_fpd_matched
              , i_is_fsum_matched  => l_fin_rec.is_fsum_matched
              , i_file_id          => l_fin_rec.file_id
              , o_p0025_2          => l_fin_rec.p0025_2
            );
        end if;

        l_fin_rec.is_incoming     := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal     := com_api_type_pkg.TRUE;
        l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
        l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
        l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
        l_fin_rec.file_id         := null;

        mup_utl_pkg.get_ipm_transaction_type (
            i_oper_type       => i_auth_rec.oper_type
          , i_mcc             => i_auth_rec.mcc
          , i_current_version => l_current_version
          , i_de022_5         => l_fin_rec.de022_5
          , o_de003_1         => l_fin_rec.de003_1
        );

        trc_log_pkg.debug('create_from_auth: l_fin_rec.de022_5=' || l_fin_rec.de022_5 || ', l_fin_rec.de003_1=' || l_fin_rec.de003_1);

        l_fin_rec.impact := mup_utl_pkg.get_message_impact (
            i_mti         => l_fin_rec.mti
          , i_de024       => l_fin_rec.de024
          , i_de003_1     => l_fin_rec.de003_1
          , i_is_reversal => l_fin_rec.is_reversal
          , i_is_incoming => l_fin_rec.is_incoming
        );

        l_stage           := 'de030';
        l_fin_rec.de030_1 := l_fin_rec.de004;
        l_fin_rec.de030_2 := 0;

        l_stage           := 'p0149';
        l_fin_rec.p0149_1 := l_fin_rec.de049;
        l_fin_rec.p0149_2 := 0;

        if l_current_version < mup_api_const_pkg.MUP_STANDARD_VERSION_ID_18Q4 then
            l_fin_rec.de004 := i_auth_rec.oper_amount;
            l_fin_rec.de049 := i_auth_rec.oper_currency;
        else
            if nvl(i_auth_rec.oper_amount, l_fin_rec.de004) > l_fin_rec.de004 then
                com_api_error_pkg.raise_error(
                    i_error         => 'MUP_ERROR_WRONG_VALUE'
                  , i_env_param1    => i_auth_rec.oper_amount  
                  , i_env_param2    => l_fin_rec.de004  
                ); 
            end if;
            l_fin_rec.de004 := nvl(i_auth_rec.oper_amount, l_fin_rec.de004);
            l_fin_rec.de049 := nvl(i_auth_rec.oper_currency, l_fin_rec.de049);
        end if;

        mup_utl_pkg.add_curr_exp (
            io_p0148        => l_fin_rec.p0148
          , i_curr_code     => l_fin_rec.p0149_1
        );
        mup_utl_pkg.add_curr_exp (
            io_p0148        => l_fin_rec.p0148
          , i_curr_code     => l_fin_rec.de049
        );

        l_fin_rec.p0375 := i_id;
        l_fin_rec.id    := i_id;

        l_fin_rec.de023 := null;

        l_stage := 'put';
        put_message (
            i_fin_rec  => l_fin_rec
        );

        l_stage := 'done';

    else
        mup_api_shared_data_pkg.collect_fin_message_params(
            io_params     => l_param_tab
          , i_is_incoming => com_api_const_pkg.FALSE
        );

        l_fin_rec.id              := i_id;
        l_fin_rec.status          := case when i_auth_rec.oper_amount = 0
                                         then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                                         else nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY)
                                     end;

        l_fin_rec.inst_id         := i_auth_rec.acq_inst_id;
        l_fin_rec.network_id      := i_auth_rec.iss_network_id;
        l_fin_rec.is_incoming     := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal     := i_auth_rec.is_reversal;
        l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
        l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
        l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;

        l_fin_rec.mti             := mup_api_const_pkg.MSG_TYPE_PRESENTMENT;
        l_fin_rec.de024           := mup_api_const_pkg.FUNC_CODE_FIRST_PRES;
        l_fin_rec.de026           := i_auth_rec.mcc;

        l_fin_rec.de022_5 :=
            case i_auth_rec.crdh_presence
                when 'F2250000' then '0'
                when 'F2250001' then '1'
                when 'F2250002' then '2'
                when 'F2250004' then '4'
                when 'F2250005' then '5'
                else null
            end;

        l_stage := 'de003';
        mup_utl_pkg.get_ipm_transaction_type (
            i_oper_type       => i_auth_rec.oper_type
          , i_mcc             => i_auth_rec.mcc
          , i_de022_5         => l_fin_rec.de022_5
          , i_current_version => l_current_version
          , o_de003_1         => l_fin_rec.de003_1
        );

        trc_log_pkg.debug('create_from_auth: l_fin_rec.de022_5=' || l_fin_rec.de022_5 || ', l_fin_rec.de003_1=' || l_fin_rec.de003_1);

        l_fin_rec.impact := mup_utl_pkg.get_message_impact (
            i_mti         => l_fin_rec.mti
          , i_de024       => l_fin_rec.de024
          , i_de003_1     => l_fin_rec.de003_1
          , i_is_reversal => l_fin_rec.is_reversal
          , i_is_incoming => l_fin_rec.is_incoming
        );

        l_stage := 'card';
        l_fin_rec.de002 := i_auth_rec.card_number;
        l_fin_rec.de003_2 := mup_api_const_pkg.DEFAULT_DE003_2;
        l_fin_rec.de003_3 := mup_api_const_pkg.DEFAULT_DE003_3;

        l_fin_rec.de004 := i_auth_rec.oper_amount;
        l_fin_rec.de012 := coalesce(i_auth_rec.host_date, i_auth_rec.oper_date);
        l_fin_rec.de014 := i_auth_rec.card_expir_date;

        l_stage := 'de022';
        --check!
        l_fin_rec.de022_1  := case i_auth_rec.card_data_input_cap
                                  when 'F2210000' then '0'
                                  when 'F2210001' then '1'
                                  when 'F2210002' then '2'
                                  when 'F2210003' then '3'
                                  when 'F2210004' then '4'
                                  when 'F2210005' then '5'
                                  when 'F2210006' then '6'
                                  when 'F221000A' then 'A'
                                  when 'F221000B' then 'B'
                                  when 'F221000C' then 'C'
                                  when 'F221000D' then 'D'
                                  when 'F221000E' then 'E'
                                  when 'F221000M' then 'M'
                                  when 'F221000S' then 'S'
                                  when 'F221000V' then 'V'
                                  else '0'
                              end;

        l_fin_rec.de022_2  := case i_auth_rec.crdh_auth_cap
                                  when 'F2220000' then '0'
                                  when 'F2220001' then '1'
                                  when 'F2220002' then '2'
                                  when 'F2220005' then '5'
                                  when 'F2220006' then '6'
                                  when 'F2220008' then '8'
                                  when 'F2220009' then '9'
                                  else '9'
                              end;

        l_fin_rec.de022_3  := case i_auth_rec.card_capture_cap
                                  when 'F2230000' then '0'
                                  when 'F2230001' then '1'
                                  when 'F2230002' then '2'
                                  else '2'
                              end;

        l_fin_rec.de022_4  := case i_auth_rec.terminal_operating_env
                                  when 'F2240000' then '0'
                                  when 'F2240001' then '1'
                                  when 'F2240002' then '2'
                                  when 'F2240003' then '3'
                                  when 'F2240004' then '4'
                                  when 'F2240005' then '5'
                                  when 'F2240006' then '6'
                                  when 'F2240007' then '7'
                                  when 'F2240009' then '9'
                                  when 'F224000A' then 'A'
                                  when 'F224000B' then 'B'
                                  when 'F224000U' then 'U'
                                  else '9'
                              end;

        l_fin_rec.de022_8  := case i_auth_rec.terminal_type
                                  when 'TRMT0000' then '0'
                                  when 'TRMT0001' then '1'
                                  when 'TRMT0002' then '2'
                                  when 'TRMT0003' then '3'
                                  when 'TRMT0004' then '4'
                                  when 'TRMT0005' then '5'
                                  when 'TRMT0006' then '6'
                                  when 'TRMT0007' then '7'
                                  when 'TRMT0008' then '8'
                                  when 'TRMT0009' then '9'
                                  else '0'
                              end;

        l_fin_rec.de022_9  := case i_auth_rec.terminal_operating_env
                                  when 'F2240000' then '0'
                                  when 'F2240001' then '1'
                                  when 'F2240002' then '2'
                                  when 'F2240003' then '3'
                                  when 'F2240004' then '4'
                                  when 'F2240005' then '5'
                                  when 'F2240006' then '6'
                                  when 'F2240007' then '7'
                                  when 'F2240009' then '9'
                                  when 'F224000A' then 'A'
                                  when 'F224000B' then 'B'
                                  when 'F224000U' then 'U'
                                  else '9'
                              end;

        l_fin_rec.de022_11 := case i_auth_rec.pin_capture_cap
                                  when 'F22C000A' then 'A'
                                  when 'F22C000B' then 'B'
                                  when 'F22C000C' then 'C'
                                  when 'F22C000S' then 'S'
                                  when 'F22C0000' then '0'
                                  when 'F22C0001' then '1'
                                  when 'F22C0002' then '2'
                                  when 'F22C0003' then '3'
                                  when 'F22C0004' then '4'
                                  when 'F22C0005' then '5'
                                  when 'F22C0006' then '6'
                                  when 'F22C0007' then '7'
                                  when 'F22C0008' then '8'
                                  when 'F22C0009' then '9'
                                  else '1'
                              end;

        --e-commerce indicator
--        l_ucaf             := substr(i_auth_rec.addl_data, 203, 1);  

        l_card_data_input_mode := case i_auth_rec.card_data_input_mode
                                      when 'F2270000' then '0'
                                      when 'F2270001' then '1'
                                      when 'F2270002' then '2'
                                      when 'F2270003' then '3'
                                      when 'F2270005' then '5'
                                      when 'F2270006' then '6'
                                      when 'F2270007' then '7'
                                      when 'F2270008' then '8'
                                      when 'F2270009' then '9'
                                      when 'F227000A' then 'A'
                                      when 'F227000B' then 'B'
                                      when 'F227000C' then 'C'
                                      when 'F227000D' then 'D'
                                      when 'F227000E' then 'E'
                                      when 'F227000F' then 'F'
                                      when 'F227000M' then 'M'
                                      when 'F227000N' then 'N'
                                      when 'F227000P' then 'P'
                                      when 'F227000R' then 'R'
                                      when 'F227000S' then 'S'
                                      when 'F227000W' then 'W'
                                      else '0'
                                  end;

        l_crdh_auth_method     := case i_auth_rec.crdh_auth_method
                                      when 'F2280000' then '0'
                                      when 'F2280001' then '1'
                                      when 'F2280002' then '2'
                                      when 'F2280005' then '5'
                                      when 'F2280006' then '6'
                                      when 'F2280009' then '9'
                                      when 'F228000S' then 'S'
                                      when 'F228000W' then 'W'
                                      when 'F228000X' then 'X'
                                      else '9'
                                  end;

        l_crdh_auth_entity     := case i_auth_rec.crdh_auth_entity
                                      when 'F2290000' then '0'
                                      when 'F2290001' then '1'
                                      when 'F2290002' then '2'
                                      when 'F2290003' then '3'
                                      when 'F2290004' then '4'
                                      when 'F2290005' then '5'
                                      when 'F2290006' then '6'
                                      when 'F2290009' then '9'
                                      else '9'
                                  end;

        l_host_id := net_api_network_pkg.get_member_id(
            i_inst_id     => nvl(i_inst_id, i_auth_rec.iss_inst_id)
          , i_network_id  => nvl(i_network_id, i_auth_rec.iss_network_id)
        );

        l_standard_id := net_api_network_pkg.get_offline_standard(
            i_host_id       => l_host_id
        );
        l_standard_version_id := cmn_api_standard_pkg.get_current_version(
                                     i_network_id => nvl(i_network_id, i_auth_rec.iss_network_id)
                                 );
        
        correct_de22s(i_standard_version_id => l_standard_version_id);

        l_stage := 'de038';
        if i_auth_rec.network_refnum is null
           or l_fin_rec.de022_6 in ('F5', 'F7')
           or i_auth_rec.oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND
        then
            l_fin_rec.de038 := null;
        else
            l_fin_rec.de038 := i_auth_rec.auth_code;
        end if;

        l_stage := 'de031';
        l_acquirer_bin := nvl(
            cmn_api_standard_pkg.get_varchar_value (
                i_inst_id     => l_fin_rec.inst_id
              , i_standard_id => l_standard_id
              , i_object_id   => l_host_id
              , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name  => mup_api_const_pkg.ACQUIRER_BIN
              , i_param_tab   => l_param_tab
            )
          , i_auth_rec.acq_inst_bin
        );

        if l_fin_rec.de003_1 in (
                   mup_api_const_pkg.PROC_CODE_P2P_CREDIT -- '26'
                 , mup_api_const_pkg.PROC_CODE_CASH_IN    -- '27'
                 , mup_api_const_pkg.PROC_CODE_PAYMENT    -- '28'
               )
        then
            l_fin_rec.de031 := 
                get_card_replenishment_arn(
                    i_acquirer_bin  => l_acquirer_bin 
                  , i_oper_date     => i_auth_rec.oper_date
                  , i_de037         => i_auth_rec.originator_refnum -- value of l_fin_rec.de037 will be filled later
                );
        else      
           
            l_fin_rec.de031 := acq_api_merchant_pkg.get_arn(
                i_acquirer_bin => l_acquirer_bin
            );
        end if;

        l_stage := 'de032';
        l_fin_rec.de032 := l_acquirer_bin;

        l_stage := 'de033';
        rul_api_shared_data_pkg.load_oper_params(
            i_oper_id    => i_auth_rec.id
            , io_params  => l_param_tab
        );

        l_fin_rec.de033 := cmn_api_standard_pkg.get_varchar_value (
            i_inst_id     => l_fin_rec.inst_id
          , i_standard_id => l_standard_id
          , i_object_id   => l_host_id
          , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name  => mup_api_const_pkg.FORW_INST_ID
          , i_param_tab   => l_param_tab
        );

        l_fin_rec.de094 := cmn_api_standard_pkg.get_varchar_value (
            i_inst_id     => l_fin_rec.inst_id
          , i_standard_id => l_standard_id
          , i_object_id   => l_host_id
          , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name  => mup_api_const_pkg.CMID
          , i_param_tab   => l_param_tab
        );

        l_fin_rec.de032 := l_fin_rec.de094;

        l_stage := 'de037';
        if i_auth_rec.oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND then
            l_fin_rec.de037 := null;
        else
            l_fin_rec.de037 := i_auth_rec.originator_refnum;
        end if;
        l_fin_rec.de040 := i_auth_rec.card_service_code;

        l_stage := 'de041';
        l_fin_rec.de041 := 
            case when length(i_auth_rec.terminal_number) >= 8 
               then substr(i_auth_rec.terminal_number, -8) 
               else i_auth_rec.terminal_number
            end;
        l_fin_rec.de042   := i_auth_rec.merchant_number;
        l_fin_rec.de043_1 := i_auth_rec.merchant_name;
        l_fin_rec.de043_2 := i_auth_rec.merchant_street;
        l_fin_rec.de043_3 := i_auth_rec.merchant_city;
        l_fin_rec.de043_4 := i_auth_rec.merchant_postcode;
        l_fin_rec.de043_6 := com_api_country_pkg.get_country_name(i_code => i_auth_rec.merchant_country);--i_auth_rec.merchant_region;
        l_fin_rec.de043_5 := l_fin_rec.de043_6;

        l_stage := 'de049';
        l_fin_rec.de049 := i_auth_rec.oper_currency;
        mup_utl_pkg.add_curr_exp (
            io_p0148        => l_fin_rec.p0148,
            i_curr_code     => l_fin_rec.de049
        );

        l_fin_rec.de054 :=
        case l_fin_rec.de003_1
        when mup_api_const_pkg.PROC_CODE_ATM then
            set_de054 (
                i_amount      => i_auth_rec.oper_surcharge_amount
                , i_currency  => i_auth_rec.oper_currency
                , i_type      => '42'
            )
        else
            null
        end;

        l_stage := 'de063';
        if i_auth_rec.oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND then
            l_fin_rec.de063 := null;
        else
            l_fin_rec.de063 := mup_utl_pkg.build_nrn(
                i_netw_refnum  =>  i_auth_rec.network_refnum
            );
        end if;

        l_stage := 'p0025';
        l_fin_rec.p0025_1   := null;
        l_fin_rec.p0025_2   := null;
        l_fin_rec.p0146     := null;
        l_fin_rec.p0149_1   := null;
        l_fin_rec.p0149_2   := null;

        l_stage := 'p0165';
        if nvl(i_collection_only, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
            if i_auth_rec.sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS then
                l_fin_rec.p0165  := mup_api_const_pkg.SETTLEMENT_TYPE_COLLECT_ON_US;
            else
                l_fin_rec.p0165  := mup_api_const_pkg.SETTLEMENT_TYPE_COLLECTION;
            end if;
            l_fin_rec.de093      := l_fin_rec.de094;
            l_fin_rec.network_id := nvl(i_network_id, l_fin_rec.network_id);
        else
            l_fin_rec.p0165 := mup_api_const_pkg.SETTLEMENT_TYPE_MUP;
        end if;

        l_stage := 'p0176';
        l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8A2B');
        l_fin_rec.p0176 := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

        l_stage := 'p0190';
        l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8A2A');
        l_fin_rec.p0190 := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

        l_stage := 'p2158_1';
        l_fin_rec.p2158_1 := mup_utl_pkg.get_p2158_1(
            i_iss_network_id  => l_fin_rec.network_id
        );

        l_fin_rec.p0198 := '00';

        l_stage := 'emv';
        if  l_fin_rec.de022_1 in ('3', '4', '5', '8', '9', 'A', 'B') and
            l_fin_rec.de022_6 in ('05', '07', 'F5', 'F7')
        then
            get_emv_data(
                io_fin_rec    => l_fin_rec
              , i_mask_error  => com_api_type_pkg.TRUE
              , i_emv_data    => i_auth_rec.emv_data
              , o_emv_tag_tab => l_emv_tag_tab
            );

            l_fin_rec.de055 := hextoraw(
                                   emv_api_tag_pkg.format_emv_data(
                                       io_emv_tag_tab => l_emv_tag_tab
                                     , i_tag_type_tab => mup_api_const_pkg.EMV_TAGS_LIST_FOR_DE055
                                   )
                               );
        end if;

        l_stage := 'p0375';
        l_fin_rec.p0375 := l_fin_rec.id;

        l_stage := 'de023';
        if l_fin_rec.de055 is not null then
            l_fin_rec.de023 := i_auth_rec.card_seq_number;
        end if;

        if i_auth_rec.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT and i_auth_rec.mcc = '6538' then
            l_tag_id           := aup_api_tag_pkg.find_tag_by_reference('DF8A1B');
            l_fin_rec.p2002    := aup_api_tag_pkg.get_tag_value(
                                      i_auth_id => i_auth_rec.id
                                    , i_tag_id  => l_tag_id
                                  );
        end if;

        if i_auth_rec.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT and i_auth_rec.mcc = '6536' then
            l_tag_id           := aup_api_tag_pkg.find_tag_by_reference('DF862F');
            l_fin_rec.p2063    := substr(aup_api_tag_pkg.get_tag_value(
                                      i_auth_id => i_auth_rec.id
                                    , i_tag_id  => l_tag_id
                                  ), 5, 16);
        end if;

            l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8A75');

            if l_fin_rec.de003_1 in (
                   mup_api_const_pkg.PROC_CODE_P2P_CREDIT -- '26'
                 , mup_api_const_pkg.PROC_CODE_CASH_IN    -- '27'
                 , mup_api_const_pkg.PROC_CODE_PAYMENT    -- '28'
               )
             and aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id) = '1'
            then
                l_fin_rec.status := mup_api_const_pkg.MSG_STATUS_DO_NOT_UNLOAD;
                l_fin_rec.p0375  := l_fin_rec.de031; -- replace ID in p0375 by ARN value
            end if;

        if l_current_version >= mup_api_const_pkg.MUP_STANDARD_VERSION_ID_18Q4 then
            l_stage := 'is_collection';
            if i_collection_only = com_api_const_pkg.TRUE then
                l_fin_rec.is_collection := com_api_const_pkg.TRUE;
            else
                l_fin_rec.is_collection := com_api_const_pkg.FALSE;
        end if;
        end if;

        l_stage := 'put';
        put_message (
            i_fin_rec   => l_fin_rec
        );

        l_stage := 'done';
    end if;
exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating IPM presentment on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end create_from_auth;

procedure set_message (
    i_mes_rec     in            mup_api_type_pkg.t_mes_rec
  , io_fin_rec    in out nocopy mup_api_type_pkg.t_fin_rec
  , io_pds_tab    in out nocopy mup_api_type_pkg.t_pds_tab
  , i_network_id  in            com_api_type_pkg.t_tiny_id
  , i_host_id     in            com_api_type_pkg.t_tiny_id
  , i_standard_id in            com_api_type_pkg.t_tiny_id
  , i_financial   in            com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
) is
    l_pds_body                  mup_api_type_pkg.t_pds_body;
    l_card_network_id           com_api_type_pkg.t_tiny_id;
    l_card_type                 com_api_type_pkg.t_tiny_id;
    l_card_country              com_api_type_pkg.t_curr_code;
    l_emv_tag_tab               com_api_type_pkg.t_tag_value_tab;
    l_stage                     varchar2(100);
    l_standard_version_id       com_api_type_pkg.t_tiny_id;
begin

    l_standard_version_id :=
        cmn_api_standard_pkg.get_current_version(
            i_standard_id  => i_standard_id 
          , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id    => i_host_id
          , i_eff_date     => com_api_sttl_day_pkg.get_sysdate()
        );

    l_stage := 'de026';
    io_fin_rec.de026 := i_mes_rec.de026;

    l_stage := 'de003';
    io_fin_rec.de003_1 := i_mes_rec.de003_1;
    io_fin_rec.de003_2 := i_mes_rec.de003_2;
    io_fin_rec.de003_3 := i_mes_rec.de003_3;

    l_stage := 'extract_pds';
    mup_api_pds_pkg.extract_pds (
        de048     => i_mes_rec.de048
      , de062     => i_mes_rec.de062
      , de123     => i_mes_rec.de123
      , de124     => i_mes_rec.de124
      , de125     => i_mes_rec.de125
      , pds_tab   => io_pds_tab
    );
    l_stage := 'p0025';
    l_pds_body := mup_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
      , i_pds_tag   => mup_api_const_pkg.PDS_TAG_0025
    );
    l_stage := 'parse_p0025';
    mup_api_pds_pkg.parse_p0025 (
        i_p0025     => l_pds_body
      , o_p0025_1   => io_fin_rec.p0025_1
      , o_p0025_2   => io_fin_rec.p0025_2
    );

    l_stage := 'is_reversal';
    if substr(io_fin_rec.p0025_1, 1, 1) = mup_api_const_pkg.REVERSAL_PDS_REVERSAL then
        io_fin_rec.is_reversal := com_api_type_pkg.TRUE;
    elsif substr(io_fin_rec.p0025_1, 1, 1) is null then
        io_fin_rec.is_reversal := com_api_type_pkg.FALSE;
    else
        com_api_error_pkg.raise_error(
            i_error       => 'MUP_ERROR_WRONG_VALUE'
          , i_env_param1  => 'P0025_1'
          , i_env_param2  => 1
          , i_env_param3  => io_fin_rec.p0025_1
        );
    end if;

    if i_financial = com_api_type_pkg.TRUE then
        io_fin_rec.impact := mup_utl_pkg.get_message_impact (
            i_mti          => io_fin_rec.mti
          , i_de024        => io_fin_rec.de024
          , i_de003_1      => io_fin_rec.de003_1
          , i_is_reversal  => io_fin_rec.is_reversal
          , i_is_incoming  => io_fin_rec.is_incoming
        );
    end if;

    l_stage := 'card';
    io_fin_rec.de002    := i_mes_rec.de002;
    io_fin_rec.de004    := i_mes_rec.de004;
    io_fin_rec.de012    := i_mes_rec.de012;
    io_fin_rec.de014    := last_day(i_mes_rec.de014);

    l_stage := 'de005 - de010';
    io_fin_rec.de005    := i_mes_rec.de005;
    io_fin_rec.de006    := i_mes_rec.de006;
    io_fin_rec.de009    := i_mes_rec.de009;
    io_fin_rec.de010    := i_mes_rec.de010;

    l_stage := 'de022';
    io_fin_rec.de022_1  := i_mes_rec.de022_1;
    io_fin_rec.de022_2  := i_mes_rec.de022_2;
    io_fin_rec.de022_3  := i_mes_rec.de022_3;
    io_fin_rec.de022_4  := i_mes_rec.de022_4;
    io_fin_rec.de022_5  := i_mes_rec.de022_5;
    io_fin_rec.de022_6  := i_mes_rec.de022_6;
    io_fin_rec.de022_7  := i_mes_rec.de022_7;
    io_fin_rec.de022_8  := i_mes_rec.de022_8;
    io_fin_rec.de022_9  := i_mes_rec.de022_9;
    io_fin_rec.de022_10 := i_mes_rec.de022_10;
    io_fin_rec.de022_11 := i_mes_rec.de022_11;

    l_stage := 'de023, de025, de026';
    io_fin_rec.de023    := i_mes_rec.de023;
    io_fin_rec.de025    := i_mes_rec.de025;
    io_fin_rec.de026    := i_mes_rec.de026;

    l_stage := 'de030';
    io_fin_rec.de030_1  := i_mes_rec.de030_1;
    io_fin_rec.de030_2  := i_mes_rec.de030_2;

    l_stage := 'de031 - de042';
    io_fin_rec.de031    := i_mes_rec.de031;
    io_fin_rec.de032    := i_mes_rec.de032;
    io_fin_rec.de033    := i_mes_rec.de033;
    io_fin_rec.de037    := i_mes_rec.de037;
    io_fin_rec.de038    := i_mes_rec.de038;
    io_fin_rec.de040    := i_mes_rec.de040;
    io_fin_rec.de041    := i_mes_rec.de041;
    io_fin_rec.de042    := i_mes_rec.de042;

    l_stage := 'de043';
    io_fin_rec.de043_1  := i_mes_rec.de043_1;
    io_fin_rec.de043_2  := i_mes_rec.de043_2;
    io_fin_rec.de043_3  := i_mes_rec.de043_3;
    io_fin_rec.de043_4  := i_mes_rec.de043_4;
    io_fin_rec.de043_5  := i_mes_rec.de043_5;
    io_fin_rec.de043_6  := i_mes_rec.de043_6;

    l_stage := 'de049';
    io_fin_rec.de049    := i_mes_rec.de049;
    l_stage := 'de050';
    io_fin_rec.de050    := i_mes_rec.de050;
    l_stage := 'de051';
    io_fin_rec.de051    := i_mes_rec.de051;

    l_stage := 'de054';
    io_fin_rec.de054    := i_mes_rec.de054;

    l_stage := 'de055';
    io_fin_rec.de055    := i_mes_rec.de055;
    if io_fin_rec.de055 is not null then
        get_emv_data(
            io_fin_rec    => io_fin_rec
          , i_mask_error  => com_api_type_pkg.TRUE
          , i_emv_data    => rawtohex(io_fin_rec.de055)
          , o_emv_tag_tab => l_emv_tag_tab
        );
    end if;

    l_stage := 'de063';
    io_fin_rec.de063 := i_mes_rec.de063;

    l_stage := 'p0005 - p0137';
    io_fin_rec.p0137 := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0137
    );

    l_stage := 'p0146';
    io_fin_rec.p0146 := mup_api_pds_pkg.get_pds_body(
                            i_pds_tab => io_pds_tab
                          , i_pds_tag => mup_api_const_pkg.PDS_TAG_0146
                        );

    if io_fin_rec.p0146 is not null then
        mup_api_pds_pkg.parse_p0146(
            i_pds_body  => io_fin_rec.p0146
          , o_p0146     => l_pds_body -- is not used
          , o_p0146_net => io_fin_rec.p0146_net
        );
    end if;

    l_stage := 'p0148';
    io_fin_rec.p0148 := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0148
    );

    l_stage := 'p0149';
    l_pds_body := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0149
    );
    mup_api_pds_pkg.parse_p0149 (
        i_p0149         => l_pds_body
      , o_p0149_1       => io_fin_rec.p0149_1
      , o_p0149_2       => io_fin_rec.p0149_2
    );

    l_stage := 'p0165';
    io_fin_rec.p0165 := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0165
    );

    l_stage := 'p0176';
    io_fin_rec.p0176 := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0176
    );

    l_stage := 'p0190';
    io_fin_rec.p0190 := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0190
    );

    l_stage := 'p0198';
    io_fin_rec.p0198 := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0198
    );

    l_stage := 'p0228';
    io_fin_rec.p0228 := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0228
    );

    l_stage := 'p0262';
    io_fin_rec.p0262 := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0262
    );

    l_stage := 'p0265';
    io_fin_rec.p0265 := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0265
    );

    l_stage := 'p0266';
    io_fin_rec.p0266 := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0266
    );

    l_stage := 'p0267';
    io_fin_rec.p0267 := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0267
    );

    l_stage := 'p0268';
    l_pds_body := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0268
    );
    mup_api_pds_pkg.parse_p0268(
        i_p0268         => l_pds_body
      , o_p0268_1       => io_fin_rec.p0268_1
      , o_p0268_2       => io_fin_rec.p0268_2
    );

    l_stage := 'p0375';
    io_fin_rec.p0375 := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0375
    );

    l_stage := 'de071';
    io_fin_rec.de071 := i_mes_rec.de071;
    l_stage := 'de072';
    io_fin_rec.de072 := i_mes_rec.de072;

    l_stage := 'de073';
    io_fin_rec.de073 := i_mes_rec.de073;

    l_stage := 'de093';
    io_fin_rec.de093 := i_mes_rec.de093;
    l_stage := 'de094';
    io_fin_rec.de094 := i_mes_rec.de094;
    l_stage := 'de095';
    io_fin_rec.de095 := i_mes_rec.de095;
    l_stage := 'de100';
    io_fin_rec.de100 := i_mes_rec.de100;

    l_stage := '2002';
    io_fin_rec.p2002 := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_2002
    );

    l_stage := '2063';
    io_fin_rec.p2063 := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_2063
    );

    l_stage := 'p2158';
    l_pds_body := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_2158
    );
    mup_api_pds_pkg.parse_p2158(
        i_p2158           => l_pds_body
      , o_p2158_1         => io_fin_rec.p2158_1
      , o_p2158_2         => io_fin_rec.p2158_2
      , o_p2158_3         => io_fin_rec.p2158_3
      , o_p2158_4         => io_fin_rec.p2158_4
      , o_p2158_5         => io_fin_rec.p2158_5
      , o_p2158_6         => io_fin_rec.p2158_6
    );

    l_stage := 'p2159';
    l_pds_body := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_2159
    );
    mup_api_pds_pkg.parse_p2159(
        i_p2159           => l_pds_body
      , o_p2159_1         => io_fin_rec.p2159_1
      , o_p2159_2         => io_fin_rec.p2159_2
      , o_p2159_3         => io_fin_rec.p2159_3
      , o_p2159_4         => io_fin_rec.p2159_4
      , o_p2159_5         => io_fin_rec.p2159_5
      , o_p2159_6         => io_fin_rec.p2159_6
    );

    l_stage := 'p2072';
    l_pds_body := mup_api_pds_pkg.get_pds_body (
        i_pds_tab       => io_pds_tab
      , i_pds_tag       => mup_api_const_pkg.PDS_TAG_2072
    );
    mup_api_pds_pkg.parse_p2072(
        i_p2072           => l_pds_body
      , o_p2072_1         => io_fin_rec.p2072_1
      , o_p2072_2         => io_fin_rec.p2072_2
    );

        l_stage := 'p2175';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab       => io_pds_tab
          , i_pds_tag       => mup_api_const_pkg.PDS_TAG_2175
        );
        mup_api_pds_pkg.parse_p2175(
            i_p2175         => l_pds_body
          , o_p2175_1       => io_fin_rec.p2175_1
          , o_p2175_2       => io_fin_rec.p2175_2
      , i_standard_version_id => l_standard_version_id
        );

    if l_standard_version_id >= mup_api_const_pkg.MUP_STANDARD_VERSION_ID_18Q4 then
        l_stage := 'p2097';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab       => io_pds_tab
          , i_pds_tag       => mup_api_const_pkg.PDS_TAG_2097
        );
        mup_api_pds_pkg.parse_p2097(
            i_p2097               => l_pds_body
          , o_p2097_1             => io_fin_rec.p2097_1
          , o_p2097_2             => io_fin_rec.p2097_2
          , i_standard_version_id => l_standard_version_id
        );

        l_stage := 'p2001';
        l_pds_body := mup_api_pds_pkg.get_pds_body (
            i_pds_tab       => io_pds_tab
          , i_pds_tag       => mup_api_const_pkg.PDS_TAG_2001
        );
        mup_api_pds_pkg.parse_p2001(
            i_p2001           => l_pds_body
          , o_p2001_1         => io_fin_rec.p2001_1
          , o_p2001_2         => io_fin_rec.p2001_2
          , o_p2001_3         => io_fin_rec.p2001_3
          , o_p2001_4         => io_fin_rec.p2001_4
          , o_p2001_5         => io_fin_rec.p2001_5
          , o_p2001_6         => io_fin_rec.p2001_6
          , o_p2001_7         => io_fin_rec.p2001_7
        );
    end if;

    -- determine internal institution number
    iss_api_bin_pkg.get_bin_info(
        i_card_number      => io_fin_rec.de002
      , o_card_inst_id     => io_fin_rec.inst_id
      , o_card_network_id  => l_card_network_id
      , o_card_type        => l_card_type
      , o_card_country     => l_card_country
      , i_raise_error      => com_api_const_pkg.FALSE
    );

    if io_fin_rec.inst_id is null then
        io_fin_rec.inst_id := cmn_api_standard_pkg.find_value_owner(
                                  i_standard_id  => i_standard_id
                                , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                                , i_object_id    => i_host_id
                                , i_param_name   => mup_api_const_pkg.CMID
                                , i_value_char   => io_fin_rec.de093
                              );
    end if;

    if io_fin_rec.inst_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'MUP_CMID_NOT_REGISTRED'
          , i_env_param1  => io_fin_rec.de093
          , i_env_param2  => i_network_id
        );
    end if;
exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating IPM first presentment on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end set_message;

function get_status(
    i_network_id          in com_api_type_pkg.t_tiny_id
  , i_host_id             in com_api_type_pkg.t_tiny_id
  , i_standard_id         in com_api_type_pkg.t_tiny_id
  , i_inst_id             in com_api_type_pkg.t_inst_id
) return  com_api_type_pkg.t_dict_value
is
    l_param_tab                     com_api_type_pkg.t_param_tab;
    l_reconciliation_mode           mup_api_type_pkg.t_pds_body;
begin
    l_reconciliation_mode := nvl(
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => i_inst_id
          , i_standard_id => i_standard_id
          , i_object_id   => i_host_id
          , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name  => mup_api_const_pkg.RECONCILIATION_MODE
          , i_param_tab   => l_param_tab
        )
      , mup_api_const_pkg.RECONCILIATION_MODE_FULL
    );

    return
        case when l_reconciliation_mode = mup_api_const_pkg.RECONCILIATION_MODE_FULL
             then opr_api_const_pkg.OPERATION_STATUS_WAIT_SETTL
             else null
        end;
end get_status;

procedure create_incoming_adjustment(
    i_mes_rec            in     mup_api_type_pkg.t_mes_rec
  , i_file_id            in     com_api_type_pkg.t_short_id
  , i_incom_sess_file_id in     com_api_type_pkg.t_long_id
  , o_fin_ref_id            out com_api_type_pkg.t_long_id
  , i_network_id         in     com_api_type_pkg.t_tiny_id
  , i_host_id            in     com_api_type_pkg.t_tiny_id
  , i_standard_id        in     com_api_type_pkg.t_tiny_id
  , i_local_message      in     com_api_type_pkg.t_boolean
  , i_create_operation   in     com_api_type_pkg.t_boolean := null
  , i_need_repeat        in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               mup_api_type_pkg.t_fin_rec;
    l_pds_tab               mup_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;

    l_stage                 varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Processing incoming adjustment'
    );

    o_fin_ref_id := null;

    -- init
    l_fin_rec.id              := opr_api_create_pkg.get_id;
    l_fin_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id      := i_network_id;
    l_fin_rec.is_incoming     := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
    l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
    l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
    l_fin_rec.file_id         := i_file_id;

    l_stage := 'mti & de024';
    l_fin_rec.mti   := i_mes_rec.mti;
    l_fin_rec.de024 := i_mes_rec.de024;

    -- set message
    set_message (
        i_mes_rec      => i_mes_rec
      , io_fin_rec     => l_fin_rec
      , io_pds_tab     => l_pds_tab
      , i_network_id   => i_network_id
      , i_host_id      => i_host_id
      , i_standard_id  => i_standard_id
    );

    mup_api_dispute_pkg.assign_dispute_id (
        io_fin_rec    => l_fin_rec
      , o_auth        => l_auth
      , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    mup_api_pds_pkg.save_pds (
        i_msg_id   => l_fin_rec.id
      , i_pds_tab  => l_pds_tab
    );

    o_fin_ref_id := l_fin_rec.id;

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        create_operation (
            i_fin_rec             => l_fin_rec
          , i_standard_id         => i_standard_id
          , i_auth                => l_auth
          , i_status              => get_status (
                                         i_network_id  => i_network_id
                                       , i_host_id     => i_host_id
                                       , i_standard_id => i_standard_id
                                       , i_inst_id     => l_fin_rec.inst_id
                                     )
          , i_incom_sess_file_id  => i_incom_sess_file_id
          , i_host_id             => i_host_id
        );
    end if;

    trc_log_pkg.debug (
        i_text       => 'Incoming adjustment processed. Assigned id[#1]'
      , i_env_param1 => l_fin_rec.id
    );

exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating IPM adjustment on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end create_incoming_adjustment;

procedure create_incoming_first_pres (
    i_mes_rec               in mup_api_type_pkg.t_mes_rec
  , i_file_id               in com_api_type_pkg.t_short_id
  , i_incom_sess_file_id    in com_api_type_pkg.t_long_id
  , o_fin_ref_id           out com_api_type_pkg.t_long_id
  , i_network_id            in com_api_type_pkg.t_tiny_id
  , i_host_id               in com_api_type_pkg.t_tiny_id
  , i_standard_id           in com_api_type_pkg.t_tiny_id
  , i_local_message         in com_api_type_pkg.t_boolean
  , i_create_operation      in com_api_type_pkg.t_boolean := null
  , i_need_repeat           in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               mup_api_type_pkg.t_fin_rec;
    l_pds_tab               mup_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;

    l_stage                 varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Processing first presentment'
    );

    o_fin_ref_id := null;

    -- init
    l_fin_rec.id              := opr_api_create_pkg.get_id;
    l_fin_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id      := i_network_id;
    l_fin_rec.is_incoming     := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
    l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
    l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
    l_fin_rec.file_id         := i_file_id;

    l_stage := 'mti & de024';
    l_fin_rec.mti   := i_mes_rec.mti;
    l_fin_rec.de024 := i_mes_rec.de024;

    -- set message
    set_message (
        i_mes_rec        => i_mes_rec
        , io_fin_rec     => l_fin_rec
        , io_pds_tab     => l_pds_tab
        , i_network_id   => i_network_id
        , i_host_id      => i_host_id
        , i_standard_id  => i_standard_id
    );

    mup_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    mup_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    o_fin_ref_id := l_fin_rec.id;

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        create_operation (
            i_fin_rec             => l_fin_rec
          , i_standard_id         => i_standard_id
          , i_auth                => l_auth
          , i_status              => get_status (
                                         i_network_id  => i_network_id
                                       , i_host_id     => i_host_id
                                       , i_standard_id => i_standard_id
                                       , i_inst_id     => l_fin_rec.inst_id
                                     )
          , i_incom_sess_file_id  => i_incom_sess_file_id
          , i_host_id             => i_host_id
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'Incoming first presentment processed. Assigned id[#1]'
        , i_env_param1 => l_fin_rec.id
    );

exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating IPM first presentment on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end create_incoming_first_pres;

procedure create_incoming_second_pres (
    i_mes_rec               in mup_api_type_pkg.t_mes_rec
  , i_file_id               in com_api_type_pkg.t_short_id
  , i_incom_sess_file_id    in com_api_type_pkg.t_long_id
  , i_network_id            in com_api_type_pkg.t_tiny_id
  , i_host_id               in com_api_type_pkg.t_tiny_id
  , i_standard_id           in com_api_type_pkg.t_tiny_id
  , i_local_message         in com_api_type_pkg.t_boolean
  , i_create_operation      in com_api_type_pkg.t_boolean := null
  , i_need_repeat           in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               mup_api_type_pkg.t_fin_rec;
    l_pds_tab               mup_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;

    l_stage                 varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Processing second presentment'
    );
    -- init
    l_fin_rec.id              := opr_api_create_pkg.get_id;
    l_fin_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id      := i_network_id;
    l_fin_rec.is_incoming     := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
    l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
    l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
    l_fin_rec.file_id         := i_file_id;
    --l_fin_rec.local_message := i_local_message;

    l_stage := 'mti & de024';
    l_fin_rec.mti   := i_mes_rec.mti;
    l_fin_rec.de024 := i_mes_rec.de024;

    -- set message
    set_message (
        i_mes_rec        => i_mes_rec
        , io_fin_rec     => l_fin_rec
        , io_pds_tab     => l_pds_tab
        , i_network_id   => i_network_id
        , i_host_id      => i_host_id
        , i_standard_id  => i_standard_id
    );

    mup_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    mup_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        create_operation (
            i_fin_rec              => l_fin_rec
            , i_standard_id        => i_standard_id
            , i_auth               => l_auth
            , i_incom_sess_file_id => i_incom_sess_file_id
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'Incoming second presentment processed. Assigned id[#1]'
        , i_env_param1 => l_fin_rec.id
    );

exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating IPM second presentment on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end create_incoming_second_pres;

procedure create_incoming_retrieval (
    i_mes_rec               in mup_api_type_pkg.t_mes_rec
  , i_file_id               in com_api_type_pkg.t_short_id
  , i_incom_sess_file_id    in com_api_type_pkg.t_long_id
  , i_network_id            in com_api_type_pkg.t_tiny_id
  , i_host_id               in com_api_type_pkg.t_tiny_id
  , i_standard_id           in com_api_type_pkg.t_tiny_id
  , i_local_message         in com_api_type_pkg.t_boolean
  , i_create_operation      in com_api_type_pkg.t_boolean := null
  , i_need_repeat           in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               mup_api_type_pkg.t_fin_rec;
    l_pds_tab               mup_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;

    l_stage                 varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Processing retrieval request'
    );
    -- init
    l_fin_rec.id              := opr_api_create_pkg.get_id;
    l_fin_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id      := i_network_id;
    l_fin_rec.is_incoming     := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
    l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
    l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
    l_fin_rec.file_id         := i_file_id;
    --l_fin_rec.local_message := i_local_message;

    l_stage := 'mti & de024';
    l_fin_rec.mti   := i_mes_rec.mti;
    l_fin_rec.de024 := i_mes_rec.de024;

    -- set message
    set_message (
        i_mes_rec        => i_mes_rec
        , io_fin_rec     => l_fin_rec
        , io_pds_tab     => l_pds_tab
        , i_network_id   => i_network_id
        , i_financial    => com_api_type_pkg.FALSE
        , i_host_id      => i_host_id
        , i_standard_id  => i_standard_id
    );

    mup_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    mup_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        create_operation (
            i_fin_rec              => l_fin_rec
            , i_standard_id        => i_standard_id
            , i_auth               => l_auth
            , i_incom_sess_file_id => i_incom_sess_file_id
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'Incoming retrieval request processed. Assigned id[#1]'
        , i_env_param1 => l_fin_rec.id
    );

exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating IPM retrieval request on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end create_incoming_retrieval;


procedure create_incoming_chargeback (
    i_mes_rec               in mup_api_type_pkg.t_mes_rec
  , i_file_id               in com_api_type_pkg.t_short_id
  , i_incom_sess_file_id    in com_api_type_pkg.t_long_id
  , i_network_id            in com_api_type_pkg.t_tiny_id
  , i_host_id               in com_api_type_pkg.t_tiny_id
  , i_standard_id           in com_api_type_pkg.t_tiny_id
  , i_local_message         in com_api_type_pkg.t_boolean
  , i_create_operation      in com_api_type_pkg.t_boolean := null
  , i_need_repeat           in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               mup_api_type_pkg.t_fin_rec;
    l_pds_tab               mup_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;

    l_stage                 varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Processing incoming chargeback'
    );

    -- init
    l_fin_rec.id              := opr_api_create_pkg.get_id;
    l_fin_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id      := i_network_id;
    l_fin_rec.is_incoming     := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
    l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
    l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
    l_fin_rec.file_id         := i_file_id;

    l_stage := 'mti & de024';
    l_fin_rec.mti   := i_mes_rec.mti;
    l_fin_rec.de024 := i_mes_rec.de024;

    -- set message
    set_message (
        i_mes_rec        => i_mes_rec
        , io_fin_rec     => l_fin_rec
        , io_pds_tab     => l_pds_tab
        , i_network_id   => i_network_id
        , i_host_id      => i_host_id
        , i_standard_id  => i_standard_id
    );

    mup_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    mup_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        create_operation (
            i_fin_rec              => l_fin_rec
            , i_standard_id        => i_standard_id
            , i_auth               => l_auth
            , i_incom_sess_file_id => i_incom_sess_file_id
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'Incoming chargeback processed. Assigned id[#1]'
        , i_env_param1 => l_fin_rec.id
    );

exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating IPM chargeback on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end create_incoming_chargeback;

procedure create_incoming_fee (
    i_mes_rec               in mup_api_type_pkg.t_mes_rec
  , i_file_id               in com_api_type_pkg.t_short_id
  , i_incom_sess_file_id    in com_api_type_pkg.t_long_id
  , i_network_id            in com_api_type_pkg.t_tiny_id
  , i_host_id               in com_api_type_pkg.t_tiny_id
  , i_standard_id           in com_api_type_pkg.t_tiny_id
  , i_local_message         in com_api_type_pkg.t_boolean
  , i_create_operation      in com_api_type_pkg.t_boolean := null
  , i_need_repeat           in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               mup_api_type_pkg.t_fin_rec;
    l_pds_tab               mup_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;

    l_stage                 varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Processing incoming fee collection'
    );
    -- init
    l_fin_rec.id              := opr_api_create_pkg.get_id;
    l_fin_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id      := i_network_id;
    l_fin_rec.is_incoming     := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
    l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
    l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
    l_fin_rec.file_id         := i_file_id;
    --l_fin_rec.local_message := i_local_message;

    l_stage := 'mti & de024';
    l_fin_rec.mti   := i_mes_rec.mti;
    l_fin_rec.de024 := i_mes_rec.de024;

    -- set message
    set_message (
        i_mes_rec        => i_mes_rec
        , io_fin_rec     => l_fin_rec
        , io_pds_tab     => l_pds_tab
        , i_network_id   => i_network_id
        , i_host_id      => i_host_id
        , i_standard_id  => i_standard_id
    );

    mup_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    mup_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        create_operation (
            i_fin_rec              => l_fin_rec
            , i_standard_id        => i_standard_id
            , i_auth               => l_auth
            , i_incom_sess_file_id => i_incom_sess_file_id
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'Incoming fee collection processed. Assigned id[#1]'
        , i_env_param1 => l_fin_rec.id
    );

exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating IPM fee collection on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end create_incoming_fee;

function is_collection_allow (
    i_card_num              in com_api_type_pkg.t_card_number
  , i_network_id            in com_api_type_pkg.t_tiny_id
  , i_inst_id               in com_api_type_pkg.t_inst_id
  , i_card_type             in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_boolean is
    l_return com_api_type_pkg.t_boolean;
    l_host_id           com_api_type_pkg.t_tiny_id;
    l_standard_id       com_api_type_pkg.t_tiny_id;
    l_param_tab         com_api_type_pkg.t_param_tab;
begin

    l_host_id := net_api_network_pkg.get_default_host(i_network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_network_id => i_network_id);

    if l_standard_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'UNKNOWN_NETWORK'
            , i_env_param1  => i_network_id
        );
    end if;

    cmn_api_standard_pkg.get_param_value (
        i_inst_id        => i_inst_id
        , i_standard_id  => l_standard_id
        , i_object_id    => l_host_id
        , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
        , i_param_name   => mup_api_const_pkg.COLLECTION_ONLY
        , o_param_value  => l_return
        , i_param_tab    => l_param_tab
    );

    return l_return;
end is_collection_allow;

function get_acq_member (
    i_acq_bin               in mup_api_type_pkg.t_de031
) return com_api_type_pkg.t_medium_id is
    l_result com_api_type_pkg.t_medium_id;
begin
    select to_number(ltrim(mab.member_id, '0'))
      into l_result
      from mup_acq_bin mab
     where mab.acq_bin = i_acq_bin
       and rownum = 1;

     return l_result;
exception
    when others then
        return null;
end get_acq_member;

procedure init_no_original_id_tab
is
begin
    g_no_original_id_tab.delete;
end init_no_original_id_tab;

procedure process_no_original_id_tab
is
    l_operation_id_tab         com_api_type_pkg.t_number_tab;
    l_original_id_tab          com_api_type_pkg.t_number_tab;
begin
    -- It is case when original record is later than reversal record in the same file.
    if g_no_original_id_tab.count > 0 then
        for i in 1 .. g_no_original_id_tab.count loop
            l_operation_id_tab(l_operation_id_tab.count + 1) := g_no_original_id_tab(i).id;
            l_original_id_tab(l_original_id_tab.count + 1)   := get_original_id(
                                                                    i_fin_rec => g_no_original_id_tab(i)
                                                                );
        end loop;

        forall i in 1 .. l_operation_id_tab.count
            update opr_operation
               set original_id = l_original_id_tab(i)
             where id          = l_operation_id_tab(i);
    end if;
end process_no_original_id_tab;

procedure create_incoming_ntf (
    i_mes_rec            in     mup_api_type_pkg.t_mes_rec
  , i_file_id            in     com_api_type_pkg.t_short_id
  , i_incom_sess_file_id in     com_api_type_pkg.t_long_id
  , o_fin_ref_id            out com_api_type_pkg.t_long_id
  , i_network_id         in     com_api_type_pkg.t_tiny_id
  , i_host_id            in     com_api_type_pkg.t_tiny_id
  , i_standard_id        in     com_api_type_pkg.t_tiny_id
  , i_create_operation   in     com_api_type_pkg.t_boolean
)is
    l_fin_rec                   mup_api_type_pkg.t_fin_rec;
    l_pds_tab                   mup_api_type_pkg.t_pds_tab;
    l_auth                      aut_api_type_pkg.t_auth_rec;

    l_stage                     varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Processing incoming notification'
    );

    o_fin_ref_id := null;

    -- init
    l_fin_rec.id              := opr_api_create_pkg.get_id;
    l_fin_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id      := i_network_id;
    l_fin_rec.is_incoming     := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
    l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
    l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
    l_fin_rec.file_id         := i_file_id;

    l_stage := 'mti & de024';
    l_fin_rec.mti   := i_mes_rec.mti;
    l_fin_rec.de024 := i_mes_rec.de024;

    -- set message
    set_message (
        i_mes_rec        => i_mes_rec
        , io_fin_rec     => l_fin_rec
        , io_pds_tab     => l_pds_tab
        , i_network_id   => i_network_id
        , i_host_id      => i_host_id
        , i_standard_id  => i_standard_id
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    mup_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    o_fin_ref_id := l_fin_rec.id;

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then

        create_operation (
            i_fin_rec             => l_fin_rec
          , i_standard_id         => i_standard_id
          , i_auth                => l_auth
          , i_status              => get_status (
                                         i_network_id  => i_network_id
                                       , i_host_id     => i_host_id
                                       , i_standard_id => i_standard_id
                                       , i_inst_id     => l_fin_rec.inst_id
                                     )
          , i_incom_sess_file_id  => i_incom_sess_file_id
          , i_host_id             => i_host_id
          , i_client_id_type      => opr_api_const_pkg.CLIENT_ID_TYPE_CARD
          , i_client_id_value     => l_fin_rec.de002
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'Incoming notification processed. Assigned id[#1]'
        , i_env_param1 => l_fin_rec.id
    );

exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating IPM first presentment on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;

end create_incoming_ntf;

function is_mup (
    i_id               in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean is
    l_result                  com_api_type_pkg.t_boolean;
begin
    select count(1)
      into l_result
      from mup_fin
     where id = i_id
       and rownum <= 1;

    return l_result;
end is_mup;

procedure get_fin_message(
    i_id                       in     com_api_type_pkg.t_long_id
  , o_fin_fields                  out com_api_type_pkg.t_param_tab
  , i_mask_error               in     com_api_type_pkg.t_boolean
) is
    l_pds_number_tab                  com_api_type_pkg.t_tiny_tab;
    l_pds_body_tab                    com_api_type_pkg.t_desc_tab;
begin
    begin
        select f.id
             , f.split_hash
             , f.inst_id
             , f.network_id
             , f.file_id
             , f.status
             , f.impact
             , f.is_incoming
             , f.is_reversal
             , f.is_rejected
             , f.is_fpd_matched
             , f.is_fsum_matched
             , f.dispute_id
             , f.dispute_rn
             , f.fpd_id
             , f.fsum_id
             , f.reject_id
             , f.mti
             , f.de024
             , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as de002
             , f.de003_1
             , f.de003_2
             , f.de003_3
             , f.de004
             , f.de005
             , f.de006
             , f.de009
             , f.de010
             , f.de012
             , f.de014
             , f.de022_1
             , f.de022_2
             , f.de022_3
             , f.de022_4
             , f.de022_5
             , f.de022_6
             , f.de022_7
             , f.de022_8
             , f.de022_9
             , f.de022_10
             , f.de022_11
             , f.de023
             , f.de025
             , f.de026
             , f.de030_1
             , f.de030_2
             , f.de031
             , f.de032
             , f.de033
             , f.de037
             , f.de038
             , f.de040
             , f.de041
             , f.de042
             , f.de043_1
             , f.de043_2
             , f.de043_3
             , f.de043_4
             , f.de043_5
             , f.de043_6
             , f.de049
             , f.de050
             , f.de051
             , f.de054
             , f.de055
             , f.de063
             , f.de071
             , f.de072
             , f.de073
             , f.de093
             , f.de094
             , f.de095
             , f.de100
             , f.p0025_1
             , f.p0025_2
             , f.p0137
             , f.p0146
             , f.p0146_net
             , f.p0148
             , f.p0149_1
             , f.p0149_2
             , f.p0165
             , f.p0190
             , f.p0198
             , f.p0228
             , f.p0261
             , f.p0262
             , f.p0265
             , f.p0266
             , f.p0267
             , f.p0268_1
             , f.p0268_2
             , f.p0375
             , f.p2002
             , f.p2063
             , f.p2158_1
             , f.p2158_2
             , f.p2158_3
             , f.p2158_4
             , f.p2158_5
             , f.p2158_6
             , f.p2159_1
             , f.p2159_2
             , f.p2159_3
             , f.p2159_4
             , f.p2159_5
             , f.p2159_6
             , f.emv_9f26
             , f.emv_9f27
             , f.emv_9f10
             , f.emv_9f37
             , f.emv_9f36
             , f.emv_95
             , f.emv_9a
             , f.emv_9c
             , f.emv_9f02
             , f.emv_5f2a
             , f.emv_82
             , f.emv_9f1a
             , f.emv_9f03
             , f.emv_9f34
             , f.emv_9f33
             , f.emv_9f35
             , f.emv_9f1e
             , f.emv_9f53
             , f.emv_84
             , f.emv_9f09
             , f.emv_9f41
             , f.emv_9f4c
             , f.emv_91
             , f.emv_8a
             , f.emv_71
             , f.emv_72
             , f.p0176
             , f.p2072_1
             , f.p2072_2
             , f.p2175_1
             , f.p2175_2
             , f.p2097_1
             , f.p2097_2
             , f.is_collection
             , f.p2001_1
             , f.p2001_2
             , f.p2001_3
             , f.p2001_4
             , f.p2001_5
             , f.p2001_6
             , f.p2001_7
          into o_fin_fields('id')
             , o_fin_fields('split_hash')
             , o_fin_fields('inst_id')
             , o_fin_fields('network_id')
             , o_fin_fields('file_id')
             , o_fin_fields('status')
             , o_fin_fields('impact')
             , o_fin_fields('is_incoming')
             , o_fin_fields('is_reversal')
             , o_fin_fields('is_rejected')
             , o_fin_fields('is_fpd_matched')
             , o_fin_fields('is_fsum_matched')
             , o_fin_fields('dispute_id')
             , o_fin_fields('dispute_rn')
             , o_fin_fields('fpd_id')
             , o_fin_fields('fsum_id')
             , o_fin_fields('reject_id')
             , o_fin_fields('mti')
             , o_fin_fields('de024')
             , o_fin_fields('de002')
             , o_fin_fields('de003_1')
             , o_fin_fields('de003_2')
             , o_fin_fields('de003_3')
             , o_fin_fields('de004')
             , o_fin_fields('de005')
             , o_fin_fields('de006')
             , o_fin_fields('de009')
             , o_fin_fields('de010')
             , o_fin_fields('de012')
             , o_fin_fields('de014')
             , o_fin_fields('de022_1')
             , o_fin_fields('de022_2')
             , o_fin_fields('de022_3')
             , o_fin_fields('de022_4')
             , o_fin_fields('de022_5')
             , o_fin_fields('de022_6')
             , o_fin_fields('de022_7')
             , o_fin_fields('de022_8')
             , o_fin_fields('de022_9')
             , o_fin_fields('de022_10')
             , o_fin_fields('de022_11')
             , o_fin_fields('de023')
             , o_fin_fields('de025')
             , o_fin_fields('de026')
             , o_fin_fields('de030_1')
             , o_fin_fields('de030_2')
             , o_fin_fields('de031')
             , o_fin_fields('de032')
             , o_fin_fields('de033')
             , o_fin_fields('de037')
             , o_fin_fields('de038')
             , o_fin_fields('de040')
             , o_fin_fields('de041')
             , o_fin_fields('de042')
             , o_fin_fields('de043_1')
             , o_fin_fields('de043_2')
             , o_fin_fields('de043_3')
             , o_fin_fields('de043_4')
             , o_fin_fields('de043_5')
             , o_fin_fields('de043_6')
             , o_fin_fields('de049')
             , o_fin_fields('de050')
             , o_fin_fields('de051')
             , o_fin_fields('de054')
             , o_fin_fields('de055')
             , o_fin_fields('de063')
             , o_fin_fields('de071')
             , o_fin_fields('de072')
             , o_fin_fields('de073')
             , o_fin_fields('de093')
             , o_fin_fields('de094')
             , o_fin_fields('de095')
             , o_fin_fields('de100')
             , o_fin_fields('p0025_1')
             , o_fin_fields('p0025_2')
             , o_fin_fields('p0137')
             , o_fin_fields('p0146')
             , o_fin_fields('p0146_net')
             , o_fin_fields('p0148')
             , o_fin_fields('p0149_1')
             , o_fin_fields('p0149_2')
             , o_fin_fields('p0165')
             , o_fin_fields('p0190')
             , o_fin_fields('p0198')
             , o_fin_fields('p0228')
             , o_fin_fields('p0261')
             , o_fin_fields('p0262')
             , o_fin_fields('p0265')
             , o_fin_fields('p0266')
             , o_fin_fields('p0267')
             , o_fin_fields('p0268_1')
             , o_fin_fields('p0268_2')
             , o_fin_fields('p0375')
             , o_fin_fields('p2002')
             , o_fin_fields('p2063')
             , o_fin_fields('p2158_1')
             , o_fin_fields('p2158_2')
             , o_fin_fields('p2158_3')
             , o_fin_fields('p2158_4')
             , o_fin_fields('p2158_5')
             , o_fin_fields('p2158_6')
             , o_fin_fields('p2159_1')
             , o_fin_fields('p2159_2')
             , o_fin_fields('p2159_3')
             , o_fin_fields('p2159_4')
             , o_fin_fields('p2159_5')
             , o_fin_fields('p2159_6')
             , o_fin_fields('emv_9f26')
             , o_fin_fields('emv_9f27')
             , o_fin_fields('emv_9f10')
             , o_fin_fields('emv_9f37')
             , o_fin_fields('emv_9f36')
             , o_fin_fields('emv_95')
             , o_fin_fields('emv_9a')
             , o_fin_fields('emv_9c')
             , o_fin_fields('emv_9f02')
             , o_fin_fields('emv_5f2a')
             , o_fin_fields('emv_82')
             , o_fin_fields('emv_9f1a')
             , o_fin_fields('emv_9f03')
             , o_fin_fields('emv_9f34')
             , o_fin_fields('emv_9f33')
             , o_fin_fields('emv_9f35')
             , o_fin_fields('emv_9f1e')
             , o_fin_fields('emv_9f53')
             , o_fin_fields('emv_84')
             , o_fin_fields('emv_9f09')
             , o_fin_fields('emv_9f41')
             , o_fin_fields('emv_9f4c')
             , o_fin_fields('emv_91')
             , o_fin_fields('emv_8a')
             , o_fin_fields('emv_71')
             , o_fin_fields('emv_72')
             , o_fin_fields('p0176')
             , o_fin_fields('p2072_1')
             , o_fin_fields('p2072_2')
             , o_fin_fields('p2175_1')
             , o_fin_fields('p2175_2')
             , o_fin_fields('p2097_1')
             , o_fin_fields('p2097_2')
             , o_fin_fields('is_collection')
             , o_fin_fields('p2001_1')
             , o_fin_fields('p2001_2')
             , o_fin_fields('p2001_3')
             , o_fin_fields('p2001_4')
             , o_fin_fields('p2001_5')
             , o_fin_fields('p2001_6')
             , o_fin_fields('p2001_7')
          from      mup_fin     f
          left join mup_card    c    on f.id = c.id
         where f.id = i_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'FINANCIAL_MESSAGE_NOT_FOUND'
              , i_env_param1  => i_id
              , i_mask_error  => i_mask_error
            );
    end;

    select pds_number
         , pds_body
      bulk collect into
           l_pds_number_tab
         , l_pds_body_tab
      from mup_msg_pds
     where msg_id = i_id;

    for i in 1 .. l_pds_number_tab.count() loop
        o_fin_fields('PDS_' || l_pds_number_tab(i)) := l_pds_body_tab(i);
    end loop;

exception
    when com_api_error_pkg.e_application_error then
        null;
end get_fin_message;

end mup_api_fin_pkg;
/

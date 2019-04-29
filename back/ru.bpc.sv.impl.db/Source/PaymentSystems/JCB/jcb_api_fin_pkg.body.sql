create or replace package body jcb_api_fin_pkg is
/*********************************************************
 *  API for JCB finance message  <br />
 *  Created by Kolodkina A. (kolodkina@bpcbt.com) at 01.05.2016 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: jcb_api_fin_pkg <br />
 *  @headcom
 **********************************************************/

g_no_original_id_tab    jcb_api_type_pkg.t_fin_tab;

FIN_COLUMN_LIST         constant com_api_type_pkg.t_text :=
 'f.rowid' ||   
', f.id'||     
', f.status'|| 
', f.inst_id'||
', f.network_id'||
', f.file_id'||   
', f.is_incoming'||
', f.is_reversal'||
', f.is_rejected'||
', f.dispute_id '||
', f.dispute_rn '||
', f.impact'||
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
', f.de016'||
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
', f.de022_12'||
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
', f.de071'||
', f.de072'||
', f.de093'||
', f.de094'||
', f.de097'||
', f.de100'|| 
', f.p3001'||
', f.p3002'||
', f.p3003'||
', f.p3005'||
', f.p3006'||
', f.p3007_1'||
', f.p3007_2'||
', f.p3008'||
', f.p3009'||
', f.p3011'||
', f.p3012'||
', f.p3013'||
', f.p3014'||
', f.p3021'||
', f.p3201'||
', f.p3202'||
', f.p3203'||
', f.p3205'||
', f.p3206'||
', f.p3207'||
', f.p3208'||
', f.p3209'||
', f.p3210'||
', f.p3211'||
', f.p3250'||
', f.p3251'||
', f.p3302'||
', f.emv_9f26'||
', f.emv_9f02'||
', f.emv_9f27'||
', f.emv_9f10'||
', f.emv_9f36'||
', f.emv_95'||
', f.emv_82'||
', f.emv_9a'||
', f.emv_9c'||
', f.emv_9f37'||
', f.emv_5f2a'||
', f.emv_9f33'||
', f.emv_9f34'||
', f.emv_9f1a'||
', f.emv_9f35'||
--', emv_9f53'||
', f.emv_84'||
', f.emv_9f09'||
', f.emv_9f03'||
', f.emv_9f1e'||
', f.emv_9f41'||
', f.emv_4f'
;

procedure get_processing_date (
    i_id                  in com_api_type_pkg.t_long_id
    , i_file_id           in com_api_type_pkg.t_short_id
    , o_p3007_2           out jcb_api_type_pkg.t_p3007_2
) is
begin
    if i_file_id is not null then
       
       select f.p3901_2
         into o_p3007_2
        from
            jcb_file f
        where
            f.id = i_file_id;
    else
        o_p3007_2 := get_sysdate;
    end if;
exception
    when no_data_found then
        o_p3007_2 := get_sysdate;
end;

function estimate_messages_for_upload (
    i_network_id            in      com_api_type_pkg.t_tiny_id
  , i_cmid                  in      jcb_api_type_pkg.t_de033
  , i_start_date            in      date default null
  , i_end_date              in      date default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id default null
  , i_include_affiliate     in      com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) return number is
    l_result                        number;
    l_host_id                       com_api_type_pkg.t_tiny_id;
    l_standard_id                   com_api_type_pkg.t_tiny_id;
begin
    if i_include_affiliate = com_api_const_pkg.TRUE
        and i_inst_id is not null
    then
        l_host_id     := net_api_network_pkg.get_default_host(i_network_id => i_network_id);
        l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

        select /*+ INDEX(f, jcb_fin_status_CLMS10_ndx)*/
               count(*)
          into l_result
          from jcb_fin_message f
             , opr_operation o
             , (select distinct v.param_value cmid
                  from cmn_parameter p
                     , net_api_interface_param_val_vw v
                     , net_member m
                     , net_interface i
                 where p.name           = jcb_api_const_Pkg.CMID
                   and p.standard_id    = l_standard_id
                   and p.id             = v.param_id
                   and m.id             = v.consumer_member_id
                   and v.host_member_id = l_host_id
                   and m.id             = i.consumer_member_id
                   and v.interface_id   = i.id
                   and (i.msp_member_id in (select id
                                              from net_member
                                             where network_id = i_network_id
                                               and inst_id    = i_inst_id)
                           or m.inst_id = i_inst_id)
               ) cmid
         where decode(f.status, 'CLMS0010', f.de033, null) = cmid.cmid
           and f.split_hash in (select split_hash from com_api_split_map_vw)
           and f.is_incoming = 0
           and f.id = o.id
           and f.network_id = i_network_id
           and (f.de012 between nvl(i_start_date, trunc(f.de012)) and nvl(i_end_date, trunc(f.de012)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_type_pkg.FALSE
                 or o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_type_pkg.TRUE
           );
    else
        select /*+ INDEX(f, jcb_fin_status_CLMS10_ndx)*/
               count(*)
          into l_result
          from jcb_fin_message f
             , opr_operation o
         where decode(f.status, 'CLMS0010', f.de033, null) = i_cmid 
           and f.split_hash in (select split_hash from com_api_split_map_vw)
           and f.is_incoming = 0
           and f.id = o.id
           and f.network_id = i_network_id
           and (f.de012 between nvl(i_start_date, trunc(f.de012)) and nvl(i_end_date, trunc(f.de012)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_type_pkg.FALSE
                 or o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_type_pkg.TRUE
           );
    end if;

    return l_result;
end;

procedure enum_messages_for_upload (
    o_fin_cur               in out sys_refcursor
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_cmid                  in     jcb_api_type_pkg.t_de033
  , i_start_date            in     date                       default null
  , i_end_date              in     date                       default null
  , i_inst_id               in     com_api_type_pkg.t_inst_id default null
  , i_include_affiliate     in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
)
is
    WHERE_PLACEHOLDER              constant varchar2(100)     := '##WHERE##';
    DATE_PLACEHOLDER               constant varchar2(100)     := '##DATE##';
    DATE_CONDITION                 constant com_api_type_pkg.t_text :=
        ' and (f.de012 between nvl(:i_start_date, trunc(f.de012)) '
     ||                   ' and nvl(:i_end_date,   trunc(f.de012)) + 1 - 1/86400 '
     || ' and f.is_reversal = ' || com_api_type_pkg.FALSE
     || ' or o.host_date between nvl(:i_start_date, trunc(o.host_date)) '
     ||                    ' and nvl(:i_end_date,    trunc(o.host_date)) + 1 - 1/86400 '
     || ' and f.is_reversal = ' || com_api_type_pkg.TRUE || ') ';
    l_cursor                       com_api_type_pkg.t_text;
    l_host_id                      com_api_type_pkg.t_tiny_id;
    l_standard_id                  com_api_type_pkg.t_tiny_id;
    l_param_name                   com_api_type_pkg.t_name;
begin
    if i_include_affiliate = com_api_const_pkg.TRUE
        and i_inst_id is not null
    then
        l_host_id     := net_api_network_pkg.get_default_host(i_network_id => i_network_id);
        l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

        l_param_name := jcb_api_const_pkg.CMID;

        l_cursor := '
select /*+ INDEX(f, jcb_fin_status_CLMS10_ndx)*/
    ' || FIN_COLUMN_LIST || '
 from jcb_fin_message f
    , jcb_card c
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
                                      and inst_id    = :i_inst_id)
                  or m.inst_id = :i_inst_id)
      ) cmid
  where ' || WHERE_PLACEHOLDER || '
    and f.split_hash in (select split_hash from com_api_split_map_vw)
    and f.network_id = :i_network_id
    and f.is_incoming = 0
    and f.id = o.id
    and f.id = c.id(+) ' || DATE_PLACEHOLDER || '
  order by f.id
    for update of f.status ';

        l_cursor := replace(
                        l_cursor
                      , WHERE_PLACEHOLDER
                      , 'decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', f.de033, null) = cmid.cmid'
                    );
        l_cursor := replace(
                        l_cursor
                      , DATE_PLACEHOLDER
                      , case
                            when i_start_date is not null
                              or i_end_date is not null
                            then DATE_CONDITION
                            else ' '
                        end
                    );
        if i_start_date is not null or i_end_date is not null then
            open  o_fin_cur
            for   l_cursor
            using l_param_name
                , l_standard_id
                , l_host_id
                , i_network_id
                , i_inst_id
                , i_inst_id
                , i_network_id
                , i_start_date
                , i_end_date
                , i_start_date
                , i_end_date;
        else
            open  o_fin_cur
            for   l_cursor
            using l_param_name
                , l_standard_id
                , l_host_id
                , i_network_id
                , i_inst_id
                , i_inst_id
                , i_network_id;
        end if;
    else
        l_cursor := '
select /*+ INDEX(f, jcb_fin_status_CLMS10_ndx)*/
    ' || FIN_COLUMN_LIST || '
  from jcb_fin_message f
     , jcb_card c
     , opr_operation o
 where ' || WHERE_PLACEHOLDER || '
   and f.split_hash in (select split_hash from com_api_split_map_vw)
   and f.network_id = :i_network_id
   and f.is_incoming = 0
   and f.id = o.id
   and f.id = c.id(+) ' || DATE_PLACEHOLDER || '
 order by f.id
   for update of f.status ';

        l_cursor := replace(
                        l_cursor
                      , WHERE_PLACEHOLDER
                      , 'decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', f.de094, null) = :i_cmid'
                    );
        l_cursor := replace(
                        l_cursor
                      , DATE_PLACEHOLDER
                      , case
                            when i_start_date is not null or i_end_date is not null
                            then DATE_CONDITION
                            else ' '
                        end
                    );
        if i_start_date is not null or i_end_date is not null then
            open  o_fin_cur
            for   l_cursor
            using i_cmid
                , i_network_id
                , i_start_date
                , i_end_date
                , i_start_date
                , i_end_date;
        else
            open  o_fin_cur
            for   l_cursor
            using i_cmid
                , i_network_id;
        end if;
    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT)  || '.enum_messages_for_upload >> FAILED:'
                   ||   ' i_network_id ['  || i_network_id
                   || '], i_inst_id ['     || i_inst_id
                   || '], i_cmid ['        || i_cmid
                   || '], i_include_affiliate [' || i_include_affiliate
                   || '], i_start_date ['  || com_api_type_pkg.convert_to_char(i_start_date)
                   || '], i_end_date ['    || com_api_type_pkg.convert_to_char(i_end_date)
                   || '], l_host_id ['     || l_host_id
                   || '], l_standard_id [' || l_standard_id
                   || '], l_param_name ['  || l_param_name
                   || ']'
        );
        trc_log_pkg.debug(i_text => l_cursor);

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end enum_messages_for_upload;

procedure get_fin (
    i_id                    in com_api_type_pkg.t_long_id
    , o_fin_rec             out jcb_api_type_pkg.t_fin_rec
    , i_mask_error          in com_api_type_pkg.t_boolean
) is
    l_fin_cur               sys_refcursor;
    l_statemet              com_api_type_pkg.t_text;
begin
    l_statemet := '
select
' || FIN_COLUMN_LIST || '
from
jcb_fin_message f
, jcb_card c
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
end;

procedure get_fin (
    i_mti                   in jcb_api_type_pkg.t_mti
    , i_de024               in jcb_api_type_pkg.t_de024
    , i_is_reversal         in com_api_type_pkg.t_boolean
    , i_dispute_id          in com_api_type_pkg.t_long_id
    , o_fin_rec             out jcb_api_type_pkg.t_fin_rec
    , i_mask_error          in com_api_type_pkg.t_boolean
) is
    l_fin_cur               sys_refcursor;
    l_statemet              com_api_type_pkg.t_text;
begin
    l_statemet := '
select
' || FIN_COLUMN_LIST || '
from
jcb_fin_message f
, jcb_card c
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
end;

procedure get_original_fin (
    i_mti                   in jcb_api_type_pkg.t_mti
    , i_de002               in jcb_api_type_pkg.t_de002
    , i_de024               in jcb_api_type_pkg.t_de024
    , i_de031               in jcb_api_type_pkg.t_de031
    , i_id                  in com_api_type_pkg.t_long_id
    , o_fin_rec             out jcb_api_type_pkg.t_fin_rec
) is
    l_fin_cur               sys_refcursor;
    l_statemet              com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug (
        i_text          => 'get_original_fin start'
    );

    l_statemet := '
select
' || FIN_COLUMN_LIST || '
from
jcb_fin_message f
, jcb_card c
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

    trc_log_pkg.debug (
        i_text          => l_statemet
    );

    open l_fin_cur for l_statemet
    using
        i_mti
      , i_de024
      , iss_api_token_pkg.encode_card_number(i_card_number => i_de002)
      , i_de031
      , com_api_type_pkg.FALSE
      , i_id
      , i_id;

    jcb_api_dispute_pkg.fetch_dispute_id (
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
end;

procedure get_original_fee (
    i_mti                   in jcb_api_type_pkg.t_mti
    , i_de002               in jcb_api_type_pkg.t_de002
    , i_de024               in jcb_api_type_pkg.t_de024
    , i_de031               in jcb_api_type_pkg.t_de031
    , i_de094               in jcb_api_type_pkg.t_de094
    , i_p3201               in jcb_api_type_pkg.t_p3201
    , o_fin_rec             out jcb_api_type_pkg.t_fin_rec
) is
    l_fin_cur               sys_refcursor;
    l_statemet              com_api_type_pkg.t_text;
begin
    l_statemet := '
select
' || FIN_COLUMN_LIST || '
from
jcb_fin_message f
, jcb_card c
where
f.mti = :i_mti
and f.de024 in ('''||jcb_api_const_pkg.FUNC_CODE_FEE_COLLECTION||''')
and c.card_number = :i_de002
and f.de031 = :i_de031
and f.is_reversal = :i_is_reversal
and f.de094 = :i_de094
and f.p3201 = :i_p3201
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
      , i_p3201;
    fetch l_fin_cur into o_fin_rec;
    close l_fin_cur;

exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;
        raise;
end;

function pack_message (
    i_fin_rec               in jcb_api_type_pkg.t_fin_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_de071               in jcb_api_type_pkg.t_de071
    , i_with_rdw            in com_api_type_pkg.t_boolean     := null
) return blob is
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_standard_version      com_api_type_pkg.t_tiny_id;
    l_pds_tab               jcb_api_type_pkg.t_pds_tab;
    l_raw_data              blob;
begin
    l_host_id := net_api_network_pkg.get_default_host(
        i_network_id  => i_fin_rec.network_id
    );
    l_standard_id := net_api_network_pkg.get_offline_standard (
        i_host_id       => l_host_id
    );
    l_standard_version :=
        cmn_api_standard_pkg.get_current_version(
            i_network_id  => i_fin_rec.network_id
        );
    jcb_api_pds_pkg.read_pds (
        i_msg_id        => i_fin_rec.id
        , o_pds_tab     => l_pds_tab
    );
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3001
        , i_pds_body    => i_fin_rec.p3001
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3002
        , i_pds_body    => i_fin_rec.p3002
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3003
        , i_pds_body    => i_fin_rec.p3003
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3003
        , i_pds_body    => i_fin_rec.p3003
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3005
        , i_pds_body    => i_fin_rec.p3005
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3007
        , i_pds_body    => jcb_api_pds_pkg.format_p3007(
                               i_p3007_1 => i_fin_rec.p3007_1
                             , i_p3007_2 => i_fin_rec.p3007_2
                           )
    );
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3008
        , i_pds_body    => i_fin_rec.p3008
    );
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3009
        , i_pds_body    => i_fin_rec.p3009
    );
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3011
        , i_pds_body    => i_fin_rec.p3011
    );
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3012
        , i_pds_body    => i_fin_rec.p3012
    );
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3013
        , i_pds_body    => i_fin_rec.p3013
    );
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3014
        , i_pds_body    => i_fin_rec.p3014
    );
    if l_standard_version >= jcb_api_const_pkg.STANDARD_ID_VERISON_18Q2 then
        jcb_api_pds_pkg.set_pds_body (
            io_pds_tab      => l_pds_tab
            , i_pds_tag     => 3021
            , i_pds_body    => i_fin_rec.p3021
        );
    end if;
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3201
        , i_pds_body    => i_fin_rec.p3201
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3202
        , i_pds_body    => i_fin_rec.p3202
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3203
        , i_pds_body    => i_fin_rec.p3203
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3205
        , i_pds_body    => i_fin_rec.p3205
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3206
        , i_pds_body    => i_fin_rec.p3206
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3207
        , i_pds_body    => i_fin_rec.p3207
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3208
        , i_pds_body    => i_fin_rec.p3208
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3209
        , i_pds_body    => i_fin_rec.p3209
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3210
        , i_pds_body    => i_fin_rec.p3210
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3211
        , i_pds_body    => i_fin_rec.p3211
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3250
        , i_pds_body    => i_fin_rec.p3250
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3251
        , i_pds_body    => i_fin_rec.p3251
    );    
    jcb_api_pds_pkg.set_pds_body (
        io_pds_tab      => l_pds_tab
        , i_pds_tag     => 3302
        , i_pds_body    => i_fin_rec.p3302
    );    

    l_raw_data := jcb_api_msg_pkg.pack_message (
        i_pds_tab           => l_pds_tab
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
        , i_de016           => i_fin_rec.de016
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
        , i_de022_12        => i_fin_rec.de022_12
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
        , i_de071           => i_de071
        , i_de072           => i_fin_rec.de072
        , i_de093           => i_fin_rec.de093
        , i_de094           => i_fin_rec.de094
        , i_de097           => i_fin_rec.de097
        , i_de100           => i_fin_rec.de100
        , i_with_rdw        => i_with_rdw
    );
    return l_raw_data;
end;

procedure mark_ok_uploaded (
    i_rowid                 in com_api_type_pkg.t_rowid_tab
    , i_id                  in com_api_type_pkg.t_number_tab
    , i_de071               in com_api_type_pkg.t_number_tab
    , i_file_id             in com_api_type_pkg.t_number_tab
) is
begin
    forall i in 1 .. i_rowid.count
        update
            jcb_fin_message
        set
            status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
            , is_rejected = com_api_type_pkg.FALSE
            , de071 = i_de071(i)
            , file_id = i_file_id(i)
        where
            rowid = i_rowid(i);

    opr_api_clearing_pkg.mark_uploaded (
        i_id_tab            => i_id
    );
end;

procedure mark_error_uploaded (
    i_rowid                 in com_api_type_pkg.t_rowid_tab
) is
begin
    forall i in 1 .. i_rowid.count
        update
            jcb_fin_message
        set
            status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOAD_ERR
        where
            rowid = i_rowid(i);
end;

function get_original_id (
    i_fin_rec               in jcb_api_type_pkg.t_fin_rec
) return com_api_type_pkg.t_long_id is
    l_original_id           com_api_type_pkg.t_long_id;
    l_mti                   jcb_api_type_pkg.t_mti;
    l_de024_1               jcb_api_type_pkg.t_de024;
    l_de024_2               jcb_api_type_pkg.t_de024;
    l_split_hash            com_api_type_pkg.t_inst_id;
begin
    l_split_hash := com_api_hash_pkg.get_split_hash(i_fin_rec.de002);

    if i_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_PRESENTMENT
       and i_fin_rec.de024 = jcb_api_const_pkg.FUNC_CODE_FIRST_PRES
       and i_fin_rec.is_reversal = com_api_type_pkg.TRUE
       and i_fin_rec.dispute_id is not null
    then
        l_mti := i_fin_rec.mti;

        select
            min(id)
        into
            l_original_id
        from
            jcb_fin_message
        where split_hash = l_split_hash
            and mti = l_mti
            and de024 = i_fin_rec.de024
            and is_reversal = com_api_type_pkg.FALSE
            and dispute_id = i_fin_rec.dispute_id;

    else
        if i_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
           and i_fin_rec.de024 = jcb_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
        then
            l_mti := jcb_api_const_pkg.MSG_TYPE_PRESENTMENT;
            l_de024_1 := jcb_api_const_pkg.FUNC_CODE_FIRST_PRES;
            l_de024_2 := jcb_api_const_pkg.FUNC_CODE_FIRST_PRES;

        elsif i_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_CHARGEBACK
            and i_fin_rec.de024 in (jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                                  , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART)
        then
            l_mti := jcb_api_const_pkg.MSG_TYPE_PRESENTMENT;
            l_de024_1 := jcb_api_const_pkg.FUNC_CODE_FIRST_PRES;
            l_de024_2 := jcb_api_const_pkg.FUNC_CODE_FIRST_PRES;

        elsif i_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_PRESENTMENT
            and i_fin_rec.de024 in (jcb_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
                                  , jcb_api_const_pkg.FUNC_CODE_SECOND_PRES_PART)
        then
            l_mti := jcb_api_const_pkg.MSG_TYPE_CHARGEBACK;
            l_de024_1 := jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL;
            l_de024_2 := jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART;

        elsif i_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_CHARGEBACK
            and i_fin_rec.de024 in (jcb_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
                                  , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART)
        then
            l_mti := jcb_api_const_pkg.MSG_TYPE_PRESENTMENT;
            l_de024_1 := jcb_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL;
            l_de024_2 := jcb_api_const_pkg.FUNC_CODE_SECOND_PRES_PART;

        --???
        elsif i_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_FEE
            and i_fin_rec.de024 = jcb_api_const_pkg.FUNC_CODE_FEE_COLLECTION
        then
            l_mti := jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
            l_de024_1 := jcb_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST;
            l_de024_2 := jcb_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST;

        end if;

        if l_mti is not null then
            select
                min(id)
            into
                l_original_id
            from
                jcb_fin_message
            where split_hash = l_split_hash
                and mti = l_mti
                and de024 in (l_de024_1, l_de024_2)
                and de031 = i_fin_rec.de031;
        end if;
    end if;

    if l_original_id is null and l_mti is not null then
        g_no_original_id_tab(g_no_original_id_tab.count + 1) := i_fin_rec;
    end if;

    return l_original_id;
end;

procedure create_operation(
    i_fin_rec             in jcb_api_type_pkg.t_fin_rec
  , i_standard_id         in com_api_type_pkg.t_tiny_id
  , i_auth                in aut_api_type_pkg.t_auth_rec
  , i_status              in com_api_type_pkg.t_dict_value := null
  , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
  , i_host_id             in com_api_type_pkg.t_tiny_id    default null
) is
    l_iss_inst_id                   com_api_type_pkg.t_inst_id;
    l_acq_inst_id                   com_api_type_pkg.t_inst_id;
    l_card_inst_id                  com_api_type_pkg.t_inst_id;
    l_iss_network_id                com_api_type_pkg.t_tiny_id;
    l_acq_network_id                com_api_type_pkg.t_tiny_id;
    l_card_network_id               com_api_type_pkg.t_tiny_id;
    l_card_type_id                  com_api_type_pkg.t_tiny_id;
    l_card_country                  com_api_type_pkg.t_country_code;
    l_bin_currency                  com_api_type_pkg.t_curr_code;
    l_sttl_currency                 com_api_type_pkg.t_curr_code;
    l_msg_type                      com_api_type_pkg.t_dict_value;
    l_sttl_type                     com_api_type_pkg.t_dict_value;
    l_status                        com_api_type_pkg.t_dict_value;
    l_match_status                  com_api_type_pkg.t_dict_value;
    l_terminal_type                 com_api_type_pkg.t_dict_value;
    l_oper_type                     com_api_type_pkg.t_dict_value;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_original_id                   com_api_type_pkg.t_long_id;
    l_proc_mode                     com_api_type_pkg.t_dict_value;
    l_terminal_number               com_api_type_pkg.t_terminal_number;

    l_operation                     opr_api_type_pkg.t_oper_rec;
    l_participant                   opr_api_type_pkg.t_oper_part_rec;
    l_iss_part                      opr_api_type_pkg.t_oper_part_rec;
    l_acq_part                      opr_api_type_pkg.t_oper_part_rec;
begin
    l_oper_id     := i_fin_rec.id;
    l_original_id := get_original_id(i_fin_rec => i_fin_rec);
    l_status      := nvl(i_status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY);

    if i_fin_rec.is_reversal = com_api_type_pkg.TRUE
       and i_fin_rec.is_incoming = com_api_type_pkg.FALSE
    then
        opr_api_operation_pkg.get_operation(
            i_oper_id    => l_original_id
          , o_operation  => l_operation
        );

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

    -- we do not create disputes yet
    elsif i_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_FEE
      and i_fin_rec.de024 = jcb_api_const_pkg.FUNC_CODE_FEE_COLLECTION
      and (i_auth.id is null or i_fin_rec.is_incoming = com_api_type_pkg.FALSE)
    then
        
        null;        

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

        if l_card_inst_id is null then
            l_iss_inst_id    := i_fin_rec.inst_id;
            l_iss_network_id := ost_api_institution_pkg.get_inst_network(i_fin_rec.inst_id);
        end if;

        if l_acq_inst_id is null then
            l_acq_network_id := i_fin_rec.network_id;
            l_acq_inst_id    := net_api_network_pkg.get_inst_id(i_fin_rec.network_id);
        end if;

        if l_acq_network_id is null then
            l_acq_network_id := ost_api_institution_pkg.get_inst_network(l_acq_inst_id);
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

                update jcb_fin_message
                   set status = jcb_api_const_pkg.MSG_STATUS_INVALID
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
    end if;

    -- Operation type and message type are not defined by a financial message in case of reversal operation,
    -- fields' values of an original operation are used instead of this
    if l_msg_type is null then
        l_msg_type := net_api_map_pkg.get_msg_type(
                          i_network_msg_type   => i_fin_rec.mti || i_fin_rec.de024
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

    if i_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_PRESENTMENT
        and i_fin_rec.de024 =jcb_api_const_pkg.FUNC_CODE_FIRST_PRES
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
        end if;
    end if;

    -- if chargeback operation
    if i_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_CHARGEBACK
       and i_fin_rec.de024 in (jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                             , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                             , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
                             , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART) then
        opr_api_operation_pkg.get_operation(
            i_oper_id             => l_original_id
          , o_operation           => l_operation
        );
        opr_api_operation_pkg.get_participant(
            i_oper_id            => l_operation.id
          , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ISSUER
          , o_participant        => l_participant
        );

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

    if l_terminal_type is null then
        l_terminal_type  :=
        case i_fin_rec.de026
            when jcb_api_const_pkg.MCC_ATM
            then acq_api_const_pkg.TERMINAL_TYPE_ATM
            else acq_api_const_pkg.TERMINAL_TYPE_POS
        end;
    end if;
    
    if i_fin_rec.status = jcb_api_const_pkg.MSG_STATUS_INVALID then
        
        l_status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        
    end if;
    
    opr_api_create_pkg.create_operation(
        io_oper_id              => l_oper_id
      , i_session_id            => get_session_id
      , i_status                => l_status
      , i_status_reason         => null
      , i_sttl_type             => l_sttl_type
      , i_msg_type              => l_msg_type
      , i_oper_type             => l_oper_type
      , i_oper_reason           => null
      , i_is_reversal           => i_fin_rec.is_reversal
      , i_original_id           => l_original_id
      , i_oper_amount           => nvl(i_fin_rec.de004, i_fin_rec.de030_1)
      , i_oper_currency         => i_fin_rec.de049
      , i_oper_cashback_amount  => null
      , i_sttl_amount           => i_fin_rec.de005
      , i_sttl_currency         => i_fin_rec.de050
      , i_oper_date             => i_fin_rec.de012
      , i_host_date             => null
      , i_terminal_type         => l_terminal_type 
      , i_mcc                   => i_fin_rec.de026
      , i_originator_refnum     => i_fin_rec.de037
      , i_network_refnum        => i_fin_rec.de031
      , i_acq_inst_bin          => nvl(i_fin_rec.de032, i_fin_rec.de033)
      , i_merchant_number       => i_fin_rec.de042
      , i_terminal_number       => nvl(l_terminal_number, i_fin_rec.de041)
      , i_merchant_name         => i_fin_rec.de043_1
      , i_merchant_street       => i_fin_rec.de043_2
      , i_merchant_city         => i_fin_rec.de043_3
      , i_merchant_region       => i_fin_rec.de043_5
      , i_merchant_country      => com_api_country_pkg.get_country_code_by_name(i_fin_rec.de043_6, com_api_type_pkg.FALSE)
      , i_merchant_postcode     => i_fin_rec.de043_4
      , i_dispute_id            => i_fin_rec.dispute_id
      , i_match_status          => l_match_status
      , i_proc_mode             => l_proc_mode
      , i_incom_sess_file_id    => i_incom_sess_file_id
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
      , i_client_id_type    => opr_api_const_pkg.CLIENT_ID_TYPE_CARD
      , i_client_id_value   => i_fin_rec.de002
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
      , i_merchant_id       => l_acq_part.merchant_id
      , i_terminal_id       => l_acq_part.terminal_id
      , i_terminal_number   => nvl(l_terminal_number, i_fin_rec.de041)
      , i_split_hash        => l_acq_part.split_hash
      , i_without_checks    => com_api_const_pkg.TRUE
    );
end;

procedure put_message (
    i_fin_rec               in jcb_api_type_pkg.t_fin_rec
) is
    l_split_hash            com_api_type_pkg.t_tiny_id;
begin
    l_split_hash := com_api_hash_pkg.get_split_hash(i_fin_rec.de002);

    trc_log_pkg.debug (
        i_text          => 'put_message start'
    );

    insert into jcb_fin_message (
        id
        , split_hash     
        , status         
        , inst_id        
        , network_id     
        , file_id        
        , is_incoming    
        , is_reversal    
        , is_rejected    
        , reject_id      
        , dispute_id     
        , dispute_rn     
        , impact         
        , mti                
        --, de002          
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
        , de016          
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
        , de022_12       
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
        , de071          
        , de072          
        , de093          
        , de094          
        , de097          
        , de100              
        , p3001          
        , p3002        
        , p3003          
        , p3005          
        , p3006
        , p3007_1        
        , p3007_2        
        , p3008          
        , p3009          
        , p3011          
        , p3012          
        , p3013          
        , p3014          
        , p3021          
        , p3201          
        , p3202          
        , p3203          
        , p3205          
        , p3206          
        , p3207          
        , p3208          
        , p3209          
        , p3210          
        , p3211          
        , p3250          
        , p3251          
        , p3302          
        , emv_9f26       
        , emv_9f02       
        , emv_9f27       
        , emv_9f10       
        , emv_9f36       
        , emv_95         
        , emv_82         
        , emv_9a         
        , emv_9c         
        , emv_9f37       
        , emv_5f2a       
        , emv_9f33       
        , emv_9f34       
        , emv_9f1a       
        , emv_9f35       
        , emv_84         
        , emv_9f09       
        , emv_9f03       
        , emv_9f1e       
        , emv_9f41          
        , emv_4f           
    ) values (
        i_fin_rec.id
        , l_split_hash
        , i_fin_rec.status         
        , i_fin_rec.inst_id        
        , i_fin_rec.network_id     
        , i_fin_rec.file_id        
        , i_fin_rec.is_incoming    
        , i_fin_rec.is_reversal    
        , i_fin_rec.is_rejected    
        , null      
        , i_fin_rec.dispute_id     
        , i_fin_rec.dispute_rn     
        , i_fin_rec.impact         
        , i_fin_rec.mti                
        --, i_fin_rec.de002          
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
        , i_fin_rec.de016          
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
        , i_fin_rec.de022_12       
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
        , i_fin_rec.de071          
        , i_fin_rec.de072          
        , i_fin_rec.de093          
        , i_fin_rec.de094          
        , i_fin_rec.de097          
        , i_fin_rec.de100              
        , i_fin_rec.p3001          
        , i_fin_rec.p3002        
        , i_fin_rec.p3003          
        , i_fin_rec.p3005          
        , i_fin_rec.p3006
        , i_fin_rec.p3007_1        
        , i_fin_rec.p3007_2        
        , i_fin_rec.p3008          
        , i_fin_rec.p3009          
        , i_fin_rec.p3011          
        , i_fin_rec.p3012          
        , i_fin_rec.p3013          
        , i_fin_rec.p3014          
        , i_fin_rec.p3021          
        , i_fin_rec.p3201          
        , i_fin_rec.p3202          
        , i_fin_rec.p3203          
        , i_fin_rec.p3205          
        , i_fin_rec.p3206          
        , i_fin_rec.p3207          
        , i_fin_rec.p3208          
        , i_fin_rec.p3209          
        , i_fin_rec.p3210          
        , i_fin_rec.p3211          
        , i_fin_rec.p3250          
        , i_fin_rec.p3251          
        , i_fin_rec.p3302          
        , i_fin_rec.emv_9f26       
        , i_fin_rec.emv_9f02       
        , i_fin_rec.emv_9f27       
        , i_fin_rec.emv_9f10       
        , i_fin_rec.emv_9f36       
        , i_fin_rec.emv_95         
        , i_fin_rec.emv_82         
        , i_fin_rec.emv_9a         
        , i_fin_rec.emv_9c         
        , i_fin_rec.emv_9f37       
        , i_fin_rec.emv_5f2a       
        , i_fin_rec.emv_9f33       
        , i_fin_rec.emv_9f34       
        , i_fin_rec.emv_9f1a       
        , i_fin_rec.emv_9f35       
        , i_fin_rec.emv_84         
        , i_fin_rec.emv_9f09       
        , i_fin_rec.emv_9f03       
        , i_fin_rec.emv_9f1e       
        , i_fin_rec.emv_9f41          
        , i_fin_rec.emv_4f           
    );

    insert into jcb_card (
        id
        , card_number
    ) values (
        i_fin_rec.id
        , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.de002)
    );

    trc_log_pkg.debug (
        i_text          => 'put_message end'
    );
    
end;

/*
 * When the parameter is set to TRUE then a string of EMV data is considered as a string of HEX digits.
 * otherwise, it is meant as a raw/binary string,
 * i.e. it may contain HEX digits, numeric symbols or alpha-numeric ones.
 */
function is_binary
return com_api_type_pkg.t_boolean
result_cache
is
begin
    return nvl(
               set_ui_value_pkg.get_system_param_n(i_param_name => 'EMV_TAGS_IS_BINARY')
             , com_api_type_pkg.FALSE
           );
end;

procedure get_emv_data(
    io_fin_rec              in out nocopy jcb_api_type_pkg.t_fin_rec
  , i_mask_error            in            com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_emv_data              in            com_api_type_pkg.t_text
  , o_emv_tag_tab           out           com_api_type_pkg.t_tag_value_tab
) is
    l_data                  com_api_type_pkg.t_name;
    l_is_binary             com_api_type_pkg.t_boolean := is_binary();
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

    -- mandatory tags
    io_fin_rec.emv_9f26 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F26' 
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f27 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F27' 
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f10 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F10'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f37 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F37' 
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f36 := emv_api_tag_pkg.get_tag_value(
        i_tag            => '9F36' 
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_95 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '95'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    l_data := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9A' 
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    if l_data is not null and ltrim(l_data, '0') is not null then
        if substr(l_data, 5, 2) = '00' then
            io_fin_rec.emv_9a := to_date(substr(l_data, 1, 4)||'01', jcb_api_const_pkg.TAG_9A_DATE_FORMAT);
        else
            io_fin_rec.emv_9a := to_date(l_data, jcb_api_const_pkg.TAG_9A_DATE_FORMAT);
        end if;
    end if;
    io_fin_rec.emv_9c := emv_api_tag_pkg.get_tag_value(
        i_tag            => '9C' 
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f02 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F02'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_5f2a := emv_api_tag_pkg.get_tag_value (
        i_tag            => '5F2A' 
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_82 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '82' 
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f1a := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F1A' 
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f03 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F03'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );

    -- Conditional tags
    io_fin_rec.emv_9f34 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F34'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f35 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F35'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f09 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F09'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f33 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F33'
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
        io_fin_rec.emv_9f1e := prs_api_util_pkg.hex2bin(i_hex_string => io_fin_rec.emv_9f1e);
    end if;

    io_fin_rec.emv_4f := emv_api_tag_pkg.get_tag_value (
        i_tag            => '4F'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_9f41 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '9F41'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );
    io_fin_rec.emv_84 := emv_api_tag_pkg.get_tag_value (
        i_tag            => '84'
        , i_emv_tag_tab  => o_emv_tag_tab
        , i_mask_error   => i_mask_error
    );

    -- check all mandatory tags for field C055
    if io_fin_rec.emv_9f02 is null then
        io_fin_rec.emv_9f26 := null;
        io_fin_rec.emv_9f27 := null;
        io_fin_rec.emv_9f10 := null;
        io_fin_rec.emv_9f36 := null;
        io_fin_rec.emv_95   := null;
        io_fin_rec.emv_82   := null;
        io_fin_rec.emv_9a   := null;
        io_fin_rec.emv_9c   := null;
        io_fin_rec.emv_9f37 := null;
        io_fin_rec.emv_5f2a := null;
        io_fin_rec.emv_9f33 := null;
        io_fin_rec.emv_9f34 := null;
        io_fin_rec.emv_9f1a := null;
        io_fin_rec.emv_9f35 := null;
        io_fin_rec.emv_84   := null;
        io_fin_rec.emv_9f09 := null;
        io_fin_rec.emv_9f03 := null;
        io_fin_rec.emv_9f1e := null;
        io_fin_rec.emv_9f41 := null;
        io_fin_rec.emv_4f   := null;
    end if;

exception
    when others then -- removed EMV parsing when loading because it is not necessary
        trc_log_pkg.debug(
            i_text        => lower($$PLSQL_UNIT) || '.get_emv_data FAILED with [#1]; dumping o_emv_tag_tab...'
          , i_env_param1  => sqlerrm
        );
end;

procedure create_from_auth (
    i_auth_rec              in aut_api_type_pkg.t_auth_rec
    , i_id                  in com_api_type_pkg.t_long_id
    , i_inst_id             in com_api_type_pkg.t_inst_id := null
    , i_network_id          in com_api_type_pkg.t_tiny_id := null
    , i_status              in com_api_type_pkg.t_dict_value := null
    , i_collection_only     in com_api_type_pkg.t_boolean := null
) is
    l_fin_rec               jcb_api_type_pkg.t_fin_rec;
    l_stage                 varchar2(100);
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_standard_version      com_api_type_pkg.t_tiny_id;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_acquirer_bin          com_api_type_pkg.t_rrn;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_emv_tag_tab           com_api_type_pkg.t_tag_value_tab;
    l_tag_id                com_api_type_pkg.t_short_id;
    l_atm_fee_charge        com_api_type_pkg.t_boolean;

    procedure read_de22s is
    begin
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

        l_fin_rec.de022_5  := case i_auth_rec.crdh_presence
                                  when 'F2250000' then '0'
                                  when 'F2250001' then '1'
                                  when 'F2250002' then '2'
                                  when 'F2250003' then '3'
                                  when 'F2250004' then '4'
                                  when 'F2250005' then '5'
                                  when 'F2250009' then '9'
                                  else '9'
                              end;

        l_fin_rec.de022_6  := case i_auth_rec.card_presence
                                  when 'F2260000' then '0'
                                  when 'F2260001' then '1'
                                  when 'F2260009' then '9'
                                  else '9'
                              end;

        l_fin_rec.de022_7  := case i_auth_rec.card_data_input_mode
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

        l_fin_rec.de022_8  := case i_auth_rec.crdh_auth_method
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

        l_fin_rec.de022_9  := case i_auth_rec.crdh_auth_entity
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

        l_fin_rec.de022_10 := case i_auth_rec.card_data_output_cap
                                  when 'F22A0000' then '0'
                                  when 'F22A0001' then '1'
                                  when 'F22A0002' then '2'
                                  when 'F22A0003' then '3'
                                  when 'F22A000S' then 'S'
                                  else '0'
                              end;

        l_fin_rec.de022_11 := case i_auth_rec.terminal_output_cap
                                  when 'F22B0000' then '0'
                                  when 'F22B0001' then '1'
                                  when 'F22B0002' then '2'
                                  when 'F22B0003' then '3'
                                  when 'F22B0004' then '4'
                                  else '0'
                              end;

        l_fin_rec.de022_12 := case i_auth_rec.pin_capture_cap
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
    end read_de22s;

    procedure correct_de22s is
      l_de061_1     jcb_api_type_pkg.t_de022s;
      l_de061_2     jcb_api_type_pkg.t_de022s;    
      l_de022_1_2   com_api_type_pkg.t_byte_char;    
      l_de022_7     jcb_api_type_pkg.t_de022s;    
      l_de022_5     jcb_api_type_pkg.t_de022s;    
    begin
        -- de022_1
        if l_fin_rec.de022_1 in ('A','B') then
            l_fin_rec.de022_1:= '2';
        
        elsif l_fin_rec.de022_1 in ('C','D','E','M') then   
            l_fin_rec.de022_1:= '5';
            
        elsif l_fin_rec.de022_1 in ('V') then
            l_fin_rec.de022_1:= '0';         
        end if;
                                
        -- de022_3
        if l_fin_rec.de022_3 = '2' then
            l_fin_rec.de022_3:= '0';
        end if;

        -- de022_2
        /*if l_fin_rec.de022_3 = '0' then
            l_fin_rec.de022_2:= '0';
        elsif l_fin_rec.de022_3 = '1' then    
            l_fin_rec.de022_2:= '1';
        elsif l_fin_rec.de022_3 = '2' then    
            l_fin_rec.de022_2:= '9';
        end if;*/    
        
        -- de022_4
        if l_fin_rec.de022_4 in ('6','7','9','A','B') then
            l_fin_rec.de022_4:= 'Z';
        end if;
            
        -- de022_5
        if l_fin_rec.de022_5 = '4' then
            l_fin_rec.de022_5 := '8';
        end if;

        if l_fin_rec.de022_5 = '5' then
            l_fin_rec.de022_5 := '9';
        end if;    

        /*if l_fin_rec.de022_5 in ('2', '3') then
            l_de061_1 := '1';
        else       
            l_de061_1 := '2';
        end if;

        if l_fin_rec.de022_5 = '4' then     
            l_de061_2 := '1';
        else
            l_de061_2 := '2';
        end if;  
                              
        case l_de061_1||l_de061_2
            when '00' then l_de022_5 := 'Z';
            when '01' then l_de022_5 := '4';
            when '02' then l_de022_5 := 'Z';
            when '10' then l_de022_5 := '2';
            when '11' then l_de022_5 := '4';
            when '12' then l_de022_5 := '2';
            when '20' then l_de022_5 := 'Z';
            when '21' then l_de022_5 := '4';
            when '22' then l_de022_5 := 'Z';
        else
            l_de022_5 := null;
        end case;                                                
        
        l_fin_rec.de022_5 := nvl(l_de022_5, l_fin_rec.de022_5);
        
        */

        -- de022_6
        if l_fin_rec.de022_6 = '0' then
            l_fin_rec.de022_6 := '1';
        elsif l_fin_rec.de022_6 = '1' then
            l_fin_rec.de022_6 := '0';
        else
            l_fin_rec.de022_6 := 'Z';
        end if;
        
        -- de022_7
        if l_fin_rec.de022_7 = 'F' then
            l_fin_rec.de022_7 := 'C';
        
        elsif l_fin_rec.de022_7 in ('M', 'N', 'P') then
            l_fin_rec.de022_7 := 'M';

        elsif l_fin_rec.de022_7 in ('S', 'R', '9', '7', '5', '8') then
            l_fin_rec.de022_7 := 'S';

        elsif l_fin_rec.de022_7 = 'B' then
            l_fin_rec.de022_7 := 'U';
        end if;    
        
        -- Analize service code and card data input capability
        if l_fin_rec.de022_7 = '2' and l_fin_rec.de022_1 in ('5', '8') and substr(l_fin_rec.de040,1,1) in ('2', '6') then
            l_fin_rec.de022_7 := 'U';
        end if;
        /*l_de022_1_2 := l_fin_rec.de022_1 || l_fin_rec.de022_2;
        l_de022_7 := 
            case l_de022_1_2
                when '00' then '0'
                when '01' then '1'
                when '02' then '2'
                when '05' then 'C'
                when '07' then 'M'
                when '81' then 'S'
                when '91' then 'A'
                when '97' then 'U'
                else null
            end;
        l_fin_rec.de022_7 := nvl(l_de022_7, l_fin_rec.de022_7);
        */
        
        -- de022_8
        if l_fin_rec.de022_8 in ('9','S', 'W', 'X') then
            l_fin_rec.de022_8:= 'Z';
        end if;

        -- de022_9
        if l_fin_rec.de022_9 = '6' then
            l_fin_rec.de022_9 := '4';
        
        elsif l_fin_rec.de022_9 = '9' then   
            l_fin_rec.de022_9 := '5';
        end if;        

        -- de022_10
        if l_fin_rec.de022_10 = 'S' then
            l_fin_rec.de022_10 := '0';
        end if;        

    end correct_de22s;

begin
    l_stage := 'start';

    l_standard_version :=
        cmn_api_standard_pkg.get_current_version(
            i_network_id  => nvl(i_network_id, i_auth_rec.iss_network_id)
        );

    if i_auth_rec.is_reversal = com_api_type_pkg.TRUE then

        -- find presentment and make reversal
        get_fin (
            i_id            => i_auth_rec.original_id
            , o_fin_rec     => l_fin_rec
        );

        update
            jcb_fin_message
        set
            status = case when status in (net_api_const_pkg.CLEARING_MSG_STATUS_READY)
                           and de004 = i_auth_rec.oper_amount
                          then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                          else status
                     end
        where
            rowid = l_fin_rec.row_id
        returning
            case when status in (net_api_const_pkg.CLEARING_MSG_STATUS_PENDING)
                   or i_auth_rec.oper_amount = 0
                 then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                 else nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY)
            end
        into
            l_fin_rec.status;
            
        l_fin_rec.p3007_1 := jcb_api_const_pkg.REVERSAL_PDS_REVERSAL;
       
        get_processing_date (
            i_id             => l_fin_rec.id
            , i_file_id      => l_fin_rec.file_id
            , o_p3007_2      => l_fin_rec.p3007_2
        );

        l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal := com_api_type_pkg.TRUE;
        l_fin_rec.is_rejected := com_api_type_pkg.FALSE;
        l_fin_rec.file_id     := null;

        -- For de003 Reversal / Chargeback / Representment / Retrieval Transaction shall be set the same value as Presentment Transaction.

        l_fin_rec.impact := jcb_utl_pkg.get_message_impact (
            i_mti           => l_fin_rec.mti
            , i_de024       => l_fin_rec.de024
            , i_de003_1     => l_fin_rec.de003_1
            , i_is_reversal => l_fin_rec.is_reversal
            , i_is_incoming => l_fin_rec.is_incoming
        );
        
        l_fin_rec.de004 := i_auth_rec.oper_amount;
        l_fin_rec.de049 := i_auth_rec.oper_currency;

        jcb_utl_pkg.add_curr_exp (
            io_p3002        => l_fin_rec.p3002,
            i_curr_code     => l_fin_rec.de049
        );

        l_fin_rec.id := i_id;

        l_stage := 'put';        
        put_message (
            i_fin_rec   => l_fin_rec
        );

        l_stage := 'done';

    else
        l_fin_rec.id := i_id;
        l_fin_rec.status      := case when i_auth_rec.oper_amount = 0
                                     then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                                     else nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY)
                                 end;
        l_fin_rec.inst_id     := i_auth_rec.acq_inst_id;
        l_fin_rec.network_id  := i_auth_rec.iss_network_id;
        l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal := i_auth_rec.is_reversal;
        l_fin_rec.is_rejected := com_api_type_pkg.FALSE;

        l_fin_rec.mti   := jcb_api_const_pkg.MSG_TYPE_PRESENTMENT;
        l_fin_rec.de024 := jcb_api_const_pkg.FUNC_CODE_FIRST_PRES;
        l_fin_rec.de026 := i_auth_rec.mcc;

        l_stage := 'de003';
        l_host_id := net_api_network_pkg.get_member_id (
            i_inst_id       => nvl(i_inst_id, i_auth_rec.iss_inst_id)
           , i_network_id   => nvl(i_network_id, i_auth_rec.iss_network_id)
        );

        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id       => l_host_id
        );
        jcb_utl_pkg.get_jcb_transaction_type (
            i_oper_type          => i_auth_rec.oper_type
            , i_mcc              => i_auth_rec.mcc
            , o_de003_1          => l_fin_rec.de003_1
            , i_standard_version => l_standard_version
        );
        
        l_stage := 'impact';
        l_fin_rec.impact := jcb_utl_pkg.get_message_impact (
            i_mti           => l_fin_rec.mti
            , i_de024       => l_fin_rec.de024
            , i_de003_1     => l_fin_rec.de003_1
            , i_is_reversal => l_fin_rec.is_reversal
            , i_is_incoming => l_fin_rec.is_incoming
        );
        
        l_stage := 'card';
        l_fin_rec.de002   := i_auth_rec.card_number;
        l_fin_rec.de003_2 := nvl(substr(i_auth_rec.account_type, -2), jcb_api_const_pkg.DEFAULT_DE003_2);
        l_fin_rec.de003_3 := nvl(substr(i_auth_rec.dst_account_type, -2), jcb_api_const_pkg.DEFAULT_DE003_3);
        l_fin_rec.de004   := i_auth_rec.oper_amount;
        
        l_stage := 'de012';
        l_tag_id          := aup_api_tag_pkg.find_tag_by_reference('DF8423');
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT) || ' l_tag_id = ' || l_tag_id
                                          || ', nvl(aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id), i_auth_rec.host_date) = ' || nvl(aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id), i_auth_rec.host_date)
                                          || ', trunc(i_auth_rec.card_expir_date) = ' || trunc(i_auth_rec.card_expir_date)
        );
        
        l_fin_rec.de012   := nvl(
                                  to_date(aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id)
                                        , jcb_api_const_pkg.DE012_DATE_FORMAT)
                                , i_auth_rec.host_date
                                );
        l_fin_rec.de014   := trunc(i_auth_rec.card_expir_date);-- null; -- JCB required not to fill 

        l_stage := 'de022';
        read_de22s;
        correct_de22s;

        l_stage := 'de026';
        l_fin_rec.de026 := i_auth_rec.mcc;

        l_stage := 'de038';
        l_fin_rec.de038 := i_auth_rec.auth_code;
        l_fin_rec.de040 := i_auth_rec.card_service_code;

        l_stage := 'de031';
        l_acquirer_bin := nvl(
            cmn_api_standard_pkg.get_varchar_value (
                i_inst_id     => l_fin_rec.inst_id
              , i_standard_id => l_standard_id
              , i_object_id   => l_host_id
              , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name  => jcb_api_const_pkg.CMID
              , i_param_tab   => l_param_tab
            )
          , i_auth_rec.acq_inst_bin
        );

        l_fin_rec.de031 := jcb_utl_pkg.get_arn(
            i_acquirer_bin => l_acquirer_bin
        );

        l_stage := 'de032, de033, de094';
        l_fin_rec.de032   := l_acquirer_bin;
        l_fin_rec.de033   := l_acquirer_bin;

        l_fin_rec.de094 := cmn_api_standard_pkg.get_varchar_value (
            i_inst_id       => l_fin_rec.inst_id
            , i_standard_id => l_standard_id
            , i_object_id   => l_host_id
            , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_param_name  => jcb_api_const_pkg.CMID
            , i_param_tab   => l_param_tab
        );

        l_stage := 'de037';
        l_fin_rec.de037   := i_auth_rec.originator_refnum;

        l_stage := 'de041';
        l_fin_rec.de041   := 
            case when length(i_auth_rec.terminal_number) >= 8 
               then substr(i_auth_rec.terminal_number, -8) 
               else i_auth_rec.terminal_number
            end;
        l_fin_rec.de042   := i_auth_rec.merchant_number;
        l_fin_rec.de043_1 := substr(i_auth_rec.merchant_name, 1, 25);
        l_fin_rec.de043_2 := substr(i_auth_rec.merchant_street, 1, 45);
        l_fin_rec.de043_3 := substr(i_auth_rec.merchant_city, 1, 13);
        l_fin_rec.de043_4 := substr(i_auth_rec.merchant_postcode, 1, 10);
        l_fin_rec.de043_6 := com_api_country_pkg.get_country_name(i_code => i_auth_rec.merchant_country);--i_auth_rec.merchant_region;
        l_fin_rec.de043_5 := l_fin_rec.de043_6;

        l_stage := 'de049';
        l_fin_rec.de049 := i_auth_rec.oper_currency;
        jcb_utl_pkg.add_curr_exp (
            io_p3002        => l_fin_rec.p3002,
            i_curr_code     => l_fin_rec.de049
        );

        if l_standard_version >= jcb_api_const_pkg.STANDARD_ID_VERISON_18Q2 then 
            l_atm_fee_charge := cmn_api_standard_pkg.get_number_value(
                i_inst_id       => l_fin_rec.inst_id
                , i_standard_id => l_standard_id
                , i_object_id   => l_host_id
                , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
                , i_param_name  => jcb_api_const_pkg.ATM_FEE_CHARGE
                , i_param_tab   => l_param_tab
            );
            if l_atm_fee_charge = com_api_const_pkg.TRUE then 
                l_fin_rec.de054 := set_de054 (
                    i_amount    => i_auth_rec.oper_surcharge_amount
                  , i_currency  => i_auth_rec.oper_currency
                  , i_type      => '42'
                );
            end if;
        end if;

        l_stage := 'emv';
        if  l_fin_rec.de022_1 in ('5', 'C', 'D', 'E', 'M') 
            and 
            (
                l_fin_rec.de022_7 in ('5', 'C', 'F', 'M', 'N', 'P')
                 or
                 (l_fin_rec.de022_7 = 'Z' and i_auth_rec.emv_data is not null)   
             )
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
                                      , i_tag_type_tab => jcb_api_const_pkg.EMV_TAGS_LIST_FOR_DE055
                                    )
                               );

            l_fin_rec.de023 := i_auth_rec.card_seq_number;
        
        else
            l_fin_rec.de023 := null;  
            l_fin_rec.de014 := null;          
        end if;

        l_stage := 'put addendum message';
        if l_fin_rec.de003_1 = jcb_api_const_pkg.PROC_CODE_SENDER_CREDIT then  --p2p Credit
            jcb_api_add_pkg.create_outgoing_addendum (
                i_fin_rec       => l_fin_rec
            );
        end if;

        l_stage := 'p3009';
        if l_fin_rec.de022_7 = 'S' then
            case
                when substr(i_auth_rec.addl_data, 1, 2) = '01' and substr(i_auth_rec.addl_data, 203, 1) = '2'
                then l_fin_rec.p3009 := '05';
                when substr(i_auth_rec.addl_data, 1, 2) = '01' and substr(i_auth_rec.addl_data, 203, 1) = '1'
                then l_fin_rec.p3009 := '06';
                when substr(i_auth_rec.addl_data, 1, 2) = '01' and substr(i_auth_rec.addl_data, 203, 1) = '0'
                  or substr(i_auth_rec.addl_data, 1, 2) = '02'
                  or substr(i_auth_rec.addl_data, 203, 1) = '3'
                then l_fin_rec.p3009 := '07';
                else l_fin_rec.p3009 := null;
            end case;             
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
            i_text          => 'Error generating JCB presentment on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end;

procedure set_message (
    i_mes_rec               in jcb_api_type_pkg.t_mes_rec
    , io_fin_rec            in out nocopy jcb_api_type_pkg.t_fin_rec
    , io_pds_tab            in out nocopy jcb_api_type_pkg.t_pds_tab
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_financial           in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
    , io_p3005_tab          in out nocopy jcb_api_type_pkg.t_p3005_tab
) is
    l_pds_body              jcb_api_type_pkg.t_pds_body;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_card_type             com_api_type_pkg.t_tiny_id;
    l_card_country          com_api_type_pkg.t_curr_code;
    l_emv_tag_tab           com_api_type_pkg.t_tag_value_tab;
    l_stage                 varchar2(100);
    l_p3007                 com_api_type_pkg.t_name;
    l_standard_version      com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text => 'set message: start for ' || i_mes_rec.mti
    );
    l_standard_version :=
        cmn_api_standard_pkg.get_current_version(
            i_network_id  => i_network_id
        );

    l_stage := 'de026';
    io_fin_rec.de026 := i_mes_rec.de026;
    io_fin_rec.de025 := i_mes_rec.de025;

    l_stage := 'de003';
    io_fin_rec.de003_1 := i_mes_rec.de003_1;
    io_fin_rec.de003_2 := i_mes_rec.de003_2;
    io_fin_rec.de003_3 := i_mes_rec.de003_3;

    l_stage := 'extract_pds';
    jcb_api_pds_pkg.extract_pds (
        de048       => i_mes_rec.de048
        , de062     => i_mes_rec.de062
        , de123     => i_mes_rec.de123
        , de124     => i_mes_rec.de124
        , de125     => i_mes_rec.de125
        , de126     => i_mes_rec.de126
        , pds_tab   => io_pds_tab
    );
    
    l_stage := 'card';
    io_fin_rec.de002   := i_mes_rec.de002;

    l_stage := 'de004 - de010';
    io_fin_rec.de004   := i_mes_rec.de004;
    io_fin_rec.de005   := i_mes_rec.de005;
    io_fin_rec.de006   := i_mes_rec.de006;
    io_fin_rec.de009   := i_mes_rec.de009;
    io_fin_rec.de010   := i_mes_rec.de010;

    l_stage := 'de012 - de016';
    io_fin_rec.de012   := i_mes_rec.de012;
    io_fin_rec.de014   := last_day(i_mes_rec.de014);
    io_fin_rec.de016   := i_mes_rec.de016;

    l_stage := 'de022';
    io_fin_rec.de022_1 := i_mes_rec.de022_1;
    io_fin_rec.de022_2 := i_mes_rec.de022_2;
    io_fin_rec.de022_3 := i_mes_rec.de022_3;
    io_fin_rec.de022_4 := i_mes_rec.de022_4;
    io_fin_rec.de022_5 := i_mes_rec.de022_5;
    io_fin_rec.de022_6 := i_mes_rec.de022_6;
    io_fin_rec.de022_7 := i_mes_rec.de022_7;
    io_fin_rec.de022_8 := i_mes_rec.de022_8;
    io_fin_rec.de022_9 := i_mes_rec.de022_9;
    io_fin_rec.de022_10 := i_mes_rec.de022_10;
    io_fin_rec.de022_11 := i_mes_rec.de022_11;
    io_fin_rec.de022_12 := i_mes_rec.de022_12;

    l_stage := 'de023, de026';
    io_fin_rec.de023   := i_mes_rec.de023;
    io_fin_rec.de026   := i_mes_rec.de026;

    l_stage := 'de030 - de042';
    io_fin_rec.de030_1 := i_mes_rec.de030_1;
    io_fin_rec.de030_2 := i_mes_rec.de030_2;
    io_fin_rec.de031   := i_mes_rec.de031;
    io_fin_rec.de032   := i_mes_rec.de032;
    io_fin_rec.de033   := i_mes_rec.de033;
    io_fin_rec.de037   := i_mes_rec.de037;
    io_fin_rec.de038   := i_mes_rec.de038;
    io_fin_rec.de040   := i_mes_rec.de040;
    io_fin_rec.de041   := i_mes_rec.de041;
    io_fin_rec.de042   := i_mes_rec.de042;

    l_stage := 'de043';
    io_fin_rec.de043_1 := i_mes_rec.de043_1;
    io_fin_rec.de043_2 := i_mes_rec.de043_2;
    io_fin_rec.de043_3 := i_mes_rec.de043_3;
    io_fin_rec.de043_4 := i_mes_rec.de043_4;
    io_fin_rec.de043_5 := i_mes_rec.de043_5;
    io_fin_rec.de043_6 := i_mes_rec.de043_6;

    l_stage := 'de049';
    io_fin_rec.de049   := i_mes_rec.de049;
    l_stage := 'de050';
    io_fin_rec.de050   := i_mes_rec.de050;
    l_stage := 'de051';
    io_fin_rec.de051   := i_mes_rec.de051;
    l_stage := 'de054';
    io_fin_rec.de054   := i_mes_rec.de054;

    l_stage := 'de055';
    io_fin_rec.de055   := i_mes_rec.de055;
    if io_fin_rec.de055 is not null then
        get_emv_data(
            io_fin_rec    => io_fin_rec
          , i_mask_error  => com_api_type_pkg.TRUE
          , i_emv_data    => io_fin_rec.de055
          , o_emv_tag_tab => l_emv_tag_tab
        );
    end if;
    
    l_stage := 'de071';
    io_fin_rec.de071   := i_mes_rec.de071;
    l_stage := 'de072';
    io_fin_rec.de072   := i_mes_rec.de072;
    
    l_stage := 'de093';
    io_fin_rec.de093   := i_mes_rec.de093;
    l_stage := 'de094';
    io_fin_rec.de094   := i_mes_rec.de094;
    l_stage := 'de100';
    io_fin_rec.de100   := i_mes_rec.de100;
       
    l_stage := 'p3001';
    io_fin_rec.p3001 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3001
    );            

    l_stage := 'p3002';
    io_fin_rec.p3002 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3002
    );           
    
    l_stage := 'p3003';
    io_fin_rec.p3003 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3003
    );            

    l_stage := 'p3005';
    io_fin_rec.p3005 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3005
    );            

    jcb_api_pds_pkg.parse_p3005 (   
        i_p3005        => io_fin_rec.p3005
        , i_fin_rec_id => io_fin_rec.id
        , o_p3005_tab  => io_p3005_tab
    );

    l_stage := 'p3006';
    io_fin_rec.p3006 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab => io_pds_tab
      , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3006
    );
    trc_log_pkg.debug(
        i_text => 'set message: [' || io_fin_rec.p3006 || '], len=' || length(io_fin_rec.p3006)
    );

    l_stage := 'is_reversal';
    l_p3007 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab     => io_pds_tab
        , i_pds_tag   => jcb_api_const_pkg.PDS_TAG_3007
    );            

    jcb_api_pds_pkg.parse_p3007 (
        i_p3007       => l_p3007
        , o_p3007_1   => io_fin_rec.p3007_1
        , o_p3007_2   => io_fin_rec.p3007_2
    );

    if io_fin_rec.p3007_1 = jcb_api_const_pkg.REVERSAL_PDS_REVERSAL then
        
        io_fin_rec.is_reversal := com_api_type_pkg.TRUE;
    elsif io_fin_rec.p3007_1 = jcb_api_const_pkg.REVERSAL_PDS_CANCEL then
        
        io_fin_rec.is_reversal := com_api_type_pkg.FALSE;
    elsif io_fin_rec.p3007_1 is null then
        
        io_fin_rec.is_reversal := com_api_type_pkg.FALSE;
    else
        com_api_error_pkg.raise_error(
            i_error         => 'JCB_ERROR_WRONG_VALUE'
            , i_env_param1  => 'P3007_1'
            , i_env_param2  => 1
            , i_env_param3  => io_fin_rec.p3007_1
        );
    end if;
    
    l_stage := 'impact';
    if i_financial = com_api_type_pkg.TRUE then
        io_fin_rec.impact := jcb_utl_pkg.get_message_impact (
            i_mti           => io_fin_rec.mti
            , i_de024       => io_fin_rec.de024
            , i_de003_1     => io_fin_rec.de003_1
            , i_is_reversal => io_fin_rec.is_reversal
            , i_is_incoming => io_fin_rec.is_incoming
        );
    end if;
    
    l_stage := 'p3008';
    io_fin_rec.p3008 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3008
    );            
    l_stage := 'p3009';
    io_fin_rec.p3009 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3009
    );            
    l_stage := 'p3011';
    io_fin_rec.p3011 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3011
    );            
    l_stage := 'p3012';
    io_fin_rec.p3012 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3012
    );            
    l_stage := 'p3013';
    io_fin_rec.p3013 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3013
    );    
    l_stage := 'p3014';
    io_fin_rec.p3014 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3014
    );
    if l_standard_version >= jcb_api_const_pkg.STANDARD_ID_VERISON_18Q2 then
        l_stage := 'p3021';
        io_fin_rec.p3021 := jcb_api_pds_pkg.get_pds_body (
            i_pds_tab   => io_pds_tab
            , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3021
        );
    end if;
    l_stage := 'p3201';
    io_fin_rec.p3201 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3201
    );                
    l_stage := 'p3202';
    io_fin_rec.p3202 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3202
    );                
    l_stage := 'p3203';
    io_fin_rec.p3203 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3203
    );            
    l_stage := 'p3205';
    io_fin_rec.p3205 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3205
    );            
    l_stage := 'p3206';
    io_fin_rec.p3206 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3206
    );            
    l_stage := 'p3207';
    io_fin_rec.p3207 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3207
    );                
    l_stage := 'p3208';
    io_fin_rec.p3208 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3208
    );   
    l_stage := 'p3209';
    io_fin_rec.p3209 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3209
    );   
    l_stage := 'p3210';
    io_fin_rec.p3210 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3210
    );       
    l_stage := 'p3211';
    io_fin_rec.p3211 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3211
    );   
    l_stage := 'p3250';
    io_fin_rec.p3250 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3250
    );   
    l_stage := 'p3251';
    io_fin_rec.p3251 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3251
    );   
    l_stage := 'p3302';
    io_fin_rec.p3302 := jcb_api_pds_pkg.get_pds_body (
        i_pds_tab   => io_pds_tab
        , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3302
    );   
    
    -- determine internal institution number
    if io_fin_rec.inst_id is null then
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => io_fin_rec.de002
          , o_card_inst_id     => io_fin_rec.inst_id
          , o_card_network_id  => l_card_network_id
          , o_card_type        => l_card_type
          , o_card_country     => l_card_country
          , i_raise_error      => com_api_const_pkg.FALSE
        );
    end if;

    if io_fin_rec.inst_id is null then
        io_fin_rec.inst_id := cmn_api_standard_pkg.find_value_owner(
                                  i_standard_id  => i_standard_id
                                , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                                , i_object_id    => i_host_id                                
                                , i_param_name   => jcb_api_const_pkg.CMID
                                , i_value_char   => nvl(io_fin_rec.de093, io_fin_rec.de100)
                              );
    end if;    

    if io_fin_rec.inst_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'JCB_CMID_NOT_REGISTRED'
          , i_env_param1  => nvl(io_fin_rec.de093, io_fin_rec.de100)
          , i_env_param2  => i_network_id
        );
    end if;
    trc_log_pkg.debug(
        i_text => 'set message: end'
    );
exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating JCB first presentment on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end;

procedure create_incoming_first_pres (
    i_mes_rec               in jcb_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , o_fin_ref_id         out com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_create_operation    in com_api_type_pkg.t_boolean
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               jcb_api_type_pkg.t_fin_rec;
    l_pds_tab               jcb_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;
    l_p3005_tab             jcb_api_type_pkg.t_p3005_tab;

    l_stage                 varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Processing first presentment'
    );

    o_fin_ref_id := null;

    -- init
    l_fin_rec.id          := opr_api_create_pkg.get_id;
    l_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id  := i_network_id;
    l_fin_rec.file_id     := i_file_id;
    l_fin_rec.is_incoming := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected := com_api_type_pkg.FALSE;

    l_stage := 'mti & de024';
    l_fin_rec.mti         := i_mes_rec.mti;
    l_fin_rec.de024       := i_mes_rec.de024;

    -- set message
    set_message (
        i_mes_rec        => i_mes_rec
        , io_fin_rec     => l_fin_rec
        , io_pds_tab     => l_pds_tab
        , i_network_id   => i_network_id
        , i_host_id      => i_host_id
        , i_standard_id  => i_standard_id
        , io_p3005_tab   => l_p3005_tab
    );

    jcb_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec    => l_fin_rec
    );

    jcb_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    jcb_api_pds_pkg.save_p3005 (
        i_msg_id      => l_fin_rec.id
        , i_p3005_tab => l_p3005_tab
    );

    o_fin_ref_id := l_fin_rec.id;

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        create_operation (
            i_fin_rec             => l_fin_rec
          , i_standard_id         => i_standard_id
          , i_auth                => l_auth
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
            i_text          => 'Error generating JCB first presentment on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end;

procedure create_incoming_second_pres (
    i_mes_rec               in jcb_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_create_operation    in com_api_type_pkg.t_boolean
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               jcb_api_type_pkg.t_fin_rec;
    l_pds_tab               jcb_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;
    l_p3005_tab             jcb_api_type_pkg.t_p3005_tab;

    l_stage                 varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Processing second presentment: i_need_repeat = ' || i_need_repeat
    );
    
    -- init
    l_fin_rec.id          := opr_api_create_pkg.get_id;
    l_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id  := i_network_id;
    l_fin_rec.file_id     := i_file_id;
    l_fin_rec.is_incoming := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected := com_api_type_pkg.FALSE;

    l_stage := 'mti & de024';
    l_fin_rec.mti         := i_mes_rec.mti;
    l_fin_rec.de024       := i_mes_rec.de024;

    -- set message
    set_message (
        i_mes_rec        => i_mes_rec
        , io_fin_rec     => l_fin_rec
        , io_pds_tab     => l_pds_tab
        , i_network_id   => i_network_id
        , i_host_id      => i_host_id
        , i_standard_id  => i_standard_id
        , io_p3005_tab   => l_p3005_tab
    );
    
    trc_log_pkg.debug (
        i_text          => 'i_need_repeat='|| i_need_repeat
    );
    
    jcb_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    jcb_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    jcb_api_pds_pkg.save_p3005 (
        i_msg_id      => l_fin_rec.id
        , i_p3005_tab => l_p3005_tab
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
            i_text          => 'Error generating JCB second presentment on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end;

procedure create_incoming_retrieval (
    i_mes_rec               in jcb_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_create_operation    in com_api_type_pkg.t_boolean := null
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               jcb_api_type_pkg.t_fin_rec;
    l_pds_tab               jcb_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;
    l_p3005_tab             jcb_api_type_pkg.t_p3005_tab;

    l_stage                 varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Processing retrieval request'
    );
    
    -- init
    l_fin_rec.id          := opr_api_create_pkg.get_id;
    l_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id  := i_network_id;
    l_fin_rec.file_id     := i_file_id;
    l_fin_rec.is_incoming := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected := com_api_type_pkg.FALSE;

    l_stage := 'mti & de024';
    l_fin_rec.mti         := i_mes_rec.mti;
    l_fin_rec.de024       := i_mes_rec.de024;

    -- set message
    set_message (
        i_mes_rec        => i_mes_rec
        , io_fin_rec     => l_fin_rec
        , io_pds_tab     => l_pds_tab
        , i_network_id   => i_network_id
        , i_financial    => com_api_type_pkg.FALSE
        , i_host_id      => i_host_id
        , i_standard_id  => i_standard_id
        , io_p3005_tab   => l_p3005_tab
    );
    
    jcb_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    jcb_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    jcb_api_pds_pkg.save_p3005 (
        i_msg_id      => l_fin_rec.id
        , i_p3005_tab => l_p3005_tab
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
            i_text          => 'Error generating JCB retrieval request on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end;

procedure create_incoming_req_acknowl (
    i_mes_rec               in jcb_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_create_operation    in com_api_type_pkg.t_boolean
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               jcb_api_type_pkg.t_fin_rec;
    l_pds_tab               jcb_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;
    l_p3005_tab             jcb_api_type_pkg.t_p3005_tab;

    l_stage                 varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Processing retrieval request acknowledgement'
    );
    
    -- init
    l_fin_rec.id          := opr_api_create_pkg.get_id;
    l_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id  := i_network_id;
    l_fin_rec.file_id     := i_file_id;
    l_fin_rec.is_incoming := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected := com_api_type_pkg.FALSE;

    l_stage := 'mti & de024';
    l_fin_rec.mti         := i_mes_rec.mti;
    l_fin_rec.de024       := i_mes_rec.de024;

    -- set message
    set_message (
        i_mes_rec        => i_mes_rec
        , io_fin_rec     => l_fin_rec
        , io_pds_tab     => l_pds_tab
        , i_network_id   => i_network_id
        , i_financial    => com_api_type_pkg.FALSE
        , i_host_id      => i_host_id
        , i_standard_id  => i_standard_id
        , io_p3005_tab   => l_p3005_tab
    );

    jcb_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec    => l_fin_rec
    );

    jcb_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    jcb_api_pds_pkg.save_p3005 (
        i_msg_id      => l_fin_rec.id
        , i_p3005_tab => l_p3005_tab
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
        i_text         => 'Incoming retrieval request acknowledgement processed. Assigned id[#1]'
        , i_env_param1 => l_fin_rec.id
    );

exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating JCB retrieval request acknowledgement on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end;

procedure create_incoming_chargeback (
    i_mes_rec               in jcb_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_create_operation    in com_api_type_pkg.t_boolean
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               jcb_api_type_pkg.t_fin_rec;
    l_pds_tab               jcb_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;
    l_p3005_tab             jcb_api_type_pkg.t_p3005_tab;

    l_stage                 varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Processing incoming chargeback'
    );
    
    l_fin_rec.id          := opr_api_create_pkg.get_id;
    l_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id  := i_network_id;
    l_fin_rec.file_id     := i_file_id;
    l_fin_rec.is_incoming := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected := com_api_type_pkg.FALSE;

    l_stage := 'mti & de024';
    l_fin_rec.mti         := i_mes_rec.mti;
    l_fin_rec.de024       := i_mes_rec.de024;
    
    -- set message
    set_message (
        i_mes_rec        => i_mes_rec
        , io_fin_rec     => l_fin_rec
        , io_pds_tab     => l_pds_tab
        , i_network_id   => i_network_id
        , i_host_id      => i_host_id
        , i_standard_id  => i_standard_id
        , io_p3005_tab   => l_p3005_tab
    );

    jcb_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    jcb_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    jcb_api_pds_pkg.save_p3005 (
        i_msg_id      => l_fin_rec.id
        , i_p3005_tab => l_p3005_tab
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
            i_text          => 'Error generating JCB chargeback on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end;

procedure create_incoming_fee (
    i_mes_rec               in jcb_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_create_operation    in com_api_type_pkg.t_boolean
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               jcb_api_type_pkg.t_fin_rec;
    l_pds_tab               jcb_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;
    l_p3005_tab             jcb_api_type_pkg.t_p3005_tab;

    l_stage                 varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Processing incoming fee collection'
    );
    
    -- init
    l_fin_rec.id          := opr_api_create_pkg.get_id;
    l_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_fin_rec.network_id  := i_network_id;
    l_fin_rec.file_id     := i_file_id;
    l_fin_rec.is_incoming := com_api_type_pkg.TRUE;
    l_fin_rec.is_rejected := com_api_type_pkg.FALSE;

    l_stage := 'mti & de024';
    l_fin_rec.mti         := i_mes_rec.mti;
    l_fin_rec.de024       := i_mes_rec.de024;
    
    -- set message
    set_message (
        i_mes_rec        => i_mes_rec
        , io_fin_rec     => l_fin_rec
        , io_pds_tab     => l_pds_tab
        , i_network_id   => i_network_id
        , i_host_id      => i_host_id
        , i_standard_id  => i_standard_id
        , io_p3005_tab   => l_p3005_tab
    );
    
    jcb_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    jcb_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    jcb_api_pds_pkg.save_p3005 (
        i_msg_id      => l_fin_rec.id
        , i_p3005_tab => l_p3005_tab
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
            i_text          => 'Error generating JCB fee collection on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end;

procedure init_no_original_id_tab
is
begin
    g_no_original_id_tab.delete;
end;

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
end;

function set_de054(
    i_amount                in com_api_type_pkg.t_money
  , i_currency              in com_api_type_pkg.t_curr_code
  , i_type                  in com_api_type_pkg.t_dict_value
) return jcb_api_type_pkg.t_de054 is
    l_result                jcb_api_type_pkg.t_de054;
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

end;
/

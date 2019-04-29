create or replace package body vis_prc_ammf_pkg as
/*********************************************************
 *  Visa AMMF service API  <br />
 *  Created by Gerbeev I.(gerbeev@bpcbt.com)  at 21.01.2019 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: vis_prc_ammf_pkg <br />
 *  @headcom
 **********************************************************/

BULK_LIMIT                      constant integer  := 1000;
SPACE                           constant com_api_type_pkg.t_name := ' ';

VISA_INTERNAL_AMMF_BIN          constant com_api_type_pkg.t_name := '320040';
VISA_AMMF_SERVICE_IDENTIFIER    constant com_api_type_pkg.t_name := 'AMMF03';

type t_merchant_rec is record(
    merchant_number         com_api_type_pkg.t_merchant_number
  , merchant_name           com_api_type_pkg.t_name
  , mcc                     com_api_type_pkg.t_mcc
  , street                  com_api_type_pkg.t_name
  , city                    com_api_type_pkg.t_name
  , postal_code             com_api_type_pkg.t_postal_code
  , country                 com_api_type_pkg.t_country_code
);

type t_merchant_tab is table of t_merchant_rec index by binary_integer;

type t_batch_rec is record(
    proc_bin                 com_api_type_pkg.t_dict_value
  , acq_business_id          com_api_type_pkg.t_dict_value
  , cmid                     com_api_type_pkg.t_cmid
);

procedure put_value(
    io_raw_line     in out  com_api_type_pkg.t_raw_data
  , i_value         in      com_api_type_pkg.t_full_desc
  , i_begin         in      com_api_type_pkg.t_tiny_id
  , i_end           in      com_api_type_pkg.t_tiny_id
  , i_length        in      com_api_type_pkg.t_tiny_id
  , i_field_desc    in      com_api_type_pkg.t_name     := null
  , i_right_pad     in      com_api_type_pkg.t_boolean  := com_api_const_pkg.FALSE
) is
    l_value                 com_api_type_pkg.t_full_desc;
begin
    if i_right_pad = com_api_const_pkg.TRUE then
        l_value := rpad(nvl(i_value, SPACE), i_length, SPACE);
    else
        l_value := lpad(nvl(i_value, SPACE), i_length, SPACE);
    end if;

    if length(i_value) > i_length then
        com_api_error_pkg.raise_error(
            i_error             => 'VALUE_EXCEEDED_ALLOWED_MAXIMUM'
          , i_env_param1        => length(i_value)
          , i_env_param2        => i_length
          , i_env_param3        => i_field_desc
        );
    end if;

    io_raw_line := substr(io_raw_line, 1, i_begin) || l_value || substr(io_raw_line, i_end);
end put_value;

procedure enum_ammf_msg_for_upload(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_eff_date              in      date
  , i_full_export           in      com_api_type_pkg.t_boolean
  , o_event_object_id_tab       out com_api_type_pkg.t_number_tab
  , o_fin_cur                   out sys_refcursor
) is
    type t_object_rec is record(
        object_id               com_api_type_pkg.t_long_id
      , event_object_id_tab     num_tab_tpt
    );
    type t_object_tab is table of t_object_rec index by binary_integer;

    l_object_tab            t_object_tab;
    l_object_id_tab         num_tab_tpt := num_tab_tpt();
begin
    if i_full_export = com_api_const_pkg.TRUE then
        open o_fin_cur for
            select m.merchant_number
                 , m.merchant_name
                 , m.mcc
                 , a.street
                 , a.city
                 , a.postal_code
                 , a.country
             from (
                select
                       m.merchant_number
                     , m.merchant_name
                     , m.mcc
                     , acq_api_merchant_pkg.get_merchant_address_id(
                           i_merchant_id   => m.id
                       ) as address_id
                  from acq_merchant m
                 where (
                        m.inst_id = i_inst_id
                        or
                        i_inst_id is null
                        or
                        i_inst_id = ost_api_const_pkg.DEFAULT_INST
                       )
                   and m.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
                   and prd_api_service_pkg.get_active_service_id(
                           i_entity_type        => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                         , i_object_id          => m.id
                         , i_attr_name          => null
                         , i_service_type_id    => vis_api_const_pkg.VIS_AMMF_SERVICE_TYPE_ID
                         , i_split_hash         => m.split_hash
                         , i_mask_error         => com_api_const_pkg.TRUE
                         , i_eff_date           => i_eff_date
                       ) is not null
            ) m
            , com_address a
            where m.address_id = a.id;
    else
        select eo.object_id as merchant_id
             , cast(collect(cast(eo.id as number)) as num_tab_tpt) as event_object_id_tab
          bulk collect into
               l_object_tab
          from evt_event_object eo
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'VIS_PRC_AMMF_PKG.PROCESS'
           and eo.eff_date      <= i_eff_date
           and eo.split_hash    in (select split_hash from com_api_split_map_vw)
           and (
                eo.inst_id = i_inst_id
                or
                i_inst_id is null
                or
                i_inst_id = ost_api_const_pkg.DEFAULT_INST
               )
           and eo.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
           and prd_api_service_pkg.get_active_service_id(
                   i_entity_type        => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                 , i_object_id          => eo.object_id
                 , i_attr_name          => null
                 , i_service_type_id    => vis_api_const_pkg.VIS_AMMF_SERVICE_TYPE_ID
                 , i_split_hash         => eo.split_hash
                 , i_mask_error         => com_api_const_pkg.TRUE
                 , i_eff_date           => i_eff_date
               ) is not null
      group by eo.object_id;

        for i in 1 .. l_object_tab.count loop
            l_object_id_tab.extend;
            l_object_id_tab(l_object_id_tab.count) := l_object_tab(i).object_id;
            for k in 1 .. l_object_tab(i).event_object_id_tab.count loop
                o_event_object_id_tab(o_event_object_id_tab.count + 1) := l_object_tab(i).event_object_id_tab(k);
            end loop;
        end loop;

        open o_fin_cur for
            select m.merchant_number
                 , m.merchant_name
                 , m.mcc
                 , a.street
                 , a.city
                 , a.postal_code
                 , a.country
              from (
                select m.merchant_number
                     , m.merchant_name
                     , m.mcc
                     , acq_api_merchant_pkg.get_merchant_address_id(
                           i_merchant_id   => m.id
                       ) as address_id
                  from acq_merchant m
                 where m.id in (select t.column_value as merchant_id from table(cast(l_object_id_tab as num_tab_tpt)) t)
                   and (
                        m.inst_id = i_inst_id
                        or
                        i_inst_id is null
                        or
                        i_inst_id = ost_api_const_pkg.DEFAULT_INST
                       )
                   and m.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
                 ) m
                 , com_address a
             where m.address_id = a.id;

        l_object_tab.delete;
        l_object_id_tab.delete;

    end if;
exception
    when others then
        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end enum_ammf_msg_for_upload;

function estimate_ammf_for_upload(
      i_inst_id             in com_api_type_pkg.t_inst_id
    , i_eff_date            in date
    , i_full_export         in com_api_type_pkg.t_boolean
) return number is
    l_result                number;
begin
    if i_full_export = com_api_const_pkg.TRUE then
        select count(1)
          into l_result
          from acq_merchant m
         where 1 = 1
           and (
                m.inst_id = i_inst_id
                or
                i_inst_id is null
                or
                i_inst_id = ost_api_const_pkg.DEFAULT_INST
               )
           and m.status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
           and prd_api_service_pkg.get_active_service_id(
                   i_entity_type        => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                 , i_object_id          => m.id
                 , i_attr_name          => null
                 , i_service_type_id    => vis_api_const_pkg.VIS_AMMF_SERVICE_TYPE_ID
                 , i_split_hash         => m.split_hash
                 , i_mask_error         => com_api_const_pkg.TRUE
                 , i_eff_date           => i_eff_date
               ) is not null;
    else
        select count(1)
          into l_result
          from evt_event_object eo
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'VIS_PRC_AMMF_PKG.PROCESS'
           and eo.eff_date      <= i_eff_date
           and eo.split_hash    in (select split_hash from com_api_split_map_vw)
           and (
                eo.inst_id = i_inst_id
                or
                i_inst_id is null
                or
                i_inst_id = ost_api_const_pkg.DEFAULT_INST
               )
           and eo.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
           and prd_api_service_pkg.get_active_service_id(
                   i_entity_type        => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                 , i_object_id          => eo.object_id
                 , i_attr_name          => null
                 , i_service_type_id    => vis_api_const_pkg.VIS_AMMF_SERVICE_TYPE_ID
                 , i_split_hash         => eo.split_hash
                 , i_mask_error         => com_api_const_pkg.TRUE
                 , i_eff_date           => i_eff_date
               ) is not null;
    end if;

    return l_result;
end estimate_ammf_for_upload;

procedure process_file_header(
      i_proc_bin             in com_api_type_pkg.t_dict_value
    , i_inst_id              in com_api_type_pkg.t_inst_id
    , i_standard_id          in com_api_type_pkg.t_inst_id
    , i_host_id              in com_api_type_pkg.t_tiny_id
    , i_session_file_id      in com_api_type_pkg.t_long_id
    , o_file                 out vis_api_type_pkg.t_visa_file_rec
) is
    l_line                   com_api_type_pkg.t_text;
    l_param_tab              com_api_type_pkg.t_param_tab;
begin
    l_line := '90';

    cmn_api_standard_pkg.get_param_value(
        i_inst_id        => i_inst_id
        , i_standard_id  => i_standard_id
        , i_object_id    => i_host_id
        , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
        , i_param_name   => vis_api_const_pkg.VISA_SECURITY_CODE
        , o_param_value  => o_file.security_code
        , i_param_tab    => l_param_tab
    );

    o_file.id             := vis_file_seq.nextval;

    o_file.session_file_id:= i_session_file_id;
    o_file.is_incoming    := com_api_type_pkg.FALSE;
    o_file.network_id     := vis_api_const_pkg.VISA_NETWORK_ID;

    o_file.proc_date      := trunc(com_api_sttl_day_pkg.get_sysdate);
    o_file.sttl_date      := null;
    o_file.release_number := null;
    o_file.proc_bin       := i_proc_bin;

    select nvl(max(to_number(visa_file_id)), 0) + 1
      into o_file.visa_file_id
      from vis_file
     where is_incoming = com_api_type_pkg.FALSE
       and proc_bin    = o_file.proc_bin
       and proc_date   = o_file.proc_date;

    o_file.trans_total    := 0;
    o_file.batch_total    := 0;
    o_file.tcr_total      := 0;
    o_file.monetary_total := 0;
    o_file.src_amount     := 0;
    o_file.dst_amount     := 0;
    o_file.inst_id        := i_inst_id;

    if o_file.proc_bin is null then
        l_line := l_line || lpad(nvl(o_file.proc_bin, SPACE), 6, SPACE);
    else
        l_line := l_line || rpad(o_file.proc_bin, 6, '0');
    end if;

    l_line := l_line || to_char(com_api_sttl_day_pkg.get_sysdate, 'YYDDD');
    l_line := l_line || rpad(SPACE, 16);
    l_line := l_line || rpad(nvl(o_file.test_option, SPACE), 4);
    l_line := l_line || rpad(SPACE, 29);
    l_line := l_line || rpad(nvl(o_file.security_code, SPACE), 8);
    l_line := l_line || rpad(SPACE, 6);
    l_line := l_line || lpad(o_file.visa_file_id, 3, '0');
    l_line := l_line || rpad(SPACE, 89);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
        , i_sess_file_id    => i_session_file_id
        );
    end if;
end;

function get_next_batch_number(
    i_batch_number           in com_api_type_pkg.t_tag
    , i_proc_date            in date
) return com_api_type_pkg.t_tag is
    l_batch_number              com_api_type_pkg.t_tag;
begin
    if i_batch_number is not null then
        l_batch_number := i_batch_number + 1;
    else
        select nvl(max(to_number(batch_number)),0) + 1
          into l_batch_number
          from vis_batch
         where trunc(proc_date) = i_proc_date;
    end if;
    return l_batch_number;
end;

procedure init_batch(
    io_batch                 in out vis_api_type_pkg.t_visa_batch_rec
    , i_session_file_id      in com_api_type_pkg.t_long_id
    , i_file_proc_bin        in varchar2
) is
begin
    io_batch.id              := vis_batch_seq.nextval;
    io_batch.file_id         := i_session_file_id;
    io_batch.proc_bin        := i_file_proc_bin;
    io_batch.proc_date       := trunc(com_api_sttl_day_pkg.get_sysdate);
    io_batch.batch_number    := get_next_batch_number(io_batch.batch_number, io_batch.proc_date);
    io_batch.center_batch_id := mod(io_batch.id, 100000000);
    io_batch.monetary_total  := 0;
    io_batch.tcr_total       := 0;
    io_batch.trans_total     := 0;
    io_batch.src_amount      := 0;
    io_batch.dst_amount      := 0;
end;

procedure process_batch_trailer(
    io_batch                 in out vis_api_type_pkg.t_visa_batch_rec
    , i_host_id              in com_api_type_pkg.t_tiny_id
    , i_inst_id              in com_api_type_pkg.t_inst_id
    , i_standard_id          in com_api_type_pkg.t_inst_id
    , i_session_file_id      in com_api_type_pkg.t_long_id
) is
    l_line                   com_api_type_pkg.t_text;
    l_visa_dialect           com_api_type_pkg.t_dict_value;
    l_param_tab              com_api_type_pkg.t_param_tab;
begin
    cmn_api_standard_pkg.get_param_value(
        i_inst_id       => i_inst_id
      , i_standard_id   => i_standard_id
      , i_object_id     => i_host_id
      , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_param_name    => vis_api_const_pkg.VISA_BASEII_DIALECT
      , o_param_value   => l_visa_dialect
      , i_param_tab     => l_param_tab
    );

    io_batch.tcr_total      := io_batch.tcr_total + 1;
    io_batch.trans_total    := io_batch.trans_total + 1;

    l_line := l_line || '9100';   -- tc, tcq, tcr

    if l_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_OPENWAY, vis_api_const_pkg.VISA_DIALECT_TIETO) then
        l_line := l_line || lpad(nvl(io_batch.proc_bin, '0'), 6, '0'); -- BIN
    else
        l_line := l_line || lpad('0', 6, '0'); -- BIN
    end if;

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || to_char(com_api_sttl_day_pkg.get_sysdate, 'YYDDD');
    else
        l_line := l_line || lpad('0', 5, '0'); -- date
    end if;

    if l_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_OPENWAY, vis_api_const_pkg.VISA_DIALECT_TIETO) then
        l_line := l_line || lpad(nvl(io_batch.src_amount, '0'), 15, '0');
    else
        l_line := l_line || lpad('0', 15, '0'); -- dst amount
    end if;

    l_line := l_line || lpad(nvl(io_batch.monetary_total, '0'), 12, '0');
    l_line := l_line || lpad(nvl(io_batch.batch_number, '0'), 6, '0');
    l_line := l_line || lpad(nvl(io_batch.tcr_total, '0'), 12, '0');
    l_line := l_line || lpad('0', 6, '0');

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || lpad(SPACE, 8);
    else
        l_line := l_line || rpad(nvl(io_batch.center_batch_id, SPACE), 8);
    end if;

    l_line := l_line || lpad(nvl(io_batch.trans_total, '0'), 9, '0');
    l_line := l_line || lpad('0', 18, '0');
    l_line := l_line || lpad(nvl(io_batch.src_amount, '0'), 15, '0');
    l_line := l_line || lpad('0', 15, '0');
    l_line := l_line || lpad('0', 15, '0');
    l_line := l_line || lpad('0', 15, '0');
    l_line := l_line || lpad(SPACE, 7);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    insert into vis_batch(
        id
      , file_id
      , proc_bin
      , proc_date
      , batch_number
      , center_batch_id
      , monetary_total
      , tcr_total
      , trans_total
      , src_amount
      , dst_amount
    ) values(
        io_batch.id
      , io_batch.file_id
      , io_batch.proc_bin
      , io_batch.proc_date
      , io_batch.batch_number
      , io_batch.center_batch_id
      , io_batch.monetary_total
      , io_batch.tcr_total
      , io_batch.trans_total
      , io_batch.src_amount
      , io_batch.dst_amount
    );
end;

procedure process_file_trailer(
    io_file                  in out vis_api_type_pkg.t_visa_file_rec
    , i_host_id              in com_api_type_pkg.t_tiny_id
    , i_inst_id              in com_api_type_pkg.t_inst_id
    , i_standard_id          in com_api_type_pkg.t_inst_id
    , i_session_file_id      in com_api_type_pkg.t_long_id
) is
    l_visa_dialect           com_api_type_pkg.t_dict_value;
    l_line                   com_api_type_pkg.t_text;
    l_param_tab              com_api_type_pkg.t_param_tab;
begin
    cmn_api_standard_pkg.get_param_value(
        i_inst_id       => i_inst_id
      , i_standard_id   => i_standard_id
      , i_object_id     => i_host_id
      , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_param_name    => vis_api_const_pkg.VISA_BASEII_DIALECT
      , o_param_value   => l_visa_dialect
      , i_param_tab     => l_param_tab
    );

    io_file.tcr_total      := io_file.tcr_total + 1;
    io_file.trans_total    := io_file.trans_total + 1;

    l_line := l_line || '9200';   -- tc, tcq, tcr

    if l_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_OPENWAY, vis_api_const_pkg.VISA_DIALECT_TIETO) then
        l_line := l_line || lpad(nvl(io_file.proc_bin, '0'), 6, '0'); -- BIN
    else
        l_line := l_line || lpad('0', 6, '0'); -- BIN
    end if;

    if l_visa_dialect = vis_api_const_pkg.VISA_DIALECT_TIETO then
        l_line := l_line || to_char(com_api_sttl_day_pkg.get_sysdate, 'YYDDD');
    else
        l_line := l_line || lpad('0', 5, '0'); -- date
    end if;

    if l_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_OPENWAY, vis_api_const_pkg.VISA_DIALECT_TIETO) then
        l_line := l_line || lpad(nvl(io_file.src_amount, '0'), 15, '0');
    else
        l_line := l_line || lpad('0', 15, '0'); -- dst amount
    end if;

    l_line := l_line || lpad(nvl(io_file.monetary_total, '0'), 12, '0');
    l_line := l_line || lpad(nvl(io_file.batch_total, '0'), 6, '0');
    l_line := l_line || lpad(nvl(io_file.tcr_total, '0'), 12, '0');
    l_line := l_line || lpad('0', 6, '0');
    l_line := l_line || rpad(SPACE, 8);
    l_line := l_line || lpad(nvl(io_file.trans_total, '0'), 9, '0');
    l_line := l_line || lpad('0', 18, '0');
    l_line := l_line || lpad(nvl(io_file.src_amount, '0'), 15, '0');
    l_line := l_line || lpad('0', 15, '0');
    l_line := l_line || lpad('0', 15, '0');
    l_line := l_line || lpad('0', 15, '0');
    l_line := l_line || lpad(SPACE, 7);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
        , i_sess_file_id    => i_session_file_id
        );
    end if;

    insert into vis_file(
        id
      , is_incoming
      , network_id
      , proc_bin
      , proc_date
      , sttl_date
      , release_number
      , test_option
      , security_code
      , visa_file_id
      , trans_total
      , batch_total
      , tcr_total
      , monetary_total
      , src_amount
      , dst_amount
      , inst_id
      , session_file_id
    ) values(
        io_file.id
      , io_file.is_incoming
      , io_file.network_id
      , io_file.proc_bin
      , io_file.proc_date
      , io_file.sttl_date
      , io_file.release_number
      , io_file.test_option
      , io_file.security_code
      , io_file.visa_file_id
      , io_file.trans_total
      , io_file.batch_total
      , io_file.tcr_total
      , io_file.monetary_total
      , io_file.src_amount
      , io_file.dst_amount
      , io_file.inst_id
      , io_file.session_file_id
   );
end;


procedure process_draft(
    i_merchant_rec          in      t_merchant_rec
  , i_batch_rec             in      t_batch_rec
  , i_session_file_id       in      com_api_type_pkg.t_long_id
  , io_batch                in out  vis_api_type_pkg.t_visa_batch_rec
) is
    l_line                  com_api_type_pkg.t_text;
begin
    --------------------------- TCR0 ---------------------------
    put_value(
        io_raw_line     => l_line
      , i_value         => vis_api_const_pkg.TC_VISA_AMMF_SERVICE
      , i_begin         => 1
      , i_end           => 2
      , i_length        => 2
      , i_field_desc    => 'TCR 0, Pos.1–2, Transaction Code'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => '0'
      , i_begin         => 3
      , i_end           => 3
      , i_length        => 1
      , i_field_desc    => 'TCR 0, Pos.3, Transaction Code Qualifier'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => '0'
      , i_begin         => 4
      , i_end           => 4
      , i_length        => 1
      , i_field_desc    => 'TCR 0, Pos.4, Transaction Component Sequence Number'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => VISA_INTERNAL_AMMF_BIN
      , i_begin         => 5
      , i_end           => 10
      , i_length        => 6
      , i_field_desc    => 'TCR 0, Pos.5–10, Destination BIN'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => i_batch_rec.cmid
      , i_begin         => 11
      , i_end           => 16
      , i_length        => 6
      , i_field_desc    => 'TCR 0, Pos.11–16, Source BIN'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => VISA_AMMF_SERVICE_IDENTIFIER
      , i_begin         => 17
      , i_end           => 22
      , i_length        => 6
      , i_field_desc    => 'TCR 0, Pos.17–22, Service Identifier'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 23
      , i_end           => 37
      , i_length        => 15
      , i_field_desc    => 'TCR 0, Pos.23–37, Reserved'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 38
      , i_end           => 39
      , i_length        => 2
      , i_field_desc    => 'TCR 0, Pos.38–39, Reserved'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 40
      , i_end           => 40
      , i_length        => 1
      , i_field_desc    => 'TCR 0, Pos.40, Reserved'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 41
      , i_end           => 43
      , i_length        => 3
      , i_field_desc    => 'TCR 0, Pos.41–43, Reserved'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 44
      , i_end           => 46
      , i_length        => 3
      , i_field_desc    => 'TCR 0, Pos.44–46, Reserved'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => i_batch_rec.proc_bin
      , i_begin         => 47
      , i_end           => 52
      , i_length        => 6
      , i_field_desc    => 'TCR 0, Pos.47–52, Acquirer CIB'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => i_batch_rec.acq_business_id
      , i_begin         => 53
      , i_end           => 60
      , i_length        => 8
      , i_field_desc    => 'TCR 0, Pos.53–60, Acquirer BID'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => i_merchant_rec.merchant_number
      , i_begin         => 61
      , i_end           => 90
      , i_length        => 30
      , i_field_desc    => 'TCR 0, Pos.61–90, Acquirer Assigned Merchant ID'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 91
      , i_end           => 167
      , i_length        => 77
      , i_field_desc    => 'TCR 0, Pos.91–167, Reserved'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 168
      , i_end           => 168
      , i_length        => 1
      , i_field_desc    => 'TCR 0, Pos.168, Reserved'
    );

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data        => l_line
          , i_sess_file_id    => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
    end if;

    --------------------------- TCR1 ---------------------------
    l_line              := null;
    put_value(
        io_raw_line     => l_line
      , i_value         => vis_api_const_pkg.TC_VISA_AMMF_SERVICE
      , i_begin         => 1
      , i_end           => 2
      , i_length        => 2
      , i_field_desc    => 'TCR 1, Pos.1–2, Transaction Code'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => '0'
      , i_begin         => 3
      , i_end           => 3
      , i_length        => 1
      , i_field_desc    => 'TCR 1, Pos.3, Transaction Code Qualifier'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => '1'
      , i_begin         => 4
      , i_end           => 4
      , i_length        => 1
      , i_field_desc    => 'TCR 1, Pos.4, Transaction Component Sequence Number'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => i_merchant_rec.merchant_name
      , i_begin         => 5
      , i_end           => 79
      , i_length        => 75
      , i_field_desc    => 'TCR 1, Pos.5–79, Merchant DBA Name'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => i_merchant_rec.merchant_name
      , i_begin         => 80
      , i_end           => 154
      , i_length        => 75
      , i_field_desc    => 'TCR 1, Pos.80–154, Merchant Legal Name'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 155
      , i_end           => 168
      , i_length        => 14
      , i_field_desc    => 'TCR 1, Pos.155–168, National Tax Identification Number'
    );

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data        => l_line
          , i_sess_file_id    => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
    end if;

    --------------------------- TCR2 ---------------------------
    l_line              := null;
    put_value(
        io_raw_line     => l_line
      , i_value         => vis_api_const_pkg.TC_VISA_AMMF_SERVICE
      , i_begin         => 1
      , i_end           => 2
      , i_length        => 2
      , i_field_desc    => 'TCR 2, Pos.1–2, Transaction Code'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => '0'
      , i_begin         => 3
      , i_end           => 3
      , i_length        => 1
      , i_field_desc    => 'TCR 2, Pos.3, Transaction Code Qualifier'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => '2'
      , i_begin         => 4
      , i_end           => 4
      , i_length        => 1
      , i_field_desc    => 'TCR 2, Pos.4, Transaction Component Sequence Number'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => i_merchant_rec.street
      , i_begin         => 5
      , i_end           => 124
      , i_length        => 120
      , i_right_pad     => com_api_const_pkg.TRUE
      , i_field_desc    => 'TCR 2, Pos.5–64 Location Street Address Line 1 & Pos.65–124 Location Street Address Line 2'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => i_merchant_rec.city
      , i_begin         => 125
      , i_end           => 153
      , i_length        => 29
      , i_right_pad     => com_api_const_pkg.TRUE
      , i_field_desc    => 'TCR 2, Pos.125–153, Location City'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 154
      , i_end           => 155
      , i_length        => 2
      , i_field_desc    => 'TCR 2, Pos.154–155, Location State Code'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => i_merchant_rec.postal_code
      , i_begin         => 156
      , i_end           => 165
      , i_length        => 10
      , i_right_pad     => com_api_const_pkg.TRUE
      , i_field_desc    => 'TCR 2, Pos.156–165, Location Postal Code'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => i_merchant_rec.country
      , i_begin         => 166
      , i_end           => 168
      , i_length        => 3
      , i_right_pad     => com_api_const_pkg.TRUE
      , i_field_desc    => 'TCR 2, Pos.166–168, Location ISO Numeric Country Code'
    );
        trc_log_pkg.debug(l_line);
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data        => l_line
          , i_sess_file_id    => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
    end if;

    --------------------------- TCR3 ---------------------------
    l_line              := null;
    put_value(
        io_raw_line     => l_line
      , i_value         => vis_api_const_pkg.TC_VISA_AMMF_SERVICE
      , i_begin         => 1
      , i_end           => 2
      , i_length        => 2
      , i_field_desc    => 'TCR 3, Pos.1–2, Transaction Code'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => '0'
      , i_begin         => 3
      , i_end           => 3
      , i_length        => 1
      , i_field_desc    => 'TCR 3, Pos.3, Transaction Code Qualifier'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => '3'
      , i_begin         => 4
      , i_end           => 4
      , i_length        => 1
      , i_field_desc    => 'TCR 3, Pos.4, Transaction Component Sequence Number'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => i_merchant_rec.mcc
      , i_begin         => 5
      , i_end           => 8
      , i_length        => 4
      , i_right_pad     => com_api_const_pkg.TRUE
      , i_field_desc    => 'TCR 3, Pos.5–8, MCC1'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 9
      , i_end           => 12
      , i_length        => 4
      , i_field_desc    => 'TCR 3, Pos.9–12, MCC2'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 13
      , i_end           => 16
      , i_length        => 4
      , i_field_desc    => 'TCR 3, Pos.13–16, MCC3'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 17
      , i_end           => 20
      , i_length        => 4
      , i_field_desc    => 'TCR 3, Pos.17–20, MCC4'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 21
      , i_end           => 24
      , i_length        => 4
      , i_field_desc    => 'TCR 3, Pos.21–24, MCC5'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 25
      , i_end           => 28
      , i_length        => 4
      , i_field_desc    => 'TCR 3, Pos.25–28, MCC6'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 29
      , i_end           => 32
      , i_length        => 4
      , i_field_desc    => 'TCR 3, Pos.29–32, MCC7'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 33
      , i_end           => 36
      , i_length        => 4
      , i_field_desc    => 'TCR 3, Pos.33–36, MCC8'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 37
      , i_end           => 40
      , i_length        => 4
      , i_field_desc    => 'TCR 3, Pos.37–40, MCC9'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 41
      , i_end           => 44
      , i_length        => 4
      , i_field_desc    => 'TCR 3, Pos.41–44, MCC10'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 45
      , i_end           => 168
      , i_length        => 124
      , i_field_desc    => 'TCR 3, Pos.45–168, Reserved'
    );
        trc_log_pkg.debug(l_line);
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data        => l_line
          , i_sess_file_id    => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
    end if;

    --------------------------- TCR4 ---------------------------
    l_line              := null;
    put_value(
        io_raw_line     => l_line
      , i_value         => vis_api_const_pkg.TC_VISA_AMMF_SERVICE
      , i_begin         => 1
      , i_end           => 2
      , i_length        => 2
      , i_field_desc    => 'TCR 4, Pos.1–2, Transaction Code'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => '0'
      , i_begin         => 3
      , i_end           => 3
      , i_length        => 1
      , i_field_desc    => 'TCR 4, Pos.3, Transaction Code Qualifier'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => '4'
      , i_begin         => 4
      , i_end           => 4
      , i_length        => 1
      , i_field_desc    => 'TCR 4, Pos.4, Transaction Component Sequence Number'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => i_batch_rec.cmid
      , i_begin         => 5
      , i_end           => 10
      , i_length        => 6
      , i_field_desc    => 'TCR 4, Pos.5–10, Acquirer BIN1'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => i_merchant_rec.merchant_number
      , i_begin         => 11
      , i_end           => 25
      , i_length        => 15
      , i_field_desc    => 'TCR 4, Pos.11–25, Card Acceptor ID1'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 26
      , i_end           => 31
      , i_length        => 6
      , i_field_desc    => 'TCR 4, Pos.26–31, Acquirer BIN2'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 32
      , i_end           => 46
      , i_length        => 15
      , i_field_desc    => 'TCR 4, Pos.32–46, Card Acceptor ID2'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 47
      , i_end           => 52
      , i_length        => 6
      , i_field_desc    => 'TCR 4, Pos.47–52, Acquirer BIN3'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 53
      , i_end           => 67
      , i_length        => 15
      , i_field_desc    => 'TCR 4, Pos.53–67, Card Acceptor ID3'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 68
      , i_end           => 73
      , i_length        => 6
      , i_field_desc    => 'TCR 4, Pos.68–73, Acquirer BIN4'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 74
      , i_end           => 88
      , i_length        => 15
      , i_field_desc    => 'TCR 4, Pos.74–88, Card Acceptor ID4'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 89
      , i_end           => 94
      , i_length        => 6
      , i_field_desc    => 'TCR 4, Pos.89–94, Acquirer BIN5'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 95
      , i_end           => 109
      , i_length        => 15
      , i_field_desc    => 'TCR 4, Pos.95–109, Card Acceptor ID5'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 110
      , i_end           => 115
      , i_length        => 6
      , i_field_desc    => 'TCR 4, Pos.110–115, Acquirer BIN6'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 116
      , i_end           => 130
      , i_length        => 15
      , i_field_desc    => 'TCR 4, Pos.116–130, Card Acceptor ID6'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 131
      , i_end           => 136
      , i_length        => 6
      , i_field_desc    => 'TCR 4, Pos.131–136, Acquirer BIN7'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 137
      , i_end           => 151
      , i_length        => 15
      , i_field_desc    => 'TCR 4, Pos.137–151, Card Acceptor ID7'
    );
    put_value(
        io_raw_line     => l_line
      , i_value         => SPACE
      , i_begin         => 152
      , i_end           => 168
      , i_length        => 17
      , i_field_desc    => 'TCR 4, Pos.152–168, Reserved'
    );
        trc_log_pkg.debug(l_line);
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data        => l_line
          , i_sess_file_id    => i_session_file_id
        );
        io_batch.tcr_total := io_batch.tcr_total + 1;
    end if;

    io_batch.trans_total := io_batch.trans_total + 1;

exception
    when others then
        raise;
end process_draft;

procedure process(
    i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_full_export               in      com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) || '.process: ';
    l_estimated_count           com_api_type_pkg.t_long_id      := 0;
    l_processed_count           com_api_type_pkg.t_long_id      := 0;
    l_record_count              com_api_type_pkg.t_long_id      := 0;
    l_inst_id_tab               com_api_type_pkg.t_inst_id_tab;
    l_host_id_tab               com_api_type_pkg.t_number_tab;
    l_standard_id_tab           com_api_type_pkg.t_number_tab;
    l_params                    com_api_type_pkg.t_param_tab;

    l_proc_bin                  com_api_type_pkg.t_dict_value;
    l_session_file_id           com_api_type_pkg.t_long_id;

    l_file                      vis_api_type_pkg.t_visa_file_rec;
    l_batch                     vis_api_type_pkg.t_visa_batch_rec;

    l_header_writed             boolean := false;

    l_event_object_id_tab       com_api_type_pkg.t_number_tab;
    l_eff_date                  date                            := com_api_sttl_day_pkg.get_sysdate;
    l_batch_rec                 t_batch_rec;

    l_param_tab                 com_api_type_pkg.t_param_tab;

    l_merchant_tab              t_merchant_tab;
    l_fin_cur                   sys_refcursor;

    l_host_id                   com_api_type_pkg.t_tiny_id;
    l_standard_id               com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'Visa AMMF service procedure start. Parameters: i_inst_id [#1], i_full_export [#2].'
      , i_env_param1    => i_inst_id
      , i_env_param2    => i_full_export
    );

    prc_api_stat_pkg.log_start;

    select m.id         as host_id
         , r.inst_id
         , s.standard_id
      bulk collect into
           l_host_id_tab
         , l_inst_id_tab
         , l_standard_id_tab
      from net_network n
         , net_member m
         , net_interface i
         , net_member r
         , cmn_standard_object s
     where n.id             = vis_api_const_pkg.VISA_NETWORK_ID
       and n.id             = m.network_id
       and n.inst_id        = m.inst_id
       and s.object_id      = m.id
       and s.entity_type    = net_api_const_pkg.ENTITY_TYPE_HOST
       and s.standard_type  = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING
       and (
            r.inst_id = i_inst_id or i_inst_id is null
            or (
                i_inst_id is not null
                and r.inst_id in (
                    select m.inst_id
                      from net_interface i
                         , net_member m
                     where i.msp_member_id in (
                            select id
                              from net_member
                             where network_id = vis_api_const_pkg.VISA_NETWORK_ID
                               and inst_id    = i_inst_id
                           )
                       and m.id = i.consumer_member_id
                    )
               )
           )
       and r.id = i.consumer_member_id
       and i.host_member_id = m.id
       ;

    l_host_id :=
        net_api_network_pkg.get_default_host(
            i_network_id  => vis_api_const_pkg.VISA_NETWORK_ID
        );

    l_standard_id :=
        net_api_network_pkg.get_offline_standard(
            i_host_id       => l_host_id
        );

    l_batch_rec.proc_bin :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => i_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => vis_api_const_pkg.VISA_ACQ_PROC_BIN_HEADER
          , i_param_tab     => l_param_tab
        );

    trc_log_pkg.debug(
        i_text  => LOG_PREFIX || 'inst_id tab count: ' || l_inst_id_tab.count
    );

    for i in 1 .. l_inst_id_tab.count loop
        l_record_count :=
            estimate_ammf_for_upload(
                i_inst_id       => l_inst_id_tab(i)
              , i_eff_date      => l_eff_date
              , i_full_export   => i_full_export
            );

        l_estimated_count := l_estimated_count + l_record_count;

        trc_log_pkg.debug(
            i_text  => LOG_PREFIX || 'l_estimated_count: ' || l_estimated_count || ' l_record_count: ' || l_record_count || ' l_inst_id_tab(i): ' || l_inst_id_tab(i)
        );
    end loop;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count  => l_estimated_count
    );

    if l_estimated_count > 0 then
        for i in 1 .. l_inst_id_tab.count loop
            l_proc_bin      := null;
            l_header_writed := false;

            l_batch_rec.cmid :=
                cmn_api_standard_pkg.get_varchar_value(
                    i_inst_id       => l_inst_id_tab(i)
                  , i_standard_id   => l_standard_id_tab(i)
                  , i_object_id     => l_host_id_tab(i)
                  , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_param_name    => vis_api_const_pkg.CMID
                  , i_param_tab     => l_param_tab
                );

            l_batch_rec.proc_bin := nvl(l_batch_rec.proc_bin, l_batch_rec.cmid);

            l_batch_rec.acq_business_id :=
                cmn_api_standard_pkg.get_varchar_value(
                    i_inst_id       => l_inst_id_tab(i)
                  , i_standard_id   => l_standard_id_tab(i)
                  , i_object_id     => l_host_id_tab(i)
                  , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_param_name    => vis_api_const_pkg.ACQ_BUSINESS_ID
                  , i_param_tab     => l_param_tab
                );

            trc_log_pkg.debug(
                i_text  => LOG_PREFIX || 'cmid = ' || l_batch_rec.cmid || ', proc_bin = ' || l_batch_rec.proc_bin || ', acq_business_id = ' || l_batch_rec.acq_business_id
            );

            enum_ammf_msg_for_upload(
                i_inst_id               => l_inst_id_tab(i)
              , i_eff_date              => l_eff_date
              , i_full_export           => i_full_export
              , o_event_object_id_tab   => l_event_object_id_tab
              , o_fin_cur               => l_fin_cur
            );

            loop
                fetch l_fin_cur bulk collect into l_merchant_tab limit BULK_LIMIT;

                for j in 1 .. l_merchant_tab.count loop
                    if l_proc_bin is null or (l_proc_bin is not null and l_batch_rec.proc_bin != l_proc_bin) then

                        prc_api_file_pkg.open_file(
                            o_sess_file_id  => l_session_file_id
                            , i_file_type   => vis_api_const_pkg.FILE_TYPE_AMMF
                            , io_params     => l_params
                        );

                        trc_log_pkg.debug(
                            'Open session file id [' || l_session_file_id || ']' ||
                            ', with file type [' || vis_api_const_pkg.FILE_TYPE_AMMF || ']'
                        );

                        process_file_header(
                              i_proc_bin         => l_batch_rec.proc_bin
                            , i_inst_id          => l_inst_id_tab(j)
                            , i_standard_id      => l_standard_id_tab(j)
                            , i_host_id          => l_host_id_tab(j)
                            , i_session_file_id  => l_session_file_id
                            , o_file             => l_file
                        );

                        init_batch(
                            io_batch             => l_batch
                            , i_session_file_id  => l_file.id
                            , i_file_proc_bin    => l_file.proc_bin
                        );

                        l_proc_bin          := l_batch_rec.proc_bin;

                        l_header_writed     := true;
                    end if;

                    if l_header_writed and (l_proc_bin is not null and l_batch_rec.proc_bin != l_proc_bin)
                    then
                        process_batch_trailer(
                            io_batch            => l_batch
                          , i_host_id           => l_host_id_tab(j)
                          , i_inst_id           => l_inst_id_tab(j)
                          , i_standard_id       => l_standard_id_tab(j)
                          , i_session_file_id   => l_session_file_id
                        );

                        l_file.tcr_total        := l_file.tcr_total      + l_batch.tcr_total;
                        l_file.trans_total      := l_file.trans_total    + l_batch.trans_total;
                        l_file.src_amount       := l_file.src_amount     + l_batch.src_amount;
                        l_file.monetary_total   := l_file.monetary_total + l_batch.monetary_total;
                        l_file.dst_amount       := l_file.dst_amount     + l_batch.dst_amount;
                        l_file.batch_total      := l_file.batch_total    + 1;

                        process_file_trailer(
                            io_file             => l_file
                          , i_host_id           => l_host_id_tab(j)
                          , i_inst_id           => l_inst_id_tab(j)
                          , i_standard_id       => l_standard_id_tab(j)
                          , i_session_file_id   => l_session_file_id
                        );

                        prc_api_file_pkg.close_file(
                            i_sess_file_id      => l_session_file_id
                          , i_status            => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                        );

                        l_header_writed     := false;
                    end if;

                    process_draft(
                        i_merchant_rec      => l_merchant_tab(j)
                      , i_batch_rec         => l_batch_rec
                      , i_session_file_id   => l_session_file_id
                      , io_batch            => l_batch
                    );

                end loop;

                l_processed_count := l_processed_count + l_merchant_tab.count;

                prc_api_stat_pkg.log_current(
                    i_current_count     => l_processed_count
                  , i_excepted_count    => 0
                );

                exit when l_fin_cur%notfound;
            end loop;
            close l_fin_cur;

            if l_header_writed then
                process_batch_trailer(
                    io_batch             => l_batch
                    , i_host_id          => l_host_id_tab(i)
                    , i_inst_id          => l_inst_id_tab(i)
                    , i_standard_id      => l_standard_id_tab(i)
                    , i_session_file_id  => l_session_file_id
                );

                l_file.tcr_total      := l_file.tcr_total      + l_batch.tcr_total;
                l_file.trans_total    := l_file.trans_total    + l_batch.trans_total;
                l_file.src_amount     := l_file.src_amount     + l_batch.src_amount;
                l_file.monetary_total := l_file.monetary_total + l_batch.monetary_total;
                l_file.dst_amount     := l_file.dst_amount     + l_batch.dst_amount;
                l_file.batch_total    := l_file.batch_total    + 1;

                process_file_trailer(
                    io_file              => l_file
                    , i_host_id          => l_host_id_tab(i)
                    , i_inst_id          => l_inst_id_tab(i)
                    , i_standard_id      => l_standard_id_tab(i)
                    , i_session_file_id  => l_session_file_id
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => l_session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                );
            end if;

            if i_full_export = com_api_const_pkg.FALSE and l_event_object_id_tab.count > 0 then
                evt_api_event_pkg.change_event_object_status(
                    i_event_object_id_tab => l_event_object_id_tab
                  , i_event_object_status => evt_api_const_pkg.EVENT_STATUS_PROCESSED
                );
                trc_log_pkg.debug(
                    'Event objects status processed: ' || l_event_object_id_tab.count
                );
            end if;

        end loop;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        , i_processed_total  => l_processed_count
    );

    trc_log_pkg.debug(
        i_text  => 'Visa AMMF service procedure end'
    );

exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end process;

end;
/

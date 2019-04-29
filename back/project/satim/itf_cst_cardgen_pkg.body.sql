create or replace package body itf_cst_cardgen_pkg is
/*********************************************************
 *  Custom cardgen processing API <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 18.02.2015 <br />
 *  Last changed by $Author: kondratyev $ <br />
 *  $LastChangedDate:: 2015-02-18 12:20:06 +0400#$ <br />
 *  Revision: $LastChangedRevision: 36849 $ <br />
 *  Module: itf_cst_cardgen_pkg <br />
 *  @headcom
 **********************************************************/

BER_TLV_MIN_LENGTH    constant com_api_type_pkg.t_tiny_id  := 127;
BER_TLV_ADD_LENGTH    constant com_api_type_pkg.t_short_id := 32768;
g_host_id                      com_api_type_pkg.t_tiny_id;
g_standard_id                  com_api_type_pkg.t_tiny_id;

function get_tag_length(
    i_len                      in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_name
is
    l_result    com_api_type_pkg.t_tag;
begin
    l_result :=
        case when i_len > BER_TLV_MIN_LENGTH
            then trim(to_char((i_len + BER_TLV_ADD_LENGTH), 'XXXX'))
            else lpad(trim(to_char(i_len, lpad('X', length(i_len), 'X'))), 2, '0')
        end;
    return l_result;
end get_tag_length;

procedure get_add_data(
    i_batch_card_rec    in     prs_api_type_pkg.t_batch_card_rec
  , i_card_info_rec     in     prs_api_type_pkg.t_card_info_rec
  , o_add_line             out com_api_type_pkg.t_lob_data
) is
    l_param_tab         com_api_type_pkg.t_param_tab;
    type t_cmid_tab     is table of com_api_type_pkg.t_tag index by com_api_type_pkg.t_tag;
    l_cmid_tab          t_cmid_tab;
    l_ica_ref_number    com_api_type_pkg.t_tag;
    l_card_inst_id      com_api_type_pkg.t_inst_id;
    l_card_network_id   com_api_type_pkg.t_tiny_id;
    l_card_type         com_api_type_pkg.t_tiny_id;
    l_card_country      com_api_type_pkg.t_curr_code;
    l_value_tag         com_api_type_pkg.t_param_value;
    l_card_category     com_api_type_pkg.t_tag;
    l_reissue_reason    com_api_type_pkg.t_tag;
    l_prev_card_number  com_api_type_pkg.t_card_number;
    l_curr_reissue_seq  com_api_type_pkg.t_byte_char;
    l_prev_seq_number   com_api_type_pkg.t_byte_char;
    l_prev_expir_date   com_api_type_pkg.t_date_short;
    l_ext_inst_code     com_api_type_pkg.t_attr_name := 'SAT';     -- stub
begin
    trc_log_pkg.debug(
        i_text         => 'itf_cst_cardgen_pkg.get_add_data: card_id=' || i_batch_card_rec.card_id
    ); 

    select case d.category
               when iss_api_const_pkg.CARD_CATEGORY_PRIMARY then '001'
               when iss_api_const_pkg.CARD_CATEGORY_SUPLEMENTARY then '002'
                               else '999'
            end                                                                   as card_category
         , case
               when c.reissue_reason is null       then '001'
               when c.reissue_reason  = 'EVNT0195' then '002'
               when c.reissue_reason  = 'EVNT0192' then '003'
               when c.reissue_reason  = 'EVNT0193' then '004'
               when c.reissue_reason  = 'EVNT0143' then '005'
               when c.reissue_reason  = 'EVNT2006' then '006'
                                                   else '999'
            end                                                                   as reissue_reason
         , nvl(n.card_number, lpad(' ', 19, ' '))                                 as prev_card_number
         , to_char((select count(*)
                      from iss_card_instance i
                     start with i.card_id = i_batch_card_rec.card_id
                   connect by prior i.preceding_card_instance_id = i.id), 'fm09') as curr_reissue_seq
         , nvl(to_char(p.seq_number, 'fm09'), '01')                               as prev_seq_number
         , nvl(to_char(p.expir_date, 'yyyymmdd'), lpad(' ',  8, ' '))             as prev_expir_date
      into l_card_category
         , l_reissue_reason
         , l_prev_card_number
         , l_curr_reissue_seq
         , l_prev_seq_number
         , l_prev_expir_date
      from iss_card_instance  c
         , iss_card_instance  p
         , iss_card_number    n
         , iss_card           d
     where c.card_id    = i_batch_card_rec.card_id
       and c.seq_number = (select max(q.seq_number)
                             from iss_card_instance q
                            where q.card_id = c.card_id)
       and c.preceding_card_instance_id = p.id(+)
       and c.split_hash = p.split_hash(+)
       and p.card_id    = n.card_id(+)
       and c.card_id    = d.id;

    iss_api_bin_pkg.get_bin_info(
        i_card_number       => i_batch_card_rec.card_number
      , o_card_inst_id      => l_card_inst_id
      , o_card_network_id   => l_card_network_id
      , o_card_type         => l_card_type
      , o_card_country      => l_card_country
      , i_raise_error       => com_api_type_pkg.FALSE
    );

    if l_card_network_id = cmp_api_const_pkg.MC_NETWORK then
        if not l_cmid_tab.exists(i_batch_card_rec.inst_id) then 
            l_cmid_tab(i_batch_card_rec.inst_id) :=
                cmn_api_standard_pkg.get_varchar_value(
                    i_inst_id       => i_batch_card_rec.inst_id
                  , i_standard_id   => g_standard_id
                  , i_object_id     => g_host_id
                  , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_param_name    => mcw_api_const_pkg.CMID
                  , i_param_tab     => l_param_tab
                );
        end if;
        l_ica_ref_number := l_cmid_tab(i_batch_card_rec.inst_id);
    else
        l_ica_ref_number := '000000';
    end if;

    o_add_line := 'DF8501' || get_tag_length(length(l_card_type))        || l_card_type
               || 'DF8570' || get_tag_length(length(l_ext_inst_code))    || l_ext_inst_code
               || 'DF802D' || get_tag_length(length(l_card_category))    || l_card_category
               || 'DF8E02' || get_tag_length(length(l_reissue_reason))   || l_reissue_reason
               || 'DF8E03' || get_tag_length(length(l_prev_card_number)) || l_prev_card_number
               || 'DF8E04' || get_tag_length(length(l_prev_seq_number))  || l_prev_seq_number
               || 'DF8E05' || get_tag_length(length(l_prev_expir_date))  || l_prev_expir_date
               || 'DF8E06' || get_tag_length(length(l_ica_ref_number))   || l_ica_ref_number;

    l_value_tag :=
        com_api_flexible_data_pkg.get_flexible_value(
            i_field_name        => 'CST_EMBOSS_COMPANY_NAME'
          , i_entity_type       => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
          , i_object_id         => i_batch_card_rec.card_id
        );

    if l_value_tag is not null then
        o_add_line := o_add_line || 'DF8E07' || get_tag_length(length(l_value_tag)) || l_value_tag;
    end if;

    l_value_tag :=
        com_api_flexible_data_pkg.get_flexible_value(
            i_field_name        => 'CST_SATIM_CARD_OFFLINE_LIMIT'
          , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id         => i_batch_card_rec.card_id
        );

    if l_value_tag is not null then
        o_add_line := o_add_line || 'DF8E08' || get_tag_length(length(l_value_tag)) || l_value_tag;
    end if;

end get_add_data;

procedure collect_file_params(
    i_batch_card_rec    in              prs_api_type_pkg.t_batch_card_rec
  , i_card_info_rec     in              prs_api_type_pkg.t_card_info_rec
  , io_params           in out nocopy   com_api_type_pkg.t_param_tab
) is
begin
    rul_api_param_pkg.set_param(
        i_name      => prs_api_const_pkg.PARAM_PERSO_PRIORITY
      , i_value     => i_batch_card_rec.perso_priority
      , io_params   => io_params
    );

    rul_api_param_pkg.set_param(
        i_name      => prs_api_const_pkg.PARAM_CARD_TYPE_NAME
      , i_value     => com_api_i18n_pkg.get_text(
                           i_table_name  => 'net_card_type'
                         , i_column_name => 'name'
                         , i_object_id   => i_batch_card_rec.card_type_id
                         , i_lang        =>  get_user_lang()
                       )
      , io_params   => io_params
    );
end collect_file_params;

begin
    g_host_id     := net_api_network_pkg.get_default_host(i_network_id  => cmp_api_const_pkg.MC_NETWORK);
    g_standard_id := net_api_network_pkg.get_offline_standard(i_host_id  => g_host_id);
end itf_cst_cardgen_pkg;
/

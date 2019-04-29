create or replace package body mcw_api_fin_pkg is
/*********************************************************
 *  API for MasterCard finance message <br />
 *  Created by Khougaev (khougaev@bpcbt.com)  at 05.11.2009 <br />
 *  Module: MCW_API_FIN_PKG <br />
 *  @headcom
 **********************************************************/

CRLF                    constant com_api_type_pkg.t_oracle_name := chr(13) || chr(10);

g_no_original_id_tab    mcw_api_type_pkg.t_fin_tab;

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
', f.de063'||
', f.de071'||
', f.de072'||
', f.de073'||
', f.de093'||
', f.de094'||
', f.de095'||
', f.de100'||
', f.de111'||
', f.p0001_1'||
', f.p0001_2'||
', f.p0002'||
', f.p0004_1'||
', f.p0004_2'||
', iss_api_token_pkg.decode_card_number(i_card_number => c.p0014, i_mask_error => 1) as p0014'||
', f.p0018' ||
', f.p0021'||
', f.p0022'||
', f.p0023'||
', f.p0025_1'||
', f.p0025_2'||
', f.p0028'||
', f.p0029'||
', f.p0042'||
', f.p0043'||
', f.p0045'||
', f.p0047'||
', f.p0052'||
', f.p0058'||
', f.p0059'||
', f.p0072'||
', f.p0137'||
', f.p0146'||
', f.p0146_net'||
', f.p0147'||
', f.p0148'||
', f.p0149_1'||
', f.p0149_2'||
', f.p0158_1'||
', f.p0158_2'||
', f.p0158_3'||
', f.p0158_4'||
', f.p0158_5'||
', f.p0158_6'||
', f.p0158_7'||
', f.p0158_8'||
', f.p0158_9'||
', f.p0158_10'||
', f.p0158_11'||
', f.p0158_12'||
', f.p0158_13'||
', f.p0158_14'||
', f.p0159_1'||
', f.p0159_2'||
', f.p0159_3'||
', f.p0159_4'||
', f.p0159_5'||
', f.p0159_6'||
', f.p0159_7'||
', f.p0159_8'||
', f.p0159_9'||
', f.p0165'||
', f.p0176'||
', f.p0181'||
', f.p0184'||
', f.p0185'||
', f.p0186'||
', f.p0198'||
', f.p0200_1'||
', f.p0200_2'||
', f.p0207'||
', f.p0208_1'||
', f.p0208_2'||
', f.p0209'||
', f.p0210_1'||
', f.p0210_2'||
', f.p0228'||
', f.p0230'||
', f.p0241'||
', f.p0243'||
', f.p0244'||
', f.p0260'||
', f.p0261'||
', f.p0262'||
', f.p0264'||
', f.p0265'||
', f.p0266'||
', f.p0267'||
', f.p0268_1'||
', f.p0268_2'||
', f.p0375'||
', f.p0674'||
', f.p1001'||
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
', f.emv_9f53'||
', f.emv_84'||
', f.emv_9f09'||
', f.emv_9f03'||
', f.emv_9f1e'||
', f.emv_9f41'||
', f.local_message'||
', f.ird_trace'||
', f.ext_claim_id'||
', f.ext_message_id'||
', o.msg_type'
;

procedure get_ird(
    o_p0158_4                out com_api_type_pkg.t_byte_char
  , o_ird_trace              out com_api_type_pkg.t_full_desc
  , i_mti                 in     mcw_api_type_pkg.t_mti
  , i_de024               in     mcw_api_type_pkg.t_de024
  , i_acq_bin             in     mcw_api_type_pkg.t_de002
  , i_hpan                in     mcw_api_type_pkg.t_de002
  , io_de003_1            in out mcw_api_type_pkg.t_de003s
  , i_mcc                 in     com_api_type_pkg.t_mcc
  , i_p0043               in     mcw_api_type_pkg.t_p0043
  , i_p0052               in     mcw_api_type_pkg.t_p0052
  , i_p0023               in     mcw_api_type_pkg.t_p0023
  , i_de038               in     mcw_api_type_pkg.t_de038
  , i_de012               in     mcw_api_type_pkg.t_de012
  , i_de022_1             in     mcw_api_type_pkg.t_de022s
  , i_de022_2             in     mcw_api_type_pkg.t_de022s
  , i_de022_3             in     mcw_api_type_pkg.t_de022s
  , i_de022_4             in     mcw_api_type_pkg.t_de022s
  , i_de022_5             in     mcw_api_type_pkg.t_de022s
  , i_de022_6             in     mcw_api_type_pkg.t_de022s
  , i_de022_7             in     mcw_api_type_pkg.t_de022s
  , i_de022_8             in     mcw_api_type_pkg.t_de022s
  , i_de026               in     mcw_api_type_pkg.t_de026
  , i_de040               in     mcw_api_type_pkg.t_de040
  , i_de004               in     mcw_api_type_pkg.t_de004
  , i_emv_compliant       in     com_api_type_pkg.t_boolean
  , i_de004_rub           in     mcw_api_type_pkg.t_de004
  , i_de043_6             in     mcw_api_type_pkg.t_de043_6
  , i_standard_id         in     com_api_type_pkg.t_tiny_id    := null
  , i_host_id             in     com_api_type_pkg.t_tiny_id    := null
  , i_p0004_1             in     mcw_api_type_pkg.t_p0004_1
  , i_p0004_2             in     mcw_api_type_pkg.t_p0004_2
  , i_p0176               in     mcw_api_type_pkg.t_p0176
  , i_p0207               in     mcw_api_type_pkg.t_p0207
  , i_de042               in     mcw_api_type_pkg.t_de042
  , i_de043_1             in     mcw_api_type_pkg.t_de043_1
  , i_de043_2             in     mcw_api_type_pkg.t_de043_2
  , i_de043_3             in     mcw_api_type_pkg.t_de043_3
  , i_de043_4             in     mcw_api_type_pkg.t_de043_4
  , i_de043_5             in     mcw_api_type_pkg.t_de043_5
  , i_de049               in     mcw_api_type_pkg.t_de049
  , i_p0674               in     mcw_api_type_pkg.t_p0674
  , i_de063               in     mcw_api_type_pkg.t_de063
  , i_p0001_1             in     mcw_api_type_pkg.t_p0001_1
  , i_p0001_2             in     mcw_api_type_pkg.t_p0001_2
  , i_p0198               in     mcw_api_type_pkg.t_p0198
) 
is
    cursor ird_cur is
        select ird.arrangement_type
             , ird.arrangement_code
             , ird.ird
             , ird.product_id
             , ird.brand
             , ird.issuer_region
             , ird.acquiring_region
             , ird.acq_country
             , ird.de003_1
             , ird.cab_program
             , rownum rn
          from (
                select /*+ INDEX (ind, net_bin_scan_ndx) */
                       distinct
                       aar.arrangement_type
                     , aar.arrangement_code
                     , prc_ird.ird ird
                     , bin.product_id
                     , bin.brand
                     , bin.region      as issuer_region
                     , mab.region      as acquiring_region
                     , mab.country     as acq_country
                     , prc_ird.de003_1
                     , iar.type_priority
                     , iar.brand_priority
                     , mi.priority
                     , mm.cab_program
                     , decode(prod_ird.ird, '%', 1, 0) ird_priority
                  from net_bin_range_index ind
                     , mcw_bin_range bin
                     , mcw_iss_arrangement iar
                     , mcw_acq_arrangement aar
                     , mcw_proc_code_ird prc_ird
                     , mcw_product_ird prod_ird
                     , mcw_acq_bin mab
                     , com_country cc
                     , mcw_mcc mm
                     , mcw_cab_program_ird mcpi
                     , (select ird, priority, arrangement_type, arrangement_code
                          from mcw_interchange_map
                         where nvl(is_default, 0) = 0
                         group by ird, priority, arrangement_type, arrangement_code) mi
                 where ind.pan_prefix              = substr(i_hpan, 1, 5)
                   and i_hpan between ind.pan_low and ind.pan_high
                   and ind.pan_low               = bin.pan_low
                   and ind.pan_high              = bin.pan_high
                   and ind.pan_low               = iar.pan_low
                   and ind.pan_high              = iar.pan_high
                   and aar.acq_bin               = i_acq_bin
                   and aar.arrangement_type      = iar.arrangement_type
                   and aar.arrangement_code      = iar.arrangement_code
                   and aar.brand                 = iar.brand
                   and prc_ird.arrangement_type  = aar.arrangement_type
                   and prc_ird.arrangement_code  = aar.arrangement_code
                   and prc_ird.mti               = '1240'
                   and prc_ird.de024             = '200'
                   and prc_ird.de003_1           = io_de003_1
                   and prc_ird.brand             = aar.brand
                   and prod_ird.arrangement_type = prc_ird.arrangement_type
                   and prod_ird.arrangement_code = prc_ird.arrangement_code
                   and prod_ird.product_id       = bin.product_id
                   and prod_ird.brand            = prc_ird.brand
                   and prc_ird.ird            like prod_ird.ird
                   and mab.acq_bin               = aar.acq_bin
                   and mab.brand                 = aar.brand
                   and cc.name                   = mab.country
                   and case when cc.code = bin.country and (io_de003_1 in ('00', '09', '18', '20') or bin.region != 'D') and aar.arrangement_type = '4'
                            then com_api_type_pkg.TRUE
                            when (cc.code = bin.country and io_de003_1 not in ('00', '09', '18', '20') or mab.region = bin.region) and aar.arrangement_type = '2'
                            then com_api_type_pkg.TRUE
                            when mab.region != bin.region and aar.arrangement_type = '1'
                            then com_api_type_pkg.TRUE
                            when cc.code != bin.country   and aar.arrangement_type = '3'
                            then com_api_type_pkg.TRUE
                            when aar.arrangement_type = '8'
                            then com_api_type_pkg.TRUE
                            else com_api_type_pkg.FALSE
                       end = com_api_type_pkg.TRUE
                   and mm.mcc                      = i_mcc
                   and mm.cab_program              = mcpi.cab_program
                   and mcpi.brand                  = prc_ird.brand
                   and mcpi.arrangement_type       = prc_ird.arrangement_type
                   and mcpi.arrangement_code       = prc_ird.arrangement_code
                   and prod_ird.ird             like mcpi.ird
                   and (prc_ird.paypass_ind is null or (prc_ird.paypass_ind = 'Y' and bin.paypass_ind = 'Y'))
                   and mi.arrangement_type         = aar.arrangement_type
                   and prc_ird.arrangement_code like mi.arrangement_code
                   and prc_ird.ird              like mi.ird
                 order by iar.type_priority
                        , iar.brand_priority
                        , mi.priority
                        , decode(prod_ird.ird, '%', 1, 0)
            ) ird;

    cursor ird_def_cur is
        select arrangement_type
             , arrangement_code
             , ird
             , product_id
             , brand
             , issuer_region
          from (
              select /*+ INDEX (ind, net_bin_scan_ndx) */
                  distinct
                    aar.arrangement_type
                  , aar.arrangement_code
                  , imp.ird
                  , bin.product_id
                  , bin.brand
                  , bin.region issuer_region
                  , iar.type_priority
                  , iar.brand_priority
               from net_bin_range_index ind
                  , mcw_bin_range bin
                  , mcw_iss_arrangement iar
                  , mcw_acq_arrangement aar
                  , mcw_interchange_map imp
              where ind.pan_prefix = substr(i_hpan, 1, 5)
                and i_hpan between ind.pan_low and ind.pan_high
                and ind.pan_low             = bin.pan_low
                and ind.pan_high            = bin.pan_high
                and ind.pan_low             = iar.pan_low
                and ind.pan_high            = iar.pan_high
                and aar.acq_bin             = i_acq_bin
                and aar.arrangement_type    = iar.arrangement_type
                and aar.arrangement_code    = iar.arrangement_code
                and aar.brand               = iar.brand
                and imp.arrangement_type    = aar.arrangement_type
                and aar.arrangement_code like imp.arrangement_code
                and nvl(imp.is_default, 0)  = 1
        )
        order by type_priority
               , brand_priority;

    l_standard_version      com_api_type_pkg.t_tiny_id;

    l_ids                   com_api_type_pkg.t_number_tab;
    l_mods                  com_api_type_pkg.t_number_tab;
    l_irds                  com_api_type_pkg.t_dict_tab;
    l_mod_index             binary_integer;
    l_loop_count            binary_integer;

    l_param_tab             com_api_type_pkg.t_param_tab;

    procedure set_mod_params (
        i_mti                in     mcw_api_type_pkg.t_mti
      , i_de024              in     mcw_api_type_pkg.t_de024
      , i_brand              in     com_api_type_pkg.t_dict_value
      , i_product_id         in     com_api_type_pkg.t_dict_value
      , i_de003_1            in     mcw_api_type_pkg.t_de003s
      , i_issuer_region      in     com_api_type_pkg.t_dict_value
      , i_acquiring_region   in     com_api_type_pkg.t_dict_value
      , i_p0043              in     mcw_api_type_pkg.t_p0043
      , i_p0052              in     mcw_api_type_pkg.t_p0052
      , i_p0023              in     mcw_api_type_pkg.t_p0023
      , i_de038              in     mcw_api_type_pkg.t_de038
      , i_de012              in     mcw_api_type_pkg.t_de012
      , i_de022_1            in     mcw_api_type_pkg.t_de022s
      , i_de022_2            in     mcw_api_type_pkg.t_de022s
      , i_de022_3            in     mcw_api_type_pkg.t_de022s
      , i_de022_4            in     mcw_api_type_pkg.t_de022s
      , i_de022_5            in     mcw_api_type_pkg.t_de022s
      , i_de022_6            in     mcw_api_type_pkg.t_de022s
      , i_de022_7            in     mcw_api_type_pkg.t_de022s
      , i_de022_8            in     mcw_api_type_pkg.t_de022s
      , i_de026              in     mcw_api_type_pkg.t_de026
      , i_de040              in     mcw_api_type_pkg.t_de040
      , i_de004              in     mcw_api_type_pkg.t_de004
      , i_emv_compliant      in     com_api_type_pkg.t_boolean
      , i_de004_rub          in     mcw_api_type_pkg.t_de004
      , i_de043_6            in     mcw_api_type_pkg.t_de043_6
      , i_acq_country        in     com_api_type_pkg.t_country_code default null
      , i_cab_program        in     com_api_type_pkg.t_mcc default null
      , i_standard_version   in     com_api_type_pkg.t_tiny_id
      , i_p0001_1            in     mcw_api_type_pkg.t_p0001_1
      , i_p0001_2            in     mcw_api_type_pkg.t_p0001_2
      , i_p0004_1            in     mcw_api_type_pkg.t_p0004_1
      , i_p0004_2            in     mcw_api_type_pkg.t_p0004_2
      , i_p0176              in     mcw_api_type_pkg.t_p0176
      , i_p0207              in     mcw_api_type_pkg.t_p0207
      , i_de042              in     mcw_api_type_pkg.t_de042
      , i_de043_1            in     mcw_api_type_pkg.t_de043_1
      , i_de043_2            in     mcw_api_type_pkg.t_de043_2
      , i_de043_3            in     mcw_api_type_pkg.t_de043_3
      , i_de043_4            in     mcw_api_type_pkg.t_de043_4
      , i_de043_5            in     mcw_api_type_pkg.t_de043_5
      , i_de049              in     mcw_api_type_pkg.t_de049
      , i_p0674              in     mcw_api_type_pkg.t_p0674
      , i_de063              in     mcw_api_type_pkg.t_de063
      , i_p0198              in     mcw_api_type_pkg.t_p0198
    ) is
    begin
        l_param_tab.delete;
        rul_api_param_pkg.set_param(
            i_name     => 'MESSAGE_TYPE'
          , io_params  => l_param_tab
          , i_value    => i_mti
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_024'
          , io_params  => l_param_tab
          , i_value    => i_de024
        );
        rul_api_param_pkg.set_param(
            i_name     => 'CARD_PROGRAM_ID'
          , io_params  => l_param_tab
          , i_value    => i_brand
        );
        rul_api_param_pkg.set_param(
            i_name     => 'GCMS_PRODUCT_ID'
          , io_params  => l_param_tab
          , i_value    => i_product_id
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_003_1'
          , io_params  => l_param_tab
          , i_value    => i_de003_1
        );
        rul_api_param_pkg.set_param(
            i_name     => 'ACQUIRING_REGION'
          , io_params  => l_param_tab
          , i_value    => i_acquiring_region
        );
        rul_api_param_pkg.set_param(
            i_name     => 'ISSUER_REGION'
          , io_params  => l_param_tab
          , i_value    => i_issuer_region
        );
        rul_api_param_pkg.set_param(
            i_name     => 'PDS_0043'
          , io_params  => l_param_tab
          , i_value    => i_p0043
        );
        rul_api_param_pkg.set_param(
            i_name     => 'PDS_0052'
          , io_params  => l_param_tab
          , i_value    => i_p0052
        );
        rul_api_param_pkg.set_param(
            i_name     => 'PDS_0023'
          , io_params  => l_param_tab
          , i_value    => i_p0023
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_038'
          , io_params  => l_param_tab
          , i_value    => i_de038
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_012'
          , io_params  => l_param_tab
          , i_value    => i_de012
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_022_1'
          , io_params  => l_param_tab
          , i_value    => i_de022_1
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_022_3'
          , io_params  => l_param_tab
          , i_value    => i_de022_3
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_022_4'
          , io_params  => l_param_tab
          , i_value    => i_de022_4
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_022_5'
          , io_params  => l_param_tab
          , i_value    => i_de022_5
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_022_6'
          , io_params  => l_param_tab
          , i_value    => i_de022_6
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_022_7'
          , io_params  => l_param_tab
          , i_value    => i_de022_7
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_026'
          , io_params  => l_param_tab
          , i_value    => i_de026
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_040'
          , io_params  => l_param_tab
          , i_value    => i_de040
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_022_2'
          , io_params  => l_param_tab
          , i_value    => i_de022_2
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_022_8'
          , io_params  => l_param_tab
          , i_value    => i_de022_8
        );
        rul_api_param_pkg.set_param(
            i_name     => 'EMV_COMPLIANT'
          , io_params  => l_param_tab
          , i_value    => i_emv_compliant
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_004'
          , io_params  => l_param_tab
          , i_value    => i_de004
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE004_RUB'
          , io_params  => l_param_tab
          , i_value    => i_de004_rub
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_043_6'
          , io_params  => l_param_tab
          , i_value    => i_de043_6
        );
        rul_api_param_pkg.set_param(
            i_name     => 'ACQ_COUNTRY'
          , io_params  => l_param_tab
          , i_value    => i_acq_country
        );
        rul_api_param_pkg.set_param(
            i_name     => 'CAB_PROGRAM'
          , io_params  => l_param_tab
          , i_value    => i_cab_program
        );
        rul_api_param_pkg.set_param(
            i_name     => 'STANDARD_VERSION'
          , io_params  => l_param_tab
          , i_value    => i_standard_version
        );
        rul_api_param_pkg.set_param(
            i_name     => 'PDS_0004'
          , io_params  => l_param_tab
          , i_value    => i_p0004_1||i_p0004_2
        );
        rul_api_param_pkg.set_param(
            i_name     => 'PDS_0176'
          , io_params  => l_param_tab
          , i_value    => i_p0176
        );
        rul_api_param_pkg.set_param(
            i_name     => 'PDS_0207'
          , io_params  => l_param_tab
          , i_value    => i_p0207
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_042'
          , io_params  => l_param_tab
          , i_value    => i_de042
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_043_1'
          , io_params  => l_param_tab
          , i_value    => i_de043_1
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_043_2'
          , io_params  => l_param_tab
          , i_value    => i_de043_2
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_043_3'
          , io_params  => l_param_tab
          , i_value    => i_de043_3
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_043_4'
          , io_params  => l_param_tab
          , i_value    => i_de043_4
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_043_5'
          , io_params  => l_param_tab
          , i_value    => i_de043_5
        );
        rul_api_param_pkg.set_param(
            i_name     => 'DE_049'
          , io_params  => l_param_tab
          , i_value    => i_de049
        );
        rul_api_param_pkg.set_param(
            i_name     => 'PDS_0674'
          , io_params  => l_param_tab
          , i_value    => i_p0674
        );
        rul_api_param_pkg.set_param(
            i_name     => 'TRACE_ID'
          , io_params  => l_param_tab
          , i_value    => substr(i_de063, 2)
        );
        rul_api_param_pkg.set_param(
            i_name     => 'PDS_0001'
          , io_params  => l_param_tab
          , i_value    => i_p0001_1 || i_p0001_2
        );
        rul_api_param_pkg.set_param(
            i_name     => 'FACE_TO_FACE'
          , io_params  => l_param_tab
          , i_value    => case when i_de022_4 = '1' and i_de022_5 = '0' and i_de022_6 = '1' then 1 else 0 end
        );
        rul_api_param_pkg.set_param(
            i_name     => 'MAGNETIC_STRIPE_DATA_PRESENT'
          , io_params  => l_param_tab
          , i_value    => case when i_p0001_1 is null and i_p0001_2 is null and i_mti = '1240' and i_de024 = '200' then 1 else 0 end
        );
        rul_api_param_pkg.set_param(
            i_name     => 'P_0198'
          , io_params  => l_param_tab
          , i_value    => i_p0198
        );

    end set_mod_params;

    procedure correct_de003s is
    begin
        -- transactions with maestro cards the processing code DE3 has value 00 instead of 18
        if o_p0158_4 in ('45', '49', '46', '47', '48') then
            io_de003_1 :=
                case
                    when io_de003_1 in (mcw_api_const_pkg.PROC_CODE_UNIQUE)
                    then mcw_api_const_pkg.PROC_CODE_PURCHASE
                    else io_de003_1
                end;
        end if;
    end;

begin
    trc_log_pkg.debug(
        i_text  => 'get_ird: START; i_acq_bin [' || i_acq_bin
                || '], i_hpan ['          || iss_api_card_pkg.get_card_mask(i_card_number => i_hpan)
                || '], io_de003_1 ['      || io_de003_1
                || '], i_mcc ['           || i_mcc
                || '], i_p0043 ['         || i_p0043
                || '], i_p0052 ['         || i_p0052
                || '], i_p0023 ['         || i_p0023
                || '], i_de038 ['         || i_de038
                || '], i_de012 ['         || i_de012
                || '], i_de022_1 ['       || i_de022_1
                || '], i_de022_2 ['       || i_de022_2
                || '], i_de022_3 ['       || i_de022_3
                || '], i_de022_4 ['       || i_de022_4
                || '], i_de022_5 ['       || i_de022_5
                || '], i_de022_6 ['       || i_de022_6
                || '], i_de022_7 ['       || i_de022_7
                || '], i_de022_8 ['       || i_de022_8
                || '], i_de026 ['         || i_de026
                || '], i_de040 ['         || i_de040
                || '], i_de004 ['         || i_de004
                || '], i_emv_compliant [' || i_emv_compliant
                || '], i_de004_rub ['     || i_de004_rub
                || '], i_de043_6 ['       || i_de043_6
                || '], i_standard_id ['   || i_standard_id
                || '], i_host_id ['       || i_host_id
                || '], i_p0004_1 ['       || i_p0004_1
                || '], i_p0004_2 ['       || i_p0004_2
                || ']'
    );

    -- Get current version ID for Mastercard offline clearing standard
    -- to provide possibility to use it in modifiers' conditions
    l_standard_version :=
        cmn_api_standard_pkg.get_current_version(
            i_standard_id  => nvl(i_standard_id, mcw_api_const_pkg.MCW_STANDARD_ID)
          , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id    => coalesce(
                                  i_host_id
                                , net_api_network_pkg.get_default_host(
                                      i_network_id  => mcw_api_const_pkg.MCW_NETWORK_ID
                                  )
                              )
          , i_eff_date     => com_api_sttl_day_pkg.get_sysdate()
        );

    o_p0158_4    := mcw_cst_ird_pkg.get_default_ird;
    l_loop_count := 0;

    for rec in ird_cur loop

        select i.mod_id
             , i.ird
             , i.id
          bulk collect into
               l_mods
             , l_irds
             , l_ids
          from mcw_interchange_map i
         where i.arrangement_type      = rec.arrangement_type
           and rec.arrangement_code like i.arrangement_code
           and i.ird                like rec.ird
         order by i.priority;

        set_mod_params(
            i_mti               => i_mti
          , i_de024             => i_de024
          , i_brand             => rec.brand
          , i_product_id        => rec.product_id
          , i_de003_1           => rec.de003_1
          , i_issuer_region     => rec.issuer_region
          , i_acquiring_region  => rec.acquiring_region
          , i_p0043             => i_p0043
          , i_p0052             => i_p0052
          , i_p0023             => i_p0023
          , i_de038             => i_de038
          , i_de012             => i_de012
          , i_de022_1           => i_de022_1
          , i_de022_2           => i_de022_2
          , i_de022_3           => i_de022_3
          , i_de022_4           => i_de022_4
          , i_de022_5           => i_de022_5
          , i_de022_6           => i_de022_6
          , i_de022_7           => i_de022_7
          , i_de022_8           => i_de022_8
          , i_de026             => i_de026
          , i_de040             => i_de040
          , i_de004             => i_de004
          , i_emv_compliant     => i_emv_compliant
          , i_de004_rub         => i_de004_rub
          , i_de043_6           => i_de043_6
          , i_acq_country       => rec.acq_country
          , i_cab_program       => rec.cab_program
          , i_standard_version  => l_standard_version
          , i_p0004_1           => i_p0004_1
          , i_p0004_2           => i_p0004_2
          , i_p0176             => i_p0176 
          , i_p0207             => i_p0207 
          , i_de042             => i_de042
          , i_de043_1           => i_de043_1
          , i_de043_2           => i_de043_2
          , i_de043_3           => i_de043_3
          , i_de043_4           => i_de043_4
          , i_de043_5           => i_de043_5
          , i_de049             => i_de049
          , i_p0674             => i_p0674
          , i_de063             => i_de063
          , i_p0001_1           => i_p0001_1
          , i_p0001_2           => i_p0001_2
          , i_p0198             => i_p0198
        );

        l_mod_index :=
            rul_api_mod_pkg.select_condition(
                i_mods        => l_mods
              , i_params      => l_param_tab
              , i_mask_error  => com_api_type_pkg.TRUE
            );

        o_ird_trace  := o_ird_trace
                        || case
                               when l_loop_count = 0
                               then null
                               when l_mod_index is not null
                               then ','
                               else null
                           end
                        || case
                               when l_mod_index is not null
                               then l_ids(l_mod_index)
                               else null
                           end;

        l_loop_count := l_loop_count + 1;

        if l_mod_index is not null then
            o_p0158_4 := l_irds(l_mod_index);
            correct_de003s;

            trc_log_pkg.debug (
                i_text          => 'get_ird: FINISH in cycle 1; return o_p0158_4 [#1], mod_id [#2]'
              , i_env_param1    => o_p0158_4
              , i_env_param2    => l_mods(l_mod_index)
            );

            return;
        end if;

    end loop;

    o_ird_trace  := o_ird_trace || '/';
    l_loop_count := 0;

    for rec in ird_def_cur loop
        select i.mod_id
             , i.ird
             , i.id
          bulk collect into
               l_mods
             , l_irds
             , l_ids
          from mcw_interchange_map i
         where i.arrangement_type      = rec.arrangement_type
           and rec.arrangement_code like i.arrangement_code
           and i.ird                like rec.ird
           and nvl(i.is_default, 0)    = 1
         order by i.priority;

        set_mod_params(
            i_mti               => i_mti
          , i_de024             => i_de024
          , i_brand             => rec.brand
          , i_product_id        => rec.product_id
          , i_de003_1           => io_de003_1
          , i_issuer_region     => rec.issuer_region
          , i_acquiring_region  => null
          , i_p0043             => i_p0043
          , i_p0052             => i_p0052
          , i_p0023             => i_p0023
          , i_de038             => i_de038
          , i_de012             => i_de012
          , i_de022_1           => i_de022_1
          , i_de022_2           => i_de022_2
          , i_de022_3           => i_de022_3
          , i_de022_4           => i_de022_4
          , i_de022_5           => i_de022_5
          , i_de022_6           => i_de022_6
          , i_de022_7           => i_de022_7
          , i_de022_8           => i_de022_8
          , i_de026             => i_de026
          , i_de040             => i_de040
          , i_de004             => i_de004
          , i_emv_compliant     => i_emv_compliant
          , i_de004_rub         => i_de004_rub
          , i_de043_6           => i_de043_6
          , i_standard_version  => l_standard_version
          , i_p0004_1           => i_p0004_1
          , i_p0004_2           => i_p0004_2
          , i_p0176             => i_p0176
          , i_p0207             => i_p0207
          , i_de042             => i_de042
          , i_de043_1           => i_de043_1
          , i_de043_2           => i_de043_2
          , i_de043_3           => i_de043_3
          , i_de043_4           => i_de043_4
          , i_de043_5           => i_de043_5
          , i_de049             => i_de049
          , i_p0674             => i_p0674
          , i_de063             => i_de063
          , i_p0001_1           => i_p0001_1
          , i_p0001_2           => i_p0001_2
          , i_p0198             => i_p0198
        );

        l_mod_index :=
            rul_api_mod_pkg.select_condition(
                i_mods        => l_mods
              , i_params      => l_param_tab
              , i_mask_error  => com_api_type_pkg.TRUE
            );

        o_ird_trace  := o_ird_trace
                        || case
                               when l_loop_count = 0
                               then null
                               when l_mod_index is not null
                               then ','
                               else null
                           end
                        || case
                               when l_mod_index is not null
                               then l_ids(l_mod_index)
                               else null
                           end;

        l_loop_count := l_loop_count + 1;

        if l_mod_index is not null then
            o_p0158_4 := l_irds(l_mod_index);
            correct_de003s;

            trc_log_pkg.debug(
                i_text          => 'get_ird: FINISH in cycle 2; return o_p0158_4 [#1], mod_id [#2]'
              , i_env_param1    => o_p0158_4
              , i_env_param2    => l_mods(l_mod_index)
            );
            
            return;
        end if;

    end loop;

    o_ird_trace := o_ird_trace || '/';

    trc_log_pkg.debug (
        i_text          => 'get_ird: FINISH; return o_p0158_4 [#1]'
      , i_env_param1    => o_p0158_4
    );

end get_ird;

procedure modify_ird (
    i_id                  in com_api_type_pkg.t_long_id
  , i_ird                 in mcw_api_type_pkg.t_p0158_4
  , i_ird_trace           in com_api_type_pkg.t_full_desc := null
) is
begin
    update mcw_fin
       set p0158_4   = i_ird
         , reject_id = null
         , status    = net_api_const_pkg.CLEARING_MSG_STATUS_READY
         , ird_trace = i_ird_trace
     where id = i_id;
end modify_ird;

function get_ird_trace_desc(
    i_ird_trace           in com_api_type_pkg.t_full_desc
) return com_api_type_pkg.t_text
is
    l_part1        com_api_type_pkg.t_full_desc;
    l_part2        com_api_type_pkg.t_full_desc;
    l_result       com_api_type_pkg.t_full_desc;
    l_slash1       com_api_type_pkg.t_tiny_id;
    l_slash2       com_api_type_pkg.t_tiny_id;

    function get_ird_desc(
        i_id_list  com_api_type_pkg.t_full_desc
    ) return com_api_type_pkg.t_full_desc
    is
        l_id_tab         com_api_type_pkg.t_long_tab;
        l_object_id_tab  num_tab_tpt := num_tab_tpt();
        l_result         com_api_type_pkg.t_full_desc;
    begin
        com_api_type_pkg.get_array_from_string(i_id_list, l_id_tab);

        for i in 1 .. l_id_tab.count loop
            l_object_id_tab.extend;
            l_object_id_tab(i) := l_id_tab(i);
        end loop;

        select listagg('id = ' || i.id || ' (type = '     || i.arrangement_type
                                       || ', code = '''   || i.arrangement_code || ''''
                                       || ', priority = ' || i.priority
                                       || ', mod_id = '   || i.mod_id
                                       || ', IRD = '''    || i.ird              || ''''
                                       || ')'
                     , CRLF)
                   within group (order by i.id)
          into l_result
          from mcw_interchange_map i
         where id in (select column_value from table(cast(l_object_id_tab as num_tab_tpt)));

        return l_result;
    end get_ird_desc;
begin
    l_part1  := i_ird_trace;
    l_slash1 := instr(l_part1, '/');
    if l_slash1 > 0 then
        l_part2  := substr(l_part1,    l_slash1 + 1);
        l_part1  := substr(l_part1, 1, l_slash1 - 1);
        l_slash2 := instr(l_part2, '/');
        if l_slash2 > 0 then
            l_part2 := substr(l_part2, 1, l_slash2 - 1);
        end if;
    end if;

    l_result := '[1] Step 1:'                || CRLF
                || get_ird_desc(l_part1)     || CRLF || CRLF;

    if l_slash1 > 0 then
        l_result := l_result
                    || '[2] Step 2:'         || CRLF
                    || get_ird_desc(l_part2) || CRLF || CRLF;
    end if;

    if l_slash2 > 0 then
        l_result := l_result
                    || '[3] Apply default IRD = '
                    || mcw_cst_ird_pkg.get_default_ird || CRLF;
    else
        l_result := l_result
                    || '[3] Apply last IRD'            || CRLF;
    end if;

    return l_result;
end get_ird_trace_desc;

procedure get_processing_date (
    i_id                in     com_api_type_pkg.t_long_id
  , i_is_fpd_matched    in     com_api_type_pkg.t_boolean
  , i_is_fsum_matched   in     com_api_type_pkg.t_boolean
  , i_file_id           in     com_api_type_pkg.t_short_id
  , o_p0025_2              out mcw_api_type_pkg.t_p0025_2
) is
begin
    if i_is_fpd_matched = com_api_type_pkg.TRUE then
        select mcw_api_file_pkg.extract_file_date (
                   i_p0105  => f.p0105
               )
          into o_p0025_2
          from mcw_fin m
             , mcw_fpd d
             , mcw_file f
         where m.id = i_id
           and d.id = m.fpd_id
           and d.file_id = f.id;

    elsif i_is_fsum_matched = com_api_type_pkg.TRUE then
        select mcw_api_file_pkg.extract_file_date (
                   i_p0105  => f.p0105
               )
          into o_p0025_2
          from mcw_fin m
             , mcw_fsum s
             , mcw_file f
         where m.id = i_id
           and s.id = m.fsum_id
           and s.file_id = f.id;

    elsif i_file_id is not null then
        select mcw_api_file_pkg.extract_file_date (
                   i_p0105  => f.p0105
               )
          into o_p0025_2
          from mcw_file f
         where f.id = i_file_id;

    else
        o_p0025_2 := get_sysdate;

    end if;
exception
    when no_data_found then
        o_p0025_2 := get_sysdate;
end;

function estimate_messages_for_upload (
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_cmid                in mcw_api_type_pkg.t_de033
    , i_inst_code           in com_api_type_pkg.t_dict_value := null
    , i_start_date          in date                          := null
    , i_end_date            in date                          := null
    , i_include_affiliate   in com_api_type_pkg.t_boolean    := com_api_const_pkg.FALSE
    , i_inst_id             in com_api_type_pkg.t_inst_id    := null
) return number is
    l_result                number;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
begin
    if i_include_affiliate = com_api_const_pkg.TRUE
        and i_inst_id is not null
    then
        l_host_id     := net_api_network_pkg.get_default_host(i_network_id);
        l_standard_id := net_api_network_pkg.get_offline_standard(
                             i_host_id => l_host_id
                         );

        if nvl(i_inst_code, mcw_api_const_pkg.UPLOAD_FORWARDING) = mcw_api_const_pkg.UPLOAD_FORWARDING then
            select /*+ INDEX(f, mcw_fin_status_CLMS10_ndx)*/
                   count(*)
              into l_result
              from mcw_fin f
                 , opr_operation o
                 , (select distinct v.param_value cmid
                      from cmn_parameter p
                         , net_api_interface_param_val_vw v
                         , net_member m
                         , net_interface i
                     where p.name           = mcw_api_const_pkg.CMID
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
                 or f.de012 is null and i_start_date is null and i_end_date is null);
        else
            select /*+ INDEX(f, mcw_fin_status_de094_ndx)*/
                   count(*)
              into l_result
              from mcw_fin f
                 , opr_operation o
                 , (select distinct v.param_value cmid
                      from cmn_parameter p
                         , net_api_interface_param_val_vw v
                         , net_member m
                         , net_interface i
                     where p.name           = mcw_api_const_pkg.FORW_INST_ID
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
                    ) cmid
             where decode(f.status, 'CLMS0010', f.de094, null) = cmid.cmid
               and f.split_hash in (select split_hash from com_api_split_map_vw)
               and f.is_incoming = 0
               and f.id = o.id
               and f.network_id = i_network_id
               and (f.de012 between nvl(i_start_date, trunc(f.de012)) and nvl(i_end_date, trunc(f.de012)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_type_pkg.FALSE
                 or o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_type_pkg.TRUE
                 or f.de012 is null and i_start_date is null and i_end_date is null);
        end if;
    else
        if nvl(i_inst_code, mcw_api_const_pkg.UPLOAD_FORWARDING) = mcw_api_const_pkg.UPLOAD_FORWARDING then
            select /*+ INDEX(f, mcw_fin_status_CLMS10_ndx)*/
                   count(*)
              into l_result
              from mcw_fin f
                 , opr_operation o
             where decode(f.status, 'CLMS0010', f.de033, null) = i_cmid -- net_api_const.CLEARING_MSG_STATUS_READY
               and f.split_hash in (select split_hash from com_api_split_map_vw)
               and f.is_incoming = 0
               and f.id = o.id
               and f.network_id = i_network_id
               and (f.de012 between nvl(i_start_date, trunc(f.de012)) and nvl(i_end_date, trunc(f.de012)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_type_pkg.FALSE
                 or o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_type_pkg.TRUE
                 or f.de012 is null and i_start_date is null and i_end_date is null);
        else
            select /*+ INDEX(f, mcw_fin_status_de094_ndx)*/
                   count(*)
              into l_result
              from mcw_fin f
                 , opr_operation o
             where decode(f.status, 'CLMS0010', f.de094, null) = i_cmid -- net_api_const.CLEARING_MSG_STATUS_READY
               and f.split_hash in (select split_hash from com_api_split_map_vw)
               and f.is_incoming = 0
               and f.id = o.id
               and f.network_id = i_network_id
               and (f.de012 between nvl(i_start_date, trunc(f.de012)) and nvl(i_end_date, trunc(f.de012)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_type_pkg.FALSE
                 or o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_type_pkg.TRUE
                 or f.de012 is null and i_start_date is null and i_end_date is null);
        end if;
    end if;

    return l_result;
end;

procedure enum_messages_for_upload (
    o_fin_cur               in out sys_refcursor
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_cmid                in mcw_api_type_pkg.t_de033
    , i_inst_code           in com_api_type_pkg.t_dict_value := null
    , i_start_date          in date                          := null
    , i_end_date            in date                          := null
    , i_include_affiliate   in com_api_type_pkg.t_boolean    := com_api_const_pkg.FALSE
    , i_inst_id             in com_api_type_pkg.t_inst_id    := null
) is
    WHERE_PLACEHOLDER       constant varchar2(100) := '##WHERE##';
    DATE_PLACEHOLDER        constant varchar2(100) := '##DATE##';
    DATE_CONDITION          constant com_api_type_pkg.t_text := '
    and (f.de012 between nvl(:i_start_date, trunc(f.de012))
                     and nvl(:i_end_date, trunc(f.de012)) + 1 - 1/86400
         and f.is_reversal = ' || com_api_type_pkg.FALSE || '
         or
         o.host_date between nvl(:i_start_date, trunc(o.host_date))
                         and nvl(:i_end_date, trunc(o.host_date)) + 1 - 1/86400
         and f.is_reversal = ' || com_api_type_pkg.TRUE || ') '
    ;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_param_name            com_api_type_pkg.t_name;
    l_cursor                com_api_type_pkg.t_text;
begin
    if  i_include_affiliate = com_api_const_pkg.TRUE
        and i_inst_id is not null
    then
        l_host_id     := net_api_network_pkg.get_default_host(
                             i_network_id => i_network_id
                         );
        l_standard_id := net_api_network_pkg.get_offline_standard(
                             i_host_id    => l_host_id
                         );
        if nvl(i_inst_code, mcw_api_const_pkg.UPLOAD_FORWARDING) = mcw_api_const_pkg.UPLOAD_FORWARDING then
            l_param_name := mcw_api_const_pkg.FORW_INST_ID;
        else
            l_param_name := mcw_api_const_pkg.CMID;
        end if;

        l_cursor := '
select /*+ INDEX(f, '|| case 
                        when nvl(i_inst_code, mcw_api_const_pkg.UPLOAD_FORWARDING) = mcw_api_const_pkg.UPLOAD_FORWARDING then
                            'mcw_fin_status_CLMS10_ndx'
                        else
                            'mcw_fin_status_de094_ndx'
                        end || ')*/
    ' || FIN_COLUMN_LIST || '
from
    mcw_fin f
    , mcw_card c
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
order by
    nvl(f.local_message, 0)
    , f.id
for update of
    f.status';

        l_cursor := replace(
            l_cursor
          , WHERE_PLACEHOLDER
          , case
            when nvl(i_inst_code, mcw_api_const_pkg.UPLOAD_FORWARDING) = mcw_api_const_pkg.UPLOAD_FORWARDING then
                'decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', f.de033, null) = cmid.cmid'
            else
                'decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', f.de094, null) = cmid.cmid'
            end
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
select /*+ INDEX(f, '|| case 
                        when nvl(i_inst_code, mcw_api_const_pkg.UPLOAD_FORWARDING) = mcw_api_const_pkg.UPLOAD_FORWARDING then
                            'mcw_fin_status_CLMS10_ndx'
                        else
                            'mcw_fin_status_de094_ndx'
                        end || ')*/
    ' || FIN_COLUMN_LIST || '
from
    mcw_fin f
  , mcw_card c
  , opr_operation o
where ' || WHERE_PLACEHOLDER || '
    and f.split_hash in (select split_hash from com_api_split_map_vw)
    and f.network_id = :i_network_id
    and f.is_incoming = 0
    and f.id = o.id
    and f.id = c.id(+) ' || DATE_PLACEHOLDER || '
order by
    nvl(f.local_message, 0)
    , f.id
for update of
    f.status';

        l_cursor := replace(
            l_cursor
          , WHERE_PLACEHOLDER
          , case
            when nvl(i_inst_code, mcw_api_const_pkg.UPLOAD_FORWARDING) = mcw_api_const_pkg.UPLOAD_FORWARDING then
                'decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', f.de033, null) = :i_cmid'
            else
                'decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', f.de094, null) = :i_cmid'
            end
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
            using i_cmid, i_network_id, i_start_date, i_end_date, i_start_date, i_end_date;
        else
            open  o_fin_cur
            for   l_cursor
            using i_cmid, i_network_id;
        end if;
    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT)  || '.enum_messages_for_upload >> FAILED:'
                   ||   ' i_network_id ['  || i_network_id
                   || '], i_inst_id ['     || i_inst_id
                   || '], i_cmid ['        || i_cmid
                   || '], i_inst_code ['   || i_inst_code
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
end enum_messages_for_upload;

procedure enum_messages_first_pres (
    o_fin_cur               in out sys_refcursor
    , i_de002               in mcw_api_type_pkg.t_de002
    , i_de037               in mcw_api_type_pkg.t_de037
) is
    l_statement              com_api_type_pkg.t_text;
begin
    l_statement := '
select
' || FIN_COLUMN_LIST || '
  from mcw_fin f
     , mcw_card c
     , (select ''MSGTPRES'' msg_type from dual) as o
 where c.card_number = :i_de002
   and f.de037 = :i_de037
   and f.mti = :i_mti
   and f.de024 = :i_de024
   and f.is_reversal = :i_is_reversal
   and f.is_incoming = :i_is_incoming
   and f.id = c.id(+)
   for update of f.status';

    open o_fin_cur for l_statement
    using i_de002, i_de037
          , mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
          , mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
          , com_api_type_pkg.FALSE
          , com_api_type_pkg.FALSE;
end;

procedure get_fin (
    i_id                    in com_api_type_pkg.t_long_id
    , o_fin_rec             out mcw_api_type_pkg.t_fin_rec
    , i_mask_error          in com_api_type_pkg.t_boolean   := com_api_type_pkg.FALSE
) is
    l_fin_cur               sys_refcursor;
    l_statement              com_api_type_pkg.t_text;
begin
    l_statement := '
select
' || FIN_COLUMN_LIST || '
  from mcw_fin f
     , mcw_card c
     , opr_operation o
 where f.id = :i_id
   and f.id = c.id(+)
   and f.id = o.id(+)';

    open l_fin_cur for l_statement using i_id;
    fetch l_fin_cur into o_fin_rec;
    close l_fin_cur;

    if o_fin_rec.id is null then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error       => 'FINANCIAL_MESSAGE_NOT_FOUND'
              , i_env_param1  => i_id
            );
        else
            trc_log_pkg.error(
                i_text        => 'FINANCIAL_MESSAGE_NOT_FOUND'
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
    i_mti                   in mcw_api_type_pkg.t_mti
    , i_de024               in mcw_api_type_pkg.t_de024
    , i_is_reversal         in com_api_type_pkg.t_boolean
    , i_dispute_id          in com_api_type_pkg.t_long_id
    , o_fin_rec             out mcw_api_type_pkg.t_fin_rec
    , i_mask_error          in com_api_type_pkg.t_boolean
) is
    l_fin_cur               sys_refcursor;
    l_statement              com_api_type_pkg.t_text;
begin
    l_statement := '
select
     ' || FIN_COLUMN_LIST || '
  from mcw_fin f
     , mcw_card c
     , opr_operation o
 where f.mti = :i_mti
   and f.de024 = :i_de024
   and f.is_reversal = :i_is_reversal
   and f.dispute_id = :i_dispute_id
   and f.id = c.id(+)
   and f.id = o.id(+)';

    open l_fin_cur for l_statement using i_mti, i_de024, i_is_reversal, i_dispute_id;
    fetch l_fin_cur into o_fin_rec;
    close l_fin_cur;

    if o_fin_rec.id is null then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error       => 'FINANCIAL_MESSAGE_NOT_FOUND'
              , i_env_param2  => i_mti
              , i_env_param3  => i_de024
              , i_env_param4  => i_is_reversal
            );
        else
            trc_log_pkg.error(
                i_text        => 'FINANCIAL_MESSAGE_NOT_FOUND'
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
             , f.status
             , f.inst_id
             , f.network_id
             , f.file_id
             , f.is_incoming
             , f.is_reversal
             , f.is_rejected
             , f.reject_id
             , f.is_fpd_matched
             , f.fpd_id
             , f.dispute_id
             , f.impact
             , f.mti
             , f.de024
             , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
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
             , f.de022_12
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
             , f.de111
             , f.p0002
             , f.p0023
             , f.p0025_1
             , f.p0025_2
             , f.p0043
             , f.p0052
             , f.p0137
             , f.p0148
             , f.p0146
             , f.p0146_net
             , f.p0149_1
             , f.p0149_2
             , f.p0158_1
             , f.p0158_2
             , f.p0158_3
             , f.p0158_4
             , f.p0158_5
             , f.p0158_6
             , f.p0158_7
             , f.p0158_8
             , f.p0158_9
             , f.p0158_10
             , f.p0159_1
             , f.p0159_2
             , f.p0159_3
             , f.p0159_4
             , f.p0159_5
             , f.p0159_6
             , f.p0159_7
             , f.p0159_8
             , f.p0159_9
             , f.p0165
             , f.p0176
             , f.p0228
             , f.p0230
             , f.p0241
             , f.p0243
             , f.p0244
             , f.p0260
             , f.p0261
             , f.p0262
             , f.p0264
             , f.p0265
             , f.p0266
             , f.p0267
             , f.p0268_1
             , f.p0268_2
             , f.p0375
             , f.is_fsum_matched
             , f.fsum_id
             , f.emv_9f26
             , f.emv_9f02
             , f.emv_9f27
             , f.emv_9f10
             , f.emv_9f36
             , f.emv_95
             , f.emv_82
             , f.emv_9a
             , f.emv_9c
             , f.emv_9f37
             , f.emv_5f2a
             , f.emv_9f33
             , f.emv_9f34
             , f.emv_9f1a
             , f.emv_9f35
             , f.emv_9f53
             , f.emv_84
             , f.emv_9f09
             , f.emv_9f03
             , f.emv_9f1e
             , f.emv_9f41
             , f.dispute_rn
             , f.p0042
             , f.p0158_11
             , f.p0158_12
             , f.p0158_13
             , f.p0158_14
             , f.p0198
             , f.p0200_1
             , f.p0200_2
             , f.p0210_1
             , f.p0210_2
             , f.local_message
             , f.p0181
             , f.p0147
             , f.p0208_1
             , f.p0208_2
             , f.p0209
             , f.p0045
             , f.p0047
             , f.p0207
             , f.p0001_1
             , f.p0001_2
             , f.p0058
             , f.p0059
             , f.p1001
             , f.ird_trace
             , f.p0004_1
             , f.p0004_2
             , f.p0072
             , f.p0028
             , f.p0029
             , f.p0674
             , f.p0018
             , f.p0021
          into o_fin_fields('id')
             , o_fin_fields('split_hash')
             , o_fin_fields('status')
             , o_fin_fields('inst_id')
             , o_fin_fields('network_id')
             , o_fin_fields('file_id')
             , o_fin_fields('is_incoming')
             , o_fin_fields('is_reversal')
             , o_fin_fields('is_rejected')
             , o_fin_fields('reject_id')
             , o_fin_fields('is_fpd_matched')
             , o_fin_fields('fpd_id')
             , o_fin_fields('dispute_id')
             , o_fin_fields('impact')
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
             , o_fin_fields('de022_12')
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
             , o_fin_fields('de111')
             , o_fin_fields('p0002')
             , o_fin_fields('p0023')
             , o_fin_fields('p0025_1')
             , o_fin_fields('p0025_2')
             , o_fin_fields('p0043')
             , o_fin_fields('p0052')
             , o_fin_fields('p0137')
             , o_fin_fields('p0148')
             , o_fin_fields('p0146')
             , o_fin_fields('p0146_net')
             , o_fin_fields('p0149_1')
             , o_fin_fields('p0149_2')
             , o_fin_fields('p0158_1')
             , o_fin_fields('p0158_2')
             , o_fin_fields('p0158_3')
             , o_fin_fields('p0158_4')
             , o_fin_fields('p0158_5')
             , o_fin_fields('p0158_6')
             , o_fin_fields('p0158_7')
             , o_fin_fields('p0158_8')
             , o_fin_fields('p0158_9')
             , o_fin_fields('p0158_10')
             , o_fin_fields('p0159_1')
             , o_fin_fields('p0159_2')
             , o_fin_fields('p0159_3')
             , o_fin_fields('p0159_4')
             , o_fin_fields('p0159_5')
             , o_fin_fields('p0159_6')
             , o_fin_fields('p0159_7')
             , o_fin_fields('p0159_8')
             , o_fin_fields('p0159_9')
             , o_fin_fields('p0165')
             , o_fin_fields('p0176')
             , o_fin_fields('p0228')
             , o_fin_fields('p0230')
             , o_fin_fields('p0241')
             , o_fin_fields('p0243')
             , o_fin_fields('p0244')
             , o_fin_fields('p0260')
             , o_fin_fields('p0261')
             , o_fin_fields('p0262')
             , o_fin_fields('p0264')
             , o_fin_fields('p0265')
             , o_fin_fields('p0266')
             , o_fin_fields('p0267')
             , o_fin_fields('p0268_1')
             , o_fin_fields('p0268_2')
             , o_fin_fields('p0375')
             , o_fin_fields('is_fsum_matched')
             , o_fin_fields('fsum_id')
             , o_fin_fields('emv_9f26')
             , o_fin_fields('emv_9f02')
             , o_fin_fields('emv_9f27')
             , o_fin_fields('emv_9f10')
             , o_fin_fields('emv_9f36')
             , o_fin_fields('emv_95')
             , o_fin_fields('emv_82')
             , o_fin_fields('emv_9a')
             , o_fin_fields('emv_9c')
             , o_fin_fields('emv_9f37')
             , o_fin_fields('emv_5f2a')
             , o_fin_fields('emv_9f33')
             , o_fin_fields('emv_9f34')
             , o_fin_fields('emv_9f1a')
             , o_fin_fields('emv_9f35')
             , o_fin_fields('emv_9f53')
             , o_fin_fields('emv_84')
             , o_fin_fields('emv_9f09')
             , o_fin_fields('emv_9f03')
             , o_fin_fields('emv_9f1e')
             , o_fin_fields('emv_9f41')
             , o_fin_fields('dispute_rn')
             , o_fin_fields('p0042')
             , o_fin_fields('p0158_11')
             , o_fin_fields('p0158_12')
             , o_fin_fields('p0158_13')
             , o_fin_fields('p0158_14')
             , o_fin_fields('p0198')
             , o_fin_fields('p0200_1')
             , o_fin_fields('p0200_2')
             , o_fin_fields('p0210_1')
             , o_fin_fields('p0210_2')
             , o_fin_fields('local_message')
             , o_fin_fields('p0181')
             , o_fin_fields('p0147')
             , o_fin_fields('p0208_1')
             , o_fin_fields('p0208_2')
             , o_fin_fields('p0209')
             , o_fin_fields('p0045')
             , o_fin_fields('p0047')
             , o_fin_fields('p0207')
             , o_fin_fields('p0001_1')
             , o_fin_fields('p0001_2')
             , o_fin_fields('p0058')
             , o_fin_fields('p0059')
             , o_fin_fields('p1001')
             , o_fin_fields('ird_trace')
             , o_fin_fields('p0004_1')
             , o_fin_fields('p0004_2')
             , o_fin_fields('p0072')
             , o_fin_fields('p0028')
             , o_fin_fields('p0029')
             , o_fin_fields('p0674')
             , o_fin_fields('p0018')
             , o_fin_fields('p0021')
          from      mcw_fin     f
          left join mcw_card    c    on f.id = c.id
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
      from mcw_msg_pds
     where msg_id = i_id;

    for i in 1 .. l_pds_number_tab.count() loop
        o_fin_fields('PDS_' || l_pds_number_tab(i)) := l_pds_body_tab(i);
    end loop;

exception
    when com_api_error_pkg.e_application_error then
        null;
end get_fin_message;

procedure get_original_fin (
    i_mti                   in mcw_api_type_pkg.t_mti
    , i_de002               in mcw_api_type_pkg.t_de002
    , i_de024               in mcw_api_type_pkg.t_de024
    , i_de031               in mcw_api_type_pkg.t_de031
    , i_id                  in com_api_type_pkg.t_long_id  := null
    , o_fin_rec             out mcw_api_type_pkg.t_fin_rec
) is
    l_fin_cur               sys_refcursor;
    l_statement              com_api_type_pkg.t_text;
begin
    l_statement := '
select
     ' || FIN_COLUMN_LIST || '
  from mcw_fin f
     , mcw_card c
     , opr_operation o
 where f.mti = :i_mti
   and f.de024 = :i_de024
   and c.card_number = :i_de002
   and f.de031 = :i_de031
   and f.is_reversal = :i_is_reversal
   and f.id = c.id(+)
   and (f.id = :id or :id is null)
   and f.id = o.id(+)
 order by f.dispute_id
   for update';

    open l_fin_cur for l_statement
    using
        i_mti
      , i_de024
      , iss_api_token_pkg.encode_card_number(i_card_number => i_de002)
      , i_de031
      , com_api_type_pkg.FALSE
      , i_id
      , i_id;

    mcw_api_dispute_pkg.fetch_dispute_id (
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
    i_mti                   in mcw_api_type_pkg.t_mti
    , i_de002               in mcw_api_type_pkg.t_de002
    , i_de024               in mcw_api_type_pkg.t_de024
    , i_de031               in mcw_api_type_pkg.t_de031
    , i_de094               in mcw_api_type_pkg.t_de094    := null
    , i_p0137               in mcw_api_type_pkg.t_p0137    := null
    , o_fin_rec             out mcw_api_type_pkg.t_fin_rec
) is
    l_fin_cur               sys_refcursor;
    l_statement              com_api_type_pkg.t_text;
begin
    l_statement := '
select
     ' || FIN_COLUMN_LIST || '
  from mcw_fin f
     , mcw_card c
     , opr_operaion o
 where f.mti = :i_mti
   and f.de024 in ('''||mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE||''','''||mcw_api_const_pkg.FUNC_CODE_SYSTEM_FEE||''')
   and c.card_number = :i_de002
   and f.de031 = :i_de031
   and f.is_reversal = :i_is_reversal
   and f.de094 = :i_de094
   and f.p0137 = :i_p0137
   and f.id = c.id(+)
   and f.id = o.id(+)   
 order by f.dispute_id';

    open l_fin_cur for l_statement
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
end;

procedure pack_message(
    i_fin_rec               in     mcw_api_type_pkg.t_fin_rec
  , i_file_id               in     com_api_type_pkg.t_short_id
  , i_de071                 in     mcw_api_type_pkg.t_de071
  , i_charset               in     com_api_type_pkg.t_oracle_name
  , i_curr_standard_version in     com_api_type_pkg.t_tiny_id
  , o_raw_data                 out varchar2
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.pack_message';
    l_pds_tab               mcw_api_type_pkg.t_pds_tab;
begin
    mcw_api_pds_pkg.read_pds(
        i_msg_id      => i_fin_rec.id
      , o_pds_tab     => l_pds_tab
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0002
      , i_pds_body    => i_fin_rec.p0002
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0004
      , i_pds_body    => mcw_api_pds_pkg.format_p0004(
                             i_p0004_1 => i_fin_rec.p0004_1
                           , i_p0004_2 => i_fin_rec.p0004_2
                         )
    );

    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0018
      , i_pds_body    => i_fin_rec.p0018
    );

    if i_curr_standard_version >= mcw_api_const_pkg.STANDARD_VERSION_19Q2_ID then
        mcw_api_pds_pkg.set_pds_body(
            io_pds_tab => l_pds_tab
          , i_pds_tag  => mcw_api_const_pkg.PDS_TAG_0021
          , i_pds_body => i_fin_rec.p0021
        );
        if com_api_sttl_day_pkg.get_sysdate() >= mcw_api_const_pkg.STANDARD_VERSION_19Q2_DATE then
            mcw_api_pds_pkg.set_pds_body(
                io_pds_tab => l_pds_tab
              , i_pds_tag  => mcw_api_const_pkg.PDS_TAG_0022
              , i_pds_body => i_fin_rec.p0022
            );
        end if;
    end if;

    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0023
      , i_pds_body    => i_fin_rec.p0023
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0025
      , i_pds_body    => mcw_api_pds_pkg.format_p0025(
                             i_p0025_1 => i_fin_rec.p0025_1
                           , i_p0025_2 => i_fin_rec.p0025_2
                         )
    );

    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0028
      , i_pds_body    => i_fin_rec.p0028
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0029
      , i_pds_body    => i_fin_rec.p0029
    );

    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0042
      , i_pds_body    => i_fin_rec.p0042
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0043
      , i_pds_body    => i_fin_rec.p0043
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0052
      , i_pds_body    => i_fin_rec.p0052
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0072
      , i_pds_body    => i_fin_rec.p0072
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0137
      , i_pds_body    => i_fin_rec.p0137
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0148
      , i_pds_body    => i_fin_rec.p0148
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0149
      , i_pds_body    => mcw_api_pds_pkg.format_p0149(
                             i_p0149_1 => i_fin_rec.p0149_1
                           , i_p0149_2 => lpad(i_fin_rec.p0149_2, 3, '0')
                         )
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0158
      , i_pds_body    => mcw_api_pds_pkg.format_p0158(
                             i_p0158_1  => i_fin_rec.p0158_1
                           , i_p0158_2  => i_fin_rec.p0158_2
                           , i_p0158_3  => i_fin_rec.p0158_3
                           , i_p0158_4  => i_fin_rec.p0158_4
                           , i_p0158_5  => i_fin_rec.p0158_5
                           , i_p0158_6  => i_fin_rec.p0158_6
                           , i_p0158_7  => i_fin_rec.p0158_7
                           , i_p0158_8  => i_fin_rec.p0158_8
                           , i_p0158_9  => i_fin_rec.p0158_9
                           , i_p0158_10 => i_fin_rec.p0158_10
                           , i_p0158_11 => i_fin_rec.p0158_11
                           , i_p0158_12 => i_fin_rec.p0158_12
                           , i_p0158_13 => i_fin_rec.p0158_13
                           , i_p0158_14 => i_fin_rec.p0158_14
                         )
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0165
      , i_pds_body    => i_fin_rec.p0165
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0176
      , i_pds_body    => i_fin_rec.p0176
    );

    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0181
      , i_pds_body    => i_fin_rec.p0181
    );

    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0198
      , i_pds_body    => i_fin_rec.p0198
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0200
      , i_pds_body    => mcw_api_pds_pkg.format_p0200(
                             i_p0200_1 => i_fin_rec.p0200_1
                           , i_p0200_2 => i_fin_rec.p0200_2
                         )
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0207
      , i_pds_body    => i_fin_rec.p0207
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0208
      , i_pds_body    => mcw_api_pds_pkg.format_p0208(
                             i_p0208_1   => i_fin_rec.p0208_1
                           , i_p0208_2   => i_fin_rec.p0208_2
                         )
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0209
      , i_pds_body    => mcw_utl_pkg.pad_number(i_fin_rec.p0209, 11, 11)
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0210
      , i_pds_body    => mcw_api_pds_pkg.format_p0210(
                             i_p0210_1 => i_fin_rec.p0210_1
                           , i_p0210_2 => i_fin_rec.p0210_2
                         )
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0228
      , i_pds_body    => i_fin_rec.p0228
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0230
      , i_pds_body    => i_fin_rec.p0230
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0261
      , i_pds_body    => i_fin_rec.p0261
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0262
      , i_pds_body    => i_fin_rec.p0262
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0264
      , i_pds_body    => i_fin_rec.p0264
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0265
      , i_pds_body    => i_fin_rec.p0265
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0266
      , i_pds_body    => i_fin_rec.p0266
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0267
      , i_pds_body    => i_fin_rec.p0267
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0268
      , i_pds_body    => mcw_api_pds_pkg.format_p0268(
                             i_p0268_1 => i_fin_rec.p0268_1
                           , i_p0268_2 => i_fin_rec.p0268_2
                         )
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0375
      , i_pds_body    => i_fin_rec.p0375
    );

    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => 0674
      , i_pds_body    => i_fin_rec.p0674
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ': i_fin_rec.p1001 [#1]'
      , i_env_param1 => i_fin_rec.p1001
    );
    mcw_api_pds_pkg.set_pds_body(
        io_pds_tab    => l_pds_tab
      , i_pds_tag     => mcw_api_const_pkg.PDS_TAG_1001
      , i_pds_body    => i_fin_rec.p1001
    );

    mcw_api_msg_pkg.pack_message(
        o_raw_data        => o_raw_data
      , i_pds_tab         => l_pds_tab
      , i_mti             => i_fin_rec.mti
      , i_de002           => nvl(i_fin_rec.p0014, i_fin_rec.de002)
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
    , i_id                  in com_api_type_pkg.t_number_tab
    , i_de071               in com_api_type_pkg.t_number_tab
    , i_file_id             in com_api_type_pkg.t_number_tab
) is
begin
    forall i in 1 .. i_rowid.count
        update
            mcw_fin
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
            mcw_fin
        set
            status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOAD_ERR
        where
            rowid = i_rowid(i);
end;

procedure flush_job is
begin
    null;
end;

procedure cancel_job is
begin
    null;
end;

function get_cashback_amount(
    i_de054                 in com_api_type_pkg.t_full_desc
    , i_oper_curr           in com_api_type_pkg.t_curr_code
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
end;

function get_original_id (
    i_fin_rec               in mcw_api_type_pkg.t_fin_rec
) return com_api_type_pkg.t_long_id is
    l_original_id           com_api_type_pkg.t_long_id;
    l_mti                   mcw_api_type_pkg.t_mti;
    l_de024_1               mcw_api_type_pkg.t_de024;
    l_de024_2               mcw_api_type_pkg.t_de024;
    l_split_hash            com_api_type_pkg.t_inst_id;
    l_is_reversal           com_api_type_pkg.t_boolean;
begin
    l_split_hash := com_api_hash_pkg.get_split_hash(i_fin_rec.de002);

    if i_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
       and i_fin_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
                             , mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
                             , mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_PART
                              )
       and i_fin_rec.is_reversal = com_api_type_pkg.TRUE
       and i_fin_rec.dispute_id is not null
    then
        l_mti := i_fin_rec.mti;

        select min(id)
          into l_original_id
          from mcw_fin
         where split_hash  = l_split_hash
           and mti         = l_mti
           and de024       = i_fin_rec.de024
           and is_reversal = com_api_type_pkg.FALSE
           and dispute_id  = i_fin_rec.dispute_id;

    else
        if i_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
           and i_fin_rec.de024 = mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
        then
            if i_fin_rec.is_reversal = com_api_type_pkg.TRUE then
                l_is_reversal := com_api_type_pkg.FALSE;
                l_mti         := i_fin_rec.mti;
                l_de024_1     := i_fin_rec.de024;
                l_de024_2     := i_fin_rec.de024;
            else
                l_mti         := mcw_api_const_pkg.MSG_TYPE_PRESENTMENT;
                l_de024_1     := mcw_api_const_pkg.FUNC_CODE_FIRST_PRES;
                l_de024_2     := mcw_api_const_pkg.FUNC_CODE_FIRST_PRES;
            end if;

        elsif i_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
            and i_fin_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                                  , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART)
        then
            if i_fin_rec.is_reversal = com_api_type_pkg.TRUE then
                l_is_reversal := com_api_type_pkg.FALSE;
                l_mti         := i_fin_rec.mti;
                l_de024_1     := i_fin_rec.de024;
                l_de024_2     := i_fin_rec.de024;
            else
                l_mti     := mcw_api_const_pkg.MSG_TYPE_PRESENTMENT;
                l_de024_1 := mcw_api_const_pkg.FUNC_CODE_FIRST_PRES;
                l_de024_2 := mcw_api_const_pkg.FUNC_CODE_FIRST_PRES;
            end if;

        elsif i_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
            and i_fin_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
                                  , mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_PART)
        then
            if i_fin_rec.is_reversal = com_api_type_pkg.TRUE then
                l_is_reversal := com_api_type_pkg.FALSE;
                l_mti         := i_fin_rec.mti;
                l_de024_1     := i_fin_rec.de024;
                l_de024_2     := i_fin_rec.de024;
            else
                l_mti     := mcw_api_const_pkg.MSG_TYPE_CHARGEBACK;
                l_de024_1 := mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL;
                l_de024_2 := mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART;
            end if;

        elsif i_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
            and i_fin_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
                                  , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART)
        then
            if i_fin_rec.is_reversal = com_api_type_pkg.TRUE then
                l_is_reversal := com_api_type_pkg.FALSE;
                l_mti         := i_fin_rec.mti;
                l_de024_1     := i_fin_rec.de024;
                l_de024_2     := i_fin_rec.de024;
            else
                l_mti     := mcw_api_const_pkg.MSG_TYPE_PRESENTMENT;
                l_de024_1 := mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL;
                l_de024_2 := mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_PART;
            end if;

        elsif i_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_FEE
            and i_fin_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE)
        then
            l_mti     := mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
            l_de024_1 := mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST;
            l_de024_2 := mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST;

        elsif i_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_FEE
            and i_fin_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_FEE_RETURN)
        then
            l_mti     := mcw_api_const_pkg.MSG_TYPE_FEE;
            l_de024_1 := mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE;
            l_de024_2 := mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE;

        elsif i_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_FEE
            and i_fin_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_FEE_RESUBMITION)
        then
            l_mti     := mcw_api_const_pkg.MSG_TYPE_FEE;
            l_de024_1 := mcw_api_const_pkg.FUNC_CODE_FEE_RETURN;
            l_de024_2 := mcw_api_const_pkg.FUNC_CODE_FEE_RETURN;

        elsif i_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_FEE
            and i_fin_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_FEE_SECOND_RETURN)
        then
            l_mti     := mcw_api_const_pkg.MSG_TYPE_FEE;
            l_de024_1 := mcw_api_const_pkg.FUNC_CODE_FEE_RESUBMITION;
            l_de024_2 := mcw_api_const_pkg.FUNC_CODE_FEE_RESUBMITION;

        end if;

        if l_mti is not null then
            select min(id)
              into l_original_id
              from mcw_fin
             where split_hash   = l_split_hash
               and mti          = l_mti
               and de024       in (l_de024_1, l_de024_2)
               and de031        = i_fin_rec.de031
               and (is_reversal = l_is_reversal or l_is_reversal is null);
        end if;
    end if;

    if l_original_id is null and l_mti is not null then
        g_no_original_id_tab(g_no_original_id_tab.count + 1) := i_fin_rec;
    end if;

    return l_original_id;
end;

procedure create_operation_fraud(
    i_fin_rec               in mcw_api_type_pkg.t_fin_rec
  , i_standard_id           in com_api_type_pkg.t_tiny_id
  , i_host_id               in com_api_type_pkg.t_tiny_id
  , i_original_fin_id       in com_api_type_pkg.t_long_id   default null
) is
    l_iss_inst_id           com_api_type_pkg.t_inst_id;
    l_acq_inst_id           com_api_type_pkg.t_inst_id;
    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_iss_network_id        com_api_type_pkg.t_tiny_id;
    l_acq_network_id        com_api_type_pkg.t_tiny_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_card_country          com_api_type_pkg.t_country_code;
    l_bin_currency          com_api_type_pkg.t_curr_code;
    l_sttl_currency         com_api_type_pkg.t_curr_code;
    l_country_code          com_api_type_pkg.t_country_code;
    l_sttl_type             com_api_type_pkg.t_dict_value;
    l_match_status          com_api_type_pkg.t_dict_value;

    l_oper                  opr_api_type_pkg.t_oper_rec;
    l_iss_part              opr_api_type_pkg.t_oper_part_rec;
    l_acq_part              opr_api_type_pkg.t_oper_part_rec;

    l_operation             opr_api_type_pkg.t_oper_rec;
    l_participant           opr_api_type_pkg.t_oper_part_rec;
begin
    l_oper.id := i_fin_rec.id;
    if l_oper.id is null then
        l_oper.id := opr_api_create_pkg.get_id;
    end if;

    if  i_fin_rec.dispute_id is not null
        or
        i_fin_rec.is_reversal = com_api_type_pkg.TRUE
        and i_fin_rec.is_incoming = com_api_type_pkg.FALSE
    then
        if i_original_fin_id is null then
            l_oper.original_id := get_original_id(
                                      i_fin_rec => i_fin_rec
                                  );
        else
            l_oper.original_id := i_original_fin_id;
        end if;

        opr_api_operation_pkg.get_operation(
            i_oper_id   => l_oper.original_id
          , o_operation => l_operation
        );

        l_sttl_type := l_operation.sttl_type;

        opr_api_operation_pkg.get_participant(
            i_oper_id           => l_operation.id
          , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
          , o_participant       => l_participant
        );

        l_iss_inst_id         := l_participant.inst_id;
        l_iss_network_id      := l_participant.network_id;
        l_iss_part.split_hash := l_participant.split_hash;
        l_card_type_id        := l_participant.card_type_id;
        l_card_country        := l_participant.card_country;
        l_card_inst_id        := l_participant.card_inst_id;
        l_card_network_id     := l_participant.card_network_id;

        opr_api_operation_pkg.get_participant(
            i_oper_id           => l_operation.id
          , i_participaint_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
          , o_participant       => l_participant
        );

        l_acq_inst_id          := l_participant.inst_id;
        l_acq_network_id       := l_participant.network_id;
        l_acq_part.merchant_id := l_participant.merchant_id;
        l_acq_part.terminal_id := l_participant.terminal_id;
        l_acq_part.split_hash  := l_participant.split_hash;

        l_oper.terminal_type   := l_operation.terminal_type;
    else
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => i_fin_rec.de002
          , o_iss_inst_id      => l_iss_inst_id
          , o_iss_network_id   => l_iss_network_id
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_card_type        => l_card_type_id
          , o_card_country     => l_country_code
          , o_bin_currency     => l_bin_currency
          , o_sttl_currency    => l_sttl_currency
        );

        if l_card_inst_id is null then
            l_iss_inst_id    := i_fin_rec.inst_id;
            l_iss_network_id := ost_api_institution_pkg.get_inst_network(i_inst_id => i_fin_rec.inst_id);
        end if;

        begin
            l_acq_inst_id := cmn_api_standard_pkg.find_value_owner(
                                 i_standard_id       => i_standard_id
                               , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
                               , i_object_id         => i_host_id
                               , i_param_name        => case
                                                            when i_fin_rec.de094 = nvl(i_fin_rec.de032, i_fin_rec.de033)
                                                            then mcw_api_const_pkg.CMID
                                                            else mcw_api_const_pkg.ACQUIRER_BIN
                                                        end
                               , i_value_char        => nvl(i_fin_rec.de032, i_fin_rec.de033)
                               , i_mask_error        => com_api_const_pkg.TRUE
                             );
            l_acq_network_id := ost_api_institution_pkg.get_inst_network(i_inst_id => l_acq_inst_id);
        exception
            when others then
                if com_api_error_pkg.get_last_error = 'NOT_FOUND_VALUE_OWNER' then
                    l_acq_inst_id := null;
                else
                    raise;
                end if;
        end;

        if l_acq_inst_id is null then
            l_acq_network_id := i_fin_rec.network_id;
            l_acq_inst_id    := net_api_network_pkg.get_inst_id(i_network_id => i_fin_rec.network_id);
        end if;

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
          , i_oper_type        => l_operation.oper_type
        );
    end if;

    l_oper.sttl_type          := l_sttl_type;
    l_oper.msg_type           := opr_api_const_pkg.MESSAGE_TYPE_FRAUD_REPORT;
    l_oper.oper_type          := l_operation.oper_type;
    l_oper.is_reversal        := i_fin_rec.is_reversal;
    l_oper.oper_amount        := nvl(i_fin_rec.de004, i_fin_rec.de030_1);
    l_oper.oper_currency      := nvl(i_fin_rec.de049, i_fin_rec.p0149_1);
    l_oper.sttl_amount        := i_fin_rec.de005;
    l_oper.sttl_currency      := i_fin_rec.de050;
    l_oper.oper_date          := i_fin_rec.de012;
    l_oper.host_date          := null;

    if l_oper.terminal_type is null then
        l_oper.terminal_type  :=
        case i_fin_rec.de026
            when vis_api_const_pkg.MCC_ATM
            then acq_api_const_pkg.TERMINAL_TYPE_ATM
            else acq_api_const_pkg.TERMINAL_TYPE_POS
        end;
    end if;

    l_oper.mcc                := i_fin_rec.de026;
    l_oper.originator_refnum  := i_fin_rec.de037;
    l_oper.acq_inst_bin       := nvl(i_fin_rec.de032, i_fin_rec.de033);
    l_oper.merchant_number    := i_fin_rec.de042;
    l_oper.terminal_number    := i_fin_rec.de041;
    l_oper.merchant_name      := i_fin_rec.de043_1;
    l_oper.merchant_street    := i_fin_rec.de043_2;
    l_oper.merchant_city      := i_fin_rec.de043_3;
    l_oper.merchant_region    := i_fin_rec.de043_5;
    l_oper.merchant_country   := com_api_country_pkg.get_country_code_by_name(
                                     i_name         =>  i_fin_rec.de043_6
                                   , i_raise_error  =>  com_api_type_pkg.FALSE
                                 );
    l_oper.merchant_postcode  := i_fin_rec.de043_4;
    l_oper.dispute_id         := i_fin_rec.dispute_id;
    l_oper.match_status       := l_match_status;
    l_oper.original_id        := coalesce(l_oper.original_id, get_original_id(i_fin_rec => i_fin_rec));

    if iss_api_card_pkg.get_card_id(i_card_number => i_fin_rec.de002) is null
    then
        l_oper.proc_mode := aut_api_const_pkg.AUTH_PROC_MODE_CARD_ABSENT;
        l_oper.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        trc_log_pkg.warn(
            i_text          => 'CARD_NOT_FOUND'
          , i_env_param1    => iss_api_card_pkg.get_card_mask(i_card_number => i_fin_rec.de002)
          , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id     => l_oper.id
        );
    end if;

    l_iss_part.inst_id         := l_iss_inst_id;
    l_iss_part.network_id      := l_iss_network_id;
    l_iss_part.client_id_type  := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    l_iss_part.client_id_value := i_fin_rec.de002;
    l_iss_part.customer_id     := iss_api_card_pkg.get_customer_id(i_card_number => i_fin_rec.de002);
    l_iss_part.card_id         := iss_api_card_pkg.get_card_id(i_fin_rec.de002);
    l_iss_part.card_type_id    := l_card_type_id;

    if i_fin_rec.de014 is null then
        begin
            select expir_date
              into l_iss_part.card_expir_date
              from (select i.expir_date
                      from iss_card_vw c
                         , iss_card_instance i
                     where c.id = l_iss_part.card_id
                       and c.id = i.card_id
                     order by i.seq_number desc
                   )
             where rownum = 1;
        exception
            when no_data_found then
                l_iss_part.card_expir_date := null;
        end;
    else
        l_iss_part.card_expir_date := i_fin_rec.de014;
    end if;

    l_iss_part.card_seq_number   := i_fin_rec.de023;
    l_iss_part.card_number       := i_fin_rec.de002;
    l_iss_part.card_mask         := iss_api_card_pkg.get_card_mask(i_card_number => i_fin_rec.de002);
    l_iss_part.card_country      := l_card_country;
    l_iss_part.card_inst_id      := l_card_inst_id;
    l_iss_part.card_network_id   := l_card_network_id;
    l_iss_part.account_id        := null;
    l_iss_part.account_number    := null;
    l_iss_part.account_amount    := null;
    l_iss_part.account_currency  := null;
    l_iss_part.auth_code         := i_fin_rec.de038;

    l_acq_part.inst_id           := l_acq_inst_id;
    l_acq_part.network_id        := l_acq_network_id;

    mcw_cst_fin_pkg.before_creating_operation(
        io_oper        => l_oper
        , io_iss_part  => l_iss_part
        , io_acq_part  => l_acq_part
    );

    opr_api_create_pkg.create_operation(
        io_oper_id                => l_oper.id
      , i_session_id              => get_session_id
      , i_status                  => nvl(l_oper.status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY)
      , i_status_reason           => null
      , i_sttl_type               => l_oper.sttl_type
      , i_msg_type                => l_oper.msg_type
      , i_oper_type               => l_oper.oper_type
      , i_oper_reason             => null
      , i_is_reversal             => l_oper.is_reversal
      , i_oper_amount             => l_oper.oper_amount
      , i_oper_currency           => l_oper.oper_currency
      , i_oper_cashback_amount    => l_oper.oper_cashback_amount
      , i_sttl_amount             => l_oper.sttl_amount
      , i_sttl_currency           => l_oper.sttl_currency
      , i_oper_date               => l_oper.oper_date
      , i_host_date               => null
      , i_terminal_type           => l_oper.terminal_type
      , i_mcc                     => l_oper.mcc
      , i_originator_refnum       => l_oper.originator_refnum
      , i_network_refnum          => l_oper.network_refnum
      , i_acq_inst_bin            => l_oper.acq_inst_bin
      , i_merchant_number         => l_oper.merchant_number
      , i_terminal_number         => l_oper.terminal_number
      , i_merchant_name           => l_oper.merchant_name
      , i_merchant_street         => l_oper.merchant_street
      , i_merchant_city           => l_oper.merchant_city
      , i_merchant_region         => l_oper.merchant_region
      , i_merchant_country        => l_oper.merchant_country
      , i_merchant_postcode       => l_oper.merchant_postcode
      , i_dispute_id              => l_oper.dispute_id
      , i_match_status            => l_oper.match_status
      , i_original_id             => l_oper.original_id
      , i_proc_mode               => l_oper.proc_mode
      , i_clearing_sequence_num   => l_oper.clearing_sequence_num
      , i_clearing_sequence_count => l_oper.clearing_sequence_count
      , i_incom_sess_file_id      => l_oper.incom_sess_file_id
    );

    opr_api_create_pkg.add_participant(
        i_oper_id           => l_oper.id
      , i_msg_type          => l_oper.msg_type
      , i_oper_type         => l_oper.oper_type
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_host_date         => null
      , i_inst_id           => l_iss_part.inst_id
      , i_network_id        => l_iss_part.network_id
      , i_customer_id       => l_iss_part.customer_id
      , i_client_id_type    => opr_api_const_pkg.CLIENT_ID_TYPE_CARD
      , i_client_id_value   => l_iss_part.card_number
      , i_card_id           => l_iss_part.card_id
      , i_card_type_id      => l_iss_part.card_type_id
      , i_card_expir_date   => l_iss_part.card_expir_date
      , i_card_seq_number   => l_iss_part.card_seq_number
      , i_card_number       => l_iss_part.card_number
      , i_card_mask         => l_iss_part.card_mask
      , i_card_hash         => l_iss_part.card_hash
      , i_card_country      => l_iss_part.card_country
      , i_card_inst_id      => l_iss_part.card_inst_id
      , i_card_network_id   => l_iss_part.card_network_id
      , i_account_id        => null
      , i_account_number    => null
      , i_account_amount    => null
      , i_account_currency  => null
      , i_auth_code         => l_iss_part.auth_code
      , i_split_hash        => l_iss_part.split_hash
      , i_without_checks    => com_api_const_pkg.TRUE
    );

    opr_api_create_pkg.add_participant(
        i_oper_id           => l_oper.id
      , i_msg_type          => l_oper.msg_type
      , i_oper_type         => l_oper.oper_type
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
      , i_host_date         => null
      , i_inst_id           => l_acq_part.inst_id
      , i_network_id        => l_acq_part.network_id
      , i_merchant_id       => l_acq_part.merchant_id
      , i_terminal_id       => l_acq_part.terminal_id
      , i_terminal_number   => l_oper.terminal_number
      , i_split_hash        => l_acq_part.split_hash
      , i_without_checks    => com_api_const_pkg.TRUE
    );

    if i_fin_rec.dispute_id is not null then
        -- Try to calculate dispute due date by the reference table DSP_DUE_DATE_LIMIT
        -- and set value of application element DUE_DATE and a new cycle counter (for notification)
        mcw_api_dispute_pkg.update_due_date(
            i_fin_rec           => i_fin_rec
          , i_standard_id       => i_standard_id
          , i_msg_type          => l_oper.msg_type
          , i_is_incoming       => i_fin_rec.is_incoming
        );
    end if;
end create_operation_fraud;

procedure create_operation(
    i_fin_rec             in mcw_api_type_pkg.t_fin_rec
  , i_standard_id         in com_api_type_pkg.t_tiny_id
  , i_auth                in aut_api_type_pkg.t_auth_rec
  , i_status              in com_api_type_pkg.t_dict_value default null
  , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
  , i_host_id             in com_api_type_pkg.t_tiny_id    default null
  , i_create_disp_case    in com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , o_msg_type           out com_api_type_pkg.t_dict_value
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
    l_match_id                      com_api_type_pkg.t_long_id;
    l_terminal_type                 com_api_type_pkg.t_dict_value;
    l_oper_type                     com_api_type_pkg.t_dict_value;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_original_id                   com_api_type_pkg.t_long_id;
    l_proc_mode                     com_api_type_pkg.t_dict_value;
    l_oper_cashback_amount          com_api_type_pkg.t_money;

    l_operation                     opr_api_type_pkg.t_oper_rec;
    l_participant                   opr_api_type_pkg.t_oper_part_rec;
    l_iss_part                      opr_api_type_pkg.t_oper_part_rec;
    l_acq_part                      opr_api_type_pkg.t_oper_part_rec;
    
    l_merchant_number               com_api_type_pkg.t_merchant_number;
    l_terminal_number               com_api_type_pkg.t_terminal_number;
    l_card_exp_date                 date;

    l_trim                          com_api_type_pkg.t_boolean;

    function ltrim6(
        i_str     in  com_api_type_pkg.t_attr_name
      , i_trim    in  com_api_type_pkg.t_boolean
    ) return com_api_type_pkg.t_attr_name
    is
    begin
        if i_trim = com_api_const_pkg.TRUE and length(i_str) > 6 then
            return ltrim(substr(i_str, 1, 6), '0') || substr(i_str, 7);
        else
            return i_str;
        end if;
    end;

begin
    trc_log_pkg.debug('mcw.create_operation: START '); 
    l_oper_id     := i_fin_rec.id;
    l_original_id := get_original_id(i_fin_rec => i_fin_rec);
    l_status      := nvl(i_status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY);

    l_trim := mcw_prc_ipm_pkg.get_trim_bin;

    trc_log_pkg.debug(
        i_text    => 'trim is ' || l_trim
    );

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

    elsif i_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_FEE
      and i_fin_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE
                            , mcw_api_const_pkg.FUNC_CODE_FEE_RETURN)
      and (i_auth.id is null or i_fin_rec.is_incoming = com_api_type_pkg.FALSE)
    then
        trc_log_pkg.debug (
            i_text          => 'Member fee: inst_id[#1] network_id[#2] card_mask[#3]'
            , i_env_param1  => i_fin_rec.inst_id
            , i_env_param2  => i_fin_rec.network_id
            , i_env_param3  => iss_api_card_pkg.get_card_mask(i_card_number => i_fin_rec.de002)
        );

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

            begin
                l_acq_inst_id :=
                    cmn_api_standard_pkg.find_value_owner(
                        i_standard_id   => i_standard_id
                      , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
                      , i_object_id     => i_host_id
                      , i_param_name    => case
                                               when i_fin_rec.de094 = nvl(i_fin_rec.de032, i_fin_rec.de033)
                                               then mcw_api_const_pkg.CMID
                                               else mcw_api_const_pkg.ACQUIRER_BIN
                                           end
                      , i_value_char    => nvl(i_fin_rec.de032, i_fin_rec.de033)
                      , i_mask_error    => com_api_const_pkg.TRUE
                      , i_masked_level  => trc_config_pkg.DEBUG
                    );
            exception
                when others then
                    if com_api_error_pkg.get_last_error = 'NOT_FOUND_VALUE_OWNER' then
                        l_acq_inst_id := null;
                    else
                        raise;
                    end if;
            end;

            if l_acq_inst_id is null then
                l_acq_inst_id := i_fin_rec.inst_id;
            end if;

            l_acq_network_id  := ost_api_institution_pkg.get_inst_network(l_acq_inst_id);
        else
            l_acq_network_id := i_fin_rec.network_id;
            l_acq_inst_id    := net_api_network_pkg.get_inst_id(i_fin_rec.network_id);    
        end if;
        
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

                update mcw_fin
                   set status =  mcw_api_const_pkg.MSG_STATUS_INVALID
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

        begin
            l_acq_inst_id :=
                cmn_api_standard_pkg.find_value_owner(
                    i_standard_id   => i_standard_id
                  , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_object_id     => i_host_id
                  , i_param_name    => case
                                           when i_fin_rec.de094 = nvl(i_fin_rec.de032, i_fin_rec.de033)
                                           then mcw_api_const_pkg.CMID
                                           else mcw_api_const_pkg.ACQUIRER_BIN
                                       end
                  , i_value_char    => nvl(i_fin_rec.de032, i_fin_rec.de033)
                  , i_mask_error    => com_api_const_pkg.TRUE
                  , i_masked_level  => trc_config_pkg.DEBUG
                );
        exception
            when others then
                if com_api_error_pkg.get_last_error = 'NOT_FOUND_VALUE_OWNER' then
                    l_acq_inst_id := null;
                else
                    raise;
                end if;
         end;

        if l_acq_inst_id is null then
            l_acq_network_id := i_fin_rec.network_id;
            l_acq_inst_id    := net_api_network_pkg.get_inst_id(i_fin_rec.network_id);
        end if;

        if l_acq_network_id is null then
            l_acq_network_id := ost_api_institution_pkg.get_inst_network(l_acq_inst_id);
        end if;

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

                update mcw_fin
                   set status = mcw_api_const_pkg.MSG_STATUS_INVALID
                 where id = i_fin_rec.id;

                trc_log_pkg.debug(
                    i_text          => 'Set message status is invalid and save operation'
                );
        end;
        
        if i_fin_rec.status = mcw_api_const_pkg.MSG_STATUS_INVALID then
            trc_log_pkg.debug(
                i_text          => 'If message status is invalid then save operation in status for manual processing'
            );
            l_status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        end if;
        
    else
        l_sttl_type       := i_auth.sttl_type;
        l_iss_inst_id     := i_auth.iss_inst_id;
        l_iss_network_id  := i_auth.iss_network_id;
        l_acq_inst_id     := i_auth.acq_inst_id;
        l_acq_network_id  := i_auth.acq_network_id;
        l_match_status    := i_auth.match_status;

        l_card_type_id    := i_auth.card_type_id;
        l_card_country    := i_auth.card_country;
        l_card_inst_id    := i_auth.card_inst_id;
        l_card_network_id := i_auth.card_network_id;

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
        case trim(i_fin_rec.p0023)
            when 'ATM' then
                acq_api_const_pkg.TERMINAL_TYPE_ATM
            when 'MAN' then
                acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER
            when 'POI' then
                acq_api_const_pkg.TERMINAL_TYPE_POS
            when 'CT1' then
                acq_api_const_pkg.TERMINAL_TYPE_ATM
            when 'CT2' then
                acq_api_const_pkg.TERMINAL_TYPE_INFO_KIOSK
            when 'CT3' then
                acq_api_const_pkg.TERMINAL_TYPE_ATM
            when 'CT4' then
                acq_api_const_pkg.TERMINAL_TYPE_POS
            when 'CT6' then
                acq_api_const_pkg.TERMINAL_TYPE_EPOS
            when 'CT7' then
                acq_api_const_pkg.TERMINAL_TYPE_TRANSPONDER
            when 'CT9' then
                acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS
            when 'NA' then
                acq_api_const_pkg.TERMINAL_TYPE_UNKNOWN
            else
                null
        end;

    if l_terminal_type is null
       and trim(i_fin_rec.p0023) is not null
    then
        com_api_error_pkg.raise_error (
            i_error      => 'TERMINAL_TYPE_INCORRECT'
          , i_env_param1 => i_fin_rec.p0023
        );
    end if;

    if i_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
        and i_fin_rec.de024 = mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
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

    -- check fin operation type
    if i_fin_rec.de003_1 = mcw_api_const_pkg.PROC_CODE_CASHBACK then
        l_oper_cashback_amount := get_cashback_amount(
                                      i_de054       => i_fin_rec.de054
                                    , i_oper_curr   => nvl(i_fin_rec.de049, i_fin_rec.p0149_1)
                                  );
    end if;

    -- if second presentment or chargeback operation
    if (
           i_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
           and i_fin_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
                                 , mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_PART)
       )
       or
       (
           i_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
           and i_fin_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                                 , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                                 , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
                                 , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART)
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

        l_iss_part.split_hash := l_participant.split_hash;
        l_card_inst_id        := nvl(l_card_inst_id, l_participant.card_inst_id);
        l_card_network_id     := nvl(l_card_network_id, l_participant.card_network_id);
        l_card_exp_date       := l_participant.card_expir_date;

        opr_api_operation_pkg.get_participant(
            i_oper_id            => l_operation.id
          , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
          , o_participant        => l_participant
        );

        l_acq_part.merchant_id := l_participant.merchant_id;
        l_acq_part.terminal_id := l_participant.terminal_id;
        l_acq_part.split_hash  := l_participant.split_hash;
        l_terminal_type        := l_operation.terminal_type;
        l_merchant_number      := l_operation.merchant_number;
        l_terminal_number      := l_operation.terminal_number;
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
      , i_oper_currency         => nvl(i_fin_rec.de049, i_fin_rec.p0149_1)
      , i_oper_cashback_amount  => l_oper_cashback_amount
      , i_sttl_amount           => i_fin_rec.de005
      , i_sttl_currency         => i_fin_rec.de050
      , i_oper_date             => i_fin_rec.de012
      , i_host_date             => null
      , i_terminal_type         => l_terminal_type
      , i_mcc                   => i_fin_rec.de026
      , i_originator_refnum     => i_fin_rec.de037
      , i_network_refnum        => i_fin_rec.de031
      , i_acq_inst_bin          => ltrim6(
                                       i_str  => nvl(i_fin_rec.de032, i_fin_rec.de033)
                                     , i_trim => l_trim
                                   )
      , i_merchant_number       => nvl(i_fin_rec.de042, l_merchant_number)
      , i_terminal_number       => nvl(l_terminal_number, i_fin_rec.de041)
      , i_merchant_name         => i_fin_rec.de043_1
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
      , i_client_id_type    => opr_api_const_pkg.CLIENT_ID_TYPE_CARD
      , i_client_id_value   => i_fin_rec.de002
      , i_card_id           => iss_api_card_pkg.get_card_id(i_fin_rec.de002)
      , i_card_type_id      => l_card_type_id
      , i_card_expir_date   => l_card_exp_date
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

    if i_create_disp_case = com_api_type_pkg.TRUE then
        csm_api_check_pkg.perform_check(
            i_oper_id           => l_oper_id
          , i_card_number       => i_fin_rec.de002
          , i_merchant_number   => coalesce(i_fin_rec.de042, l_merchant_number)
          , i_inst_id           => l_card_inst_id
          , i_msg_type          => l_msg_type
          , i_dispute_id        => i_fin_rec.dispute_id
          , i_de_024            => i_fin_rec.de024
          , i_reason_code       => null
          , i_original_id       => l_original_id
          , i_de004             => coalesce(i_fin_rec.de004, i_fin_rec.de030_1)
          , i_de049             => coalesce(i_fin_rec.de049, i_fin_rec.p0149_1)
        );
    end if;
    
    if i_fin_rec.dispute_id is not null then
        -- Try to calculate dispute due date by the reference table DSP_DUE_DATE_LIMIT
        -- and set value of application element DUE_DATE and a new cycle counter (for notification)
        mcw_api_dispute_pkg.update_due_date(
            i_fin_rec           => i_fin_rec
          , i_standard_id       => i_standard_id
          , i_msg_type          => l_msg_type
          , i_is_incoming       => i_fin_rec.is_incoming
        );
    end if;
    
    trc_log_pkg.debug(
        'mcw.create_operation: l_msg_type=' || l_msg_type
    );
    o_msg_type := l_msg_type;
    
end create_operation;

-- wrapper to use without o_msg_type (legacy style)
procedure create_operation(
    i_fin_rec             in mcw_api_type_pkg.t_fin_rec
  , i_standard_id         in com_api_type_pkg.t_tiny_id
  , i_auth                in aut_api_type_pkg.t_auth_rec
  , i_status              in com_api_type_pkg.t_dict_value default null
  , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
  , i_host_id             in com_api_type_pkg.t_tiny_id    default null
  , i_create_disp_case    in com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
) is
    l_msg_type           com_api_type_pkg.t_dict_value;
begin   
    create_operation(
        i_fin_rec            => i_fin_rec         
      , i_standard_id        => i_standard_id
      , i_auth               => i_auth
      , i_status             => i_status
      , i_incom_sess_file_id => i_incom_sess_file_id
      , i_host_id            => i_host_id
      , i_create_disp_case   => i_create_disp_case
      , o_msg_type           => l_msg_type        
    );
end create_operation;

procedure put_message(
    i_fin_rec               in mcw_api_type_pkg.t_fin_rec
) is
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_impact                com_api_type_pkg.t_sign;
    l_p0014                 mcw_api_type_pkg.t_p0014;
begin
    l_split_hash := com_api_hash_pkg.get_split_hash(i_fin_rec.de002);

    if i_fin_rec.impact is null then
        l_impact :=
            mcw_utl_pkg.get_message_impact(
                i_mti           => i_fin_rec.mti
              , i_de024         => i_fin_rec.de024
              , i_de003_1       => i_fin_rec.de003_1
              , i_is_reversal   => i_fin_rec.is_reversal
              , i_is_incoming   => i_fin_rec.is_incoming
            );
    else
        l_impact := i_fin_rec.impact;
    end if;

    insert into mcw_fin (
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
      , de063
      , de071
      , de072
      , de073
      , de093
      , de094
      , de095
      , de100
      , de111
      , p0001_1
      , p0001_2
      , p0002
      , p0004_1
      , p0004_2
      , p0018
      , p0021
      , p0022
      , p0023
      , p0025_1
      , p0025_2
      , p0028
      , p0029
      , p0042
      , p0043
      , p0045
      , p0047
      , p0052
      , p0058
      , p0059
      , p0072
      , p0137
      , p0146
      , p0146_net
      , p0147
      , p0148
      , p0149_1
      , p0149_2
      , p0158_1
      , p0158_2
      , p0158_3
      , p0158_4
      , p0158_5
      , p0158_6
      , p0158_7
      , p0158_8
      , p0158_9
      , p0158_10
      , p0158_11
      , p0158_12
      , p0158_13
      , p0158_14
      , p0159_1
      , p0159_2
      , p0159_3
      , p0159_4
      , p0159_5
      , p0159_6
      , p0159_7
      , p0159_8
      , p0159_9
      , p0165
      , p0176
      , p0181
      , p0198
      , p0200_1
      , p0200_2
      , p0207
      , p0208_1
      , p0208_2
      , p0209
      , p0210_1
      , p0210_2
      , p0228
      , p0230
      , p0241
      , p0243
      , p0244
      , p0260
      , p0261
      , p0262
      , p0264
      , p0265
      , p0266
      , p0267
      , p0268_1
      , p0268_2
      , p0375
      , p0674
      , p1001
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
      , emv_9f53
      , emv_84
      , emv_9f09
      , emv_9f03
      , emv_9f1e
      , emv_9f41
      , local_message
      , ird_trace
      , ext_claim_id
      , ext_message_id
      , p0184
      , p0185
      , p0186
      , ext_msg_status
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
      , i_fin_rec.de063
      , i_fin_rec.de071
      , i_fin_rec.de072
      , i_fin_rec.de073
      , i_fin_rec.de093
      , i_fin_rec.de094
      , i_fin_rec.de095
      , i_fin_rec.de100
      , i_fin_rec.de111
      , i_fin_rec.p0001_1
      , i_fin_rec.p0001_2
      , i_fin_rec.p0002
      , i_fin_rec.p0004_1
      , i_fin_rec.p0004_2
      , i_fin_rec.p0018
      , i_fin_rec.p0021
      , i_fin_rec.p0022
      , i_fin_rec.p0023
      , i_fin_rec.p0025_1
      , i_fin_rec.p0025_2
      , i_fin_rec.p0028
      , i_fin_rec.p0029
      , i_fin_rec.p0042
      , i_fin_rec.p0043
      , i_fin_rec.p0045
      , i_fin_rec.p0047
      , i_fin_rec.p0052
      , i_fin_rec.p0058
      , i_fin_rec.p0059
      , i_fin_rec.p0072
      , i_fin_rec.p0137
      , i_fin_rec.p0146
      , i_fin_rec.p0146_net
      , i_fin_rec.p0147
      , i_fin_rec.p0148
      , i_fin_rec.p0149_1
      , lpad(i_fin_rec.p0149_2, 3, '0')
      , i_fin_rec.p0158_1
      , i_fin_rec.p0158_2
      , i_fin_rec.p0158_3
      , i_fin_rec.p0158_4
      , i_fin_rec.p0158_5
      , i_fin_rec.p0158_6
      , i_fin_rec.p0158_7
      , i_fin_rec.p0158_8
      , i_fin_rec.p0158_9
      , i_fin_rec.p0158_10
      , i_fin_rec.p0158_11
      , i_fin_rec.p0158_12
      , i_fin_rec.p0158_13
      , i_fin_rec.p0158_14
      , i_fin_rec.p0159_1
      , i_fin_rec.p0159_2
      , i_fin_rec.p0159_3
      , i_fin_rec.p0159_4
      , i_fin_rec.p0159_5
      , i_fin_rec.p0159_6
      , i_fin_rec.p0159_7
      , i_fin_rec.p0159_8
      , i_fin_rec.p0159_9
      , i_fin_rec.p0165
      , i_fin_rec.p0176
      , i_fin_rec.p0181
      , i_fin_rec.p0198
      , i_fin_rec.p0200_1
      , i_fin_rec.p0200_2
      , i_fin_rec.p0207
      , i_fin_rec.p0208_1
      , i_fin_rec.p0208_2
      , i_fin_rec.p0209
      , i_fin_rec.p0210_1
      , i_fin_rec.p0210_2
      , i_fin_rec.p0228
      , i_fin_rec.p0230
      , i_fin_rec.p0241
      , i_fin_rec.p0243
      , i_fin_rec.p0244
      , i_fin_rec.p0260
      , i_fin_rec.p0261
      , i_fin_rec.p0262
      , i_fin_rec.p0264
      , i_fin_rec.p0265
      , i_fin_rec.p0266
      , i_fin_rec.p0267
      , i_fin_rec.p0268_1
      , i_fin_rec.p0268_2
      , i_fin_rec.p0375
      , i_fin_rec.p0674
      , i_fin_rec.p1001
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
      , i_fin_rec.emv_9f53
      , i_fin_rec.emv_84
      , i_fin_rec.emv_9f09
      , i_fin_rec.emv_9f03
      , i_fin_rec.emv_9f1e
      , i_fin_rec.emv_9f41
      , i_fin_rec.local_message
      , i_fin_rec.ird_trace
      , i_fin_rec.ext_claim_id
      , i_fin_rec.ext_message_id
      , i_fin_rec.p0184
      , i_fin_rec.p0185
      , i_fin_rec.p0186
      , i_fin_rec.ext_msg_status
    );

    begin
        l_p0014 := iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.p0014);
    exception
        when com_api_error_pkg.e_application_error then
            l_p0014 := i_fin_rec.p0014;
    end;

    insert into mcw_card(
        id
      , card_number
      , p0014
    ) values(
        i_fin_rec.id
      , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.de002)
      , l_p0014
    );
end;

function extract_acq_bin (
    i_de031                 in mcw_api_type_pkg.t_de031
) return mcw_api_type_pkg.t_de031 is
begin
    return substr(i_de031, 2, 6);
end;

function get_acq_country (
    i_acq_bin               in mcw_api_type_pkg.t_de031
) return com_api_type_pkg.t_curr_code is
    l_result com_api_type_pkg.t_curr_code;
begin
    select cc.code
      into l_result
      from mcw_acq_bin mab
           , com_country cc
     where mab.country = cc.name
       and mab.acq_bin = i_acq_bin
       and rownum = 1;

     return l_result;
exception
    when others then
        return null;
end;

function get_iss_country (
    i_de002                 in mcw_api_type_pkg.t_de002
) return com_api_type_pkg.t_curr_code is
    l_iss_inst_id          com_api_type_pkg.t_inst_id;
    l_card_inst_id         com_api_type_pkg.t_inst_id;
    l_iss_network_id       com_api_type_pkg.t_tiny_id;
    l_iss_host_id          com_api_type_pkg.t_tiny_id;
    l_pan_length           com_api_type_pkg.t_tiny_id;
    l_card_network_id      com_api_type_pkg.t_tiny_id;
    l_card_type_id         com_api_type_pkg.t_tiny_id;
    l_country_code         com_api_type_pkg.t_country_code;
begin
    begin
        select mbr.country
          into l_country_code
          from (
              select country
                from mcw_bin_range
               where i_de002 between pan_low and pan_high
               order by priority
          ) mbr
         where rownum = 1;

    exception
        when no_data_found then
            net_api_bin_pkg.get_bin_info(
                i_card_number      => i_de002
              , o_iss_inst_id      => l_iss_inst_id
              , o_iss_network_id   => l_iss_network_id
              , o_iss_host_id      => l_iss_host_id
              , o_card_type_id     => l_card_type_id
              , o_card_country     => l_country_code
              , o_card_inst_id     => l_card_inst_id
              , o_card_network_id  => l_card_network_id
              , o_pan_length       => l_pan_length
            );
    end;

    return l_country_code;
exception
    when others then
        return null;
end;

procedure get_emv_data(
    io_fin_rec              in out nocopy mcw_api_type_pkg.t_fin_rec
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
            io_fin_rec.emv_9a := to_date(substr(l_data, 1, 4)||'01', mcw_api_const_pkg.DE073_DATE_FORMAT);
        else
            io_fin_rec.emv_9a := to_date(l_data, mcw_api_const_pkg.DE073_DATE_FORMAT);
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
end;

function is_local_message (
    i_de002                 in mcw_api_type_pkg.t_de002
    , i_de031               in mcw_api_type_pkg.t_de031
    , i_de049               in mcw_api_type_pkg.t_de049
    , i_network_id          in com_api_type_pkg.t_tiny_id := null
) return com_api_type_pkg.t_boolean is
begin
    if set_ui_value_pkg.get_system_param_v(i_param_name => mcw_api_const_pkg.LOCAL_CLEARING_CENTRE) = mcw_api_const_pkg.LOCAL_CLEARING_CENTRE_RUSSIA then
        if get_acq_country(i_acq_bin => extract_acq_bin(i_de031 => i_de031)) = com_api_currency_pkg.RUBLE
           and get_iss_country(i_de002 => i_de002) = com_api_currency_pkg.RUBLE
           and i_de049 = com_api_currency_pkg.RUBLE
        then
            return com_api_const_pkg.TRUE;
        else
            return com_api_const_pkg.FALSE;
        end if;
    end if;
    return com_api_const_pkg.FALSE;
end;

function get_de004 (
    i_de004                 in mcw_api_type_pkg.t_de004
    , i_de054               in mcw_api_type_pkg.t_de054
    , i_de049               in mcw_api_type_pkg.t_de049
) return number is
    l_result                number;
begin
    l_result := mcw_utl_pkg.get_usd_rate (
        i_impact        => com_api_type_pkg.DEBIT
        , i_curr_code   => i_de049
    );
    return round((i_de004 - nvl(i_de054, 0))/l_result);
end;

function get_de004_rub (
    i_de004                 in mcw_api_type_pkg.t_de004
    , i_de054               in mcw_api_type_pkg.t_de054
    , i_de049               in mcw_api_type_pkg.t_de049
) return number is
begin
    if i_de049 = com_api_currency_pkg.RUBLE then
        return (i_de004 - nvl(i_de054, 0));
    else
        return 0;
    end if;
end;

function set_de054 (
    i_amount                in com_api_type_pkg.t_money
    , i_currency            in com_api_type_pkg.t_curr_code
    , i_type                in com_api_type_pkg.t_dict_value
) return mcw_api_type_pkg.t_de054 is
    l_result                mcw_api_type_pkg.t_de054;
begin
    if i_amount > 0 then
        l_result := '00'
                  || i_type
                  || i_currency
                  || 'D'
                  || lpad(i_amount, 12, '0');
    end if;
    return l_result;
end;

procedure create_from_auth(
    i_auth_rec              in     aut_api_type_pkg.t_auth_rec
  , i_id                    in     com_api_type_pkg.t_long_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id    := null
  , i_network_id            in     com_api_type_pkg.t_tiny_id    := null
  , i_status                in     com_api_type_pkg.t_dict_value := null
  , i_collection_only       in     com_api_type_pkg.t_boolean    := null
) is
    l_fin_rec               mcw_api_type_pkg.t_fin_rec;
    l_stage                 varchar2(100);
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_acquirer_bin          com_api_type_pkg.t_rrn;
    l_emv_compliant         com_api_type_pkg.t_boolean;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_de054                 mcw_api_type_pkg.t_de054;
    l_installment_data1     com_api_type_pkg.t_param_value;
    l_installment_data2     com_api_type_pkg.t_param_value;
    l_emv_tag_tab           com_api_type_pkg.t_tag_value_tab;
    l_p0043                 mcw_api_type_pkg.t_p0043;
    l_tag_id                com_api_type_pkg.t_short_id;
    l_sub_merchant_id       com_api_type_pkg.t_name;
    l_curr_standard_version com_api_type_pkg.t_tiny_id;
    l_de003_1               mcw_api_type_pkg.t_de003; 
    l_business_appl_id_tag_val  com_api_type_pkg.t_param_value;
    l_dcc_amount            com_api_type_pkg.t_money;
    l_dcc_currency          com_api_type_pkg.t_curr_code;

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
                                  when 'F2260000' then '1'
                                  when 'F2260001' then '0'
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
    begin
        if l_fin_rec.de022_3 in ('2') then
            l_fin_rec.de022_3 := '9';
        end if;

        -- correct fe pos modes accordingly to MC specs
        if l_fin_rec.de022_1 = '7' then
            l_fin_rec.de022_1 := 'B';
        elsif l_fin_rec.de022_1 = 'S' then
            l_fin_rec.de022_1 := 'M';
            l_fin_rec.p0018   := '1';
        elsif l_fin_rec.de022_1 = '5' then
            l_fin_rec.de022_1 := 'D';
            l_fin_rec.p0018   := '0';
        end if;

        if l_fin_rec.de022_7 in ('U', 'V') then
            l_fin_rec.de022_7 := 'S';
        elsif l_fin_rec.de022_7 in ('S', 'T') then
            l_fin_rec.de022_7 := 'S';
            l_fin_rec.p0023 := 'CT6';
        elsif l_fin_rec.de022_7 in ('5', '7', '9') then
            l_fin_rec.de022_7 := 'S';
        elsif l_fin_rec.de022_7 in ('8') then
            l_fin_rec.de022_7 := 'A';
        elsif l_fin_rec.de022_7 = 'F' and l_fin_rec.de038 is not null then
            l_fin_rec.de022_7 := 'C'; -- Online Chip
        elsif l_fin_rec.de022_7 in ('P', 'N') then
            l_fin_rec.de022_7 := 'A';
        elsif l_fin_rec.de022_7 in ('W') then
            l_fin_rec.de022_7 := 'T';
        elsif l_fin_rec.de022_7 in ('2') then
            l_fin_rec.de022_7 := 'B';
        elsif l_fin_rec.de022_7 in ('3') then
            l_fin_rec.de022_7 := '0'; -- Unspecified; data unavailable
        elsif l_fin_rec.de022_7 in ('O') then
            l_fin_rec.de022_7 := 'R';
        elsif l_fin_rec.de022_7 = 'E' then
            l_fin_rec.de022_7 := '7';
        end if;

        if l_fin_rec.de022_7 = 'S' 
        or (
            l_fin_rec.de022_7 = '7' 
        and l_fin_rec.de022_5 = '5'
        ) then
            l_fin_rec.p0023 := 'CT6';
        end if;

        if l_fin_rec.de022_4 = 'S' then
            l_fin_rec.de022_4 := '9';
            l_fin_rec.p0023   := 'CT1';
        elsif l_fin_rec.de022_4 = 'T' then
            l_fin_rec.de022_4 := '9';
            l_fin_rec.p0023   := 'CT2';
        elsif l_fin_rec.de022_4 = 'U' then
            l_fin_rec.de022_4 := '9';
            l_fin_rec.p0023   := 'CT3';
        elsif l_fin_rec.de022_4 = 'V' then
            l_fin_rec.de022_4 := '9';
            l_fin_rec.p0023   := 'CT4';
        elsif l_fin_rec.de022_4 = 'X' then
            l_fin_rec.de022_4 := '5';
        elsif l_fin_rec.de022_4 = 'A' then
            l_fin_rec.de022_4 := '1';
        elsif l_fin_rec.de022_4 = 'B' then
            l_fin_rec.de022_4 := '2';
        end if;
        
        if l_fin_rec.de022_12 in ('S') then 
            -- Add mapping for de022_2. Check, if de022_12 = 'S' (value as is received from the FE), then set de022_2 = '3'.
            l_fin_rec.de022_2 := '3';
            l_fin_rec.de022_12 := '4';
        end if;
        if l_fin_rec.de022_8 in ('W', 'X') then
            l_fin_rec.de022_8 := '9';
        end if;
        
        if l_fin_rec.de026 in ('6536', '6537') and l_fin_rec.de022_7 != 'S' then
            --MasterCard MoneySend
            l_fin_rec.p0023 := 'NA ';
        end if;
    end;

begin
    l_stage := 'start';
  -- Specific processing depending on current standard version
    l_curr_standard_version := 
        cmn_api_standard_pkg.get_current_version(
            i_network_id => nvl(i_network_id, mcw_api_const_pkg.MCW_NETWORK_ID)
        );

    if i_auth_rec.is_reversal = com_api_type_pkg.TRUE then
        flush_job;

        -- find presentment and make reversal
        get_fin (
            i_id            => i_auth_rec.original_id
            , o_fin_rec     => l_fin_rec
        );

        update mcw_fin
           set status = case
                            when status    = net_api_const_pkg.CLEARING_MSG_STATUS_READY
                                 and de004 = i_auth_rec.oper_amount
                            then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                            else status
                        end
         where rowid = l_fin_rec.row_id
         returning case
                       when status = net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                            or i_auth_rec.oper_amount = 0
                       then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                       else nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY)
                   end
          into l_fin_rec.status;

        l_fin_rec.p0025_1 := mcw_api_const_pkg.REVERSAL_PDS_REVERSAL;
        get_processing_date (
            i_id                 => l_fin_rec.id
            , i_is_fpd_matched   => l_fin_rec.is_fpd_matched
            , i_is_fsum_matched  => l_fin_rec.is_fsum_matched
            , i_file_id          => l_fin_rec.file_id
            , o_p0025_2          => l_fin_rec.p0025_2
        );

        l_fin_rec.is_incoming     := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal     := com_api_type_pkg.TRUE;
        l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
        l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
        l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
        l_fin_rec.file_id := null;

        mcw_utl_pkg.get_ipm_transaction_type (
            i_oper_type     => i_auth_rec.oper_type
            , i_mcc         => i_auth_rec.mcc
            , o_de003_1     => l_de003_1
            , o_p0043       => l_p0043
        );

        l_stage := 'p0043';
        l_business_appl_id_tag_val := 
            aup_api_tag_pkg.get_tag_value(
                i_auth_id => l_fin_rec.id
              , i_tag_id  => mcw_api_const_pkg.TAG_BUSINESS_APPLICATION_ID
            );

        if l_business_appl_id_tag_val is not null then
            l_p0043 := 
                case l_business_appl_id_tag_val
                when 'MP' then 'C67'
                when 'PP' then 'C07'
                when 'AA' then 'C52'
                else l_p0043
                end;
        end if;
        
        l_fin_rec.p0043  := nvl(
                                aup_api_tag_pkg.get_tag_value(
                                    i_auth_id => l_fin_rec.id
                                  , i_tag_id  => mcw_api_const_pkg.TAG_FUND_PAYMENT_TRNS_TYPE_ID
                                )
                              , l_p0043
                            );
           
        if l_fin_rec.p0043 = 'C67' and l_fin_rec.de003_1 = '00' then
            -- this is Masterpass QR Funding Transactions and need to fill pds 0674, pds 0028.
            l_fin_rec.p0674 :=  to_char(l_fin_rec.id, com_api_const_pkg.XML_NUMBER_FORMAT);

            l_fin_rec.p0028 := 
                aup_api_tag_pkg.get_tag_value(
                    i_auth_id => l_fin_rec.id
                  , i_tag_id  => mcw_api_const_pkg.TAG_DST_ACC_NUMBER_ID
                );
        end if;

        l_fin_rec.impact := mcw_utl_pkg.get_message_impact (
            i_mti         => l_fin_rec.mti
          , i_de024       => l_fin_rec.de024
          , i_de003_1     => l_fin_rec.de003_1
          , i_is_reversal => l_fin_rec.is_reversal
          , i_is_incoming => l_fin_rec.is_incoming
        );

        l_stage := 'p0176';
        l_fin_rec.p0176  :=
            aup_api_tag_pkg.get_tag_value(
                i_auth_id => l_fin_rec.id
              , i_tag_id  => mcw_api_const_pkg.TAG_MASTERCARD_ASSIGNED_ID
            );

        l_stage := 'de030';
        l_fin_rec.de030_1 := l_fin_rec.de004;
        l_fin_rec.de030_2 := 0;

        l_stage := 'p0149';
        l_fin_rec.p0149_1 := l_fin_rec.de049;
        l_fin_rec.p0149_2 := '000';

        l_fin_rec.de004   := i_auth_rec.oper_amount;
        l_fin_rec.de049   := i_auth_rec.oper_currency;

        mcw_utl_pkg.add_curr_exp (
            io_p0148        => l_fin_rec.p0148
          , i_curr_code     => l_fin_rec.p0149_1
        );
        mcw_utl_pkg.add_curr_exp (
            io_p0148        => l_fin_rec.p0148
          , i_curr_code     => l_fin_rec.de049
        );

        l_fin_rec.p0375   := i_id;
        l_fin_rec.id      := i_id;

        l_stage := 'put';
        put_message (
            i_fin_rec   => l_fin_rec
        );

        l_stage := 'done';

    else
        l_fin_rec.id := i_id;

        -- mark as pending if operation amount is zero but impact is Debit or Credit 
        l_fin_rec.status := case
                                when i_auth_rec.oper_amount = 0
                                     and l_fin_rec.impact  != 0
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

        l_fin_rec.mti             := mcw_api_const_pkg.MSG_TYPE_PRESENTMENT;
        l_fin_rec.de024           := mcw_api_const_pkg.FUNC_CODE_FIRST_PRES;
        l_fin_rec.de026           := i_auth_rec.mcc;
        
        l_stage := 'de003';
        mcw_utl_pkg.get_ipm_transaction_type (
            i_oper_type     => i_auth_rec.oper_type
            , i_mcc         => i_auth_rec.mcc
            , o_de003_1     => l_fin_rec.de003_1
            , o_p0043       => l_p0043
        );
        
        l_stage := 'p0043';
        l_fin_rec.p0043  := nvl(
                                aup_api_tag_pkg.get_tag_value(
                                    i_auth_id => l_fin_rec.id
                                  , i_tag_id  => mcw_api_const_pkg.TAG_FUND_PAYMENT_TRNS_TYPE_ID
                                )
                              , l_p0043
                            );
        
           
        if l_fin_rec.p0043 = 'C67' and l_fin_rec.de003_1 = '00' then
            -- this is Masterpass QR Funding Transactions and need to fill pds 0674, pds 0028.
            l_fin_rec.p0674 :=  to_char(l_fin_rec.id, com_api_const_pkg.XML_NUMBER_FORMAT);

            l_fin_rec.p0028 := 
                aup_api_tag_pkg.get_tag_value(
                    i_auth_id => l_fin_rec.id
                  , i_tag_id  => mcw_api_const_pkg.TAG_DST_ACC_NUMBER_ID
                );
        end if;

        l_fin_rec.impact := mcw_utl_pkg.get_message_impact (
            i_mti           => l_fin_rec.mti
            , i_de024       => l_fin_rec.de024
            , i_de003_1     => l_fin_rec.de003_1
            , i_is_reversal => l_fin_rec.is_reversal
            , i_is_incoming => l_fin_rec.is_incoming
        );
      
        l_stage := 'p0176';
        l_fin_rec.p0176  := 
            aup_api_tag_pkg.get_tag_value(
                i_auth_id => l_fin_rec.id
              , i_tag_id  => mcw_api_const_pkg.TAG_MASTERCARD_ASSIGNED_ID
            );

        l_stage := 'card';
        l_fin_rec.de002    := i_auth_rec.card_number;
        l_fin_rec.de003_2  := nvl(substr(i_auth_rec.account_type, -2), mcw_api_const_pkg.DEFAULT_DE003_2);
        l_fin_rec.de003_3  := nvl(substr(i_auth_rec.dst_account_type, -2), mcw_api_const_pkg.DEFAULT_DE003_3);
        l_fin_rec.de004    := i_auth_rec.oper_amount;
        l_fin_rec.de012    := i_auth_rec.oper_date;
        l_fin_rec.de014    := i_auth_rec.card_expir_date;

        l_stage := 'de022';
        read_de22s;
        correct_de22s;

        l_stage := 'de038';
        l_fin_rec.de038    := i_auth_rec.auth_code;


        l_stage := 'de023';
        l_fin_rec.de023    := i_auth_rec.card_seq_number;

        l_host_id := net_api_network_pkg.get_member_id (
            i_inst_id       => nvl(i_inst_id,    i_auth_rec.iss_inst_id)
          , i_network_id    => nvl(i_network_id, i_auth_rec.iss_network_id)
        );

        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id       => l_host_id
        );

        rul_api_shared_data_pkg.load_oper_params(
             i_oper_id      => i_auth_rec.id
           , io_params      => l_param_tab
        );

        l_sub_merchant_id := aup_api_tag_pkg.get_tag_value(
                                 i_auth_id => l_fin_rec.id
                               , i_tag_id  => aup_api_const_pkg.TAG_SUB_MERCHANT_ID
                             );

        rul_api_param_pkg.set_param(
            i_name    => 'SUB_MERCHANT_ID'
          , i_value   => l_sub_merchant_id
          , io_params => l_param_tab
        );

        l_acquirer_bin := cmn_api_standard_pkg.get_varchar_value (
            i_inst_id     => l_fin_rec.inst_id
          , i_standard_id => l_standard_id
          , i_object_id   => l_host_id
          , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name  => mcw_api_const_pkg.ACQUIRER_BIN
          , i_param_tab   => l_param_tab
        );
        
        if l_acquirer_bin is null then
            com_api_error_pkg.raise_error(
                i_error         => 'STANDARD_PARAM_NOT_FOUND'
              , i_env_param1    => mcw_api_const_pkg.ACQUIRER_BIN
              , i_env_param2    => l_fin_rec.inst_id
              , i_env_param3    => l_standard_id
              , i_env_param4    => l_host_id
            );
        end if;

        l_stage := 'de031';
        l_acquirer_bin  := nvl(l_acquirer_bin, i_auth_rec.acq_inst_bin);
        l_fin_rec.de031 := acq_api_merchant_pkg.get_arn(
                               i_acquirer_bin => l_acquirer_bin
                           );

        l_stage := 'de032';
        l_fin_rec.de032 := l_acquirer_bin;

        l_stage := 'de033';
        l_fin_rec.de033 := cmn_api_standard_pkg.get_varchar_value (
            i_inst_id       => l_fin_rec.inst_id
            , i_standard_id => l_standard_id
            , i_object_id   => l_host_id
            , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_param_name  => mcw_api_const_pkg.FORW_INST_ID
            , i_param_tab   => l_param_tab
        );

        if l_fin_rec.de033 is null then
            com_api_error_pkg.raise_error(
                i_error         => 'STANDARD_PARAM_NOT_FOUND'
              , i_env_param1    => mcw_api_const_pkg.FORW_INST_ID
              , i_env_param2    => l_fin_rec.inst_id
              , i_env_param3    => l_standard_id
              , i_env_param4    => l_host_id
            );
        end if;

        l_fin_rec.de094 := cmn_api_standard_pkg.get_varchar_value (
            i_inst_id       => l_fin_rec.inst_id
            , i_standard_id => l_standard_id
            , i_object_id   => l_host_id
            , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_param_name  => mcw_api_const_pkg.CMID
            , i_param_tab   => l_param_tab
        );

        l_fin_rec.de032 := l_fin_rec.de094;

        if l_fin_rec.de094 is null then
            com_api_error_pkg.raise_error(
                i_error         => 'STANDARD_PARAM_NOT_FOUND'
              , i_env_param1    => mcw_api_const_pkg.CMID
              , i_env_param2    => l_fin_rec.inst_id
              , i_env_param3    => l_standard_id
              , i_env_param4    => l_host_id
            );
        end if;

        l_stage := 'de037';
        l_fin_rec.de037 := i_auth_rec.originator_refnum;
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
        l_fin_rec.de043_6 := com_api_country_pkg.get_country_name(i_code => i_auth_rec.merchant_country);  -- i_auth_rec.merchant_region;
        l_fin_rec.de043_5 := l_fin_rec.de043_6;

        l_stage := 'de049';
        l_fin_rec.de049 := i_auth_rec.oper_currency;
        mcw_utl_pkg.add_curr_exp (
            io_p0148     => l_fin_rec.p0148
          , i_curr_code  => l_fin_rec.de049
        );

        l_stage := 'de054';
        l_fin_rec.de054 := case l_fin_rec.de003_1
                               when mcw_api_const_pkg.PROC_CODE_ATM then
                                   set_de054 (
                                       i_amount    => i_auth_rec.oper_surcharge_amount
                                     , i_currency  => i_auth_rec.oper_currency
                                     , i_type      => '42'
                                   )
                               when mcw_api_const_pkg.PROC_CODE_CASHBACK then
                                   set_de054 (
                                       i_amount    => i_auth_rec.oper_cashback_amount
                                     , i_currency  => i_auth_rec.oper_currency
                                     , i_type      => '40'
                                   )
                               else null
                           end;

        l_de054         := case l_fin_rec.de003_1
                               when mcw_api_const_pkg.PROC_CODE_ATM then
                                   i_auth_rec.oper_surcharge_amount
                               else null
                           end;

        l_dcc_amount    := com_api_type_pkg.convert_to_number(
                               aup_api_tag_pkg.get_tag_value (
                                   i_auth_id   => i_auth_rec.id
                                 , i_tag_id    => aup_api_const_pkg.TAG_DCC_ATM_AMOUNT
                               )
                           );
            
        l_dcc_currency  := aup_api_tag_pkg.get_tag_value (
                               i_auth_id   => i_auth_rec.id
                             , i_tag_id    => aup_api_const_pkg.TAG_DCC_ATM_CURRENCY
                           );
            
        if l_dcc_amount is not null and l_dcc_currency is not null then
            l_fin_rec.de054 := l_fin_rec.de054 ||
                                set_de054 (
                                    i_amount    => l_dcc_amount
                                  , i_currency  => l_dcc_currency
                                  , i_type      => '58'
                                );
        end if; 

        l_stage := 'de063';
        l_fin_rec.de063 := mcw_cst_fin_pkg.get_de063(
            i_auth_id => i_id
        );
        if l_fin_rec.de063 is null then
            l_fin_rec.de063 := mcw_utl_pkg.build_nrn(
                i_netw_refnum  =>  i_auth_rec.network_refnum
              , i_netw_date    =>  i_auth_rec.network_cnvt_date
            );
        end if;

        l_stage := 'p0052';
        if l_fin_rec.de022_7 = 'S' 
         or (l_fin_rec.de022_7 = '7' and l_fin_rec.de022_5 in ('4', '5')  ) 
        then
            if i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                      , opr_api_const_pkg.OPERATION_TYPE_REFUND
                                      , opr_api_const_pkg.OPERATION_TYPE_BALANCE_INQUIRY
                                      , opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                                      , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
                                      , opr_api_const_pkg.OPERATION_TYPE_PAYMENT
                                      , opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT)
            then
                l_fin_rec.p0052 :=
                    case
                        when i_auth_rec.card_data_input_mode = 'F227000S' and i_auth_rec.crdh_auth_method = 'F2280000' then '910'
                        when i_auth_rec.card_data_input_mode = 'F227000S' and i_auth_rec.crdh_auth_method = 'F2280009' then '911'
                        when i_auth_rec.card_data_input_mode = 'F227000S' and i_auth_rec.crdh_auth_method = 'F228000S' then '912'
                        when i_auth_rec.card_data_input_mode = 'F227000S' and i_auth_rec.crdh_auth_method = 'F228000X' then '913'
                        when i_auth_rec.card_data_input_mode = 'F227000S' and i_auth_rec.crdh_auth_method = 'F228000P' then '917'
                        when i_auth_rec.card_data_input_mode = 'F2270007' and i_auth_rec.crdh_auth_method = 'F2280000' then '210'
                        when i_auth_rec.card_data_input_mode = 'F2270007' and i_auth_rec.crdh_auth_method = 'F2280009' then '211'
                        when i_auth_rec.card_data_input_mode = 'F2270007' and i_auth_rec.crdh_auth_method = 'F228000W' then '211'
                        when i_auth_rec.card_data_input_mode = 'F2270007' and i_auth_rec.crdh_auth_method = 'F228000S' then '212'
                        when i_auth_rec.card_data_input_mode = 'F2270007' and i_auth_rec.crdh_auth_method = 'F228000X' then '213'
                        when i_auth_rec.card_data_input_mode = 'F2270007' and i_auth_rec.crdh_auth_method = 'F228000P' then '217'
                    end;

                if l_fin_rec.p0052 is null then
                    case substr(i_auth_rec.addl_data, 1, 2)
                        when '01' then l_fin_rec.p0052 := '21';
                        when '02' then l_fin_rec.p0052 := '91';
                        when '04' then l_fin_rec.p0052 := '24';
                        else l_fin_rec.p0052 := substr(i_auth_rec.addl_data, 1, 2);
                    end case;

                    l_fin_rec.p0052 := l_fin_rec.p0052 || nvl(ltrim(substr(i_auth_rec.addl_data, 203, 1)), '0');
                end if;
            end if;

            trc_log_pkg.debug (
                i_text      => 'l_fin_rec.p0052 = ' || l_fin_rec.p0052
            );
        end if;

        l_stage := 'p0023';
        if l_fin_rec.p0023 is null then
            case i_auth_rec.terminal_type
                when acq_api_const_pkg.TERMINAL_TYPE_ATM then l_fin_rec.p0023 := 'ATM';
                when acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER then l_fin_rec.p0023 := 'MAN';
                else null;
            end case;
        end if;

        if l_fin_rec.p0023 is null then
            case i_auth_rec.cat_level
                when 'F22D0001' then l_fin_rec.p0023 := 'CT1';
                when 'F22D0002' then l_fin_rec.p0023 := 'CT2';
                when 'F22D0003' then l_fin_rec.p0023 := 'CT3';
                when 'F22D0004' then l_fin_rec.p0023 := 'CT4';
                when 'F22D0005' then l_fin_rec.p0023 := 'CT5';
                when 'F22D0006' then l_fin_rec.p0023 := 'CT6';
                when 'F22D0007' then l_fin_rec.p0023 := 'CT7';
                when 'F22D0009' then l_fin_rec.p0023 := 'CT9';
                else
                    if i_auth_rec.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS, acq_api_const_pkg.TERMINAL_TYPE_EPOS) then
                        if  i_auth_rec.card_data_input_cap = 'F2210001'
                            or
                            i_auth_rec.card_data_input_cap = 'F221000V' and i_auth_rec.card_data_input_mode = 'F2270001'
                        then
                            l_fin_rec.p0023 := 'NA ';
                        else
                            l_fin_rec.p0023 := 'POI';
                        end if;
                    else
                        l_fin_rec.p0023 := 'NA ';
                    end if;
            end case;
        end if;

        l_stage := 'certified_emv_compliant';
        l_emv_compliant := nvl(
            cmn_api_standard_pkg.get_number_value (
                i_inst_id       => l_fin_rec.inst_id
                , i_standard_id => l_standard_id
                , i_object_id   => l_host_id
                , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
                , i_param_name  => mcw_api_const_pkg.CERTIFIED_EMV_COMPLIANT
                , i_param_tab   => l_param_tab
            )
          , com_api_type_pkg.FALSE
        );

        l_stage := 'p0004';
        if l_fin_rec.p0043 = 'C67' then
            if l_fin_rec.p0004_1 is null then
                l_fin_rec.p0004_1 := '02';
                l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8608');  -- SENDER_ACCOUNT
                l_fin_rec.p0004_2 := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
            end if;

            trc_log_pkg.debug (
                i_text      => 'l_fin_rec.p0004 = ' || l_fin_rec.p0004_1 || l_fin_rec.p0004_2
            );
        end if;

        l_stage := 'get_ird';
        get_ird(
            o_p0158_4        => l_fin_rec.p0158_4
          , o_ird_trace      => l_fin_rec.ird_trace
          , i_mti            => l_fin_rec.mti
          , i_de024          => l_fin_rec.de024
          , i_acq_bin        => substr(l_fin_rec.de031, 2, 6)
          , i_hpan           => rpad(l_fin_rec.de002, 19, '0')
          , io_de003_1       => l_fin_rec.de003_1
          , i_mcc            => l_fin_rec.de026
          , i_p0043          => l_fin_rec.p0043
          , i_p0052          => l_fin_rec.p0052
          , i_p0023          => l_fin_rec.p0023
          , i_de038          => l_fin_rec.de038
          , i_de012          => l_fin_rec.de012
          , i_de022_1        => l_fin_rec.de022_1
          , i_de022_2        => l_fin_rec.de022_2
          , i_de022_3        => l_fin_rec.de022_3
          , i_de022_4        => l_fin_rec.de022_4
          , i_de022_5        => l_fin_rec.de022_5
          , i_de022_6        => l_fin_rec.de022_6
          , i_de022_7        => l_fin_rec.de022_7
          , i_de022_8        => l_fin_rec.de022_8
          , i_de026          => l_fin_rec.de026
          , i_de040          => l_fin_rec.de040
          , i_de004          => get_de004(
                                    i_de004  => l_fin_rec.de004
                                  , i_de054  => l_de054
                                  , i_de049  => l_fin_rec.de049
                                )
          , i_emv_compliant  => l_emv_compliant
          , i_de004_rub      => get_de004_rub(
                                    i_de004  => l_fin_rec.de004
                                  , i_de054  => l_de054
                                  , i_de049  => l_fin_rec.de049
                                )
          , i_de043_6        => l_fin_rec.de043_6
          , i_standard_id    => l_standard_id
          , i_host_id        => l_host_id
          , i_p0004_1        => l_fin_rec.p0004_1
          , i_p0004_2        => l_fin_rec.p0004_2
          , i_p0176          => l_fin_rec.p0176
          , i_p0207          => l_fin_rec.p0207
          , i_de042          => l_fin_rec.de042
          , i_de043_1        => l_fin_rec.de043_1
          , i_de043_2        => l_fin_rec.de043_2
          , i_de043_3        => l_fin_rec.de043_3
          , i_de043_4        => l_fin_rec.de043_4
          , i_de043_5        => l_fin_rec.de043_5
          , i_de049          => l_fin_rec.de049
          , i_p0674          => l_fin_rec.p0674
          , i_de063          => l_fin_rec.de063
          , i_p0001_1        => l_fin_rec.p0001_1
          , i_p0001_2        => l_fin_rec.p0001_2
          , i_p0198          => l_fin_rec.p0198
        );

        l_stage := 'p0165';
        if nvl(i_collection_only, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
            l_fin_rec.p0165 := mcw_api_const_pkg.SETTLEMENT_TYPE_COLLECTION;
            l_fin_rec.de093 := l_fin_rec.de094;
            l_fin_rec.network_id := nvl(i_network_id, l_fin_rec.network_id);
        else
            l_fin_rec.p0165 := mcw_api_const_pkg.SETTLEMENT_TYPE_MASTERCARD;
        end if;

        l_stage := 'p0181';
        l_installment_data1 := aup_api_tag_pkg.get_tag_value(
                                   i_auth_id => l_fin_rec.id
                                 , i_tag_id  => aup_api_const_pkg.TAG_INSTALLMENT_PAYMENT_DATA_1
                               );

        l_installment_data2 := aup_api_tag_pkg.get_tag_value(
                                   i_auth_id => l_fin_rec.id
                                 , i_tag_id  => aup_api_const_pkg.TAG_INSTALLMENT_PAYMENT_DATA_2
                               );

        l_fin_rec.p0181 :=
            case
                when l_installment_data1 is not null
                 and l_installment_data2 is not null
                then mcw_api_pds_pkg.format_p0181(
                         i_host_id            => l_host_id
                       , i_installment_data_1 => l_installment_data1
                       , i_installment_data_2 => l_installment_data2
                     )
                else null
            end;

        l_stage := 'p0184';
        l_fin_rec.p0184 := aup_api_tag_pkg.get_tag_value(
                               i_auth_id => l_fin_rec.id
                             , i_tag_id  => mcw_api_const_pkg.TAG_DS_TRANSACTION_ID
                           );

        l_stage := 'p0185';
        l_fin_rec.p0185 := aup_api_tag_pkg.get_tag_value(
                               i_auth_id => l_fin_rec.id
                             , i_tag_id  => mcw_api_const_pkg.TAG_ACCOUNTHOLDER_AUTH_VALUE
                           );

        l_stage := 'p0186';
        -- we use NVL, because the tags of PDS 0186 are different in FE group A and FE RND
        l_fin_rec.p0186 := 
            nvl(aup_api_tag_pkg.get_tag_value(
                    i_auth_id => l_fin_rec.id
                  , i_tag_id  => mcw_api_const_pkg.TAG_PROGRAM_PROTOCOL_A)
              , aup_api_tag_pkg.get_tag_value(
                    i_auth_id => l_fin_rec.id
                  , i_tag_id  => mcw_api_const_pkg.TAG_PROGRAM_PROTOCOL_RND)
               );

        l_stage := 'p0207';
        l_fin_rec.p0207   := aup_api_tag_pkg.get_tag_value(
                                 i_auth_id => l_fin_rec.id
                               , i_tag_id  => mcw_api_const_pkg.TAG_WALLET_ID
                             );

        l_stage := 'p0208';
        l_fin_rec.p0208_1 := aup_api_tag_pkg.get_tag_value(
                                 i_auth_id => l_fin_rec.id
                               , i_tag_id  => aup_api_const_pkg.TAG_PAYMENT_FACILITATOR_ID
                             );
        l_fin_rec.p0208_2 := l_sub_merchant_id;
        
        l_stage := 'p0209';
        l_fin_rec.p0209   := aup_api_tag_pkg.get_tag_value(
                                 i_auth_id => l_fin_rec.id
                               , i_tag_id  => aup_api_const_pkg.TAG_INDEP_SALES_ORGANIZATION
                             );

        l_stage := 'p1001';
        l_fin_rec.p1001 := trim(aup_api_tag_pkg.get_tag_value(
                                    i_auth_id => l_fin_rec.id
                                  , i_tag_id  => aup_api_const_pkg.TAG_ATM_SERVICE_FEE
                                )
                           );

        l_stage := 'emv';
        if  l_fin_rec.de022_1 in ('5', 'C', 'D', 'E', 'M')
            and
            l_fin_rec.de022_7 in ('5', 'C', 'F', 'M')
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
                                     , i_tag_type_tab => mcw_api_const_pkg.EMV_TAGS_LIST_FOR_DE055
                                   )
                               );
        end if;

        l_stage := 'p0375';
        l_fin_rec.p0375 := l_fin_rec.id;

        l_stage := 'p0014';
        l_fin_rec.p0014 := aup_api_tag_pkg.get_tag_value(
                               i_auth_id => l_fin_rec.id
                             , i_tag_id  => aup_api_const_pkg.TAG_DIGITAL_ACCT_REFERENCE
                           );

        l_stage := 'local_message';
        l_fin_rec.local_message := is_local_message(
                                       i_de002      => l_fin_rec.de002
                                     , i_de031      => l_fin_rec.de031
                                     , i_de049      => l_fin_rec.de049
                                     , i_network_id => l_fin_rec.network_id
                                   );

        if l_curr_standard_version >= mcw_api_const_pkg.STANDARD_VERSION_19Q2_ID then
            if l_fin_rec.de022_7 = 'M' and l_fin_rec.de055 is not null then
                l_fin_rec.p0021 := '1';
            end if;
        end if;

        l_stage := 'put addendum message';
        if l_fin_rec.de003_1 = mcw_api_const_pkg.PROC_CODE_PAYMENT then
            mcw_api_add_pkg.create_outgoing_addendum(
                i_fin_rec => l_fin_rec
            );
        end if;

        l_stage := 'put message';
        put_message (
            i_fin_rec   => l_fin_rec
        );
    end if;
exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating IPM presentment on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end;

procedure set_message(
    i_mes_rec      in     mcw_api_type_pkg.t_mes_rec
  , io_fin_rec     in out nocopy mcw_api_type_pkg.t_fin_rec
  , io_pds_tab     in out nocopy mcw_api_type_pkg.t_pds_tab
  , i_network_id   in     com_api_type_pkg.t_tiny_id
  , i_host_id      in     com_api_type_pkg.t_tiny_id
  , i_standard_id  in     com_api_type_pkg.t_tiny_id
  , i_financial    in     com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
) is
    l_pds_body              mcw_api_type_pkg.t_pds_body;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_card_type             com_api_type_pkg.t_tiny_id;
    l_card_country          com_api_type_pkg.t_curr_code;
    l_emv_tag_tab           com_api_type_pkg.t_tag_value_tab;
    l_stage                 varchar2(100);
    l_curr_standard_version com_api_type_pkg.t_tiny_id;
begin
  
    l_curr_standard_version := 
        cmn_api_standard_pkg.get_current_version(
            i_standard_id  => nvl(i_standard_id, mcw_api_const_pkg.MCW_STANDARD_ID)
          , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id    => coalesce(
                                  i_host_id
                                , net_api_network_pkg.get_default_host(
                                      i_network_id  => mcw_api_const_pkg.MCW_NETWORK_ID
                                  )
                              )
          , i_eff_date     => com_api_sttl_day_pkg.get_sysdate()
        );

    l_stage := 'de026';
    io_fin_rec.de026 := i_mes_rec.de026;

    l_stage := 'de003';
    io_fin_rec.de003_1 := i_mes_rec.de003_1;
    io_fin_rec.de003_2 := i_mes_rec.de003_2;
    io_fin_rec.de003_3 := i_mes_rec.de003_3;

    l_stage := 'extract_pds';
    mcw_api_pds_pkg.extract_pds(
        de048       => i_mes_rec.de048
        , de062     => i_mes_rec.de062
        , de123     => i_mes_rec.de123
        , de124     => i_mes_rec.de124
        , de125     => i_mes_rec.de125
        , pds_tab   => io_pds_tab
    );
    l_stage := 'p0025';
    l_pds_body := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0025
    );
    l_stage := 'parse_p0025';
    mcw_api_pds_pkg.parse_p0025(
        i_p0025           => l_pds_body
        , o_p0025_1       => io_fin_rec.p0025_1
        , o_p0025_2       => io_fin_rec.p0025_2
    );
    l_stage := 'is_reversal';
    if substr(io_fin_rec.p0025_1, 1, 1) = mcw_api_const_pkg.REVERSAL_PDS_REVERSAL then
        io_fin_rec.is_reversal := com_api_type_pkg.TRUE;
    elsif substr(io_fin_rec.p0025_1, 1, 1) = mcw_api_const_pkg.REVERSAL_PDS_CANCEL then
        io_fin_rec.is_reversal := com_api_type_pkg.FALSE;
    elsif substr(io_fin_rec.p0025_1, 1, 1) is null then
        io_fin_rec.is_reversal := com_api_type_pkg.FALSE;
    else
        com_api_error_pkg.raise_error(
            i_error         => 'MCW_ERROR_WRONG_VALUE'
            , i_env_param1  => 'P0025_1'
            , i_env_param2  => 1
            , i_env_param3  => io_fin_rec.p0025_1
        );
    end if;

    if i_financial = com_api_type_pkg.TRUE then
        io_fin_rec.impact := mcw_utl_pkg.get_message_impact (
            i_mti           => io_fin_rec.mti
            , i_de024       => io_fin_rec.de024
            , i_de003_1     => io_fin_rec.de003_1
            , i_is_reversal => io_fin_rec.is_reversal
            , i_is_incoming => io_fin_rec.is_incoming
        );
    end if;

    l_stage := 'card';
    io_fin_rec.de002 := i_mes_rec.de002;
    io_fin_rec.de004 := i_mes_rec.de004;
    io_fin_rec.de012 := i_mes_rec.de012;
    io_fin_rec.de014 := last_day(i_mes_rec.de014);

    l_stage := 'de005 - de010';
    io_fin_rec.de005 := i_mes_rec.de005;
    io_fin_rec.de006 := i_mes_rec.de006;
    --io_fin_rec.de008 := i_mes_rec.de008;
    io_fin_rec.de009 := i_mes_rec.de009;
    io_fin_rec.de010 := i_mes_rec.de010;

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

    l_stage := 'de023, de025, de026';
    io_fin_rec.de023 := i_mes_rec.de023;
    io_fin_rec.de025 := i_mes_rec.de025;
    io_fin_rec.de026 := i_mes_rec.de026;

    l_stage := 'de030';
    io_fin_rec.de030_1 := i_mes_rec.de030_1;
    io_fin_rec.de030_2 := i_mes_rec.de030_2;

    l_stage := 'de031 - de042';
    io_fin_rec.de031 := i_mes_rec.de031;
    io_fin_rec.de032 := i_mes_rec.de032;
    io_fin_rec.de033 := i_mes_rec.de033;
    io_fin_rec.de037 := i_mes_rec.de037;
    io_fin_rec.de038 := i_mes_rec.de038;
    io_fin_rec.de040 := i_mes_rec.de040;
    io_fin_rec.de041 := i_mes_rec.de041;
    io_fin_rec.de042 := i_mes_rec.de042;

    l_stage := 'de043';
    io_fin_rec.de043_1 := i_mes_rec.de043_1;
    io_fin_rec.de043_2 := i_mes_rec.de043_2;
    io_fin_rec.de043_3 := i_mes_rec.de043_3;
    io_fin_rec.de043_4 := i_mes_rec.de043_4;
    io_fin_rec.de043_5 := i_mes_rec.de043_5;
    io_fin_rec.de043_6 := i_mes_rec.de043_6;

    l_stage := 'de049';
    io_fin_rec.de049 := i_mes_rec.de049;
    l_stage := 'de050';
    io_fin_rec.de050 := i_mes_rec.de050;
    l_stage := 'de051';
    io_fin_rec.de051 := i_mes_rec.de051;

    l_stage := 'de054';
    io_fin_rec.de054 := i_mes_rec.de054;

    l_stage := 'de055';
    io_fin_rec.de055 := i_mes_rec.de055;
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

    l_stage := 'p0001 - p0137';
    l_pds_body := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0001
    );
    mcw_api_pds_pkg.parse_p0001(
        i_p0001           => l_pds_body
      , o_p0001_1         => io_fin_rec.p0001_1
      , o_p0001_2         => io_fin_rec.p0001_2
    );
    io_fin_rec.p0002 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0002
    );
    l_pds_body := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0004
    );
    mcw_api_pds_pkg.parse_p0004(
        i_p0004           => l_pds_body
      , o_p0004_1         => io_fin_rec.p0004_1
      , o_p0004_2         => io_fin_rec.p0004_2
    );

    io_fin_rec.p0014 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0014
    );

    io_fin_rec.p0018 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0018
    );

    io_fin_rec.p0021 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0021
    );

    if l_curr_standard_version >= mcw_api_const_pkg.STANDARD_VERSION_19Q2_ID 
   and com_api_sttl_day_pkg.get_sysdate() >= mcw_api_const_pkg.STANDARD_VERSION_19Q2_DATE then

        io_fin_rec.p0022 := mcw_api_pds_pkg.get_pds_body(
            i_pds_tab         => io_pds_tab
          , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0022
        );
    end if;

    io_fin_rec.p0023 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0023
    );

    io_fin_rec.p0028 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0028
    );
    io_fin_rec.p0029 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0029
    );

    io_fin_rec.p0042 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0042
    );
    io_fin_rec.p0043 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0043
    );
    io_fin_rec.p0045 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0045
    );
    io_fin_rec.p0047 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0047
    );
    io_fin_rec.p0052 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0052
    );
    io_fin_rec.p0058 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0058
    );
    io_fin_rec.p0059 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0059
    );
    io_fin_rec.p0072 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0072
    );
    io_fin_rec.p0137 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0137
    );

    -- Consider that PDS0146 and PDS0147 contain the same fees with different
    -- precision. If field PDS0147 is present and PDS0146 is missed,
    -- fees from PDS0147 are stored in format of PDS0146
    l_stage := 'p0146';
    io_fin_rec.p0146 := mcw_api_pds_pkg.get_pds_body(
                            i_pds_tab => io_pds_tab
                          , i_pds_tag => mcw_api_const_pkg.PDS_TAG_0146
                        );
    l_stage := 'p0147';
    io_fin_rec.p0147 := mcw_api_pds_pkg.get_pds_body(
                            i_pds_tab => io_pds_tab
                          , i_pds_tag => mcw_api_const_pkg.PDS_TAG_0147
                        );
    if io_fin_rec.p0146 is not null then
        l_stage := 'p0146';
        mcw_api_pds_pkg.parse_p0146(
            i_pds_body  => io_fin_rec.p0146
          , o_p0146     => l_pds_body -- is not used
          , o_p0146_net => io_fin_rec.p0146_net
          , i_is_p0147  => com_api_type_pkg.FALSE
        );
    else
        l_stage := 'p0147';
        mcw_api_pds_pkg.parse_p0146(
            i_pds_body  => io_fin_rec.p0147
          , o_p0146     => io_fin_rec.p0146
          , o_p0146_net => io_fin_rec.p0146_net
          , i_is_p0147  => com_api_type_pkg.TRUE
        );
    end if;

    l_stage := 'p0148';
    io_fin_rec.p0148 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0148
    );

    l_stage := 'p0149';
    l_pds_body := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0149
    );
    mcw_api_pds_pkg.parse_p0149(
        i_p0149           => l_pds_body
        , o_p0149_1       => io_fin_rec.p0149_1
        , o_p0149_2       => io_fin_rec.p0149_2
    );

    l_stage := 'p0158';
    l_pds_body := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0158
    );
    mcw_api_pds_pkg.parse_p0158(
        i_p0158           => l_pds_body
      , o_p0158_1         => io_fin_rec.p0158_1
      , o_p0158_2         => io_fin_rec.p0158_2
      , o_p0158_3         => io_fin_rec.p0158_3
      , o_p0158_4         => io_fin_rec.p0158_4
      , o_p0158_5         => io_fin_rec.p0158_5
      , o_p0158_6         => io_fin_rec.p0158_6
      , o_p0158_7         => io_fin_rec.p0158_7
      , o_p0158_8         => io_fin_rec.p0158_8
      , o_p0158_9         => io_fin_rec.p0158_9
      , o_p0158_10        => io_fin_rec.p0158_10
      , o_p0158_11        => io_fin_rec.p0158_11
      , o_p0158_12        => io_fin_rec.p0158_12
      , o_p0158_13        => io_fin_rec.p0158_13
      , o_p0158_14        => io_fin_rec.p0158_14
    );

    l_stage := 'p0159';
    l_pds_body := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0159
    );
    mcw_api_pds_pkg.parse_p0159(
        i_p0159           => l_pds_body
      , o_p0159_1         => io_fin_rec.p0159_1
      , o_p0159_2         => io_fin_rec.p0159_2
      , o_p0159_3         => io_fin_rec.p0159_3
      , o_p0159_4         => io_fin_rec.p0159_4
      , o_p0159_5         => io_fin_rec.p0159_5
      , o_p0159_6         => io_fin_rec.p0159_6
      , o_p0159_7         => io_fin_rec.p0159_7
      , o_p0159_8         => io_fin_rec.p0159_8
      , o_p0159_9         => io_fin_rec.p0159_9
    );

    l_stage := 'p0165';
    io_fin_rec.p0165 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0165
    );

    l_stage := 'p0176';
    io_fin_rec.p0176 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0176
    );

    l_stage := 'p0181';
    io_fin_rec.p0181 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0181
    );

    l_stage := 'p0184';
    io_fin_rec.p0184 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0184
    );
    l_stage := 'p0185';
    io_fin_rec.p0185 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0185
    );
    l_stage := 'p0186';
    io_fin_rec.p0186 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0186
    );

    l_stage := 'p0198';
    io_fin_rec.p0198 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0198
    );

    l_stage := 'p0200';
    l_pds_body := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0200
    );
    mcw_api_pds_pkg.parse_p0200(
        i_p0200           => l_pds_body
      , o_p0200_1         => io_fin_rec.p0200_1
      , o_p0200_2         => io_fin_rec.p0200_2
    );

    l_stage := 'p0207';
    io_fin_rec.p0207 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0207
    );   

    l_stage := 'p0208';
    l_pds_body := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0208
    );
    mcw_api_pds_pkg.parse_p0208(
        i_p0208           => l_pds_body
      , o_p0208_1         => io_fin_rec.p0208_1
      , o_p0208_2         => io_fin_rec.p0208_2
    );

    l_stage := 'p0209';
    io_fin_rec.p0209 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0209
    );

    l_stage := 'p0210';
    l_pds_body := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0210
    );
    mcw_api_pds_pkg.parse_p0210(
        i_p0210           => l_pds_body
      , o_p0210_1         => io_fin_rec.p0210_1
      , o_p0210_2         => io_fin_rec.p0210_2
    );

    l_stage := 'p0228';
    io_fin_rec.p0228 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0228
    );

    l_stage := 'p0230';
    io_fin_rec.p0230 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0230
    );

    l_stage := 'p0241';
    io_fin_rec.p0241 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0241
    );

    l_stage := 'p0243';
    io_fin_rec.p0243 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0243
    );

    l_stage := 'p0244';
    io_fin_rec.p0244 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0244
    );

    l_stage := 'p0260';
    io_fin_rec.p0260 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0260
    );

    l_stage := 'p0262';
    io_fin_rec.p0262 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0262
    );

    l_stage := 'p0264';
    io_fin_rec.p0264 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0264
    );

    l_stage := 'p0265';
    io_fin_rec.p0265 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0265
    );

    l_stage := 'p0266';
    io_fin_rec.p0266 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0266
    );

    l_stage := 'p0267';
    io_fin_rec.p0267 := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0267
    );

    l_stage := 'p0268';
    l_pds_body := mcw_api_pds_pkg.get_pds_body(
        i_pds_tab         => io_pds_tab
        , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0268
    );
    mcw_api_pds_pkg.parse_p0268(
        i_p0268           => l_pds_body
      , o_p0268_1         => io_fin_rec.p0268_1
      , o_p0268_2         => io_fin_rec.p0268_2
    );

    l_stage := 'p0674';
    io_fin_rec.p0674 := trim(mcw_api_pds_pkg.get_pds_body(
                                 i_pds_tab  => io_pds_tab
                               , i_pds_tag  => mcw_api_const_pkg.PDS_TAG_0674
                             )
                        );

    l_stage := 'p1001';
    io_fin_rec.p1001 := trim(mcw_api_pds_pkg.get_pds_body(
                                 i_pds_tab  => io_pds_tab
                               , i_pds_tag  => mcw_api_const_pkg.PDS_TAG_1001
                             )
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
    l_stage := 'de111';
    io_fin_rec.de111 := i_mes_rec.de111;

    if io_fin_rec.is_incoming = com_api_const_pkg.TRUE
    then
        begin
            io_fin_rec.inst_id := cmn_api_standard_pkg.find_value_owner(
                                      i_standard_id  => i_standard_id
                                    , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                                    , i_object_id    => i_host_id
                                    , i_param_name   => case
                                                            when io_fin_rec.de094 = nvl(io_fin_rec.de032, io_fin_rec.de033)
                                                            then mcw_api_const_pkg.CMID
                                                            else mcw_api_const_pkg.ACQUIRER_BIN
                                                        end
                                    , i_value_char   => nvl(io_fin_rec.de032, io_fin_rec.de033)
                                    , i_mask_error   => com_api_const_pkg.TRUE
                                    , i_masked_level => trc_config_pkg.DEBUG
                                  );
        exception
            when others then
                if com_api_error_pkg.get_last_error = 'NOT_FOUND_VALUE_OWNER' then
                    io_fin_rec.inst_id := null;
                else
                    raise;
                end if;
        end;
    end if;

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
                                  i_standard_id    => i_standard_id
                                , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                                , i_object_id    => i_host_id
                                , i_param_name   => mcw_api_const_pkg.CMID
                                , i_value_char   => io_fin_rec.de093
                              );
    end if;

    if io_fin_rec.inst_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'MCW_CMID_NOT_REGISTRED'
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
end;

function get_status(
    i_network_id          in com_api_type_pkg.t_tiny_id
  , i_host_id             in com_api_type_pkg.t_tiny_id
  , i_standard_id         in com_api_type_pkg.t_tiny_id
  , i_inst_id             in com_api_type_pkg.t_inst_id
) return  com_api_type_pkg.t_dict_value
is
    l_param_tab                     com_api_type_pkg.t_param_tab;
    l_reconciliation_mode           mcw_api_type_pkg.t_pds_body;
begin
    l_reconciliation_mode := nvl(
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => i_inst_id
          , i_standard_id => i_standard_id
          , i_object_id   => i_host_id
          , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name  => mcw_api_const_pkg.RECONCILIATION_MODE
          , i_param_tab   => l_param_tab
        )
      , mcw_api_const_pkg.RECONCILIATION_MODE_FULL
    );

    return
        case when l_reconciliation_mode = mcw_api_const_pkg.RECONCILIATION_MODE_FULL
             then opr_api_const_pkg.OPERATION_STATUS_WAIT_SETTL
             else null
        end;
end;

procedure create_incoming_first_pres (
    i_mes_rec               in mcw_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , o_fin_ref_id          out com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_local_message       in com_api_type_pkg.t_boolean
    , i_create_operation    in com_api_type_pkg.t_boolean := null
    , i_validate_record     in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_disp_case    in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_rev_reject   in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_fin_rec               mcw_api_type_pkg.t_fin_rec;
    l_pds_tab               mcw_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;

    l_stage                 varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Processing first presentment i_network_id=' || i_network_id || ' i_create_disp_case=' || i_create_disp_case
    );

    l_stage := 'Init';
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
    l_fin_rec.local_message   := i_local_message;

    l_stage := 'mti & de024';
    l_fin_rec.mti := i_mes_rec.mti;
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

    mcw_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    --assign_original_transaction(fin_rec);

    put_message (
        i_fin_rec   => l_fin_rec
    );

    mcw_api_pds_pkg.save_pds (
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
          , i_create_disp_case    => i_create_disp_case
        );
    end if;

    --validate record and save MasterCard rejected codes
    if i_validate_record = com_api_const_pkg.TRUE
    then
        mcw_api_reject_pkg.validate_mcw_record_auth(
            i_oper_id           => l_fin_rec.id
          , i_mes_rec           => i_mes_rec
          , i_pds_tab           => l_pds_tab
          , i_create_rev_reject => i_create_rev_reject
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
end;

procedure create_incoming_second_pres (
    i_mes_rec               in mcw_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , o_fin_ref_id          out com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_local_message       in com_api_type_pkg.t_boolean
    , i_create_operation    in com_api_type_pkg.t_boolean := null
    , i_validate_record     in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_disp_case    in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_rev_reject   in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_fin_rec               mcw_api_type_pkg.t_fin_rec;
    l_pds_tab               mcw_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;

    l_stage                 varchar2(100);
    l_msg_type              com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text         => 'Processing second presentment'
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
    l_fin_rec.local_message   := i_local_message;

    l_stage := 'mti & de024';
    l_fin_rec.mti := i_mes_rec.mti;
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

    mcw_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    mcw_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    o_fin_ref_id := l_fin_rec.id;

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        create_operation (
            i_fin_rec              => l_fin_rec
            , i_standard_id        => i_standard_id
            , i_auth               => l_auth
            , i_incom_sess_file_id => i_incom_sess_file_id
            , i_create_disp_case   => i_create_disp_case
            , o_msg_type           => l_msg_type
        );
    end if;

    -- validate record and save MasterCard rejected codes
    if i_validate_record = com_api_const_pkg.TRUE
    then
        mcw_api_reject_pkg.validate_mcw_record_auth(
            i_oper_id           => l_fin_rec.id
          , i_mes_rec           => i_mes_rec
          , i_pds_tab           => l_pds_tab
          , i_create_rev_reject => i_create_rev_reject
        );
    end if;
    
    if i_create_disp_case = com_api_const_pkg.TRUE then
        mcw_api_dispute_pkg.change_case_status(
            i_dispute_id     => l_fin_rec.dispute_id
          , i_mti            => l_fin_rec.mti
          , i_de024          => l_fin_rec.de024
          , i_is_reversal    => l_fin_rec.is_reversal
          , i_reason_code    => l_fin_rec.de025
          , i_msg_status     => net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
          , i_msg_type       => l_msg_type
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
    i_mes_rec               in mcw_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_local_message       in com_api_type_pkg.t_boolean
    , i_create_operation    in com_api_type_pkg.t_boolean := null
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_disp_case    in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               mcw_api_type_pkg.t_fin_rec;
    l_pds_tab               mcw_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;

    l_stage                 varchar2(100);
    l_msg_type              com_api_type_pkg.t_dict_value;
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
    l_fin_rec.local_message   := i_local_message;

    l_stage := 'mti & de024';
    l_fin_rec.mti := i_mes_rec.mti;
    l_fin_rec.de024 := i_mes_rec.de024;
    l_fin_rec.de004 := i_mes_rec.de004;
    l_fin_rec.de049 := i_mes_rec.de049;

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

    mcw_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    mcw_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        create_operation (
            i_fin_rec              => l_fin_rec
            , i_standard_id        => i_standard_id
            , i_auth               => l_auth
            , i_incom_sess_file_id => i_incom_sess_file_id
            , i_create_disp_case   => i_create_disp_case
            , o_msg_type           => l_msg_type
        );
    end if;
    
    if i_create_disp_case = com_api_const_pkg.TRUE then
        mcw_api_dispute_pkg.change_case_status(
            i_dispute_id     => l_fin_rec.dispute_id
          , i_mti            => l_fin_rec.mti
          , i_de024          => l_fin_rec.de024
          , i_is_reversal    => l_fin_rec.is_reversal
          , i_reason_code    => l_fin_rec.de025
          , i_msg_status     => net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
          , i_msg_type       => l_msg_type
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
end;

procedure create_incoming_req_acknowl (
    i_mes_rec               in mcw_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_local_message       in com_api_type_pkg.t_boolean
    , i_create_operation    in com_api_type_pkg.t_boolean
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_disp_case    in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               mcw_api_type_pkg.t_fin_rec;
    l_pds_tab               mcw_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;

    l_stage                 varchar2(100);
    l_msg_type              com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text         => 'Processing retrieval request acknowledgement'
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
    l_fin_rec.local_message   := i_local_message;

    l_stage := 'mti & de024';
    l_fin_rec.mti := i_mes_rec.mti;
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

    mcw_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    mcw_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        create_operation (
            i_fin_rec              => l_fin_rec
            , i_standard_id        => i_standard_id
            , i_auth               => l_auth
            , i_incom_sess_file_id => i_incom_sess_file_id
            , i_create_disp_case   => i_create_disp_case
            , o_msg_type           => l_msg_type
        );
    end if;
    
    if i_create_disp_case = com_api_const_pkg.TRUE then
        mcw_api_dispute_pkg.change_case_status(
            i_dispute_id     => l_fin_rec.dispute_id
          , i_mti            => l_fin_rec.mti
          , i_de024          => l_fin_rec.de024
          , i_is_reversal    => l_fin_rec.is_reversal
          , i_reason_code    => l_fin_rec.de025
          , i_msg_status     => net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
          , i_msg_type       => l_msg_type
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'Incoming retrieval request acknowledgement processed. Assigned id[#1]'
        , i_env_param1 => l_fin_rec.id
    );

exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating IPM retrieval request acknowledgement on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end;

procedure create_incoming_chargeback (
    i_mes_rec               in mcw_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_local_message       in com_api_type_pkg.t_boolean
    , i_create_operation    in com_api_type_pkg.t_boolean := null
    , i_validate_record     in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_disp_case    in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_rev_reject   in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_fin_rec               mcw_api_type_pkg.t_fin_rec;
    l_pds_tab               mcw_api_type_pkg.t_pds_tab;
    l_auth                  aut_api_type_pkg.t_auth_rec;

    l_stage                 varchar2(100);
    l_msg_type              com_api_type_pkg.t_dict_value;
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
    l_fin_rec.local_message   := i_local_message;

    l_stage := 'mti & de024';
    l_fin_rec.mti := i_mes_rec.mti;
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

    l_stage := 'assign dispute';
    mcw_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    mcw_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        create_operation (
            i_fin_rec              => l_fin_rec
            , i_standard_id        => i_standard_id
            , i_auth               => l_auth
            , i_incom_sess_file_id => i_incom_sess_file_id
            , i_create_disp_case   => i_create_disp_case
            , o_msg_type           => l_msg_type
        );
    end if;

    --validate record and save MasterCard rejected codes
    if i_validate_record = com_api_const_pkg.TRUE
    then
        mcw_api_reject_pkg.validate_mcw_record_auth(
            i_oper_id           => l_fin_rec.id
          , i_mes_rec           => i_mes_rec
          , i_pds_tab           => l_pds_tab
          , i_create_rev_reject => i_create_rev_reject
        );
    end if;
    
    if i_create_disp_case = com_api_const_pkg.TRUE then
        mcw_api_dispute_pkg.change_case_status(
            i_dispute_id     => l_fin_rec.dispute_id
          , i_mti            => l_fin_rec.mti
          , i_de024          => l_fin_rec.de024
          , i_is_reversal    => l_fin_rec.is_reversal
          , i_reason_code    => l_fin_rec.de025
          , i_msg_status     => net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
          , i_msg_type       => l_msg_type
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
end;

procedure create_incoming_fee (
    i_mes_rec               in mcw_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_local_message       in com_api_type_pkg.t_boolean
    , i_create_operation    in com_api_type_pkg.t_boolean := null
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_disp_case    in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_rec               mcw_api_type_pkg.t_fin_rec;
    l_pds_tab               mcw_api_type_pkg.t_pds_tab;
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
    l_fin_rec.local_message   := i_local_message;

    l_stage := 'mti & de024';
    l_fin_rec.mti := i_mes_rec.mti;
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

    mcw_api_dispute_pkg.assign_dispute_id (
        io_fin_rec      => l_fin_rec
        , o_auth        => l_auth
        , i_need_repeat => i_need_repeat
    );

    put_message (
        i_fin_rec   => l_fin_rec
    );

    mcw_api_pds_pkg.save_pds (
        i_msg_id     => l_fin_rec.id
        , i_pds_tab  => l_pds_tab
    );

    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        create_operation (
            i_fin_rec              => l_fin_rec
            , i_standard_id        => i_standard_id
            , i_auth               => l_auth
            , i_incom_sess_file_id => i_incom_sess_file_id
            , i_create_disp_case   => i_create_disp_case
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
end;

procedure put_fraud(
    i_fraud_rec         in mcw_api_type_pkg.t_fraud_rec
  , i_id                in com_api_type_pkg.t_long_id       default null
) is
    l_id                    com_api_type_pkg.t_long_id;
begin
    if i_id is null then
      l_id := nvl(i_fraud_rec.id, opr_api_create_pkg.get_id);
    else
        l_id := i_id;
    end if;

    insert into mcw_fraud (
        id
      , file_id
      , is_incoming
      , is_rejected
      , dispute_id
      , status
      , c01
      , c02
      , c03
      , c04
      , c05
      , c06
      , c07
      , c08_10
      , c09
      , c11
      , c12
      , c13
      , c14
      , c15
      , c16
      , c17
      , c18
      , c19
      , c20
      , c21
      , c22
      , c23
      , c24
      , c25
      , c26
      , c27
      , c28
      , c29
      , c30
      , c31
      , c32
      , c33
      , c34
      , c35
      , c36
      , c37
      , c39
      , c44
      , c45
      , c46
      , c47
      , c48
      , format
      , inst_id
      , ext_claim_id
      , ext_message_id
    )
    values (
        l_id
      , i_fraud_rec.file_id
      , i_fraud_rec.is_incoming
      , i_fraud_rec.is_rejected
      , i_fraud_rec.dispute_id
      , i_fraud_rec.status
      , i_fraud_rec.c01
      , i_fraud_rec.c02
      , i_fraud_rec.c03
      , i_fraud_rec.c04
      , i_fraud_rec.c05
      , i_fraud_rec.c06
      , i_fraud_rec.c07
      , i_fraud_rec.c08_10
      , i_fraud_rec.c09
      , i_fraud_rec.c11
      , i_fraud_rec.c12
      , i_fraud_rec.c13
      , i_fraud_rec.c14
      , i_fraud_rec.c15
      , i_fraud_rec.c16
      , i_fraud_rec.c17
      , i_fraud_rec.c18
      , i_fraud_rec.c19
      , i_fraud_rec.c20
      , i_fraud_rec.c21
      , i_fraud_rec.c22
      , i_fraud_rec.c23
      , i_fraud_rec.c24
      , i_fraud_rec.c25
      , i_fraud_rec.c26
      , i_fraud_rec.c27
      , i_fraud_rec.c28
      , i_fraud_rec.c29
      , i_fraud_rec.c30
      , i_fraud_rec.c31
      , i_fraud_rec.c32
      , i_fraud_rec.c33
      , i_fraud_rec.c34
      , i_fraud_rec.c35
      , i_fraud_rec.c36
      , i_fraud_rec.c37
      , i_fraud_rec.c39
      , i_fraud_rec.c44
      , i_fraud_rec.c45
      , i_fraud_rec.c46
      , i_fraud_rec.c47
      , i_fraud_rec.c48
      , i_fraud_rec.format
      , i_fraud_rec.inst_id
      , i_fraud_rec.ext_claim_id
      , i_fraud_rec.ext_message_id
    );

    trc_log_pkg.debug(
        i_text        => 'flush_messages: implemented [#1] MasterCard fraud messages'
      , i_env_param1  => l_id
    );
end;

function is_collection_allow (
    i_card_num    in     com_api_type_pkg.t_card_number
  , i_network_id  in     com_api_type_pkg.t_tiny_id
  , i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_card_type   in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_boolean is
    l_return com_api_type_pkg.t_boolean;
    l_host_id            com_api_type_pkg.t_tiny_id;
    l_standard_id        com_api_type_pkg.t_tiny_id;
    l_param_tab          com_api_type_pkg.t_param_tab;
    l_network_card_type  com_api_type_pkg.t_dict_tab;
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
        , i_param_name   => mcw_api_const_pkg.COLLECTION_ONLY
        , o_param_value  => l_return
        , i_param_tab    => l_param_tab
    );

    if l_return = com_api_const_pkg.TRUE then

        l_return := com_api_const_pkg.FALSE;

        l_network_card_type := net_api_map_pkg.get_network_card_type_list(i_card_type_id => i_card_type);

        if l_network_card_type.count() > 0 then
            for i in l_network_card_type.first..l_network_card_type.last
            loop
                if  l_network_card_type(i) like mcw_api_const_pkg.BRAND_DEBIT
                 or l_network_card_type(i) like mcw_api_const_pkg.BRAND_CREDIT
                 or l_network_card_type(i) like mcw_api_const_pkg.BRAND_PRIVATE
                 or l_network_card_type(i) like mcw_api_const_pkg.BRAND_MAESTRO then
                    l_return := com_api_const_pkg.TRUE;
                    exit;
                end if;
            end loop;
        end if;
        
        if l_return = com_api_const_pkg.FALSE then
            trc_log_pkg.debug(
                i_text        => 'Brand not available for card type #1'
              , i_env_param1  => i_card_type
            );
        end if;

    else
        l_return := com_api_const_pkg.FALSE;
    end if;
    
    trc_log_pkg.debug(
        i_text        => 'Collection #1'
      , i_env_param1  => case when l_return = com_api_type_pkg.TRUE then 'allowed' else 'not allowed' end
    );

    return l_return;
end;

procedure get_card_brand (
    i_card_number           in com_api_type_pkg.t_card_number
    , o_brand               out com_api_type_pkg.t_curr_code
) is
    l_card_num_str          com_api_type_pkg.t_card_number;
    l_pan_low               com_api_type_pkg.t_card_number;
begin
    l_card_num_str := substr(i_card_number, 1, 5);

    select max(brand) keep (dense_rank first order by priority),
           max(pan_low) keep (dense_rank first order by priority)
      into o_brand,
           l_pan_low
      from mcw_bin_range
     where pan_low like l_card_num_str || '%'
       and i_card_number between pan_low and pan_high;

    if l_pan_low is null then
        com_api_error_pkg.raise_error (
            i_error         => 'BIN_NOT_FOUND_BY_CARD_NUMBER'
            , i_env_param1  => iss_api_card_pkg.get_card_mask(i_card_number)
            , i_env_param2  => l_card_num_str
        );
    end if;
end;

function get_acq_member (
    i_acq_bin               in mcw_api_type_pkg.t_de031
) return com_api_type_pkg.t_medium_id is
    l_result com_api_type_pkg.t_medium_id;
begin
    select to_number(ltrim(mab.member_id, '0'))
      into l_result
      from mcw_acq_bin mab
     where mab.acq_bin = i_acq_bin
       and rownum = 1;

    return l_result;
exception
    when others then
        return null;
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

function is_mastercard (
    i_id                      in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_result                  com_api_type_pkg.t_boolean;
begin
    select count(1)
      into l_result
      from mcw_fin
     where id = i_id
       and rownum <= 1;

    return l_result;
end;

/*
 * Remove message and related operation
 */ 
procedure remove_message(
    i_id                      in     com_api_type_pkg.t_long_id
  , i_force                   in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) is
begin
    delete 
      from mcw_fin
     where id = i_id;
    if sql%rowcount = 0 and i_force = com_api_type_pkg.FALSE then
        trc_log_pkg.debug(
            i_text       => 'Remove mcw message: [#1] is not found'
          , i_env_param1 => i_id
        );
    else
        opr_api_operation_pkg.remove_operation(
            i_oper_id => i_id
        );
    end if;
end;

/*
 * Check if editable
 */ 
function is_editable(
    i_id              in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_result    com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    for r in (
        select id
          from mcw_fin
         where id          = i_id
           and is_incoming = com_api_const_pkg.FALSE
           and status      = net_api_const_pkg.CLEARING_MSG_STATUS_READY
           and rownum      = 1
    )
    loop
        l_result := com_api_const_pkg.TRUE;
        exit;
    end loop;

    return l_result;
end is_editable;

function is_doc_export_import_enabled(
    i_id              in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_result    com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    select count(1)
      into l_result
      from mcw_fin
     where id = i_id
           and (
                  (mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
             and de024 = mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST)
               or (mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
             and de024 in (mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
                         , mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_PART))
               or (mti = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
             and de024 in (mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                         , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                         , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
                         , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART))
               );

    return l_result;
end is_doc_export_import_enabled;

end mcw_api_fin_pkg;
/

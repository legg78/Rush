create or replace package body mcw_api_ird_pkg is
-- MC Regions
-- 1  United States
-- A  Canada
-- B  Latin America and Caribbean
-- C  Asia/Pacific
-- D  Europe
-- E  Middle East/Africa (MEA)

--20
    function interregional_20 (
        i_brand            in     com_api_type_pkg.t_dict_value
      , i_product_id       in     com_api_type_pkg.t_dict_value
      , i_acquiring_region in     com_api_type_pkg.t_dict_value
      , i_issuer_region    in     com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCT', 'MCV', 'MCW', 'MIU', 'MNW', 'MPL'
                                                       , 'MRC', 'MRG', 'MWE', 'SUR')
              or i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MDW', 'MHA', 'MHB'
                                                       , 'MHD', 'MHH', 'MHL', 'MHM', 'MHN', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG'
                                                       , 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ'
                                                       , 'MRH', 'MET', 'MRD', 'MGS'))
            or
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and (i_brand in ('MCC') and i_product_id in ('MBK', 'MCC', 'MCG', 'MCS', 'MCV', 'MCW', 'MIU', 'MNW', 'MPL', 'MRG'
                                                       , 'MWE', 'SUR', 'MPD')
              or i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MHA', 'MHB', 'MHH', 'MIA', 'MIP', 'MDO', 'MDP'
                                                       , 'MDR', 'MDS', 'MPA', 'MPF', 'MPG', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR'
                                                       , 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ'))
            or
            i_acquiring_region in ('C', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCH', 'MCS', 'MCV', 'MCW', 'MIU', 'MNW', 'MPL'
                                                       , 'MRF', 'MRG', 'MRJ', 'MRO', 'MRP', 'MTP', 'MUW', 'MWD', 'MWR'
                                                       , 'SAG', 'SAS', 'SAP', 'SOS', 'TCC', 'TCG', 'TCS', 'TCW', 'TNW'
                                                       , 'TPL', 'WBE', 'SUR')
              or i_brand in ('DMC') and i_product_id in ('DAG', 'DAP', 'DAS', 'DLG', 'DLH', 'DLP', 'DLS', 'DOS', 'MDG'
                                                       , 'MDH', 'MDP', 'MDS', 'MHA', 'MHB', 'MHH', 'MIA', 'MIP', 'MPA'
                                                       , 'MPF', 'MPG', 'MPJ', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT'
                                                       , 'MPV', 'MPX', 'MPY', 'MPZ'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCH', 'MCS', 'MCV', 'MCW', 'MIU', 'MNW', 'MPL'
                                                       , 'MRF', 'MRG', 'MRJ', 'MRO', 'MRP', 'MTP', 'MUW', 'MWD', 'MWR'
                                                       , 'SAG', 'SAS', 'SAP', 'SOS', 'TCC', 'TCG', 'TCS', 'TCW', 'TNW'
                                                       , 'TPL', 'WBE', 'SUR')
              or i_brand in ('DMC') and i_product_id in ('DAG', 'DAP', 'DAS', 'DLG', 'DLH', 'DLP', 'DLS', 'DOS', 'MDG'
                                                       , 'MDH', 'MDP', 'MDS', 'MDW', 'MHA', 'MHB', 'MHH', 'MIA', 'MIP'
                                                       , 'MPA', 'MPF', 'MPG', 'MPJ', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR'
                                                       , 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ'))
            or
            i_acquiring_region in ('C', 'A', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MBK', 'MCC', 'MCG', 'MCS', 'MCV', 'MCW', 'MIU', 'MNW', 'MPL'
                                                       , 'MRG', 'MTP', 'MWE', 'SUR', 'MGP')
              or i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MDW', 'MHA'
                                                       , 'MHB', 'MHH', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MPM', 'MPN'
                                                       , 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ', 'MRH'))
            or
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCT', 'MCV', 'MCW', 'MIU', 'MPL'
                                                       , 'MRC', 'MRG', 'MWE', 'SUR', 'MWP', 'MGP')
              or i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MDW', 'MHA'
                                                       , 'MHB', 'MHD', 'MHH', 'MHL', 'MHM', 'MHN', 'MIA', 'MIP', 'MPA'
                                                       , 'MPF', 'MPG', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV'
                                                       , 'MPX', 'MPY', 'MPZ', 'MRH', 'MET', 'WPD'))
            or
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MBK', 'MCC', 'MCG', 'MCS', 'MCV', 'MCW', 'MFB', 'MFD', 'MFE'
                                                       , 'MFH', 'MFL', 'MFW', 'MIU', 'MNW', 'MPL', 'MRG', 'MWE', 'SUR')
              or i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDJ', 'MDO', 'MDP', 'MDR', 'MDS', 'MHA'
                                                       , 'MHB', 'MHH', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MPM', 'MPN'
                                                       , 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ', 'MRH'))
        then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--21
    function interregional_21 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if  i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MAB', 'MBD', 'MCB', 'MCF', 'MCO', 'MCP', 'MDB', 'MEB', 'MEO', 'MNF'
                                                       , 'MPW', 'MRW', 'MWB', 'MES')
                 or
                 i_brand in ('DMC') and i_product_id in ('MBP', 'MBT', 'MDT'))
            or
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and (i_brand in ('MCC') and i_product_id in ('MAB', 'MAC', 'MBD', 'MCB', 'MCF', 'MCO', 'MCP', 'MDB', 'MDL', 'MEB'
                                                       , 'MEO', 'MGF', 'MNF', 'MPB', 'MPK', 'MPW', 'MRW', 'MWB', 'MWO', 'MES')
                 or
                 i_brand in ('DMC'))
            or
            i_acquiring_region in ('C', 'A', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC')
                 and (i_product_id in ('MBD', 'MCB', 'MEB', 'MEO', 'MCF', 'MCO', 'MCP', 'MDB', 'MNF', 'MPB'
                                     , 'MPW', 'MRK', 'MRW', 'TCB', 'TCF', 'TCO', 'TCP', 'TEB', 'TEO', 'TNF'
                                     , 'TPB', 'MRL', 'MES')
                      or
                      -- Products below aren't available for the case when issuer is Europe and acquirer is USA:
                      i_acquiring_region not in ('1') and i_product_id in ('MRF')
                 )
                 or
                 i_brand in ('DMC') and i_product_id in ('MDT', 'BPD', 'MBP'))
            or
            i_acquiring_region in ('C', 'A', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MAB', 'MAC', 'MBD', 'MCB', 'MCF', 'MCO', 'MCP', 'MDB', 'MDL', 'MEB'
                                                       , 'MEO', 'MGF', 'MNF', 'MPB', 'MPK', 'MPW', 'MRW', 'MWB', 'MWO', 'MES')
                 or
                 i_brand in ('DMC'))
            or
            i_acquiring_region in ('C', 'A', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MAB', 'MBD', 'MCB', 'MCF', 'MCO', 'MCP', 'MDB', 'MEB', 'MEO', 'MNF'
                                                       , 'MPW', 'MRW', 'MWB', 'MES')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDT'))
            or
            i_acquiring_region in ('D')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MAB', 'MBD', 'MCB', 'MCF', 'MCO', 'MCP', 'MDB', 'MEB', 'MEO', 'MNF'
                                                       , 'MPW', 'MRW', 'MWB', 'MWP', 'MES')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDT', 'WPD'))
            or
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MAB', 'MAC', 'MBD', 'MCB', 'MCF', 'MCO', 'MCP', 'MDB', 'MDL', 'MEB'
                                                       , 'MEO', 'MGF', 'MNF', 'MPB', 'MPK', 'MPW', 'MRW', 'MWB', 'MWO', 'MES')
                 or i_brand in ('DMC'))
        then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--24
    function interregional_24 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCS', 'MCV', 'MIU', 'MRG', 'SUR'))
              or (i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDS', 'MPG', 'MPP', 'MHA', 'MHB', 'MHH', 'MIA', 'MIP'
                                                        , 'MPA', 'MPF', 'MPG', 'MPM', 'MPN', 'MPO', 'MPR', 'MPT', 'MPV', 'MPX'
                                                        , 'MPY', 'MPZ', 'ACS')))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCS', 'MCV', 'MIU', 'MPL', 'MRG', 'SUR', 'MPD'))
              or (i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MHA', 'MHB', 'MHH'
                                                        , 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR'
                                                        , 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ', 'ACS')))
            ) or (
            i_acquiring_region in ('C', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCH', 'MCS', 'MCV', 'MIU', 'MRF', 'MRG', 'MRJ', 'MRO'
                                                        , 'MRP', 'SAG', 'SAS', 'SOS', 'SUR', 'TCC', 'TCG', 'TCS'))
              or (i_brand in ('DMC') and i_product_id in ('DAG', 'DAS', 'DLG', 'DLH', 'DLP', 'DLS', 'DOS', 'MCD', 'MDG', 'MDS'
                                                        , 'MHA', 'MHB', 'MHH', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MPJ', 'MPM'
                                                        , 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ', 'ACS')))
            ) or (
            i_acquiring_region in ('A')
            and i_issuer_region in ('D')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCH', 'MCS', 'MCV', 'MIU', 'MRF', 'MRG', 'MRJ', 'MRO'
                                                        , 'MRP', 'SAG', 'SAP', 'SAS', 'SOS', 'SUR', 'TCC', 'TCG', 'TCS', 'TPL'))
              or (i_brand in ('DMC') and i_product_id in ('DAG', 'DAP', 'DAS', 'DLG', 'DLH', 'DLP', 'DLS', 'DOS', 'MCD', 'MDG'
                                                        , 'MDH', 'MDP', 'MDS', 'MDW', 'MHA', 'MHB', 'MHH', 'MIA', 'MIP', 'MPA'
                                                        , 'MPF', 'MPG', 'MPJ', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV'
                                                        , 'MPX', 'MPY', 'MPZ', 'ACS' )))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCD', 'MCG', 'MCS', 'MCV', 'MIU', 'MRG', 'SUR', 'MGP'))
              or (i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDO', 'MDS', 'MHA', 'MHB', 'MHH', 'MIA', 'MIP', 'MPA'
                                                        , 'MPF', 'MPG', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX'
                                                        , 'MPY', 'MPZ', 'ACS')))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCS', 'MCV', 'MIU', 'MRG', 'SUR', 'MGP'))
              or (i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDS', 'MHA', 'MHB', 'MHH', 'MIA', 'MIP', 'MPA', 'MPF'
                                                        , 'MPG', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY'
                                                        , 'MPZ', 'ACS')))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCS', 'MCV', 'MFD', 'MFL', 'MIU', 'MPL', 'SUR'))
              or (i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDJ', 'MDO', 'MDP', 'MDS', 'MHA', 'MHB', 'MHH', 'MIA'
                                                        , 'MIP', 'MPG', 'MPA', 'MPF', 'MPG', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR'
                                                        , 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ', 'ACS')))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--2A
    function interregional_2A (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if  i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCT', 'MCV', 'MCW', 'MIU', 'MPL', 'MRC'
                                                       , 'MRG', 'MWE', 'SUR', 'MAB', 'MBD', 'MCB', 'MCF', 'MCO', 'MCP', 'MDB'
                                                       , 'MEB', 'MEO', 'MLA', 'MNF', 'MPW', 'MRW', 'MWB', 'MES', 'MGS')
                 or
                 i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MDW', 'MHA', 'MHB'
                                                       , 'MHD', 'MHH', 'MHL', 'MHM', 'MHN', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG'
                                                       , 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ'
                                                       , 'MRH', 'BPD', 'MBP', 'MBT', 'MDT', 'MET', 'MRD'))
            or
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCT', 'MCV', 'MCW', 'MIU', 'MPL', 'MRC'
                                                       , 'MRG', 'MWE', 'SUR', 'MBD', 'MCB', 'MCF', 'MCO', 'MCP', 'MDB', 'MEB'
                                                       , 'MEO', 'MLA', 'MNF', 'MPW', 'MRW', 'MWB', 'MPD', 'MES')
                 or
                 i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDO', 'MDP', 'MDR', 'MDS', 'MHA', 'MHB', 'MHD', 'MHH'
                                                       , 'MHL', 'MHM', 'MHN', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MPM', 'MPN'
                                                       , 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ'))
            or
            i_acquiring_region in ('C', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCH', 'MCS', 'MCT', 'MCV', 'MCW', 'MIU', 'MNW'
                                                       , 'MPL', 'MRC', 'MRF', 'MRG', 'MRJ', 'MRO', 'MRP', 'MTP', 'MUW', 'MWD'
                                                       , 'MWR', 'SAG', 'SAP', 'SAS', 'SOS', 'SUR', 'TCC', 'TCE', 'TCG', 'TCS'
                                                       , 'TCW', 'TNW', 'TPL', 'TWB', 'WBE', 'MBD', 'MCB', 'MEB', 'MEO', 'MCF'
                                                       , 'MCO', 'MCP', 'MDB', 'MLA', 'MNF', 'MPB', 'MPW', 'MRK', 'MRW', 'MWB'
                                                       , 'TCB', 'TCF', 'TCO', 'TCP', 'TEB', 'TEO', 'TNF', 'TPB', 'MRL', 'MES')
                 or
                 i_brand in ('DMC') and i_product_id in ('DAG', 'DAP', 'DAS', 'DLG', 'DLH', 'DLP', 'DLS', 'DOS', 'MBW', 'MCD'
                                                       , 'MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MHA', 'MHB', 'MHD', 'MHH'
                                                       , 'MHL', 'MHM', 'MHN', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MPJ', 'MPM'
                                                       , 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ', 'MDT'
                                                       , 'BPD', 'MBP'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCH', 'MCS', 'MCT', 'MCV', 'MCW', 'MIU', 'MNW'
                                                       , 'MPL', 'MRC', 'MRF', 'MRG', 'MRJ', 'MRO', 'MRP', 'MTP', 'MUW', 'MWD'
                                                       , 'MWR', 'SAG', 'SAP', 'SAS', 'SOS', 'SUR', 'TBW', 'TCC', 'TCE', 'TCG'
                                                       , 'TCS', 'TCW', 'TNW', 'TPL', 'WBE', 'MBD', 'MCB', 'MEB', 'MEO', 'MCF'
                                                       , 'MCO', 'MCP', 'MDB', 'MLA', 'MNF', 'MPB', 'MPW', 'MRK', 'MRW', 'MWB'
                                                       , 'TCB', 'TCF', 'TCO', 'TCP', 'TEB', 'TEO', 'TNF', 'TPB', 'MRL', 'MES')
                 or
                 i_brand in ('DMC') and i_product_id in ('DAG', 'DAP', 'DAS', 'DLG', 'DLH', 'DLP', 'DLS', 'DOS', 'MBW', 'MCD'
                                                       , 'MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MDW', 'MHA', 'MHB', 'MHD'
                                                       , 'MHH', 'MHL', 'MHM', 'MHN', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MPJ'
                                                       , 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ'
                                                       , 'MDT', 'BPD', 'MBP'))
            or
            i_acquiring_region in ('C', 'A', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MBK', 'MCC', 'MCE', 'MCG', 'MCS', 'MCT', 'MCV', 'MCW', 'MIU', 'MPL'
                                                       , 'MRC', 'MRG', 'MTP', 'MWE', 'SUR', 'MAB', 'MBD', 'MCB', 'MCF', 'MCO'
                                                       , 'MCP', 'MDB', 'MEB', 'MEO', 'MLA', 'MLD', 'MLL', 'MNF', 'MPW', 'MRW'
                                                       , 'MWB', 'MES', 'MGP')
                 or
                 i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDO', 'MDP', 'MDR', 'MDS', 'MDW', 'MHA', 'MHB', 'MHD'
                                                       , 'MHH', 'MHL', 'MHM', 'MHN', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MPM'
                                                       , 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ'))
            or
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCT', 'MCV', 'MCW', 'MIU', 'MPL', 'MRC'
                                                       , 'MRG', 'MWE', 'SUR', 'MAB', 'MBD', 'MCB', 'MCF', 'MCO', 'MCP', 'MDB'
                                                       , 'MEB', 'MEO', 'MLA', 'MNF', 'MPW', 'MRW', 'MWB', 'MWP', 'MES'
                                                       , 'MGP')
                 or
                 i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MDW', 'MHA', 'MHB'
                                                       , 'MHD', 'MHH', 'MHL', 'MHM', 'MHN', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG'
                                                       , 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ'
                                                       , 'MRH', 'MDT', 'MET', 'WPD'))
            or
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCT', 'MCV', 'MCW', 'MFB', 'MFD', 'MFE'
                                                       , 'MFH', 'MFL', 'MFW', 'MIU', 'MPL', 'MRC', 'MRG', 'MWE', 'SUR', 'MAB'
                                                       , 'MAC', 'MBD', 'MCB', 'MCF', 'MCO', 'MCP', 'MDB', 'MDL', 'MEB', 'MEO'
                                                       , 'MGF', 'MLA', 'MNF', 'MPK', 'MPW', 'MRW', 'MWB', 'MWO', 'MES')
                 or
                 i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDJ', 'MDO', 'MDP', 'MDR', 'MDS', 'MHA', 'MHD'
                                                       , 'MHB', 'MHH', 'MHL', 'MHM', 'MHN', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG'
                                                       , 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ'
                                                       , 'MRH'))
        then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--51-52
    function interregional_51_52(
        i_brand              in com_api_type_pkg.t_dict_value
      , i_product_id         in com_api_type_pkg.t_dict_value
      , i_acquiring_region   in com_api_type_pkg.t_dict_value
      , i_issuer_region      in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        return
        case
            when i_acquiring_region in ('D')
                 and (i_brand in ('MCC', 'DMC', 'MSI', 'CIR')
                 and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCW', 'MIU', 'MNW', 'MPL', 'MRC'
                                    , 'MRG', 'MRJ', 'MRO', 'MTP', 'MWE', 'SAG', 'SAP', 'SAS', 'SOS'
                                    , 'SUR', 'TCC', 'TCE', 'TCG', 'TCS', 'TCW', 'TNW', 'TPL', 'TWB'
                                    , 'WBE', 'DAG', 'DAP', 'DAS', 'DLG', 'DLH', 'DLP', 'DLS', 'DOS'
                                    , 'MBW', 'MDG', 'MDH', 'MDJ', 'MDP', 'MDS', 'MDW', 'MHB', 'MHH'
                                    , 'MPG', 'MPJ', 'MPP', 'MRH', 'MAB', 'MBE', 'MCB', 'MCF', 'MCO'
                                    , 'MCP', 'MEB', 'MEC', 'MEO', 'MLA', 'MLD', 'MLL', 'MRK', 'MRW'
                                    , 'TBE', 'TCB', 'TCF', 'TCO', 'TCP', 'TEB', 'TEC', 'TEO', 'TNF'
                                    , 'BPD', 'MDT', 'MOC', 'MOG', 'MOP', 'MSA', 'MSB', 'MSF', 'MSG'
                                    , 'MSI', 'MSJ', 'MSM', 'MSN', 'MSO', 'MSQ', 'MSR', 'MST', 'MSV'
                                    , 'MSW', 'MSX', 'MSY', 'MSZ', 'OLG', 'OLP', 'SAL', 'CIR', 'MET')
                 )
              or i_acquiring_region in ('D')
                 and i_issuer_region in ('B')
                 and (i_brand || '/' || i_product_id in ('MCC/MGP')
                 )
              or i_acquiring_region in ('D')
                 and i_issuer_region in ('E')
                 and (i_brand || '/' || i_product_id in ('MCC/MWP', 'MCC/WPD', 'MCC/MGP', 'DMC/MWP', 'DMC/WPD')
                 )
              or i_acquiring_region in ('D')
                 and i_issuer_region in ('C')
                 and (i_brand in ('MCC') and i_product_id in ('MGS')
                   or i_brand in ('DMC') and i_product_id in ('MRD')
                 )
              or i_acquiring_region in ('E', '1')
                 and i_issuer_region in ('D')
                 and i_brand in ('DMC') and i_product_id in ('MBP', 'MET')
            then com_api_type_pkg.TRUE
            else com_api_type_pkg.FALSE 
        end;
    end interregional_51_52;

----
--A1, A3, A5; A2, A4, A6
    function interregional_ax_tier(
        i_brand              in com_api_type_pkg.t_dict_value
      , i_product_id         in com_api_type_pkg.t_dict_value
      , i_acquiring_region   in com_api_type_pkg.t_dict_value
      , i_issuer_region      in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        return
        case
            when i_acquiring_region in ('D')
                 and i_brand in ('MCC', 'DMC', 'MSI', 'CIR')
                 and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCW', 'MIU', 'MNW', 'MPL', 'MRC'
                                    , 'MRG', 'MRJ', 'MRO', 'MTP', 'MWE', 'SAG', 'SAP', 'SAS', 'SOS'
                                    , 'SUR', 'TCC', 'TCE', 'TCG', 'TCS', 'TCW', 'TNW', 'TPL', 'WBE'
                                    , 'DAG', 'DAP', 'DAS', 'DLG', 'DLH', 'DLP', 'DLS', 'DOS', 'MDG'
                                    , 'MDH', 'MDP', 'MDS', 'MDW', 'MHB', 'MHH', 'MDJ', 'MPG', 'MPJ'
                                    , 'MPP', 'MRH', 'MAB', 'MBE', 'MCB', 'MCF', 'MCO', 'MCP', 'MEB'
                                    , 'MEC', 'MEO', 'MLA', 'MLD', 'MLL', 'MRK', 'MRW', 'TBE', 'TCB'
                                    , 'TCF', 'TCO', 'TCP', 'TEB', 'TEC', 'TEO', 'TNF', 'BPD', 'MDT'
                                    , 'MOC', 'MOG', 'MOP', 'MSA', 'MSB', 'MSF', 'MSG', 'MSI', 'MSJ'
                                    , 'MSM', 'MSN', 'MSO', 'MSQ', 'MSR', 'MST', 'MSV', 'MSW', 'MSX'
                                    , 'MSY', 'MSZ', 'OLG', 'OLP', 'SAL', 'CIR', 'MET')
              or i_acquiring_region in ('D')
                 and i_issuer_region in ('E')
                 and (i_brand in ('MCC', 'DMC')
                 and i_product_id in ('MWP', 'WPD')
                 )
              or i_acquiring_region in ('E', '1')
                 and i_issuer_region in ('D')
                 and i_brand in ('DMC') and i_product_id in ('MBP', 'MET')
            then com_api_type_pkg.TRUE
            else com_api_type_pkg.FALSE
        end;
    end interregional_ax_tier;

----
--A5 - Tier 2, A6 - Tier 3
    function interregional_a5_a6_tier(
        i_brand              in com_api_type_pkg.t_dict_value
      , i_product_id         in com_api_type_pkg.t_dict_value
      , i_acquiring_region   in com_api_type_pkg.t_dict_value
      , i_issuer_region      in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        return
        case
            when i_acquiring_region in ('1')
                 and i_issuer_region in ('D')
                 and (i_brand in ('MCC') and i_product_id in ('MPB', 'MRL')
                      or
                      i_brand in ('DMC') and i_product_id in ('BPD', 'MET'))
            then com_api_type_pkg.TRUE
            else com_api_type_pkg.FALSE
        end;
    end interregional_a5_a6_tier;

----
--AS
    function interregional_as(
        i_brand              in com_api_type_pkg.t_dict_value
      , i_product_id         in com_api_type_pkg.t_dict_value
      , i_acquiring_region   in com_api_type_pkg.t_dict_value
      , i_issuer_region      in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        return
        case
            when i_acquiring_region in ('D')
                 and i_brand in ('MCC', 'DMC', 'MSI', 'CIR')
                 and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCW', 'MIU', 'MNW', 'MPL', 'MRC'
                                    , 'MRG', 'MRJ', 'MRO', 'MTP', 'MWE', 'SAG', 'SAP', 'SAS', 'SOS'
                                    , 'SUR', 'TCC', 'TCE', 'TCG', 'TCS', 'TCW', 'TNW', 'TPL', 'WBE'
                                    , 'DAG', 'DAP', 'DAS', 'DLG', 'DLH', 'DLP', 'DLS', 'DOS', 'MCD'
                                    , 'MDG', 'MDH', 'MDJ', 'MDO', 'MDP', 'MDR', 'MDS', 'MDW', 'MHB'
                                    , 'MHH', 'MPG', 'MPJ', 'MPP', 'MRH', 'MAB', 'MAC', 'MCB', 'MCF'
                                    , 'MCO', 'MCP', 'MDL', 'MEB', 'MEO', 'MGF', 'MLA', 'MLD', 'MLL'
                                    , 'MNF', 'MPK', 'MRW', 'MWO', 'TBE', 'TCB', 'TCF', 'TCO', 'TCP'
                                    , 'TEB', 'TEC', 'TEO', 'TNF', 'MDT', 'MOC', 'MOG', 'MOP', 'MSA'
                                    , 'MSB', 'MSF', 'MSG', 'MSI', 'MSJ', 'MSM', 'MSN', 'MSO', 'MSQ'
                                    , 'MSR', 'MST', 'MSV', 'MSW', 'MSX', 'MSY', 'MSZ', 'OLG', 'OLP'
                                    , 'SAL', 'CIR', 'MET')
              or i_acquiring_region in ('D')
                 and i_issuer_region in ('B')
                 and (i_brand in ('MCC') and i_product_id in ('MGP')
                 )
              or i_acquiring_region in ('D')
                 and i_issuer_region in ('E')
                 and (i_brand in ('MCC') and i_product_id in ('MWP', 'WPD', 'MGP')
                    or
                      i_brand in ('DMC') and i_product_id in ('MWP', 'WPD')
                 )
              or i_acquiring_region in ('D')
                 and i_issuer_region in ('C')
                 and (i_brand in ('MCC') and i_product_id in ('MGS')
                      or
                      i_brand in ('DMC') and i_product_id in ('MRD')
                 )
              or i_acquiring_region in ('E')
                 and i_issuer_region in ('D')
                 and (i_brand in ('MCC') and i_product_id in ('MPB', 'MRL')
                      or
                      i_brand in ('DMC') and i_product_id in ('BPD', 'MBP', 'MET')
                     )
            then com_api_type_pkg.TRUE
            else com_api_type_pkg.FALSE
        end;
    end interregional_as;
----
--47
    function interregional_47 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MBE', 'MEC'))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and (i_brand in ('MCC') and i_product_id in ('MBE', 'MEC'))
            ) or (
            i_acquiring_region in ('C', 'A', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MBE', 'MEC', 'TBE', 'TEC'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MBE', 'MEC'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MBE', 'MEC'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MBE', 'MEC'))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--57 Commercial
    function interregional_57_com (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('PVL') and i_product_id in ('PVA', 'PVB', 'PVC', 'PVD', 'PVE', 'PVF', 'PVG', 'PVH', 'PVI', 'PVJ', 'PVL'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('PVL') and i_product_id in ('PVA', 'PVB', 'PVC', 'PVD', 'PVE', 'PVF', 'PVG', 'PVH', 'PVI', 'PVJ', 'PVL'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('PVL') and i_product_id in ('PVA', 'PVB', 'PVC', 'PVD', 'PVE', 'PVF', 'PVG', 'PVH', 'PVI', 'PVJ', 'PVL'))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--57 Consumer
    function interregional_57_con (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('PVL') and i_product_id in ('PVA', 'PVB', 'PVC', 'PVD', 'PVE', 'PVF', 'PVG', 'PVH', 'PVI', 'PVJ', 'PVL'))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and (i_brand in ('PVL') and i_product_id in ('PVA', 'PVB', 'PVC', 'PVD', 'PVE', 'PVF', 'PVG', 'PVH', 'PVI', 'PVJ', 'PVL'))
            ) or (
            i_acquiring_region in ('C', 'A', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and (i_brand in ('PVL') and i_product_id in ('PVA', 'PVB', 'PVC', 'PVD', 'PVE', 'PVF', 'PVG', 'PVH', 'PVI', 'PVJ', 'PVL'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('PVL') and i_product_id in ('PVA', 'PVB', 'PVC', 'PVD', 'PVE', 'PVF', 'PVG', 'PVH', 'PVI', 'PVJ', 'PVL'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('PVL') and i_product_id in ('PVA', 'PVB', 'PVC', 'PVD', 'PVE', 'PVF', 'PVG', 'PVH', 'PVI', 'PVJ', 'PVL'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('PVL') and i_product_id in ('PVA', 'PVB', 'PVC', 'PVD', 'PVE', 'PVF', 'PVG', 'PVH', 'PVI', 'PVJ', 'PVL'))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--61
    function interregional_61 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MBD', 'MCB', 'MCO', 'MDB', 'MEB', 'MEO', 'MPW', 'MRW')
              or i_brand in ('DMC') and i_product_id in ('BPD', 'MBP', 'MBT', 'MDT'))
            ) or (
            i_acquiring_region in ('A')
            and (i_issuer_region in ('C')
                 and (i_brand in ('MCC') and i_product_id in ('MBD', 'MBS', 'MCB', 'MCO', 'MDB', 'MEB', 'MEO', 'MLA', 'MPW', 'MRW')
                   or i_brand in ('DMC') and i_product_id in ('BPD', 'MBP', 'MBT', 'MDT'))
                 or
                 i_issuer_region in ('D')
                 and (i_brand in ('MCC') and i_product_id in ('MBD', 'MBS', 'MCB', 'MCO', 'MDB', 'MEB', 'MEO', 'MLA'
                                                            , 'MPB', 'MPW', 'MRW', 'TCB', 'TCO', 'TEB', 'TEO', 'TPB', 'MRL', 'MRF')
                   or i_brand in ('DMC') and i_product_id in ('MDT', 'BPD', 'MBP'))
                 or
                 i_issuer_region in ('B')
                 and (i_brand in ('MCC') and i_product_id in ('MBD', 'MCB', 'MCO', 'MDB', 'MEB', 'MEO', 'MLA', 'MLD'
                                                            , 'MLL', 'MPW', 'MRW'))
                 or
                 i_issuer_region in ('E')
                 and (i_brand in ('MCC') and i_product_id in ('MBD', 'MCB', 'MCO', 'MDB', 'MEB', 'MEO', 'MLA', 'MPW', 'MRW')
                   or i_brand in ('DMC') and i_product_id in ('MDT'))
                 or
                 i_issuer_region in ('1')
                 and (i_brand in ('MCC') and i_product_id in ('MBD', 'MCB', 'MCO', 'MDB', 'MEB', 'MEO', 'MLA', 'MPW'))
                )
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and ((i_brand in ('MCC') and i_product_id in ('MBD', 'MCB', 'MCO', 'MDB', 'MEB', 'MEO', 'MPW', 'MRW'))
              or (i_brand in ('DMC') and i_product_id in ('MDT')))
            ) or (
            i_acquiring_region in ('C', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and ((i_brand in ('MCC') and i_product_id in ('MBD', 'MCB', 'MCO', 'MDB', 'MEB', 'MEO', 'MPB', 'MRF'
                                                        , 'MPW', 'MRW', 'TCB', 'TCO', 'TEB', 'TEO', 'TPB', 'MRL'))
              or (i_brand in ('DMC') and i_product_id in ('MDT', 'BPD', 'MBP')))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MBD', 'MCB', 'MCO', 'MDB', 'MEB', 'MEO', 'MPW', 'MRW'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and ((i_brand in ('MCC') and i_product_id in ('MBD', 'MCB', 'MCO', 'MDB', 'MEB', 'MEO', 'MPW', 'MRW'))
              or (i_brand in ('DMC') and i_product_id in ('MDT')))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MBD', 'MCB', 'MCO', 'MDB', 'MEB', 'MEO', 'MPW'))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--62
    function interregional_62 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES' ))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES'))
            ) or (
            i_acquiring_region in ('C', 'A', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MNF', 'MRK', 'TCF', 'TCP', 'TNF', 'MES'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES'))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--63
    function interregional_63 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES'))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES'))
            ) or (
            i_acquiring_region in ('C', 'A', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MNF', 'MRK', 'TCF', 'TCP', 'TNF', 'MES'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES'))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--67
    function interregional_67 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES'))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES'))
            ) or (
            i_acquiring_region in ('C', 'A', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MNF', 'MRK', 'TCF', 'TCP', 'TNF', 'MES'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MCF', 'MCP', 'MEF', 'MGF', 'MNF', 'MPK', 'MES'))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--73
    function interregional_73 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCS', 'MCV', 'MHB', 'MHH', 'MIU', 'MRG', 'SUR'))
              or (i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDS', 'MHA', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MPM'
                                                        , 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ', 'ACS')))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCS', 'MCV', 'MHB', 'MHH', 'MIU', 'MPL', 'MRG', 'SUR'
                                                        , 'MPD'))
              or (i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MHA', 'MIA', 'MIP'
                                                        , 'MPA', 'MPF', 'MPG', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV'
                                                        , 'MPX', 'MPY', 'MPZ', 'ACS')))
            ) or (
            i_acquiring_region in ('C', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCH', 'MCS', 'MCV', 'MHB', 'MHH', 'MIU', 'MRF', 'MRG'
                                                        , 'MRJ', 'MRO', 'MRP', 'SAG', 'SAS', 'SOS', 'SUR', 'TCC', 'TCG', 'TCS'))
             and (i_brand in ('DMC') and i_product_id in ('DAG', 'DAS', 'DLG', 'DLH', 'DLP', 'DLS', 'DOS', 'MCD', 'MDG', 'MDS'
                                                        , 'MHA', 'MIA', 'MIP', 'MPA', 'MPG', 'MPJ', 'MPF', 'MPM', 'MPN', 'MPO'
                                                        , 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ', 'ACS')))
            ) or (
            i_acquiring_region in ('A')
            and i_issuer_region in ('D')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCH', 'MCS', 'MCV', 'MHB', 'MHH', 'MIU', 'MRF', 'MRG'
                                                        , 'MRJ', 'MRO', 'MRP', 'SAG', 'SAP', 'SAS', 'SOS', 'SUR', 'TCC', 'TCG'
                                                        , 'TCS', 'TPL'))
              or (i_brand in ('DMC') and i_product_id in ('DAG', 'DAP', 'DAS', 'DLG', 'DLH', 'DLP', 'DLS', 'DOS', 'MCD', 'MDG'
                                                        , 'MDH', 'MDP', 'MDS', 'MDW', 'MHA', 'MIA', 'MIP', 'MPA', 'MPG', 'MPJ'
                                                        , 'MPF', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY'
                                                        , 'MPZ', 'ACS')))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCS', 'MCV', 'MHB', 'MHH', 'MIU', 'MRG', 'SUR', 'MGP'))
              or (i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDO', 'MDS', 'MHA', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG'
                                                        , 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ'
                                                        , 'ACS')))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCS', 'MCV', 'MHB', 'MHH', 'MIU', 'MRG', 'SUR', 'MGP'))
              or (i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDS', 'MHA', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MPM'
                                                        , 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ', 'ACS')))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCS', 'MCV', 'MFD', 'MFL', 'MIU', 'MPL'))
              or (i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDJ', 'MDO', 'MDP', 'MDS', 'MHA', 'MIA', 'MIP', 'MPA'
                                                        , 'MPF', 'MPG', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX'
                                                        , 'MPY', 'MPZ', 'ACS')))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--79
    function interregional_79 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCV', 'MIU', 'MRC', 'MRG', 'SUR'))
              or (i_brand in ('DMC') and i_product_id in ('MDG', 'MDS', 'MHA', 'MHB', 'MHH', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG'
                                                        , 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ'
                                                        , 'ACS')))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCS', 'MCV', 'MIU', 'MPL', 'MRC', 'MRG', 'SUR', 'MPD'))
              or (i_brand in ('DMC') and i_product_id in ('MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MHA', 'MHB', 'MHH', 'MIA'
                                                        , 'MIP', 'MPA', 'MPF', 'MPG', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT'
                                                        , 'MPV', 'MPX', 'MPY', 'MPZ', 'ACS')))
            ) or (
            i_acquiring_region in ('C', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCH', 'MCS', 'MCV', 'MIU', 'MRC', 'MRF', 'MRG'
                                                        , 'MRJ', 'MRO', 'MRP', 'SAG', 'SAS', 'SOS', 'SUR', 'TCC' ,'TCE', 'TCG'
                                                        , 'TCS'))
              or (i_brand in ('DMC') and i_product_id in ('DAG', 'DAS', 'DLG', 'DLH', 'DLP', 'DLS', 'DOS', 'MDG', 'MDS', 'MHA'
                                                        , 'MHB', 'MHH', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MPJ', 'MPM', 'MPN'
                                                        , 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ', 'ACS')))
            ) or (
            i_acquiring_region in ('A')
            and i_issuer_region in ('D')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCH', 'MCS', 'MCV', 'MIU', 'MRC', 'MRF', 'MRG'
                                                        , 'MRJ', 'MRO', 'MRP', 'SAG', 'SAP', 'SAS', 'SOS', 'SUR', 'TCC', 'TCE'
                                                        , 'TCG', 'TCS', 'TPL'))
              or (i_brand in ('DMC') and i_product_id in ('DAG', 'DAP', 'DAS', 'DLG', 'DLH', 'DLP', 'DLS', 'DOS', 'MDG', 'MDH'
                                                        , 'MDP', 'MDS', 'MDW', 'MHA', 'MHB', 'MHH', 'MIA', 'MIP', 'MPA', 'MPF'
                                                        , 'MPG', 'MPJ', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX'
                                                        , 'MPY', 'MPZ', 'ACS')))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'E')
            and i_issuer_region in ('B')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCV', 'MIU', 'MRC', 'MRG', 'SUR', 'MGP'))
              or (i_brand in ('DMC') and i_product_id in ('MDG', 'MDO', 'MDS', 'MHA', 'MHB', 'MHH', 'MIA', 'MIP', 'MPA', 'MPF'
                                                        , 'MPG', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY'
                                                        , 'MPZ', 'ACS')))
            ) or (
            i_acquiring_region in ('1')
            and i_issuer_region in ('B')
            and i_brand ||'/'||i_product_id in ('MCC/MGP', 'DMC/ACS')
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCV', 'MIU', 'MRC', 'MRG', 'SUR', 'MGP'))
              or (i_brand in ('DMC') and i_product_id in ('MDG', 'MDS', 'MHA', 'MHB', 'MHH', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG'
                                                        , 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ'
                                                        , 'ACS')))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and ((i_brand in ('MCC') and i_product_id in ('MCC', 'MCG', 'MCS', 'MCV', 'MFD', 'MFL', 'MIU', 'MPL', 'SUR'))
              or (i_brand in ('DMC') and i_product_id in ('MDG', 'MDJ', 'MDO', 'MDP', 'MDS', 'MHA', 'MHB', 'MHH', 'MIA', 'MIP'
                                                        , 'MPA', 'MPF', 'MPG', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV'
                                                        , 'MPX', 'MPY', 'MPZ', 'ACS')))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--EA
    function interregional_ea (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('E')
            and i_issuer_region in ('C')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MWE'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW')))
            ) or (
            i_acquiring_region in ('C')
            and i_issuer_region in ('E')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MWE', 'MWP'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW', 'WPD')))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--EE
    function interregional_ee (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MWE'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW')))
            ) or (
            i_acquiring_region in ('C', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MNW', 'MUW', 'MWD', 'MWR', 'TCW', 'TNW', 'TWB', 'WBE'))
              or (i_brand in ('DMC') and i_product_id in ('MBW', 'MDH', 'MDW')))
            ) or (
            i_acquiring_region in ('C', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and ((i_brand in ('MCC') and i_product_id in ('MBK', 'MWE'))
              or (i_brand in ('DMC') and i_product_id in ('MDW')))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MWE', 'MWP'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW', 'WPD')))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MFB', 'MFE', 'MWE'))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--EF
    function interregional_ef (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MWE'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW')))
            ) or (
            i_acquiring_region in ('C', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MNW', 'MUW', 'MWD', 'MWR', 'TCW', 'TNW', 'WBE'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW')))
            ) or (
            i_acquiring_region in ('C', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and ((i_brand in ('MCC') and i_product_id in ('MBK', 'MWE'))
              or (i_brand in ('DMC') and i_product_id in ('MDW')))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MWE', 'MWP'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW', 'WPD')))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E')
            and i_issuer_region in ('1')
             and (i_brand in ('MCC') and i_product_id in ('MFB', 'MFE', 'MWE'))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--EI
    function interregional_ei (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('E')
            and i_issuer_region in ('C')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MWE'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW')))
            ) or (
            i_acquiring_region in ('C')
            and i_issuer_region in ('E')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MWE', 'MWP'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW', 'WPD')))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--EM
    function interregional_em (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MWE'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW')))
            ) or (
            i_acquiring_region in ('C', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MNW', 'MUW', 'MWD', 'MWR', 'TCW', 'TNW', 'WBE'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW')))
            ) or (
            i_acquiring_region in ('C', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and ((i_brand in ('MCC') and i_product_id in ('MBK', 'MWE'))
              or (i_brand in ('DMC') and i_product_id in ('MDW')))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MWE', 'MWP'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW', 'WPD')))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E')
            and i_issuer_region in ('1')
             and (i_brand in ('MCC') and i_product_id in ('MFB', 'MFE', 'MWE'))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--ES
    function interregional_es (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MWE'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW')))
            ) or (
            i_acquiring_region in ('C', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MNW', 'MUW', 'MWD', 'MWR', 'TCW', 'TNW', 'WBE'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW')))
            ) or (
            i_acquiring_region in ('C', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and ((i_brand in ('MCC') and i_product_id in ('MBK', 'MWE'))
              or (i_brand in ('DMC') and i_product_id in ('MDW')))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and ((i_brand in ('MCC') and i_product_id in ('MCW', 'MWE', 'MWP'))
              or (i_brand in ('DMC') and i_product_id in ('MDH', 'MDW', 'WPD')))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and ((i_brand in ('MCC') and i_product_id in ('MFB', 'MFE', 'MWE'))
            )
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--EZ
    function interregional_ez (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCE', 'MCG', 'MCS', 'MCT', 'MCW', 'MIU', 'MPL', 'MRC', 'MRG'
                                                       , 'MWE', 'SUR', 'MAB', 'MBE', 'MCB', 'MCF', 'MCO', 'MCP', 'MEB'
                                                       , 'MEO', 'MNF', 'MRW', 'MWB', 'MES', 'MGS')
              or i_brand in ('DMC') and i_product_id in ('MDG', 'MDH', 'MDP', 'MDS', 'MDW', 'MIP', 'MPG', 'MPH', 'MPP'
                                                       , 'MRH', 'MBP', 'MBT', 'MDT', 'MET', 'MRD'))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E')
            and i_issuer_region in ('A')
            and (i_brand in ('MCC') and i_product_id in ('MRG', 'MWE', 'SUR', 'MAB', 'MAC', 'MBD', 'MBE', 'MCB', 'MCF'
                                                       , 'MCO', 'MCP', 'MDB', 'MDL', 'MEB', 'MEC', 'MEO', 'MNF', 'MPW'
                                                       , 'MRW', 'MWB', 'MWO', 'MES')
              or i_brand in ('DMC') and i_product_id in ('MPG'))
            ) or (
            i_acquiring_region in ('1')
            and i_issuer_region in ('A')
            and (i_brand in ('MCC') and i_product_id in ('MRG', 'SUR', 'MBD', 'MDB')
              or i_brand in ('DMC') and i_product_id in ('MPG'))
            ) or (
            i_acquiring_region in ('A')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MIU', 'MRC', 'MRG', 'MRJ', 'SUR', 'MBD', 'MBE', 'MCB', 'MCF'
                                                       , 'MCO', 'MCP', 'MDB', 'MEB', 'MEC', 'MEO', 'MNF', 'MPB', 'MPW'
                                                       , 'MRK', 'MRW', 'MWB', 'TBE', 'TCB', 'TCF', 'TCO', 'TCP', 'TEB'
                                                       , 'TEC', 'TEO', 'TNF', 'TPB', 'MRL', 'MRF', 'MES')
              or i_brand in ('DMC') and i_product_id in ('MIP', 'MPA', 'MPG', 'MPN', 'MPR', 'BPD')
              or i_brand in ('MSI') and i_product_id in ('MSG', 'MSO'))
            ) or (
            i_acquiring_region in ('C', 'B', 'E')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MIU', 'MRC', 'MRG', 'MRJ', 'SUR', 'MBD', 'MBE', 'MCB', 'MCF'
                                                       , 'MCO', 'MCP', 'MDB', 'MEB', 'MEC', 'MEO', 'MNF', 'MPB', 'MPW'
                                                       , 'MRK', 'MRW', 'MWB', 'TBE', 'TCB', 'TCF', 'TCO', 'TCP', 'TEB'
                                                       , 'TEC', 'TEO', 'TNF', 'TPB', 'MRL', 'MRF', 'MES')
              or i_brand in ('DMC') and i_product_id in ('MIP', 'MPA', 'MPG', 'MPN', 'MPR', 'BPD')
              or i_brand in ('MSI') and i_product_id in ('MSG', 'MSO'))
            ) or (
            i_acquiring_region in ('1')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MIU', 'MRC', 'MRG', 'MRJ', 'SUR', 'MBD', 'MDB', 'MPW', 'MPB'
                                                       , 'MRL', 'MRF')
              or i_brand in ('DMC') and i_product_id in ('MIP', 'MPA', 'MPG', 'MPN', 'MPR', 'BPD')
              or i_brand in ('MSI') and i_product_id in ('MSG', 'MSO'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'E')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MIU', 'MRC', 'MRG', 'MTP', 'SUR', 'MAB', 'MCB'
                                                       , 'MLD', 'MLL', 'MCO', 'MDB', 'MRW', 'MWB', 'MGP')
              or i_brand in ('DMC') and i_product_id in ('MBB', 'MIP', 'MPA', 'MPG', 'MPY'))
            ) or (
            i_acquiring_region in ('1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MIU', 'MRC', 'MRG', 'MTP', 'SUR', 'MBE', 'MEB', 'MLC', 'MLD'
                                                       , 'MLL', 'MPC', 'MRW', 'MWB', 'MGP')
              or i_brand in ('DMC') and i_product_id in ('MBB', 'MIP', 'MPA', 'MPG', 'MPY'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCE', 'MCG', 'MCS', 'MCT', 'MCW', 'MIU', 'MPL', 'MRC', 'MRG'
                                                       , 'MWE', 'SUR', 'MAB', 'MBE', 'MCB', 'MCF', 'MCO', 'MCP', 'MEB'
                                                       , 'MEO', 'MNF', 'MRW', 'MWB', 'MWP', 'MES', 'MGP')
              or i_brand in ('DMC') and i_product_id in ('MDG', 'MDH', 'MDP', 'MDS', 'MDW', 'MIP', 'MPG', 'MPH', 'MPP'
                                                       , 'MRH', 'MDT', 'MET', 'WPD'))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MRG', 'MWE', 'MAB', 'MAC', 'MBD', 'MBE', 'MCB', 'MCF', 'MCO'
                                                       , 'MCP', 'MDB', 'MDL', 'MEB', 'MEC', 'MEO', 'MGF', 'MNF', 'MPK'
                                                       , 'MPW', 'MRW', 'MWB', 'MWO', 'MES')
              or i_brand in ('DMC') and i_product_id in ('MHA', 'MHB', 'MHH', 'MPA', 'MPF', 'MPG', 'MPM', 'MPN', 'MPO'
                                                       , 'MPR', 'MPT', 'MPV', 'MPX', 'MPY'))
            ) or (
            i_acquiring_region in ('A')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MRG', 'MBD', 'MDB', 'MGF', 'MPK', 'MPW')
              or i_brand in ('DMC') and i_product_id in ('MHA', 'MHB', 'MHH', 'MPA', 'MPF', 'MPG', 'MPM', 'MPN', 'MPO'
                                                       , 'MPR', 'MPT', 'MPV', 'MPX', 'MPY'))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--FF
    function interregional_ff (
        i_brand            in     com_api_type_pkg.t_dict_value
      , i_product_id       in     com_api_type_pkg.t_dict_value
      , i_acquiring_region in     com_api_type_pkg.t_dict_value
      , i_issuer_region    in     com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if i_brand in ('MCC') and i_product_id in ('MES')
        then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--PA
    function interregional_pa (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if  i_acquiring_region in ('E')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MPL', 'MGS')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH', 'MET', 'MRD'))
            or
            i_acquiring_region in ('C')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MPL')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH', 'MET'))
        then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--PE
    function interregional_pe (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if  i_acquiring_region in ('D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MPL','MGS')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH', 'MET', 'MRD'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MCW', 'MPL', 'MWE', 'MGS')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDH', 'MDP', 'MDW', 'MRH', 'MET', 'MRD'))
            or
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
             and i_brand in ('MCC') and i_product_id in ('MCW', 'MWE')
            or
            i_acquiring_region in ('C', 'B', 'E', '1')
            and i_issuer_region in ('D')
             and(i_brand in ('MCC') and i_product_id in ('MPL', 'MTP', 'SAP', 'TPL')
                or
                 i_brand in ('DMC') and i_product_id in ('DAP', 'MDP'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('D')
             and i_brand in ('MCC') and i_product_id in ('MCW', 'MNW', 'MTP', 'MUW', 'MWD', 'MWR', 'TCW', 'TNW', 'WBE')
            or
            i_acquiring_region in ('C', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MCW', 'MPL', 'MTP')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MBK', 'MCW', 'MPL', 'MTP', 'MWE')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MDW', 'MRH'))
            or
            i_acquiring_region in ('C', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MPL')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH', 'MET'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MCW', 'MPL', 'MWE', 'MWP')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDH', 'MDP', 'MDW', 'MRH', 'MET', 'WPD'))
            or
            i_acquiring_region in ('C', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MCW', 'MFH', 'MFW')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDH', 'MRH'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MCW', 'MFB', 'MFE', 'MFH', 'MFW', 'MWE')
                 or
                 i_brand in ('DMC') and i_product_id in ('MRH'))
        then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--PF
    function interregional_pf (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if  i_acquiring_region in ('D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MPL', 'MGS')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH', 'MET', 'MRD'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MCW', 'MPL', 'MWE', 'MGS')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDH', 'MDP', 'MDW', 'MRH', 'MET', 'MRD'))
            or
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
             and i_brand in ('MCC') and i_product_id in ('MCW', 'MWE')
            or
            i_acquiring_region in ('C', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MPL', 'MTP', 'SAP', 'TPL')
                 or
                 i_brand in ('DMC') and i_product_id in ('DAP', 'MDP'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('D')
             and i_brand in ('MCC') and i_product_id in ('MCW', 'MNW', 'MTP', 'MUW', 'MWD', 'MWR', 'TCW', 'TNW', 'WBE')
            or
            i_acquiring_region in ('C', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MCW', 'MPL', 'MTP')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MBK', 'MCW', 'MPL', 'MTP', 'MWE')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MDW', 'MRH'))
            or
            i_acquiring_region in ('C', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MPL')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH', 'MET'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MCW', 'MPL', 'MWE', 'MWP')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDH', 'MDP', 'MDW', 'MRH', 'MET', 'WPD'))
            or
            i_acquiring_region in ('C', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MCW', 'MFH', 'MFW')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDH', 'MRH'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MCW', 'MFB', 'MFE', 'MFH', 'MFW', 'MWE')
                 or
                 i_brand in ('DMC') and i_product_id in ('MRH'))
        then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--PI
    function interregional_pi (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if  i_acquiring_region in ('E')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MPL', 'MGS')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH', 'MET', 'MRD'))
            or
            i_acquiring_region in ('C')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MPL')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH', 'MET'))
        then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--PM
    function interregional_pm (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if  i_acquiring_region in ('D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MPL', 'MGS') 
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH', 'MET', 'MRD'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MCW', 'MPL', 'MWE', 'MGS')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDH', 'MDP', 'MDW', 'MRH', 'MET', 'MRD'))
            or
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
             and i_brand in ('MCC') and i_product_id in ('MCW', 'MWE')
            or
            i_acquiring_region in ('C', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MPL', 'MTP', 'SAP', 'TPL')
                 or
                 i_brand in ('DMC') and i_product_id in ('DAP', 'MDP'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('D')
             and i_brand in ('MCC') and i_product_id in ('MCW', 'MNW', 'MTP', 'MUW', 'MWD', 'MWR', 'TCW', 'TNW', 'WBE')
            or
            i_acquiring_region in ('C', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MCW', 'MPL', 'MTP')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MBK', 'MCW', 'MPL', 'MTP', 'MWE')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MDW', 'MRH'))
            or
            i_acquiring_region in ('C', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MPL')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH', 'MET'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MCW', 'MPL', 'MWE', 'MWP')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDH', 'MDP', 'MDW', 'MRH', 'MET', 'WPD'))
            or
            i_acquiring_region in ('C', 'D', 'B', 'E,')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MCW', 'MFH', 'MFW')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDH', 'MRH'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MCW', 'MFB', 'MFE', 'MFH', 'MFW', 'MWE')
                 or
                 i_brand in ('DMC') and i_product_id in ('MRH'))
        then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--PS
    function interregional_ps (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if  i_acquiring_region in ('D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MPL', 'MGS')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH', 'MET', 'MRD'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MCW', 'MPL', 'MWE', 'MGS')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDH', 'MDP', 'MDW', 'MRH', 'MET', 'MRD'))
            or
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
             and i_brand in ('MCC') and i_product_id in ('MCW', 'MWE')
            or
            i_acquiring_region in ('C', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MPL', 'MTP', 'SAP', 'TPL')
                 or
                 i_brand in ('DMC') and i_product_id in ('DAP', 'MDP'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('D')
             and i_brand in ('MCC') and i_product_id in ('MCW', 'MNW', 'MTP', 'MUW', 'MWD', 'MWR', 'TCW', 'TNW', 'WBE')
            or
            i_acquiring_region in ('C', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MCW', 'MPL', 'MTP')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MBK', 'MCW', 'MPL', 'MTP', 'MWE')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MDW', 'MRH'))
            or
            i_acquiring_region in ('C', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MPL')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDP', 'MRH', 'MET'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCT', 'MCW', 'MPL', 'MWE', 'MWP')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDH', 'MDP', 'MDW', 'MRH', 'MET', 'WPD'))
            or
            i_acquiring_region in ('C', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MCW', 'MFH', 'MFW')
                 or
                 i_brand in ('DMC') and i_product_id in ('MDH', 'MRH'))
            or
            i_acquiring_region in ('A')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MCW', 'MFB', 'MFE', 'MFH', 'MFW', 'MWE')
                 or
                 i_brand in ('DMC') and i_product_id in ('MRH'))
        then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--IP
    function interregional_ip (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MAB', 'MWB'))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and (i_brand in ('MCC') and i_product_id in ('MAB', 'MWB'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MAB', 'MWB'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MAB', 'MWB'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MAB', 'MAC', 'MWB', 'MWO'))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;  
    end;
    
----
--74
    function interregional_74 (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCE', 'MRC'))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and (i_brand in ('MCC') and i_product_id in ('MCE', 'MRC'))
            ) or (
            i_acquiring_region in ('C', 'A', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MCE', 'MRC', 'TCE'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MCE', 'MRC'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCE', 'MRC'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MCE', 'MRC'))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;  
    end;

---
--MS
    function interregional_ms (
        i_brand              in com_api_type_pkg.t_dict_value
        , i_product_id       in com_api_type_pkg.t_dict_value
        , i_acquiring_region in com_api_type_pkg.t_dict_value
        , i_issuer_region    in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        if (i_acquiring_region in ('A', 'D', 'B', 'E', '1')
            and i_issuer_region in ('C')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCV', 'MCT', 'MCW', 'MIU', 'MNW'
                                                       , 'MPL', 'MRC', 'MRG', 'MWE', 'SUR', 'MAB', 'MBD', 'MCB', 'MDB'
                                                       , 'MEB', 'MPW', 'MRW', 'MSW', 'MWB', 'TCB', 'TCO', 'MGS')
              or i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MDW', 'MHA'
                                                       , 'MHB', 'MHH', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MPM', 'MPN'
                                                       , 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ', 'MRH'
                                                       , 'MDT', 'MSB', 'MET', 'MRD')
              or i_brand in ('MSI') and i_product_id in ('MSI'))
            ) or (
            i_acquiring_region in ('C', 'D', 'B', 'E', '1')
            and i_issuer_region in ('A')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCV', 'MCW', 'MIU', 'MNW', 'MPL'
                                                       , 'MRC', 'MRG', 'MWE', 'SUR', 'MAB', 'MBD', 'MCB', 'MDB', 'MEB'
                                                       , 'MPW', 'MRW', 'MSW', 'MWB', 'TCB', 'TCO', 'MPD')
              or i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MHA', 'MHB'
                                                       , 'MHH', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MPM', 'MPN', 'MPO'
                                                       , 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ', 'MDT', 'MSB')
              or i_brand in ('MSI') and i_product_id in ('MSI'))
            ) or (
            i_acquiring_region in ('C', 'A', 'B', 'E', '1')
            and i_issuer_region in ('D')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCH', 'MCS', 'MCV', 'MCW', 'MIU', 'MNW'
                                                       , 'MPL', 'MRC', 'MRF', 'MRG', 'MRO', 'MRP', 'MTP', 'MUW', 'MWD'
                                                       , 'MWE', 'MWR', 'SAG', 'SAS', 'SAP', 'SOS', 'SUR', 'WBE', 'MAB'
                                                       , 'MBD', 'MCB', 'MDB', 'MEB', 'MPW', 'MRW', 'MSW', 'MWB', 'TCB'
                                                       , 'TCO')                                                       
              or i_brand in ('DMC') and i_product_id in ('DAG', 'DAP', 'DAS', 'DOS', 'MCD', 'MDG', 'MDH', 'MDO', 'MDP'
                                                       , 'MDR', 'MDS', 'MDW', 'MHA', 'MHB', 'MHH', 'MIA', 'MIP', 'MPF'
                                                       , 'MPG', 'MPM', 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX'
                                                       , 'MPY', 'MPZ', 'MDT', 'MSB')
              or i_brand in ('MSI') and i_product_id in ('MOC', 'MOG', 'MOP', 'MOW', 'MSA', 'MSF', 'MSG', 'MSI', 'MSJ'
                                                       , 'MSM', 'MSN', 'MSO', 'MSQ', 'MSR', 'MST', 'MSV', 'MSX', 'MSY'
                                                       , 'MSZ', 'OLG', 'OLP', 'OLS', 'OLW', 'SAL'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'E', '1')
            and i_issuer_region in ('B')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCV', 'MCW', 'MIU', 'MNW', 'MPL'
                                                       , 'MRC', 'MRG', 'MTP', 'MWE', 'SUR', 'MAB', 'MBD', 'MCB', 'MDB'
                                                       , 'MEB', 'MPW', 'MRW', 'MSW', 'MWB', 'TCB', 'TCO', 'MGP')
              or i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MDW', 'MHA'
                                                       , 'MHB', 'MHH', 'MIA', 'MIP', 'MPF', 'MPG', 'MPM', 'MPN', 'MPO'
                                                       , 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ', 'MRH', 'MDT'
                                                       , 'MSB')
              or i_brand in ('MSI') and i_product_id in ('MSI'))
            ) or (
            i_acquiring_region in ('C', 'A', 'B', '1')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCV', 'MCW', 'MIU', 'MNW', 'MPL'
                                                       , 'MRC', 'MRG', 'MWE', 'SUR', 'MAB', 'MBD', 'MCB', 'MDB', 'MEB'
                                                       , 'MPW', 'MRW', 'MSW', 'MWB', 'TCB', 'TCO', 'MWP', 'MGP')
              or i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MDW', 'MHA'
                                                       , 'MHB', 'MHH', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MRH', 'MPM'
                                                       , 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ'
                                                       , 'MDT', 'MSB', 'MET', 'WPD')
              or i_brand in ('MSI') and i_product_id in ('MSI'))
            ) or (
            i_acquiring_region in ('D')
            and i_issuer_region in ('E')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCV', 'MCW', 'MIU', 'MNW', 'MPL'
                                                       , 'MRC', 'MRG', 'MWE', 'SUR', 'MAB', 'MBD', 'MCB', 'MDB', 'MEB'
                                                       , 'MPW', 'MRW', 'MSW', 'MWB', 'TCB', 'TCO', 'MWP', 'MGP')
              or i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDO', 'MDP', 'MDR', 'MDS', 'MDW', 'MHA'
                                                       , 'MHB', 'MHH', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MRH', 'MPM'
                                                       , 'MPN', 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ'
                                                       , 'MDT', 'MSB', 'MET', 'WPD')
              or i_brand in ('MSI') and i_product_id in ('MSI'))
            ) or (
            i_acquiring_region in ('C', 'A', 'D', 'B', 'E')
            and i_issuer_region in ('1')
            and (i_brand in ('MCC') and i_product_id in ('MCC', 'MCE', 'MCG', 'MCS', 'MCV', 'MCW', 'MFB', 'MFD', 'MFE'
                                                       , 'MFH', 'MFL', 'MFW', 'MIU', 'MNW', 'MPL', 'MRC', 'MRG', 'MWE'
                                                       , 'SUR', 'MAB', 'MBD', 'MCB', 'MDB', 'MEB', 'MPW', 'MRW', 'MSW'
                                                       , 'MWB', 'TCB', 'TCO')
              or i_brand in ('DMC') and i_product_id in ('MCD', 'MDG', 'MDH', 'MDJ', 'MDO', 'MDP', 'MDR', 'MDS', 'MHA'
                                                       , 'MHB', 'MHH', 'MIA', 'MIP', 'MPA', 'MPF', 'MPG', 'MPM', 'MPN'
                                                       , 'MPO', 'MPP', 'MPR', 'MPT', 'MPV', 'MPX', 'MPY', 'MPZ', 'MRH'
                                                       , 'MDT', 'MSB')
              or i_brand in ('MSI') and i_product_id in ('MSI'))
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

----
--ZX
    function interregional_zx(
        i_brand              in com_api_type_pkg.t_dict_value
      , i_product_id         in com_api_type_pkg.t_dict_value
      , i_acquiring_region   in com_api_type_pkg.t_dict_value
      , i_issuer_region      in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
    begin
        return
        case
        when i_issuer_region    in ('C', 'D', 'B', 'E', '1')
         and i_acquiring_region in ('C', 'D', 'B', 'E', '1')
              and i_brand in ('MCC', 'DMC')
         and i_product_id in ('MWF', 'DWF')
        then com_api_type_pkg.TRUE
        else com_api_type_pkg.FALSE
        end;
    end interregional_zx;

---
--QR
    function interregional_qr(
        i_brand            in     com_api_type_pkg.t_dict_value
      , i_product_id       in     com_api_type_pkg.t_dict_value
      , i_acquiring_region in     com_api_type_pkg.t_dict_value
      , i_issuer_region    in     com_api_type_pkg.t_dict_value
      , i_de_003_1         in     com_api_type_pkg.t_dict_value
      , i_standard_version in     com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_boolean is
    begin
        if ((i_acquiring_region in ('B', 'E')
            and i_issuer_region in ('C')
            and ((i_brand in ('MCC') and i_product_id in ('MCS', 'MCC', 'MCV', 'MCE', 'MGS') )
              or (i_brand in ('DMC') and i_product_id in ('MDR', 'MDS', 'MCD', 'MDO', 'MRD') )
              or (i_brand in ('MSI') and i_product_id in ('MOG', 'MOP', 'MSI') 
              and i_de_003_1 = '00'
                 )
                )
            ) or (
            i_acquiring_region in ('A', 'D', '1')
            and i_issuer_region in ('C')
            and ((i_brand in ('MCC') and i_product_id in ('MGS') and i_de_003_1 = '00' )
              or (i_brand in ('DMC') and i_product_id in ('MRD') )
               )
            ) or (
            i_acquiring_region in ('C', 'E')
            and i_issuer_region in ('B')
            and ((i_brand in ('MCC')  )
              or (i_brand in ('DMC')  )
              or (i_brand in ('MSI') 
               and i_de_003_1 = '00'
                 )
                )
            ) or (
            i_acquiring_region in ('A', 'D', '1')
            and i_issuer_region in ('B')
            and i_brand || '/' || i_product_id in ('MCC/MGP')
            ) or (
            i_acquiring_region in ('B', 'C')
            and i_issuer_region in ('E')
            and ((i_brand in ('MCC')  )
              or (i_brand in ('DMC')  )
              or (i_brand in ('MSI')  
              and i_de_003_1 = '00'
                 )
                )
            ) or (
            i_acquiring_region in ('A', 'D')
            and i_issuer_region in ('E')
            and i_brand || i_product_id in ('MCC/MGP' )
            ) or (
            i_acquiring_region in ('1')
            and i_issuer_region in ('E')
            and ((i_brand in ('MCC')  )
              or (i_brand in ('DMC')  )
              or (i_brand in ('MSI') 
               and i_de_003_1 = '00'
                 )
                )
            ) 
        ) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end interregional_qr;

---
--Get Amount
    function get_amount (
        i_de_004             in mcw_api_type_pkg.t_de004
        , i_curr_code        in com_api_type_pkg.t_curr_code
    ) return mcw_api_type_pkg.t_de004 is
        l_result                mcw_api_type_pkg.t_de004;
    begin
        if i_curr_code = mcw_api_const_pkg.CURRENCY_CODE_US_DOLLAR then
            l_result := i_de_004;
        else
            l_result := i_de_004 * mcw_utl_pkg.get_usd_rate (
                                       i_impact        => com_api_type_pkg.DEBIT
                                       , i_curr_code   => i_curr_code
                                   );
        end if;
        return l_result;
    end;

end;
/

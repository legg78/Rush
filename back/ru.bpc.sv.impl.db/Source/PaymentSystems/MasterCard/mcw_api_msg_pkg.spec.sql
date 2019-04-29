create or replace package mcw_api_msg_pkg is

    function format_de003 (
        i_de003_1         in mcw_api_type_pkg.t_de003
        , i_de003_2         in mcw_api_type_pkg.t_de003
        , i_de003_3         in mcw_api_type_pkg.t_de003
    ) return mcw_api_type_pkg.t_de003;
    
    function format_de022 (   
        i_de022_1           in mcw_api_type_pkg.t_de022s
        , i_de022_2         in mcw_api_type_pkg.t_de022s
        , i_de022_3         in mcw_api_type_pkg.t_de022s
        , i_de022_4         in mcw_api_type_pkg.t_de022s
        , i_de022_5         in mcw_api_type_pkg.t_de022s
        , i_de022_6         in mcw_api_type_pkg.t_de022s
        , i_de022_7         in mcw_api_type_pkg.t_de022s
        , i_de022_8         in mcw_api_type_pkg.t_de022s
        , i_de022_9         in mcw_api_type_pkg.t_de022s
        , i_de022_10        in mcw_api_type_pkg.t_de022s
        , i_de022_11        in mcw_api_type_pkg.t_de022s
        , i_de022_12        in mcw_api_type_pkg.t_de022s
    ) return mcw_api_type_pkg.t_de022;
    
    function format_de030 (
        i_de030_1           in mcw_api_type_pkg.t_de030s
        , i_de030_2         in mcw_api_type_pkg.t_de030s
    ) return mcw_api_type_pkg.t_de030;
    
    function format_de043 (
        i_de043_1  in     mcw_api_type_pkg.t_de043_1
      , i_de043_2  in     mcw_api_type_pkg.t_de043_2
      , i_de043_3  in     mcw_api_type_pkg.t_de043_3
      , i_de043_4  in     mcw_api_type_pkg.t_de043_4
      , i_de043_5  in     mcw_api_type_pkg.t_de043_5
      , i_de043_6  in     mcw_api_type_pkg.t_de043_6
    ) return mcw_api_type_pkg.t_de043 ;
    
    procedure pack_message (
        o_raw_data          out varchar2
        , i_pds_tab         in mcw_api_type_pkg.t_pds_tab
        , i_mti             in mcw_api_type_pkg.t_mti
        , i_de002           in mcw_api_type_pkg.t_de002 := null
        , i_de003_1         in mcw_api_type_pkg.t_de003 := null
        , i_de003_2         in mcw_api_type_pkg.t_de003 := null
        , i_de003_3         in mcw_api_type_pkg.t_de003 := null
        , i_de004           in mcw_api_type_pkg.t_de004 := null
        , i_de005           in mcw_api_type_pkg.t_de005 := null
        , i_de006           in mcw_api_type_pkg.t_de006 := null
        , i_de009           in mcw_api_type_pkg.t_de009 := null
        , i_de010           in mcw_api_type_pkg.t_de010 := null
        , i_de012           in mcw_api_type_pkg.t_de012 := null
        , i_de014           in mcw_api_type_pkg.t_de014 := null
        , i_de022           in mcw_api_type_pkg.t_de022 := null
        , i_de022_1         in mcw_api_type_pkg.t_de022s := null
        , i_de022_2         in mcw_api_type_pkg.t_de022s := null
        , i_de022_3         in mcw_api_type_pkg.t_de022s := null
        , i_de022_4         in mcw_api_type_pkg.t_de022s := null
        , i_de022_5         in mcw_api_type_pkg.t_de022s := null
        , i_de022_6         in mcw_api_type_pkg.t_de022s := null
        , i_de022_7         in mcw_api_type_pkg.t_de022s := null
        , i_de022_8         in mcw_api_type_pkg.t_de022s := null
        , i_de022_9         in mcw_api_type_pkg.t_de022s := null
        , i_de022_10        in mcw_api_type_pkg.t_de022s := null
        , i_de022_11        in mcw_api_type_pkg.t_de022s := null
        , i_de022_12        in mcw_api_type_pkg.t_de022s := null
        , i_de023           in mcw_api_type_pkg.t_de023 := null
        , i_de024           in mcw_api_type_pkg.t_de024 := null
        , i_de025           in mcw_api_type_pkg.t_de025 := null
        , i_de026           in mcw_api_type_pkg.t_de026 := null
        , i_de030           in mcw_api_type_pkg.t_de030 := null
        , i_de030_1         in mcw_api_type_pkg.t_de030s := null
        , i_de030_2         in mcw_api_type_pkg.t_de030s := null
        , i_de031           in mcw_api_type_pkg.t_de031 := null
        , i_de032           in mcw_api_type_pkg.t_de032 := null
        , i_de033           in mcw_api_type_pkg.t_de033 := null
        , i_de037           in mcw_api_type_pkg.t_de037 := null
        , i_de038           in mcw_api_type_pkg.t_de038 := null
        , i_de040           in mcw_api_type_pkg.t_de040 := null
        , i_de041           in mcw_api_type_pkg.t_de041 := null
        , i_de042           in mcw_api_type_pkg.t_de042 := null
        , i_de043           in mcw_api_type_pkg.t_de043 := null
        , i_de043_1         in mcw_api_type_pkg.t_de043_1 := null
        , i_de043_2         in mcw_api_type_pkg.t_de043_2 := null
        , i_de043_3         in mcw_api_type_pkg.t_de043_3 := null
        , i_de043_4         in mcw_api_type_pkg.t_de043_4 := null
        , i_de043_5         in mcw_api_type_pkg.t_de043_5 := null
        , i_de043_6         in mcw_api_type_pkg.t_de043_6 := null
        , i_de049           in mcw_api_type_pkg.t_de049 := null
        , i_de050           in mcw_api_type_pkg.t_de050 := null
        , i_de051           in mcw_api_type_pkg.t_de051 := null
        , i_de054           in mcw_api_type_pkg.t_de054 := null
        , i_de055           in mcw_api_type_pkg.t_de055 := null
        , i_de063           in mcw_api_type_pkg.t_de063 := null
        , i_de071           in mcw_api_type_pkg.t_de071 := null
        , i_de072           in mcw_api_type_pkg.t_de072 := null
        , i_de073           in mcw_api_type_pkg.t_de073 := null
        , i_de093           in mcw_api_type_pkg.t_de093 := null
        , i_de094           in mcw_api_type_pkg.t_de094 := null
        , i_de095           in mcw_api_type_pkg.t_de095 := null
        , i_de100           in mcw_api_type_pkg.t_de100 := null
        , i_de111           in mcw_api_type_pkg.t_de111 := null
        , i_de127           in mcw_api_type_pkg.t_de127 := null
        , i_charset         in com_api_type_pkg.t_oracle_name := null
    );

    procedure unpack_message (
        i_raw_data          in varchar2
        , o_mti             out mcw_api_type_pkg.t_mti
        , o_de002           out mcw_api_type_pkg.t_de002
        , o_de003_1         out mcw_api_type_pkg.t_de003
        , o_de003_2         out mcw_api_type_pkg.t_de003
        , o_de003_3         out mcw_api_type_pkg.t_de003
        , o_de004           out mcw_api_type_pkg.t_de004
        , o_de005           out mcw_api_type_pkg.t_de005
        , o_de006           out mcw_api_type_pkg.t_de006
        , o_de009           out mcw_api_type_pkg.t_de009
        , o_de010           out mcw_api_type_pkg.t_de010
        , o_de012           out mcw_api_type_pkg.t_de012
        , o_de014           out mcw_api_type_pkg.t_de014
        , o_de022_1         out mcw_api_type_pkg.t_de022s
        , o_de022_2         out mcw_api_type_pkg.t_de022s
        , o_de022_3         out mcw_api_type_pkg.t_de022s
        , o_de022_4         out mcw_api_type_pkg.t_de022s
        , o_de022_5         out mcw_api_type_pkg.t_de022s
        , o_de022_6         out mcw_api_type_pkg.t_de022s
        , o_de022_7         out mcw_api_type_pkg.t_de022s
        , o_de022_8         out mcw_api_type_pkg.t_de022s
        , o_de022_9         out mcw_api_type_pkg.t_de022s
        , o_de022_10        out mcw_api_type_pkg.t_de022s
        , o_de022_11        out mcw_api_type_pkg.t_de022s
        , o_de022_12        out mcw_api_type_pkg.t_de022s
        , o_de023           out mcw_api_type_pkg.t_de023
        , o_de024           out mcw_api_type_pkg.t_de024
        , o_de025           out mcw_api_type_pkg.t_de025
        , o_de026           out mcw_api_type_pkg.t_de026
        , o_de030_1         out mcw_api_type_pkg.t_de030s
        , o_de030_2         out mcw_api_type_pkg.t_de030s
        , o_de031           out mcw_api_type_pkg.t_de031
        , o_de032           out mcw_api_type_pkg.t_de032
        , o_de033           out mcw_api_type_pkg.t_de033
        , o_de037           out mcw_api_type_pkg.t_de037
        , o_de038           out mcw_api_type_pkg.t_de038
        , o_de040           out mcw_api_type_pkg.t_de040
        , o_de041           out mcw_api_type_pkg.t_de041
        , o_de042           out mcw_api_type_pkg.t_de042
        , o_de043_1         out mcw_api_type_pkg.t_de043_1
        , o_de043_2         out mcw_api_type_pkg.t_de043_2
        , o_de043_3         out mcw_api_type_pkg.t_de043_3
        , o_de043_4         out mcw_api_type_pkg.t_de043_4
        , o_de043_5         out mcw_api_type_pkg.t_de043_5
        , o_de043_6         out mcw_api_type_pkg.t_de043_6
        , o_de048           out mcw_api_type_pkg.t_de048
        , o_de049           out mcw_api_type_pkg.t_de049
        , o_de050           out mcw_api_type_pkg.t_de050
        , o_de051           out mcw_api_type_pkg.t_de051
        , o_de054           out mcw_api_type_pkg.t_de054
        , o_de055           out mcw_api_type_pkg.t_de055
        , o_de062           out mcw_api_type_pkg.t_de062
        , o_de063           out mcw_api_type_pkg.t_de063
        , o_de071           out mcw_api_type_pkg.t_de071
        , o_de072           out mcw_api_type_pkg.t_de072
        , o_de073           out mcw_api_type_pkg.t_de073
        , o_de093           out mcw_api_type_pkg.t_de093
        , o_de094           out mcw_api_type_pkg.t_de094
        , o_de095           out mcw_api_type_pkg.t_de095
        , o_de100           out mcw_api_type_pkg.t_de100
        , o_de111           out mcw_api_type_pkg.t_de111
        , o_de123           out mcw_api_type_pkg.t_de123
        , o_de124           out mcw_api_type_pkg.t_de124
        , o_de125           out mcw_api_type_pkg.t_de125
        , o_de127           out mcw_api_type_pkg.t_de127
        , i_charset         in com_api_type_pkg.t_oracle_name := null
    );

end;
/

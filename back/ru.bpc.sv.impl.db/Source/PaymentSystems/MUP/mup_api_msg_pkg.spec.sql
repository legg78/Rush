create or replace package mup_api_msg_pkg is

    function format_de003 (
        i_de003_1         in mup_api_type_pkg.t_de003
        , i_de003_2         in mup_api_type_pkg.t_de003
        , i_de003_3         in mup_api_type_pkg.t_de003
    ) return mup_api_type_pkg.t_de003;
    
    function format_de022 (   
        i_de022_1           in mup_api_type_pkg.t_de022s
        , i_de022_2         in mup_api_type_pkg.t_de022s
        , i_de022_3         in mup_api_type_pkg.t_de022s
        , i_de022_4         in mup_api_type_pkg.t_de022s
        , i_de022_5         in mup_api_type_pkg.t_de022s
        , i_de022_6         in com_api_type_pkg.t_byte_char
        , i_de022_7         in mup_api_type_pkg.t_de022s
        , i_de022_8         in mup_api_type_pkg.t_de022s
        , i_de022_9         in mup_api_type_pkg.t_de022s
        , i_de022_10        in mup_api_type_pkg.t_de022s
        , i_de022_11        in mup_api_type_pkg.t_de022s
    ) return mup_api_type_pkg.t_de022;
    
    function format_de030 (
        i_de030_1           in mup_api_type_pkg.t_de030s
        , i_de030_2         in mup_api_type_pkg.t_de030s
    ) return mup_api_type_pkg.t_de030;
    
    function format_de043 (   
        i_de043_1               in mup_api_type_pkg.t_de043
        , i_de043_2             in mup_api_type_pkg.t_de043
        , i_de043_3             in mup_api_type_pkg.t_de043
        , i_de043_4             in mup_api_type_pkg.t_de043
        , i_de043_5             in mup_api_type_pkg.t_de043
        , i_de043_6             in mup_api_type_pkg.t_de043
    ) return mup_api_type_pkg.t_de043;

    procedure pack_message (
        o_raw_data          out varchar2
        , i_pds_tab         in mup_api_type_pkg.t_pds_tab
        , i_mti             in mup_api_type_pkg.t_mti
        , i_de002           in mup_api_type_pkg.t_de002 := null
        , i_de003_1         in mup_api_type_pkg.t_de003 := null
        , i_de003_2         in mup_api_type_pkg.t_de003 := null
        , i_de003_3         in mup_api_type_pkg.t_de003 := null
        , i_de004           in mup_api_type_pkg.t_de004 := null
        , i_de005           in mup_api_type_pkg.t_de005 := null
        , i_de006           in mup_api_type_pkg.t_de006 := null
        , i_de009           in mup_api_type_pkg.t_de009 := null
        , i_de010           in mup_api_type_pkg.t_de010 := null
        , i_de012           in mup_api_type_pkg.t_de012 := null
        , i_de014           in mup_api_type_pkg.t_de014 := null
        , i_de022           in mup_api_type_pkg.t_de022 := null
        , i_de022_1         in mup_api_type_pkg.t_de022s := null
        , i_de022_2         in mup_api_type_pkg.t_de022s := null
        , i_de022_3         in mup_api_type_pkg.t_de022s := null
        , i_de022_4         in mup_api_type_pkg.t_de022s := null
        , i_de022_5         in mup_api_type_pkg.t_de022s := null
        , i_de022_6         in com_api_type_pkg.t_byte_char := null
        , i_de022_7         in mup_api_type_pkg.t_de022s := null
        , i_de022_8         in mup_api_type_pkg.t_de022s := null
        , i_de022_9         in mup_api_type_pkg.t_de022s := null
        , i_de022_10        in mup_api_type_pkg.t_de022s := null
        , i_de022_11        in mup_api_type_pkg.t_de022s := null
        , i_de023           in mup_api_type_pkg.t_de023 := null
        , i_de024           in mup_api_type_pkg.t_de024 := null
        , i_de025           in mup_api_type_pkg.t_de025 := null
        , i_de026           in mup_api_type_pkg.t_de026 := null
        , i_de030           in mup_api_type_pkg.t_de030 := null
        , i_de030_1         in mup_api_type_pkg.t_de030s := null
        , i_de030_2         in mup_api_type_pkg.t_de030s := null
        , i_de031           in mup_api_type_pkg.t_de031 := null
        , i_de032           in mup_api_type_pkg.t_de032 := null
        , i_de033           in mup_api_type_pkg.t_de033 := null
        , i_de037           in mup_api_type_pkg.t_de037 := null
        , i_de038           in mup_api_type_pkg.t_de038 := null
        , i_de040           in mup_api_type_pkg.t_de040 := null
        , i_de041           in mup_api_type_pkg.t_de041 := null
        , i_de042           in mup_api_type_pkg.t_de042 := null
        , i_de043           in mup_api_type_pkg.t_de043 := null
        , i_de043_1         in mup_api_type_pkg.t_de043 := null
        , i_de043_2         in mup_api_type_pkg.t_de043 := null
        , i_de043_3         in mup_api_type_pkg.t_de043 := null
        , i_de043_4         in mup_api_type_pkg.t_de043 := null
        , i_de043_5         in mup_api_type_pkg.t_de043 := null
        , i_de043_6         in mup_api_type_pkg.t_de043 := null
        , i_de049           in mup_api_type_pkg.t_de049 := null
        , i_de050           in mup_api_type_pkg.t_de050 := null
        , i_de051           in mup_api_type_pkg.t_de051 := null
        , i_de054           in mup_api_type_pkg.t_de054 := null
        , i_de055           in mup_api_type_pkg.t_de055 := null
        , i_de063           in mup_api_type_pkg.t_de063 := null
        , i_de071           in mup_api_type_pkg.t_de071 := null
        , i_de072           in mup_api_type_pkg.t_de072 := null
        , i_de073           in mup_api_type_pkg.t_de073 := null
        , i_de093           in mup_api_type_pkg.t_de093 := null
        , i_de094           in mup_api_type_pkg.t_de094 := null
        , i_de095           in mup_api_type_pkg.t_de095 := null
        , i_de100           in mup_api_type_pkg.t_de100 := null
        , i_de123           in mup_api_type_pkg.t_de123 := null
        , i_de124           in mup_api_type_pkg.t_de124 := null
        , i_de125           in mup_api_type_pkg.t_de125 := null
        , i_charset         in com_api_type_pkg.t_oracle_name := null
    );

    procedure unpack_message (
        i_raw_data          in varchar2
        , o_mti             out mup_api_type_pkg.t_mti
        , o_de002           out mup_api_type_pkg.t_de002
        , o_de003_1         out mup_api_type_pkg.t_de003
        , o_de003_2         out mup_api_type_pkg.t_de003
        , o_de003_3         out mup_api_type_pkg.t_de003
        , o_de004           out mup_api_type_pkg.t_de004
        , o_de005           out mup_api_type_pkg.t_de005
        , o_de006           out mup_api_type_pkg.t_de006
        , o_de009           out mup_api_type_pkg.t_de009
        , o_de010           out mup_api_type_pkg.t_de010
        , o_de012           out mup_api_type_pkg.t_de012
        , o_de014           out mup_api_type_pkg.t_de014
        , o_de022_1         out mup_api_type_pkg.t_de022s
        , o_de022_2         out mup_api_type_pkg.t_de022s
        , o_de022_3         out mup_api_type_pkg.t_de022s
        , o_de022_4         out mup_api_type_pkg.t_de022s
        , o_de022_5         out mup_api_type_pkg.t_de022s
        , o_de022_6         out com_api_type_pkg.t_byte_char
        , o_de022_7         out mup_api_type_pkg.t_de022s
        , o_de022_8         out mup_api_type_pkg.t_de022s
        , o_de022_9         out mup_api_type_pkg.t_de022s
        , o_de022_10        out mup_api_type_pkg.t_de022s
        , o_de022_11        out mup_api_type_pkg.t_de022s
        , o_de023           out mup_api_type_pkg.t_de023
        , o_de024           out mup_api_type_pkg.t_de024
        , o_de025           out mup_api_type_pkg.t_de025
        , o_de026           out mup_api_type_pkg.t_de026
        , o_de030_1         out mup_api_type_pkg.t_de030s
        , o_de030_2         out mup_api_type_pkg.t_de030s
        , o_de031           out mup_api_type_pkg.t_de031
        , o_de032           out mup_api_type_pkg.t_de032
        , o_de033           out mup_api_type_pkg.t_de033
        , o_de037           out mup_api_type_pkg.t_de037
        , o_de038           out mup_api_type_pkg.t_de038
        , o_de040           out mup_api_type_pkg.t_de040
        , o_de041           out mup_api_type_pkg.t_de041
        , o_de042           out mup_api_type_pkg.t_de042
        , o_de043_1         out mup_api_type_pkg.t_de043
        , o_de043_2         out mup_api_type_pkg.t_de043
        , o_de043_3         out mup_api_type_pkg.t_de043
        , o_de043_4         out mup_api_type_pkg.t_de043
        , o_de043_5         out mup_api_type_pkg.t_de043
        , o_de043_6         out mup_api_type_pkg.t_de043
        , o_de048           out mup_api_type_pkg.t_de048
        , o_de049           out mup_api_type_pkg.t_de049
        , o_de050           out mup_api_type_pkg.t_de050
        , o_de051           out mup_api_type_pkg.t_de051
        , o_de054           out mup_api_type_pkg.t_de054
        , o_de055           out mup_api_type_pkg.t_de055
        , o_de062           out mup_api_type_pkg.t_de062
        , o_de063           out mup_api_type_pkg.t_de063
        , o_de071           out mup_api_type_pkg.t_de071
        , o_de072           out mup_api_type_pkg.t_de072
        , o_de073           out mup_api_type_pkg.t_de073
        , o_de093           out mup_api_type_pkg.t_de093
        , o_de094           out mup_api_type_pkg.t_de094
        , o_de095           out mup_api_type_pkg.t_de095
        , o_de100           out mup_api_type_pkg.t_de100
        , o_de123           out mup_api_type_pkg.t_de123
        , o_de124           out mup_api_type_pkg.t_de124
        , o_de125           out mup_api_type_pkg.t_de125
        , i_charset         in com_api_type_pkg.t_oracle_name := null
    );

end;
/

create or replace package dsp_api_generate_pkg is

     procedure gen_internal_reversal;
     
     procedure gen_write_off_positive;
     
     procedure gen_write_off_negative;

     procedure gen_common_refund;

end;
/

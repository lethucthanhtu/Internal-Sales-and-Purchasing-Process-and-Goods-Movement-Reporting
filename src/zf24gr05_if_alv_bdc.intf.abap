interface zf24gr05_if_alv_bdc
  public .

*  methods:
*    execute.

  methods:
    set_dynpro
      importing
        iv_program type bdc_prog
        iv_dynpro  type bdc_dynr,

    set_field
      importing
        iv_fnam type bdc_fnam
        iv_fval type bdc_fval.

endinterface.

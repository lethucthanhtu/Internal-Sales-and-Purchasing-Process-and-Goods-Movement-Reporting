class zf24gr05_cl_alv_bdc_root definition
  public
  create public .

  public section.

*    interfaces zf24gr05_if_alv_bdc.

    " Constructor method for initialization
    methods: constructor.

  protected section.

    " Internal table to hold BDC data and a work area for a single BDC record
    data: lt_bdcdata type table of bdcdata,
          ls_bdcdata type bdcdata.

    " Method to set the dynamic program and screen number for BDC processing
    methods:
      set_dynpro
        importing
          iv_program type bdc_prog
          iv_dynpro  type bdc_dynr,

      " Method to populate BDC data fields with field names and values
      set_field
        importing
          iv_fnam type bdc_fnam
          iv_fval type bdc_fval.

    " Method to call a transaction with BDC data
    methods:
      call_tcode
        importing
          iv_tcode type tcode.

  private section.

ENDCLASS.



CLASS ZF24GR05_CL_ALV_BDC_ROOT IMPLEMENTATION.


  method call_tcode.

    " Call the specified transaction with the BDC data in 'lt_bdcdata'
    call transaction iv_tcode
      using lt_bdcdata
      mode 'E'
      update 'S'.

  endmethod.


  method constructor.

    clear ls_bdcdata.

  endmethod.


  method set_dynpro.

    clear ls_bdcdata.

    ls_bdcdata-program  = iv_program.
    ls_bdcdata-dynpro   = iv_dynpro.
    ls_bdcdata-dynbegin = 'X'.

    append ls_bdcdata to lt_bdcdata.

  endmethod.


  method set_field.

    clear ls_bdcdata.

    ls_bdcdata-fnam = iv_fnam.
    ls_bdcdata-fval = iv_fval.

    append ls_bdcdata to lt_bdcdata.

  endmethod.
ENDCLASS.

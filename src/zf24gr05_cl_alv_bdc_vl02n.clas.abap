class zf24gr05_cl_alv_bdc_vl02n definition
  inheriting from zf24gr05_cl_alv_bdc_root
  public
  final
  create public .

  public section.

    methods constructor .

    methods:
      execute
        importing
          iv_delivery_num type bdcdata-fval.

  protected section.

    methods:
      process_delivery
        importing
          iv_delivery_num type bdcdata-fval.

  private section.

ENDCLASS.



CLASS ZF24GR05_CL_ALV_BDC_VL02N IMPLEMENTATION.


  method constructor.
    COMMIT WORK.
    super->constructor( ).

  endmethod.


  method execute.

    me->process_delivery(
       iv_delivery_num = iv_delivery_num
    ).

    " Execute BDC
    me->call_tcode(
      iv_tcode = 'VL02N'
    ).

  endmethod.


  method process_delivery.

    " Add screen navigation
    me->set_dynpro(
      iv_program = 'SAPMV50A'
      iv_dynpro  = '4004'
    ).

   " Set cursor on the delivery number field
    me->set_field(
      iv_fnam = 'BDC_CURSOR'
      iv_fval = 'LIKP-VBELN'
    ).

    " Set the OK code for pressing Enter
    me->set_field(
      iv_fnam = 'BDC_OKCODE'
      iv_fval = '=ENT2'
    ).

    " Populate the delivery number field
    me->set_field(
      iv_fnam = 'LIKP-VBELN'
      iv_fval = iv_delivery_num
    ).

    " Add navigation to detail screen
    me->set_dynpro(
      iv_program = 'SAPMV50A'
      iv_dynpro  = '1000'
    ).

  endmethod.
ENDCLASS.

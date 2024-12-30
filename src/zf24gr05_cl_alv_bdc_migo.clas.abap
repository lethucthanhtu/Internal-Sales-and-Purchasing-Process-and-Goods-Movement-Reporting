class zf24gr05_cl_alv_bdc_migo definition
  inheriting from zf24gr05_cl_alv_bdc_root
  public
  final
  create public .

  public section.

   " Constructor for initializing the object
    methods: constructor.

   " Method to execute the BDC process for MIGO transaction
    methods: execute
      importing
        iv_mat_doc type bdcdata-fval.

   methods: FM_MIGO_DIALOG
      importing
        iv_GR type zf24gr05_CL_ALV=>TY_S_ALV-GOODS_RECEIPT.

  protected section.

    " Method to process the material document for the MIGO transaction
    methods:
      process_material_doc
        importing
          iv_mat_doc type bdcdata-fval.



  private section.

ENDCLASS.



CLASS ZF24GR05_CL_ALV_BDC_MIGO IMPLEMENTATION.


  method constructor.

    super->constructor( ).

  endmethod.


  method execute.

    " Process the material document for the transaction
    me->process_material_doc(
      iv_mat_doc = iv_mat_doc
    ).

    " Execute BDC transaction for MIGO
    me->call_tcode(
      iv_tcode = 'MIGO'
    ).

  endmethod.


  METHOD FM_MIGO_DIALOG.
    CALL FUNCTION 'MIGO_DIALOG'
            EXPORTING
              I_ACTION            = 'A04'
              I_REFDOC            = 'R02'
              I_NOTREE            = ABAP_TRUE
              I_NO_AUTH_CHECK     = ''
              I_SKIP_FIRST_SCREEN = ABAP_TRUE
              I_DEADEND           = ABAP_TRUE
              I_OKCODE            = 'OK_GO'
*             I_LEAVE_AFTER_POST  =
*             I_NEW_ROLLAREA      = 'X'
*             I_SYTCODE           =
*             I_EBELN             =
*             I_EBELP             =
              I_MBLNR             = IV_GR
*             I_MJAHR             =
*             I_ZEILE             =
*             I_TRANSPORT         =
*             I_ORDER_NUMBER      =
*             I_ORDER_ITEM        =
*             I_TRANSPORT_MEANS   =
*             I_TRANSPORTIDENT    =
*             I_INBOUND_DELIV     =
*             I_OUTBOUND_DELIV    =
*             I_RESERVATION_NUMB  =
*             I_RESERVATION_ITEM  =
*             EXT                 =
*             I_MOVE_TYPE         =
*             I_SPEC_STOCK        =
*             I_PSTNG_DATE        =
*             I_DOC_DATE          =
*             I_REF_DOC_NO        =
*             I_HEADER_TXT        =
            EXCEPTIONS
              ILLEGAL_COMBINATION = 1
              OTHERS              = 2.
  ENDMETHOD.


  method process_material_doc.

    " Initial screen navigation
    me->set_dynpro(
      iv_program = 'SAPLMIGO'
      iv_dynpro  = '0001'
    ).

    " Add fields for initial screen
    me->set_field(
      iv_fnam = 'BDC_OKCODE'
      iv_fval = '=OK_GO'
    ).

    " Set action type for MIGO
    me->set_field(
      iv_fnam = 'GODYNPRO-ACTION'
      iv_fval = 'A04'
    ).

    " Set reference document type
    me->set_field(
      iv_fnam = 'GODYNPRO-REFDOC'
      iv_fval = 'R02'
    ).

    " Set cursor position to the material document field
    me->set_field(
      iv_fnam = 'BDC_CURSOR'
      iv_fval = 'GODYNPRO-MAT_DOC'
    ).

    me->set_field(
      iv_fnam = 'GODYNPRO-MAT_DOC'
      iv_fval = iv_mat_doc
    ).

    " Add navigation to next screen
    me->set_dynpro(
      iv_program = 'SAPLMIGO'
      iv_dynpro  = '0001'
    ).

  endmethod.
ENDCLASS.

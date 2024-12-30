CLASS ZF24GR05_CL_BAPI_PGI DEFINITION
  INHERITING FROM ZF24GR05_CL_BAPI_ROOT
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    " Define types for message handling and protocol tables
    TYPES: RTY_T_PROTT TYPE STANDARD TABLE OF PROTT WITH EMPTY KEY,
           TY_T_PROTT  TYPE STANDARD TABLE OF PROTT.

    " Constructor for the class
    METHODS: CONSTRUCTOR.

    " Main method for posting goods issue deliveries
    METHODS:
      POST_GI_DELIVERY
        IMPORTING
          IT_DELIVERY            TYPE TY_T_DELIVERY
          IV_FLG_DISPLAY_MESSAGE TYPE ABAP_BOOL DEFAULT ABAP_TRUE
        RETURNING
          VALUE(RT_MESSAGE)      TYPE RTY_T_MESSAGE.

  PROTECTED SECTION.

  PRIVATE SECTION.

    " Helper methods for message handling
    METHODS:
      HANDLE_MULTI_MESSAGES
        IMPORTING
          IT_PROTT          TYPE TY_T_PROTT
        RETURNING
          VALUE(RT_MESSAGE) TYPE RTY_T_MESSAGE.

    METHODS:
      HANDLE_SINGLE_MESSAGE
        IMPORTING
          IV_PROTT          TYPE PROTT
        RETURNING
          VALUE(RS_MESSAGE) TYPE TY_MESSAGE.

    " Methods for posting goods issue for single or multiple deliveries
    METHODS:
      POST_SINGLE_GI
        IMPORTING
          IV_DELIVERY       TYPE TY_DELIVERY
        RETURNING
          VALUE(RT_MESSAGE) TYPE RTY_T_MESSAGE.

    METHODS:
      POST_MULTI_GI
        IMPORTING
          IT_DELIVERY       TYPE TY_T_DELIVERY
        RETURNING
          VALUE(RT_MESSAGE) TYPE RTY_T_MESSAGE.

    " Method to call the actual BAPI for goods issue
    METHODS:
      CALL_BAPI
        IMPORTING
          IV_DELIVERY     TYPE TY_DELIVERY
        RETURNING
          VALUE(RT_TABLE) TYPE RTY_T_PROTT.

    " Methods to fetch delivery-related information
    METHODS:
      FETCH_SINGLE_DELIVERY_INFO
        IMPORTING
          IV_DELIVERY        TYPE TY_DELIVERY
        RETURNING
          VALUE(RS_DELIVERY) TYPE LIKP.

    METHODS:
      FETCH_SINGLE_DELIVERY_MATDOC
        IMPORTING
          IV_DELIVERY      TYPE TY_DELIVERY
        RETURNING
          VALUE(RS_MATDOC) TYPE MSEG-MBLNR.

ENDCLASS.



CLASS ZF24GR05_CL_BAPI_PGI IMPLEMENTATION.


  METHOD CALL_BAPI.

    DATA: LS_VBKOK TYPE VBKOK.

    DATA: LT_PROTT TYPE TY_T_PROTT,
          LS_PROTT LIKE LINE OF LT_PROTT.

    DATA(LS_LIKP) = ME->FETCH_SINGLE_DELIVERY_INFO( IV_DELIVERY ).
    CHECK NOT LS_LIKP IS INITIAL.

    DATA(LV_VBELN) = LS_LIKP-VBELN.

    " Prepare BAPI parameters
    LS_VBKOK-VBELN_VL = LV_VBELN.
    LS_VBKOK-WABUC    = ABAP_TRUE.

    SET UPDATE TASK LOCAL.

    " Call the delivery update BAPI
    CALL FUNCTION 'WS_DELIVERY_UPDATE'
      EXPORTING
        VBKOK_WA                 = LS_VBKOK
        SYNCHRON                 = ABAP_TRUE
        NO_MESSAGES_UPDATE       = ABAP_FALSE
        UPDATE_PICKING           = ABAP_TRUE
        COMMIT                   = ABAP_FALSE
        DELIVERY                 = IV_DELIVERY
        NICHT_SPERREN            = ABAP_TRUE
        IF_ERROR_MESSAGES_SEND_0 = ABAP_TRUE
      TABLES
        PROT                     = LT_PROTT
*       et_created_hus           = ld_et_created_hus
      EXCEPTIONS
        ERROR_MESSAGE            = 1
        OTHERS                   = 2.

    " error happen
    IF SY-SUBRC <> 0.

      ROLLBACK WORK.

      LS_PROTT-MSGID = SY-MSGID.
      LS_PROTT-MSGTY = SY-MSGTY.
      LS_PROTT-MSGNO = SY-MSGNO.
      LS_PROTT-VBELN = LV_VBELN.
      LS_PROTT-MSGV1 = SY-MSGV1.
      LS_PROTT-MSGV2 = SY-MSGV2.
      LS_PROTT-MSGV3 = SY-MSGV3.
      LS_PROTT-MSGV4 = SY-MSGV4.

      APPEND LS_PROTT TO LT_PROTT.

    ENDIF.

    " Collect success messages if no errors
    IF LT_PROTT[] IS INITIAL.

      COMMIT WORK AND WAIT. " commit each delivery

      LS_PROTT-MSGID = 'VL'.
      LS_PROTT-MSGTY = 'S'.
      LS_PROTT-MSGNO = 746.
      LS_PROTT-VBELN = LV_VBELN.
      LS_PROTT-MSGV1 = 'Outbound Delivery'.
      LS_PROTT-MSGV2 = LV_VBELN.
      LS_PROTT-MSGV3 = ME->FETCH_SINGLE_DELIVERY_MATDOC( LV_VBELN ).
*      ls_prott-msgv4 = ''.

      APPEND LS_PROTT TO LT_PROTT.

      APPEND LV_VBELN TO T_SUCCESS_DELIVERY. " save success DO

    ELSE.

      APPEND LV_VBELN TO T_FAILED_DELIVERY.  " save faild DO

    ENDIF.

    IF SY-SUBRC = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'. " Đảm bảo commit được thực hiện ngay lập tức
    ENDIF.

    RT_TABLE = LT_PROTT.

  ENDMETHOD.


  METHOD CONSTRUCTOR.

    SUPER->CONSTRUCTOR( ).

  ENDMETHOD.


  METHOD FETCH_SINGLE_DELIVERY_INFO.

    " Fetch delivery information
    SELECT SINGLE *
      FROM LIKP
      WHERE
        VBELN = @IV_DELIVERY
      INTO @RS_DELIVERY.

    IF SY-SUBRC <> 0.
      " Outbound delivery &1 does not exist
      MESSAGE S326(ZF24GR05_MESSAGE)
        WITH IV_DELIVERY
        DISPLAY LIKE 'E'
        .
    ENDIF.

  ENDMETHOD. " fetch_single_delivery_info


  METHOD FETCH_SINGLE_DELIVERY_MATDOC.

    SELECT SINGLE MSEG~MBLNR
      FROM MSEG
      WHERE
        VBELN_IM = @IV_DELIVERY
      INTO @RS_MATDOC.

  ENDMETHOD. " fetch_single_delivery_matdoc


  METHOD HANDLE_MULTI_MESSAGES.

    LOOP AT IT_PROTT INTO DATA(WA).

      DATA(LS_MESSAGE) = ME->HANDLE_SINGLE_MESSAGE( WA ).
      APPEND LS_MESSAGE TO RT_MESSAGE.

    ENDLOOP.

  ENDMETHOD.


  METHOD HANDLE_SINGLE_MESSAGE.

    DATA: LS_MESSAGE TYPE TY_MESSAGE.

    DATA: LS_CELL_COLOR TYPE LVC_S_SCOL.
    LS_CELL_COLOR-FNAME = 'MSGTY'.
    LS_CELL_COLOR-COLOR-INT = 1.
    LS_CELL_COLOR-COLOR-INV = 0.

    " Message Formatting
    MESSAGE ID IV_PROTT-MSGID
            TYPE IV_PROTT-MSGTY
            NUMBER IV_PROTT-MSGNO
            WITH IV_PROTT-MSGV1
                 IV_PROTT-MSGV2
                 IV_PROTT-MSGV3
                 IV_PROTT-MSGV4
            INTO LS_MESSAGE-MSGTXT.

    LS_MESSAGE-DELIVERY = IV_PROTT-VBELN.
    LS_MESSAGE-MSGID    = IV_PROTT-MSGID.
    LS_MESSAGE-MSGTY    = IV_PROTT-MSGTY.
    LS_MESSAGE-MSGNO    = IV_PROTT-MSGNO.

    " Determine message color and icon based on type
    DATA(COLOR) = 0.
    DATA(ICON) = ICON_GREEN_LIGHT.

    IF LS_MESSAGE-MSGTY = 'E'.

      COLOR = 6. " Red
      ICON = ICON_RED_LIGHT.

    ELSEIF LS_MESSAGE-MSGTY = 'W'.

      COLOR = 7. " Orange
      ICON = ICON_YELLOW_LIGHT.

    ENDIF.

    LS_CELL_COLOR-COLOR-COL = COLOR.
    APPEND LS_CELL_COLOR TO LS_MESSAGE-CELL_COLOR.

    LS_MESSAGE-MSGTY_ICON = ICON.

    RS_MESSAGE = LS_MESSAGE.

  ENDMETHOD. " handle_single_message


  METHOD POST_GI_DELIVERY.

    RT_MESSAGE = ME->POST_MULTI_GI( IT_DELIVERY ).

    IF RT_MESSAGE IS NOT INITIAL.

      " remove duplicate item
      SORT RT_MESSAGE
        BY DELIVERY
           MSGID
           MSGTY
           MSGNO.
      DELETE ADJACENT DUPLICATES FROM RT_MESSAGE COMPARING ALL FIELDS.

      ME->DISPLAY_MSG(
        IS_DISPLAY = IV_FLG_DISPLAY_MESSAGE
        IT_MESSAGES = RT_MESSAGE
      ).

    ENDIF.

  ENDMETHOD.


  METHOD POST_MULTI_GI.

    LOOP AT IT_DELIVERY INTO DATA(WA).

      DATA(LT_MESSAGE) = ME->POST_SINGLE_GI( WA ).
      APPEND LINES OF LT_MESSAGE TO RT_MESSAGE.

    ENDLOOP.

  ENDMETHOD. " post_multi_gi


  METHOD POST_SINGLE_GI.

    DATA(LT_PROTT) = ME->CALL_BAPI( IV_DELIVERY ).
    APPEND LINES OF HANDLE_MULTI_MESSAGES( LT_PROTT ) TO RT_MESSAGE.

  ENDMETHOD. " post_single_gi
ENDCLASS.

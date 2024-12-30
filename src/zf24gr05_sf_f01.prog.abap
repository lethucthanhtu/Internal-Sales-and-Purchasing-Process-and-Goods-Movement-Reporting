*&---------------------------------------------------------------------*
*& Include          Z211_SF_F01
*& Function, Subroutine
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Check valid parametter
*&---------------------------------------------------------------------*
FORM is_valid_parametter.

  IF p_ebeln IS INITIAL.

    "Show error messsage without exit program
    MESSAGE I999(ZF24GR05_MESSAGE)
    DISPLAY LIKE 'I'.
    LEAVE LIST-PROCESSING.
*    MESSAGE 'Please enter a Purchase Order Number.'
*    TYPE 'I'.
*    LEAVE LIST-PROCESSING.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&  Spell total amount
*&---------------------------------------------------------------------*
FORM spell_amount.

  DATA: lv_last_index TYPE i,
        ls_spell      LIKE spell.

*FORM text_converter.
*  data(lo_converter) = new z211_cl_number_to_vietnamese( ).
*  data(lv_text) = lo_converter->number_to_vietnamese( iv_number =  ).
*ENDFORM.


  "Get index of the last item
  DESCRIBE TABLE gt_item_data1
    LINES lv_last_index.

  "Get the last item by index
  IF lv_last_index > 0.

    READ TABLE gt_item_data1
      INTO gs_item_data1
      INDEX lv_last_index.

    CALL FUNCTION 'SPELL_AMOUNT'
      EXPORTING
        amount    = gs_item_data1-total      "Take the total amount of last item to spell
        currency  = ' '
        filler    = ' '
        language  = sy-langu
      IMPORTING
        in_words  = ls_spell
      EXCEPTIONS
        not_found = 1
        too_large = 2
        OTHERS    = 3.

    IF sy-subrc <> 0.
      WRITE:/ 'Error: ' , sy-subcs.
    ELSE.

      " At this point, the value returned by the 'word' variable is in all uppercase.
      " Convert 'word' to lowercase and
      " assign it to the 'in_words' field in the structure used for
      gs_item_data1-in_words = ls_spell-word.
      TRANSLATE gs_item_data1-in_words TO LOWER CASE.

      " Capitalize the first letter of the word.
      gs_item_data1-in_words =
        to_upper( gs_item_data1-in_words+0(1) )
          && gs_item_data1-in_words+1.

      "Add total amount by words into structure called by smartform
      MODIFY gt_item_data1
        FROM gs_item_data1
        INDEX lv_last_index.

    ENDIF.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&  Check decimal format of user's account who run program.
*&---------------------------------------------------------------------*
FORM define_decimal_format.

    DATA:
          lv_username   TYPE string.

    lv_username = sy-uname.

    SELECT DCPFM AS decformat
    FROM USR01
    WHERE BNAME = @lv_username
    INTO TABLE @DATA(lt_decformat).

    IF sy-subrc = 0.

      READ TABLE lt_decformat INTO DATA(ls_decformat) INDEX 1.
      gv_decformat = ls_decformat-decformat.

    ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&  Querying and processing data to pass into SmartForms.
*&---------------------------------------------------------------------*
FORM querry_and_process_data.

  DATA:
    lv_total  TYPE bwert VALUE 0,
    lv_index  TYPE i VALUE 1,
    lv_uprice TYPE stprs.


  "Fetch data for HEADER of smartform
  SELECT DISTINCT
    ekpo~ebeln   AS po_num,              "PO number
    kna1~name1   AS cusname,             "Customer name
    lips~lgort   AS storage_location,    "Storage Location
    t001w~name1  AS plant,               "Plant
    adrc~street  AS street,              "Street
    adrc~city1   AS city                 "City

  FROM likp
    LEFT JOIN lips
      ON lips~vbeln = likp~vbeln

    LEFT JOIN ekpo
      ON  ekpo~ebeln = lips~vgbel       "Cant join bc ekpo~ebeln length 5 and lips~vgbel length 6
      AND substring( lips~vgpos, 2, 5 ) = ekpo~ebelp

    LEFT JOIN kna1
      ON likp~kunnr = kna1~kunnr

    LEFT JOIN t001w
      ON ekpo~werks = t001w~werks

    LEFT JOIN adrc
      ON kna1~adrnr = adrc~addrnumber

    LEFT JOIN ekko
     	ON ekpo~ebeln = ekko~ebeln

  WHERE
        ekpo~ebeln = @p_ebeln
    AND ekko~bsart = 'UB'              "Filter type 'UB'for PO
*    AND ekpo~ebelp = '10'

  INTO TABLE @gt_header_data.


  IF sy-subrc <> 0.

    " Show a message when the user enters a Purchasing Order Number and runs the program,
    " but that Purchasing Order Number is not valid for creating a delivery payslip.
    MESSAGE I998(ZF24GR05_MESSAGE)
    DISPLAY LIKE 'I'.
    LEAVE LIST-PROCESSING.

  ENDIF.


  " Modify the field values to ensure they are accurate and appropriate for use in the SmartForm.
  LOOP AT gt_header_data INTO gs_header_data.

    gs_header_data1-po_num           = gs_header_data-po_num.
    gs_header_data1-cusname          = gs_header_data-cusname.
    gs_header_data1-storage_location = gs_header_data-storage_location.
    gs_header_data1-plant            = gs_header_data-plant.

    " Combine 'street' and 'city' into the 'location' field.
    CONCATENATE gs_header_data-street
                gs_header_data-city
      INTO gs_header_data1-location
          SEPARATED BY ', '.

    APPEND gs_header_data1 TO gt_header_data1.

  ENDLOOP.


  "Fetch data for ITEM of smartform
  IF gt_header_data1 IS NOT INITIAL.

    SELECT
      ekpo~txz01  AS proname,       "Product name
      ekpo~matnr  AS procode,       "Product code
      ekpo~meins  AS uom,           "Unit of measure
      lips~lfimg  AS proreq,        "Number of product requirement
      lips~lgmng  AS proout,        "Number of product out
      mbew~vprsv  AS pricontrol,    "Pricing control
      mbew~stprs  AS sprice,        "Standard price
      mbew~verpr  AS vprice,        "Moving average price
      t001~waers  AS currency,      "Currency
      mseg~dmbtr  AS amount         "Amount

    FROM ekpo

      LEFT JOIN ekbe
        ON ekpo~ebeln    = ekbe~ebeln
          AND ekpo~ebelp = ekbe~ebelp

      " Cant join bc lips~vgpos have length 6, ekpo~ebelp length 5
      LEFT JOIN lips
        ON ekpo~ebeln = lips~vgbel
          AND substring( lips~vgpos, 2, 5 ) = ekpo~ebelp

      LEFT JOIN likp
        ON lips~vbeln    = likp~vbeln
          AND likp~gbstk = 'C'

      LEFT JOIN mbew
        ON ekpo~matnr    = mbew~matnr
          AND ekpo~werks = mbew~bwkey

      LEFT JOIN t001
        ON ekpo~bukrs = t001~bukrs

      INNER JOIN mseg
        ON ekbe~belnr    = mseg~mblnr
          AND ekbe~buzei = mseg~zeile
          AND ekbe~gjahr = mseg~mjahr

      JOIN @gt_header_data1 AS gt_header_data_temp
        ON ekpo~ebeln = gt_header_data_temp~po_num

    WHERE ekbe~bwart = '641'
      AND mseg~lgort IN ('RW1', 'TG1', 'FG1',     "Find correctly item in these sloc
                         'RW2', 'TG2', 'FG2',
                         'RW3', 'TG3', 'FG3')

    INTO TABLE @gt_item_data.

  ENDIF.


  " Process data
*  DO 35 TIMES.

  " Modify the field values to ensure they are accurate and appropriate for use in the SmartForm.
  LOOP AT gt_item_data INTO gs_item_data.

    " Value 'lv_index' is 1 for first item plus 1 for every item
    gs_item_data-stt = lv_index.

    gs_item_data1-proname = gs_item_data-proname.
    gs_item_data1-procode = gs_item_data-procode.
    gs_item_data1-uom     = gs_item_data-uom.

    " Modify field product requirement to use in smartform
    WRITE gs_item_data-proreq TO gs_item_data1-proreq.

    CASE gv_decformat.
      WHEN ' '.
        "Delete value after ','
        FIND ','
          IN gs_item_data1-proreq
            MATCH OFFSET DATA(lv_proreq_commas_index).

        IF sy-subrc = 0.
          gs_item_data1-proreq = gs_item_data1-proreq(lv_proreq_commas_index).
        ENDIF.


      WHEN 'X'.
        FIND '.'
          IN gs_item_data1-proreq
            MATCH OFFSET DATA(lv_proreq_dot_index).

        IF sy-subrc = 0.
          gs_item_data1-proreq = gs_item_data1-proreq(lv_proreq_dot_index).
        ENDIF.


      WHEN 'Y'.
        FIND ','
          IN gs_item_data1-proreq
            MATCH OFFSET DATA(lv_proreq_commas1_index).

        IF sy-subrc = 0.
          gs_item_data1-proreq = gs_item_data1-proreq(lv_proreq_commas1_index).
        ENDIF.

      ENDCASE.

    CONDENSE gs_item_data1-proreq.


    " Modify field product requirement to use in smartform
    WRITE gs_item_data-proout TO gs_item_data1-proout.

    CASE gv_decformat.

      WHEN ' '.
       FIND ','
         IN gs_item_data1-proout
           MATCH OFFSET DATA(lv_proout_commas_index).

       IF sy-subrc = 0.
         gs_item_data1-proout = gs_item_data1-proout(lv_proout_commas_index).
       ENDIF.


      WHEN 'X'.
        FIND '.'
          IN gs_item_data1-proout
            MATCH OFFSET DATA(lv_proout_dot_index).

        IF sy-subrc = 0.
          gs_item_data1-proout = gs_item_data1-proout(lv_proout_dot_index).
        ENDIF.


      WHEN 'Y'.
        FIND ','
          IN gs_item_data1-proout
            MATCH OFFSET DATA(lv_proout_commas1_index).

        IF sy-subrc = 0.
          gs_item_data1-proout = gs_item_data1-proout(lv_proout_commas1_index).
        ENDIF.
    ENDCASE.

    CONDENSE gs_item_data1-proout.


    "The unit price is determined based on the price control.
    CASE gs_item_data-pricontrol.

      WHEN 'S'.
*      gs_item_data1-uprice = gs_item_data-sprice.
        lv_uprice = gs_item_data-sprice.

      WHEN 'V'.
*      gs_item_data1-uprice = gs_item_data-vprice.
        lv_uprice = gs_item_data-vprice.

      WHEN OTHERS.

    ENDCASE.

    " Modify field unit price to use in smartform
    WRITE lv_uprice
      TO gs_item_data1-uprice
        CURRENCY gs_item_data-currency.

    CASE gv_decformat.
      WHEN ' '.
        FIND ','
          IN gs_item_data1-uprice
            MATCH OFFSET DATA(lv_uprice_commas_index).

        IF sy-subrc = 0.

          gs_item_data1-uprice = gs_item_data1-uprice(lv_uprice_commas_index).

        ENDIF.

      WHEN 'X'.
       FIND '.'
         IN gs_item_data1-uprice
           MATCH OFFSET DATA(lv_uprice_dot_index).

       IF sy-subrc = 0.

         gs_item_data1-uprice = gs_item_data1-uprice(lv_uprice_dot_index).

       ENDIF.

      WHEN 'Y'.
       FIND ','
         IN gs_item_data1-uprice
           MATCH OFFSET DATA(lv_uprice_commas1_index).

       IF sy-subrc = 0.

         gs_item_data1-uprice = gs_item_data1-uprice(lv_uprice_commas1_index).

       ENDIF.
    ENDCASE.


    CONDENSE gs_item_data1-uprice.


    " Modify field amount to use in smartform
    WRITE gs_item_data-amount
      TO gs_item_data1-amount
        CURRENCY gs_item_data-currency.

    CASE gv_decformat.
      WHEN ' '.
        FIND ','
          IN gs_item_data1-amount
            MATCH OFFSET DATA(lv_amount_commas_index).

        IF sy-subrc = 0.

          gs_item_data1-amount = gs_item_data1-amount(lv_amount_commas_index).

        ENDIF.


      WHEN 'X'.
        FIND '.'
          IN gs_item_data1-amount
            MATCH OFFSET DATA(lv_amount_dot_index).

        IF sy-subrc = 0.

          gs_item_data1-amount = gs_item_data1-amount(lv_amount_dot_index).

        ENDIF.


      WHEN 'Y'.
        FIND ','
          IN gs_item_data1-amount
            MATCH OFFSET DATA(lv_amount_commas1_index).

        IF sy-subrc = 0.

          gs_item_data1-amount = gs_item_data1-amount(lv_amount_commas1_index).

        ENDIF.

    ENDCASE.

    CONDENSE gs_item_data1-amount.


    lv_total += gs_item_data-amount.


    " Modify field total to use in smartform
    WRITE lv_total
      TO gs_item_data1-total
        CURRENCY gs_item_data-currency.

    CASE gv_decformat.
      WHEN ' '.
        FIND ','
          IN gs_item_data1-total
            MATCH OFFSET DATA(lv_total_commas_index).

        IF sy-subrc = 0.

          gs_item_data1-total = gs_item_data1-total(lv_total_commas_index).

        ENDIF.


      WHEN 'X'.
        FIND '.'
          IN gs_item_data1-total
            MATCH OFFSET DATA(lv_total_dot_index).

        IF sy-subrc = 0.

          gs_item_data1-total = gs_item_data1-total(lv_total_dot_index).

        ENDIF.


      WHEN 'Y'.
        FIND ','
          IN gs_item_data1-total
            MATCH OFFSET DATA(lv_total_commas1_index).

        IF sy-subrc = 0.

          gs_item_data1-total = gs_item_data1-total(lv_total_commas1_index).

        ENDIF.

    ENDCASE.

    CONDENSE gs_item_data1-total.


    " Modify field stt to use in smartform
    WRITE gs_item_data-stt TO gs_item_data1-stt.

    CONDENSE gs_item_data1-stt.

*    DATA: lv_amount1 TYPE bwert.
*    WRITE gs_item_data1-amount TO lv_amount1.

    APPEND gs_item_data1 TO gt_item_data1.

    lv_index = lv_index + 1.

  ENDLOOP.

*    ENDDO.

ENDFORM.


*&---------------------------------------------------------------------*
*&  Retrieve the name of the function module generated from an SmartForm
*&---------------------------------------------------------------------*
FORM call_sf_by_function_module.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'ZF24GR05_SMARTFORMS'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      fm_name            = gv_fname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.

* Implement suitable error handling here

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&  Call smarforms with no OTF
*&---------------------------------------------------------------------*
FORM call_sf_with_no_otf.

  "" Some input before run smartform
  gs_control_parameter-no_dialog = 'X'.
  gs_control_parameter-preview   = 'X'.
  gs_output_option-tddest        = 'LOCL'.

*TRY.

  CALL FUNCTION gv_fname
    EXPORTING
*     ARCHIVE_INDEX         =
*     ARCHIVE_INDEX_TAB     =
*     ARCHIVE_PARAMETERS    =
      control_parameters   = gs_control_parameter
*     MAIL_APPL_OBJ         =
*     MAIL_RECIPIENT        =
*     MAIL_SENDER           =
      output_options       = gs_output_option
      user_settings        = ' '
      lt_header            = gt_header_data1
      lt_item              = gt_item_data1
    IMPORTING
      document_output_info = gs_document_output_info
*     JOB_OUTPUT_INFO            =
*     JOB_OUTPUT_OPTIONS         =
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4
      OTHERS               = 5
      .

  IF sy-subrc <> 0.

* Implement suitable error handling here

  ENDIF.

*CATCH cx_root INTO DATA(lx_msg).

*  MESSAGE lx_msg->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.

*ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*&  Call Smartforms with OTF
*&---------------------------------------------------------------------*
FORM call_smartforms_with_otf.

  "" Some input before run smartform
  gs_control_parameter-no_dialog = 'X'.
  gs_control_parameter-preview   = 'X'.
  gs_control_parameter-getotf    = 'X'.
  gs_output_option-tddest        = 'LOCL'.

*TRY.

  CALL FUNCTION gv_fname
    EXPORTING
*     ARCHIVE_INDEX        =
*     ARCHIVE_INDEX_TAB    =
*     ARCHIVE_PARAMETERS   =
      control_parameters   = gs_control_parameter
*     MAIL_APPL_OBJ        =
*     MAIL_RECIPIENT       =
*     MAIL_SENDER          =
      output_options       = gs_output_option
      user_settings        = ' '
      lt_header            = gt_header_data1
      lt_item              = gt_item_data1
    IMPORTING
      document_output_info = gs_document_output_info
      job_output_info      = gs_job_output_info
      job_output_options   = gs_job_output_option
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4
      OTHERS               = 5
      .

  IF sy-subrc <> 0.

* Implement suitable error handling here

  ENDIF.

*CATCH cx_root INTO DATA(lx_msg).

*  MESSAGE lx_msg->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.

*ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*&  Convert file to pdf
*&---------------------------------------------------------------------*
FORM call_convert_otf.

  CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      format                = 'PDF'
*   MAX_LINEWIDTH               = 132
*   ARCHIVE_INDEX               = ' '
*   COPYNUMBER                  = 0
*   ASCII_BIDI_VIS2LOG          = ' '
*   PDF_DELETE_OTFTAB           = ' '
*   PDF_USERNAME                = ' '
*   PDF_PREVIEW                 = ' '
*   USE_CASCADING               = ' '
*   MODIFIED_PARAM_TABLE        =
* IMPORTING
*   BIN_FILESIZE                =
*   BIN_FILE                    =
    TABLES
      otf                   = gs_job_output_info-otfdata
      lines                 = gt_lines_pdf
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      err_bad_otf           = 4
      OTHERS                = 5
      .

  IF sy-subrc <> 0.

* Implement suitable error handling here

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&  Naming file when download PDF
*&---------------------------------------------------------------------*
FORM naming_file.

  DATA:
    lv_name_of_pdf TYPE string,
    lv_filter      TYPE string,
    lv_path        TYPE string,
    lv_user_action TYPE i,
    lo_guiobj      TYPE REF TO cl_gui_frontend_services.


  CONCATENATE 'SmartForm' '.pdf' INTO lv_name_of_pdf.
  CREATE OBJECT lo_guiobj.


  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      default_extension         = 'pdf'
      default_file_name         = lv_name_of_pdf
      file_filter               = lv_filter
    CHANGING
      filename                  = lv_name_of_pdf
      path                      = lv_path
      fullpath                  = gv_full_path
      user_action               = lv_user_action
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
      OTHERS                    = 5
      .

  IF sy-subrc <> 0.

*   Implement suitable error handling here

  ENDIF.

  IF lv_user_action = lo_guiobj->action_cancel.

    EXIT.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&  Download smartforms to file PDF
*&---------------------------------------------------------------------*
FORM call_gui_download.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*   BIN_FILESIZE                    =
      filename                = gv_full_path
      filetype                = 'BIN'
*   APPEND                          = ' '
*   WRITE_FIELD_SEPARATOR           = ' '
*   HEADER                          = '00'
*   TRUNC_TRAILING_BLANKS           = ' '
*   WRITE_LF                        = 'X'
*   COL_SELECT                      = ' '
*   COL_SELECT_MASK                 = ' '
*   DAT_MODE                        = ' '
*   CONFIRM_OVERWRITE               = ' '
*   NO_AUTH_CHECK                   = ' '
*   CODEPAGE                        = ' '
*   IGNORE_CERR                     = ABAP_TRUE
*   REPLACEMENT                     = '#'
*   WRITE_BOM                       = ' '
*   TRUNC_TRAILING_BLANKS_EOL       = 'X'
*   WK1_N_FORMAT                    = ' '
*   WK1_N_SIZE                      = ' '
*   WK1_T_FORMAT                    = ' '
*   WK1_T_SIZE                      = ' '
*   WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
*   SHOW_TRANSFER_STATUS            = ABAP_TRUE
*   VIRUS_SCAN_PROFILE              = '/SCET/GUI_DOWNLOAD'
* IMPORTING
*   FILELENGTH                      =
    TABLES
      data_tab                = gt_lines_pdf
*   FIELDNAMES                      =
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22
      .

  IF sy-subrc <> 0.

*   Implement suitable error handling here

  ENDIF.

ENDFORM.


FORM value_help.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'EBELN'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'p_ebeln'
      value_org       = 'S'
    TABLES
      value_tab       = gt_header_data
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.

* Implement suitable error handling here

  ENDIF.

ENDFORM.

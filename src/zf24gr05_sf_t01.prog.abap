*&---------------------------------------------------------------------*
*&
*& Include          Z211_SF_T01
*& Datatype, parametter
*&
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Create Strure
*&---------------------------------------------------------------------*

" Create structue of header
TYPES:
      BEGIN OF gty_header_data,
         po_num           TYPE ebeln,
         cusname          TYPE name1_gp,
         storage_location TYPE lgort_d,
         plant            TYPE name1,
         street           TYPE ad_street,
         city             TYPE ad_city1,
      END OF gty_header_data.

" Convert header structure to use in smartforms
TYPES:
      BEGIN OF gty_header_data1,
        po_num           TYPE ebeln,
        cusname          TYPE name1_gp,
        storage_location TYPE lgort_d,
        plant            TYPE name1,
        location         TYPE char255,
      END OF gty_header_data1.

" Create structue of item
TYPES:
      BEGIN OF gty_item_data,
        proname    TYPE txz01,
        procode    TYPE matnr,
        uom        TYPE bstme,
        proreq     TYPE bstmg,
        proout     TYPE menge_d,
        pricontrol TYPE vprsv,
        sprice     TYPE stprs,
        vprice     TYPE verpr,
        currency   TYPE waers,
        amount     TYPE bwert,
        stt        TYPE i,
      END OF gty_item_data.

" Convert item structure to use in smartforms
TYPES:
      BEGIN OF gty_item_data1,
         proname  TYPE txz01,
         procode  TYPE matnr,
         uom      TYPE bstme,
         proreq   TYPE char16,
         proout   TYPE char16,
         uprice   TYPE char16,
         amount   TYPE char16,
         total    TYPE char16,
         stt      TYPE char16,
         in_words TYPE in_words,
       END OF gty_item_data1.

" Create constants for print choice
CONSTANTS: gc_true TYPE sap_bool VALUE abap_true.

" Create a structure to store the value of each display option.
CONSTANTS:
          BEGIN OF gty_display,
            print_preview TYPE i VALUE 1,
            print_locally TYPE i VALUE 2,
          END OF gty_display.


*&---------------------------------------------------------------------*
*& Declare data, internal table, work space,...
*&---------------------------------------------------------------------*

" Internal table & workspace for header use in program
TYPES: gty_t_gty_header_data TYPE TABLE OF gty_header_data.

DATA:
      gt_header_data    TYPE gty_t_gty_header_data,
      gs_header_data    TYPE gty_header_data.


" Internal table & workspace for header use in smartforms
TYPES: gty_t_gty_header_data1 TYPE TABLE OF gty_header_data1.

DATA:
      gt_header_data1   TYPE gty_t_gty_header_data1,
      gs_header_data1   TYPE gty_header_data1.


" Internal table & workspace for item use in program
TYPES: gty_t_gty_item_data TYPE TABLE OF gty_item_data.

DATA:
      gt_item_data      TYPE gty_t_gty_item_data,
      gs_item_data      TYPE gty_item_data.

" Internal table & workspace for item use in smartforms
TYPES: gty_t_gty_item_data1 TYPE TABLE OF gty_item_data1.

DATA:
      gt_item_data1     TYPE gty_t_gty_item_data1,
      gs_item_data1     TYPE gty_item_data1.


" Internal table & workspace for other module function in program
TYPES: gty_t_tline TYPE TABLE OF tline.

DATA:
      gt_lines_pdf            TYPE gty_t_tline,
      gs_control_parameter    TYPE ssfctrlop,
      gs_output_option        TYPE ssfcompop,
      gs_job_output_info      TYPE ssfcrescl,
      gs_job_output_option    TYPE ssfcresop,
      gs_document_output_info TYPE ssfcrespd.


" Declare varian to use in program
DATA:
      gv_display    TYPE i,
      gv_fname      TYPE rs38l_fnam,
      gv_full_path  TYPE string,
      gv_decformat  TYPE string.
*      lr_packed TYPE REF TO data.
*      lv_decim TYPE numc12 VALUE 0,


" Declare field-symbols to use in program
*FIELD-SYMBOLS: <fs_packed> TYPE any.
*DATA: V_LANGUAGE    type SFLANGU value 'E',
*      V_E_DEVTYPE   type RSPOPTYPE.


*&---------------------------------------------------------------------*
*& SELECTION-SCREEN
*&---------------------------------------------------------------------*

*PARAMETERS:
*            lv_ebeln TYPE ekpo-ebeln,

*            " Preview Print
*            lv_pp    RADIOBUTTON GROUP grp1 DEFAULT 'X',

*            " Local Print
*            lv_lp    RADIOBUTTON GROUP grp1.


" Place each part of the parameter into separate blocks
" using WITH FRAME TITLE to make it clearer for the user to understand their selection,
" while also improving the visual layout.
SELECTION-SCREEN BEGIN OF BLOCK input WITH FRAME TITLE usr_in.

  " Quick value help for for field
  " Purchasing Order Number ( EBELN )from table EKPO.
  PARAMETERS: p_ebeln TYPE ekpo-ebeln.

SELECTION-SCREEN END OF BLOCK input.


SELECTION-SCREEN BEGIN OF BLOCK radio WITH FRAME TITLE rad_in.

  PARAMETERS:
              "Preview Print
              lv_pp    RADIOBUTTON GROUP grp1 DEFAULT 'X',

              "Local Print
              lv_lp    RADIOBUTTON GROUP grp1.

SELECTION-SCREEN END OF BLOCK radio.


*&---------------------------------------------------------------------*
*& INITIALIZATION
*&---------------------------------------------------------------------*

" INITIALIZATION is used to set the value for the
" FRAME TITLE of the parameter block.
INITIALIZATION.
  usr_in = TEXT-001.
  rad_in = TEXT-002.

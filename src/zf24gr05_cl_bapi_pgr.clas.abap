class zf24gr05_cl_bapi_pgr definition
  inheriting from zf24gr05_cl_bapi_root
  public
  final
  create public .

  public section.

    " Warpper type
*    types: begin of ZF24GR05_S_PGR,
*             vbeln type vbeln_vl,  " Delivery
*             matnr type matnr,     " Material Number
*             werks type werks_d,   " Plant
*             lgort type lgort_d,   " Storage Location
*             lfimg type lfimg,     " Delivered Quantity
*             vrkme type vrkme,     " Unit of Measure
*             charg type charg_d,   " Batch Number
*             lichn type lichn,     " Supplier Batch Number
*             vfdat type vfdat,     " Expiration Date
*             hsdat type hsdat,     " Manufacture Date
*             vgbel type vgbel,     " Purchasing Document
*             vgpos type vgpos,     " Purchasing Item
*             posnr type posnr_vl,  " Delivery Item
*             meins type meins,     " Base Unit of Measure
*           end of ZF24GR05_S_PGR.
    " Wrapper type for delivery item details
    types: ty_item type ZF24GR05_S_PGR.


    types: rty_t_item type table of ty_item with empty key,
           ty_t_item  type table of ty_item.

    types: rty_t_bapi2017_gm_item_create type table of bapi2017_gm_item_create with empty key,
           ty_t_bapi2017_gm_item_create  type table of bapi2017_gm_item_create.

    types: rty_t_bapiret2 type table of bapiret2 with empty key,
           ty_t_bapiret2  type table of bapiret2.

    " Output fields
    data: c_mblnr     type mblnr,        " Material Document Number
          c_gr_status type c.            " Status of Goods Receipt

    methods: constructor.

    methods:
      post_gr_delivery
        importing
          it_delivery     type ty_t_delivery
          iv_display      type abap_bool default abap_true
        returning
          value(rt_table) type ty_t_message.

  protected section.
    " Fetch delivery item details from SAP tables
    methods:
      fetch_items
        importing
          iv_vbeln        type ty_delivery
        returning
          value(rt_table) type rty_t_item.

    " Prepare items for BAPI goods receipt processing
    methods:
      process_items
        importing
          it_items        type ty_t_item
        returning
          value(rt_table) type rty_t_bapi2017_gm_item_create.

    " Execute BAPI for goods receipt posting
    methods:
      call_bapi
        importing
          ix_header          type bapi2017_gm_head_01
          ix_code            type bapi2017_gm_code
          it_processed_items type ty_t_bapi2017_gm_item_create
          iv_vbeln           type ty_delivery
        returning
          value(rt_table)    type ty_t_message.

    " Post goods receipt for a single delivery
    methods:
      post_single_gr
        importing
          iv_delivery       type ty_delivery
        returning
          value(rt_message) type ty_t_message.

    " Post goods receipt for multiple deliveries
    methods:
      post_multi_gr
        importing
          it_delivery       type ty_t_delivery
        returning
          value(rt_message) type ty_t_message.

  private section.

    " BAPI input parameters and extension data
    data: lx_header      type bapi2017_gm_head_01,
          lx_return      type bapiret2,
          lx_code        type bapi2017_gm_code,
          ls_extensionin type bapiparex,
          lt_extensionin type table of bapiparex.

     " Constants for processing and messaging
    constants: c_mvt_code type gm_code value '01', " Movement type for GR
               c_error    type char01  value 'E',  " Error flag
               c_x        type char01  value 'X'.  " Commit flag

    " Handle multiple BAPI messages
    methods:
      handle_multi_messages
        importing
          it_bapiret2        type ty_t_bapiret2
          iv_vbeln           type ty_delivery
        returning
          value(rt_messages) type ty_t_message.

    " Handle single BAPI message
    methods:
      handle_single_message
        importing
          iv_bapiret2       type bapiret2
          iv_vbeln          type ty_delivery
        returning
          value(rs_message) type ty_message.

ENDCLASS.



CLASS ZF24GR05_CL_BAPI_PGR IMPLEMENTATION.


  method call_bapi.

    " Local variables for BAPI return messages and processing
    data: lt_bapiret2 type table of bapiret2,
          ls_bapiret2 like line of lt_bapiret2,
          ls_message  like line of rt_table.

    data(lt_processed) = it_processed_items.

    " Call BAPI for Goods Movement Creation
    call function 'BAPI_GOODSMVT_CREATE'
      exporting
        goodsmvt_header  = ix_header
        goodsmvt_code    = ix_code
*        testrun          = abap_true
      importing
        materialdocument = c_mblnr
      tables
        goodsmvt_item    = lt_processed
        return           = lt_bapiret2
        extensionin      = lt_extensionin.

    " Check for errors
    read table lt_bapiret2
      into data(ls_bapi_output)
      with key type = c_error.

    " Process successful scenario
    if sy-subrc <> 0.
      " Commit the transaction
      call function 'BAPI_TRANSACTION_COMMIT'
        exporting
          wait = c_x.

      ls_message-delivery = iv_vbeln.
      ls_message-msgid = sy-msgid.
      ls_message-msgno = sy-msgno.
      ls_message-msgty = sy-msgty.

      message s350(ZF24GR05_MESSAGE)
        with c_mblnr
        into ls_message-msgtxt. " 'Goods receipt posted successfully. Document Number:' && c_mblnr.

      ls_message-msgty_icon = icon_green_light.

      append ls_message to rt_table.

      " Save success delivery
      append iv_vbeln to t_success_delivery.

    else.
      " Rollback the transaction
      call function 'BAPI_TRANSACTION_ROLLBACK'
*       IMPORTING
*         RETURN        =
        .

      " Save error delivery
      append iv_vbeln to t_failed_delivery.

    endif.

    " Handle and append all return messages
    append lines of
     handle_multi_messages(
       it_bapiret2 = lt_bapiret2
       iv_vbeln = iv_vbeln
     )
     to rt_table.

  endmethod. " call_bapi


  method constructor.

    super->constructor( ).

  endmethod. " constructor


  method fetch_items.

    select distinct
         lips~vbeln,
         lips~posnr,
         lips~meins,
         lips~matnr,
         lips~lfimg,
         lips~vrkme,
         ekpo~lgort,
         lips~charg,
         lips~lichn,
         lips~vfdat,
         lips~hsdat,
         lips~vgbel,
         lips~vgpos,
         ekpo~werks

    from lips

    join likp
      on likp~vbeln = lips~vbeln

    left join ekpo
        on ekpo~ebeln = lips~vgbel

    inner join mchb
        on      lips~matnr = mchb~matnr
*            AND lips~WERKS = MCHB~WERKS
            and ekpo~lgort = mchb~lgort
            and lips~charg = mchb~charg

    where
        likp~vbeln = @iv_vbeln

    into corresponding fields of table @rt_table.

    " Handle scenario where no items are found
    if sy-subrc <> 0.

      " No item(s) found for PO number: &1
      message S376(ZF24GR05_MESSAGE)
        DISPLAY LIKE  'E'.

      return.

    endif.

  endmethod. " fetch_items


  method handle_multi_messages.

    " Process each BAPI return message
    loop at it_bapiret2 into data(wa).

      " Convert individual message
      data(ls_message) =
        me->handle_single_message(
          iv_bapiret2 = wa
          iv_vbeln    = iv_vbeln
        ).
      append ls_message to rt_messages.

    endloop.

  endmethod. "handle_multi_messages


  method handle_single_message.

    data: ls_message type ty_message.

    " Message Formatting
    message id iv_bapiret2-id
            type iv_bapiret2-type
            number iv_bapiret2-number
            with iv_bapiret2-message_v1
                 iv_bapiret2-message_v2
                 iv_bapiret2-message_v3
                 iv_bapiret2-message_v4
            into ls_message-msgtxt.

    " Populate message details
    ls_message-delivery = iv_vbeln.
    ls_message-msgid    = iv_bapiret2-id.
    ls_message-msgty    = iv_bapiret2-type.
    ls_message-msgno    = iv_bapiret2-number.

    " Select icon based on message type
    data(icon) = icon_green_light.

    if ls_message-msgty = 'E'.

      " Error message - red icon
      icon = icon_red_light.

    elseif ls_message-msgty = 'W'.

      " Warning message - yellow icon
      icon = icon_yellow_light.

    endif.

    ls_message-msgty_icon = icon.

    rs_message = ls_message.

  endmethod. " handle_single_message


  method post_gr_delivery.

    " Post goods receipt for multiple deliveries
    rt_table = me->post_multi_gr( it_delivery ).

    " Remove duplicate rt_table
    delete adjacent duplicates
      from rt_table
      comparing all FIELDS.

    " Optional display of messages
    me->display_msg(
      it_messages = rt_table
      is_display = iv_display
    ).

  endmethod. " post_gr_delivery


  method post_multi_gr.

    " Process goods receipt for each delivery
    loop at it_delivery into data(wa).

      " Post goods receipt for single delivery
      data(lt_message) = me->post_single_gr( wa ).
      append lines of lt_message to rt_message.

    endloop.

  endmethod. " post_multi_gr


  method post_single_gr.

    " Fetch delivery items
    data(lt_items) = me->fetch_items( iv_delivery ).

    " Prepare header information
    lx_header-pstng_date = sy-datum.    " Posting date
    lx_header-doc_date   = sy-datum.    " Document date
    lx_header-ref_doc_no = iv_delivery. " Reference Document Number

    " Set movement code for goods receipt
    lx_code-gm_code = c_mvt_code.       " Goods movement code

    " Process each item
    data(lt_processed) = me->process_items( lt_items ).

    " Call BAPI_GOODSMVT_CREATE to post goods receipt
    data(lt_delivery_messages) =
      me->call_bapi(
        ix_header          = lx_header
        ix_code            = lx_code
        it_processed_items = lt_processed
        iv_vbeln           = iv_delivery
      ).

    rt_message = lt_delivery_messages.

  endmethod. " post_single_gr


  method process_items.

    loop at it_items into data(wa).

      " Retrieve ISO code for unit of measurement
      data: ld_isocode type isocd_unit. " ISO Code for Unit of Measurement

      select single
          isocode
        into @ld_isocode
        from t006
        where
          msehi = @wa-vrkme.

      IF sy-subrc <> 0.
        " No isocode found for Unit of Measure: &1
        MESSAGE S377(ZF24GR05_MESSAGE)
          WITH wa-vrkme
          DISPLAY LIKE 'E'
          .
      ENDIF.

      data: ls_item type bapi2017_gm_item_create.

      " Populate BAPI item details from delivery item
      ls_item-po_number   = wa-vgbel.      " Purchase Order number
      ls_item-po_item     = wa-vgpos.      " Item number
      ls_item-vendrbatch  = wa-lichn.      " Supplier Batch Number
      ls_item-move_type   = '101'.         " Movement type for goods receipt
      ls_item-mvt_ind     = 'B'.           " Movement indicator
      ls_item-plant       = wa-werks.   " Use Plant from PO
      ls_item-stge_loc    = wa-lgort.      " Storage location
      ls_item-material    = wa-matnr.      " Material number
      ls_item-batch       = wa-charg.      " Batch Number
      ls_item-entry_qnt   = wa-lfimg.      " Quantity
      ls_item-quantity    = wa-lfimg.
      ls_item-entry_uom   = wa-vrkme.      " Base Unit of Measure from material master
      ls_item-entry_uom_iso = ld_isocode.
      ls_item-expirydate   = wa-vfdat.
      ls_item-prod_date    = wa-hsdat.
      ls_item-deliv_numb   = wa-vbeln.
      ls_item-deliv_item   = wa-posnr.

      " Skip items without PO reference
      if wa-vgbel is not initial.

        append ls_item to rt_table.

      endif.

      " Prepare extension data
      ls_extensionin-structure  = 'BAPI_TE_XMSEG'.
      ls_extensionin-valuepart1+14(4) = '0001'.
      ls_extensionin-valuepart1+18(16) = wa-lfimg.
      ls_extensionin-valuepart1+34(3) = wa-vrkme.

      append ls_extensionin to lt_extensionin.

    endloop.

    " Check if we have any items to process
    if rt_table[] is initial.

      " No valid items found with PO reference.
      message S325(ZF24GR05_MESSAGE)
        DISPLAY LIKE 'E'.
      return.

    endif.

  endmethod. " process_items
ENDCLASS.

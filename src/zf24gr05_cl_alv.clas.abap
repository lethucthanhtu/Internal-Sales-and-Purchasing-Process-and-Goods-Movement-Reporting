class zf24gr05_cl_alv definition
  public
  final
  create public .

  public section.
* ==================== types ====================
    " Wrapper type
*    TYPES: BEGIN OF zf24gr05_s_alv,
*              DELIVERY                    type VBELN,
*              GOODS_ISSUE                 type MBLNR,
*              GOODS_ISSUE_TYPE            type BWART,
*              GOODS_ISSUE_STATUS          type CANCELLED,
*              GOODS_RECEIPT               type MBLNR,
*              GOODS_RECEIPT_TYPE          type BWART,
*              GOODS_RECEIPT_STATUS        type CANCELLED,
*              PRODUCT                     type MATNR,
*              BATCH                       type CHARG_D,
*              SLOC                        type LGORT_D,
*              DELIVERY_QUANTITY           type ORMNG,
*              DELIVERY_UOM                type VRKME,
*              PICKED_QUANTITY             type LFIMG,
*              PICKED_UOM                  type VRKME,
*              AVAILABLE_QUANTITY          type LABST,
*              AVAILABLE_UOM               type MEINS,
*              PICKING_DATE                type KODAT,
*              RECEIVING_PLANT             type WERKS_D,
*              SUPPLYING_PLANT             type WERKS_D,
*              PO_NUMBER                   type EBELN,
*              STOCK_IN_TRANSIT            type TRAME,
*              STOCK_IN_TRANSIT_UOM        type MEINS,
*              SHIPPING_POINT              type VSTEL,
*              PLANNED_GOODS_MOVEMENT_DATE type WADAK,
*              SHIP_TO_PARTY               type NAME1,
*              DELIVERY_ITEM               type POSNR,
*              STATUS(7),
*          END OF zf24gr05_s_alv.
    types: ty_s_raw type zf24gr05_s_alv,
           ty_t_raw type table of ty_s_raw.

    " ALV object type
    types: begin of ty_s_alv.
             include type ty_s_raw.                    "

    types: sel(3),                                     " select col (obsolete)
             line_color(4),                              " (obsolete)
             status_icon(4),                             "
             cell_color     type lvc_t_scol,       "
           end of ty_s_alv.

    " ALV table type
    types: rty_t_alv type table of ty_s_alv with empty key,
           ty_t_alv  type table of ty_s_alv.

    " Enum status
    types: begin of enum en_status structure stt,
             null   , " initial state
             open   , " [don't have GI] / [GI reverse]
             partial, " have GI & [don't have GR] / [GR reverse]
             close  , " have both GI & GR not reverse
             cancel,
           end of enum en_status structure stt.

    " Select options
    types: ty_r_product type range of ty_s_raw-product,
           ty_r_rplant  type range of ty_s_raw-receiving_plant,
           ty_r_splant  type range of ty_s_raw-supplying_plant,
           ty_r_sloc    type range of ty_s_raw-sloc,
           ty_r_ginr    type range of ty_s_raw-goods_issue,
           ty_r_grnr    type range of ty_s_raw-goods_receipt,
           ty_r_ponr    type range of ty_s_raw-po_number,
           ty_r_gidat   type range of ty_s_raw-planned_goods_movement_date,
           ty_r_grdat   type range of ty_s_raw-picking_date.

* ==================== data ====================
* # Class data
    class-data: t_alv type ty_t_alv.

* # Data

* ==================== ethods ====================
* # Class methods

* Methods
    methods:
      constructor
        importing
          ir_matnr type ty_r_product optional
          ir_splnt type ty_r_splant  optional
          ir_rplnt type ty_r_rplant  optional
          ir_sloc  type ty_r_sloc    optional
          ir_ginr  type ty_r_ginr    optional
          ir_grnr  type ty_r_grnr    optional
          ir_ponr  type ty_r_ponr    optional
          ir_gidat type ty_r_gidat   optional
          ir_grdat type ty_r_grdat   optional
        .

    methods display.

    methods:
      get_t_alv
        returning
          value(rt_table) type rty_t_alv.

  protected section.
* ==================== types ====================
*    types: ty_t_delivery type zf24gr05_cl_bapi_root=>ty_t_delivery.

* ==================== data ====================
* # Class data

* # Data
    data: lt_fieldcat type lvc_t_fcat,
          ls_layout   type ref to cl_salv_form_element.

    data: lo_events   type ref to cl_salv_events_table.

    data: lt_bdcdata type table of bdcdata,
          ls_bdcdata type bdcdata.

*    class-data: lo_alv type ref to cl_salv_table.
    data: lo_alv type ref to cl_salv_table.

*    class-data: r_matnr type ty_r_product,
    data: r_matnr type ty_r_product,
          r_splnt type ty_r_splant,
          r_rplnt type ty_r_rplant,
          r_sloc  type ty_r_sloc,
          r_ginr  type ty_r_ginr,
          r_grnr  type ty_r_grnr,
          r_ponr  type ty_r_ponr,
          r_gidat type ty_r_gidat,
          r_grdat type ty_r_grdat.

* ==================== methods ====================
* # Class methods

* # Methods
    methods:
      build_header,
      build_fieldcat,
      build_pf_status,
      build_status_col,
      build_picked_quan_col,
      build_display.

    methods:
      build_group
        importing
          iv_column type string.

    methods:
      build_layout
        importing
          iv_group_column type string optional.

*    class-methods:
    methods:
      post_gi
        importing
          it_delivery type zf24gr05_cl_bapi_root=>ty_t_delivery.

*    class-methods:
    methods:
      post_gr
        importing
          it_delivery       type zf24gr05_cl_bapi_root=>ty_t_delivery
        returning
          value(rt_message) type zf24gr05_cl_bapi_root=>ty_t_message.

    " fetch data
*    class-methods:
    methods:
      fetch_data
        importing
          ir_matnr        type ty_r_product
          ir_splnt        type ty_r_splant
          ir_rplnt        type ty_r_rplant
          ir_sloc         type ty_r_sloc
          ir_ginr         type ty_r_ginr
          ir_grnr         type ty_r_grnr
          ir_ponr         type ty_r_ponr
          ir_gidat        type ty_r_gidat
          ir_grdat        type ty_r_grdat
        returning
          value(rt_table) type rty_t_alv.

    " custom buttons
*    class-methods:
    methods:
      on_function
        for event if_salv_events_functions~added_function
        of cl_salv_events_table
        importing e_salv_function.

    " handle cell click
*    class-methods:
    methods:
      on_double_click
        for event if_salv_events_actions_table~double_click
        of cl_salv_events_table
        importing row
                  column.

    methods:
      on_after_function
        for event if_salv_events_functions~after_salv_function
        of cl_salv_events_table
        importing sender
                  e_salv_function.

    methods:
      refresh
        importing
          iv_col_name type string optional.

  private section.

ENDCLASS.



CLASS ZF24GR05_CL_ALV IMPLEMENTATION.


  method build_display.

    try.

        cl_salv_table=>factory(
          importing
            r_salv_table = lo_alv
          changing
            t_table      = t_alv
        ).

        me->build_pf_status( ).
        me->build_header( ).
        me->build_layout( ).

      catch cx_root into data(ls_error).

        message ls_error->get_text( )
          type 'S'
          display like 'E'.

    endtry.

  endmethod. " build_display


  method build_fieldcat.

    " Automatically retrieve columns (field catalog)
    data(lo_columns) = lo_alv->get_columns( ).

    try.

        lo_columns->set_column_position(
          columnname = 'STATUS_ICON'
          position = 1
        ).

        lo_columns->set_column_position(
          columnname = 'STATUS'
          position = 2
        ).

        lo_columns->set_column_position(
          columnname = 'GOODS_ISSUE_TYPE'
          position = 4
        ).

        lo_columns->set_column_position(
          columnname = 'GOODS_ISSUE_STATUS'
          position = 6
        ).

        lo_columns->set_column_position(
          columnname = 'GOODS_RECEIPT_TYPE'
          position = 7
        ).

        lo_columns->set_column_position(
          columnname = 'GOODS_RECEIPT_STATUS'
          position = 9
        ).

        lo_columns->set_column_position(
          columnname = 'PRODUCT_NAME'
          position = 10
        ).

        " Hidden columns
        lo_columns->get_column( 'SEL' )->set_visible( abap_false ).
        lo_columns->get_column( 'LINE_COLOR' )->set_visible( abap_false ).
        lo_columns->get_column( 'GOODS_ISSUE_STATUS' )->set_visible( abap_false ).
        lo_columns->get_column( 'GOODS_RECEIPT_STATUS' )->set_visible( abap_false ).
        lo_columns->get_column( 'GOODS_ISSUE_TYPE' )->set_visible( abap_false ).
        lo_columns->get_column( 'GOODS_RECEIPT_TYPE' )->set_visible( abap_false ).
        lo_columns->get_column( 'DELIVERY_ITEM' )->set_visible( abap_false ).

        " Customize specific columns if needed
        data(lo_col) = lo_columns->get_column( 'STATUS' ).
        lo_col->set_short_text( 'Status' ).
        lo_col->set_medium_text( 'Status' ).
        lo_col->set_long_text( 'Status' ).

        lo_col = lo_columns->get_column( 'STATUS_ICON' ).
        lo_col->set_short_text( '' ).
        lo_col->set_medium_text( '' ).
        lo_col->set_long_text( '' ).

        lo_col = lo_columns->get_column( 'DELIVERY' ).
        lo_col->set_short_text( 'Delivery' ).
        lo_col->set_medium_text( 'Delivery' ).
        lo_col->set_long_text( 'Delivery' ).

        lo_col = lo_columns->get_column( 'GOODS_ISSUE' ).
        lo_col->set_short_text( 'GI' ).
        lo_col->set_medium_text( 'Goods Issue' ).
        lo_col->set_long_text( 'Goods Issue' ).

        lo_col = lo_columns->get_column( 'GOODS_ISSUE_TYPE' ).
        lo_col->set_short_text( 'GI type' ).
        lo_col->set_medium_text( 'Goods Issue type' ).
        lo_col->set_long_text( 'Goods Issue type' ).

        lo_col = lo_columns->get_column( 'GOODS_RECEIPT' ).
        lo_col->set_short_text( 'GR' ).
        lo_col->set_medium_text( 'Goods Receipt' ).
        lo_col->set_long_text( 'Goods Receipt' ).

        lo_col = lo_columns->get_column( 'GOODS_RECEIPT_TYPE' ).
        lo_col->set_short_text( 'GR type' ).
        lo_col->set_medium_text( 'Goods Receipt type' ).
        lo_col->set_long_text( 'Goods Receipt type' ).

        lo_col = lo_columns->get_column( 'PRODUCT' ).
        lo_col->set_short_text( 'Product' ).
        lo_col->set_medium_text( 'Product' ).
        lo_col->set_long_text( 'Product' ).

        lo_col = lo_columns->get_column( 'PRODUCT_NAME' ).
        lo_col->set_short_text( 'Prod. Name' ).
        lo_col->set_medium_text( 'Product name' ).
        lo_col->set_long_text( 'Product name' ).

        lo_col = lo_columns->get_column( 'SLOC' ).
        lo_col->set_short_text( 'SLoc' ).
*        lo_col->set_medium_text( '' ).
*        lo_col->set_long_text( '' ).

        lo_col = lo_columns->get_column( 'DELIVERY_QUANTITY' ).
        lo_col->set_short_text( 'Deli. Qty' ).
        lo_col->set_medium_text( 'Deli Quantity' ).
        lo_col->set_long_text( 'Delivery Quantity' ).

        lo_col = lo_columns->get_column( 'DELIVERY_UOM' ).
        lo_col->set_short_text( 'UOM' ).
        lo_col->set_medium_text( 'Deli. Qty UOM' ).
        lo_col->set_long_text( 'Delivery Quantity UOM' ).

        lo_col = lo_columns->get_column( 'PICKED_QUANTITY' ).
        lo_col->set_short_text( 'Pkd .Qty' ).
        lo_col->set_medium_text( 'Picked Quantity' ).
        lo_col->set_long_text( 'Picked Quantity' ).

        lo_col = lo_columns->get_column( 'PICKED_UOM' ).
        lo_col->set_short_text( 'UOM' ).
        lo_col->set_medium_text( 'Pkd .Qty UOM' ).
        lo_col->set_long_text( 'Picked Quantity UOM' ).

        lo_col = lo_columns->get_column( 'AVAILABLE_QUANTITY' ).
        lo_col->set_short_text( 'Avai. Qty' ).
        lo_col->set_medium_text( 'Available Quantity' ).
        lo_col->set_long_text( 'Available Quantity' ).

        lo_col = lo_columns->get_column( 'AVAILABLE_UOM' ).
        lo_col->set_short_text( 'UOM' ).
        lo_col->set_medium_text( 'Avai. Qty UOM' ).
        lo_col->set_long_text( 'Available Quantity UOM' ).

        lo_col = lo_columns->get_column( 'PICKING_DATE' ).
        lo_col->set_short_text( 'Pkd Date' ).
        lo_col->set_medium_text( 'Picking Date' ).
        lo_col->set_long_text( 'Picking Date' ).

        lo_col = lo_columns->get_column( 'RECEIVING_PLANT' ).
        lo_col->set_short_text( 'Re. Plnt' ).
        lo_col->set_medium_text( 'Receiving Plant' ).
        lo_col->set_long_text( 'Receiving Plant' ).

        lo_col = lo_columns->get_column( 'SUPPLYING_PLANT' ).
        lo_col->set_short_text( 'Sup. Plnt' ).
        lo_col->set_medium_text( 'Supplying Plant' ).
        lo_col->set_long_text( 'Supplying Plant' ).

        lo_col = lo_columns->get_column( 'PO_NUMBER' ).
        lo_col->set_short_text( 'PO No.' ).
        lo_col->set_medium_text( 'Purchase Order No.' ).
        lo_col->set_long_text( 'Purchase Order Number' ).

        lo_col = lo_columns->get_column( 'STOCK_IN_TRANSIT' ).
        lo_col->set_short_text( 'STO' ).
        lo_col->set_medium_text( 'Stock in Transit' ).
        lo_col->set_long_text( 'Stock in Transit' ).

        lo_col = lo_columns->get_column( 'STOCK_IN_TRANSIT_UOM' ).
        lo_col->set_short_text( 'UOM' ).
        lo_col->set_medium_text( 'STO UOM' ).
        lo_col->set_long_text( 'Stock in Transit UOM' ).

        lo_col = lo_columns->get_column( 'SHIPPING_POINT' ).
        lo_col->set_short_text( 'Ship Point' ).
        lo_col->set_medium_text( 'Shiping Point' ).
        lo_col->set_long_text( 'Shiping Point' ).

        lo_col = lo_columns->get_column( 'PLANNED_GOODS_MOVEMENT_DATE' ).
        lo_col->set_short_text( 'Plnd Date' ).
        lo_col->set_medium_text( 'Plnd Gds Mvnt Date' ).
        lo_col->set_long_text( 'Planned Goods Movement Date' ).

*        LO_COL = LO_COLUMNS->GET_COLUMN( 'SHIP_TO_PARTY' ).
*        LO_COL->SET_SHORT_TEXT( 'Ship to Party' ).
*        LO_COL->SET_MEDIUM_TEXT( 'Ship to Party' ).
*        LO_COL->SET_LONG_TEXT( 'Ship to Party' ).

        lo_col = lo_columns->get_column( 'SHIP_TO_PARTY_NAME' ).
        lo_col->set_short_text( 'Name' ).
        lo_col->set_medium_text( 'STP Name' ).
        lo_col->set_long_text( 'Ship to Party Name' ).

      catch cx_root into data(lx_msg).

        message lx_msg->get_text( )
          type 'S'
          display like 'E'.

    endtry.

  endmethod. " build_fieldcat


  method build_group.

    field-symbols: <fs_column> type any.

*    data: pre_deli type ty_s_raw-delivery.
    data: pre_deli type string.

    data(def_color) = 1. " gray-blue
    data(alt_color) = 2. " light gray
    data(group_color) = def_color.

    loop at t_alv into data(wa).

      " covert WA to field symbol
      assign component iv_column
        of structure wa
        to <fs_column>.

      " Define color config
      data: ls_cell_color type lvc_s_scol.
      ls_cell_color-color-int = 1.
      ls_cell_color-color-inv = 0.

      if sy-tabix = 1.
        pre_deli = <fs_column>.
      endif.

      " check different delivery
      if <fs_column> <> pre_deli.

        " change color base on previous color
        case group_color.

          when alt_color.
            group_color = def_color.

          when def_color.
            group_color = alt_color.

        endcase.

      endif.

      " add modified color back to current WA (work area)
      ls_cell_color-color-col = group_color.
      append ls_cell_color to wa-cell_color.

      modify t_alv
        from wa
        transporting cell_color.

      " prepare data for next line
      pre_deli = <fs_column>.

    endloop.

  endmethod. " build_group


  method build_header.

    "define top element object
    data(lo_top_element) = new cl_salv_form_layout_grid( columns = 2 ).

    " define grid
    data(lo_grid) =
      lo_top_element->create_grid(
        row    = 3
        column = 1
      ).

    " add header
    data(lo_header) =
      lo_grid->create_header_information(
        row     = 1
        column  = 1
        text    = text-001
        tooltip = text-002
      ).

    data(lo_date) =
      lo_grid->create_text(
        row     = 2
        column  = 1
        text    = |Date: { sy-datum date = environment }|
        tooltip = 'date'
      ).

    data(lo_entries) =
      lo_grid->create_text(
        row     = 3
        column  = 1
        text    = |Number of Entries: { lines( t_alv ) }|
        tooltip = 'number of entries'
      ).

    " set top list
    lo_alv->set_top_of_list( lo_top_element ).

  endmethod. " build_header


  method build_layout.

    data(ls_column) = iv_group_column.

    " assign default value if iv_group_column empty
    if ls_column is initial.
      ls_column = 'DELIVERY'.
    endif.

    me->build_fieldcat( ).
    me->build_picked_quan_col( ).
    me->build_group( ls_column ).
    me->build_status_col( ).

  endmethod. " build_layout


  method build_pf_status.

    " Enable Selction Mode
    lo_alv->get_selections( )->set_selection_mode(
                                 if_salv_c_selection_mode=>cell
                               ).

    " Enable All Function
    lo_alv->get_functions( )->set_all( abap_true ).

    " Add custom PF status
    try.

        lo_alv->set_screen_status(
          report =  'ZF24GR05_ALV' "sy-repid
          pfstatus = 'ZF24GR05_PF_STATUS'
          set_functions = cl_salv_table=>c_functions_all
        ).

      catch cx_root into data(ls_error).

        message ls_error->get_longtext( )
          type 'S'
          display like 'E'.

    endtry.

    lo_events = lo_alv->get_event( ).

    " set handler
    set handler me->on_function for lo_events.
    set handler me->on_double_click for lo_events.
    set handler me->on_after_function for lo_events.

  endmethod. " build_pf_status


  method build_picked_quan_col.

    loop at t_alv into data(wa).

      data(lv_deli_quan) = wa-delivery_quantity.
      data(lv_pikd_quan) = wa-picked_quantity.

      " add color if lv_deli_quan <> lv_pikd_quan
      if lv_deli_quan <> lv_pikd_quan.

        data: ls_cell_color type lvc_s_scol.
        ls_cell_color-fname = 'PICKED_QUANTITY'.
        ls_cell_color-color-int = 1.
        ls_cell_color-color-inv = 0.
        ls_cell_color-color-col = 3.

        append ls_cell_color to wa-cell_color.

        modify t_alv
          from wa
          transporting cell_color.

      endif.

      " set color
      try.

          lo_alv->get_columns( )->set_color_column( 'CELL_COLOR' ).

        catch cx_salv_data_error into data(ls_error).

          message ls_error->get_text( )
            type 'S'
            display like 'E'.

      endtry.

    endloop.

  endmethod. " build_picked_quan_col


  method build_status_col.

    loop at t_alv into data(wa).

      " Define color config
      data: ls_cell_color type lvc_s_scol.

      " init data
      ls_cell_color-fname = 'STATUS'.
      ls_cell_color-color-int = 1.
      ls_cell_color-color-inv = 0.

      data(lv_ginr) = wa-goods_issue.   " GI Number
      data(lv_gimt) = wa-goods_issue_type.
      data(lv_gity) = wa-goods_issue_status.
      data(lv_grnr) = wa-goods_receipt. " GR NUmber
      data(lv_grmt) = wa-goods_receipt_type.
      data(lv_grty) = wa-goods_issue_type.

      " Default cell value
      data(color) = 6. " red
      data(status) = stt-null.
      data(status_icon) = icon_red_light.

      if   lv_gity = abap_true
        or lv_grty = abap_true.

        status = stt-cancel.

      else.

        " handle add status
        if lv_ginr is initial     " normal case: not PGI yet
*          or lv_gity = abap_true " reverse case: GI reverse
          .

          color = 5. " green
          status = stt-open.
          status_icon = icon_green_light.

        else. " normal case: have normal GI

          if lv_grnr is initial     " normal case: not PGR yet
*            or lv_grty = abap_true " revsese case: GR reverse
            .

            color = 7. " orange
            status = stt-partial.
            status_icon = icon_yellow_light.

          else. " normal csse: have normal GR

            color = 4. " blue
            status = stt-close.
            status_icon = icon_red_light.

          endif.

        endif.

      endif.

      " add color
      ls_cell_color-color-col = color.
      append ls_cell_color to wa-cell_color.

      " add status
      wa-status = status.

      " add status icon
      wa-status_icon = status_icon.

      " modify table
      modify t_alv
        from wa
        transporting status
                     status_icon
                     cell_color.

      " set color
      try.

          lo_alv->get_columns( )->set_color_column( 'CELL_COLOR' ).

        catch cx_salv_data_error into data(ls_error).

          message ls_error->get_text( )
            type 'S'
            display like 'E'.

      endtry.

    endloop.

  endmethod. " build_status_col


  method constructor.

    " save input data for refresh
    r_matnr = ir_matnr.
    r_splnt = ir_splnt.
    r_rplnt = ir_rplnt.
    r_sloc  = ir_sloc.
    r_ginr  = ir_ginr.
    r_grnr  = ir_grnr.
    r_ponr  = ir_ponr.
    r_gidat = ir_gidat.
    r_grdat = ir_grdat.

    " fetch data
    t_alv = fetch_data(
      ir_matnr = r_matnr
      ir_splnt = r_splnt
      ir_rplnt = r_rplnt
      ir_sloc  = r_sloc
      ir_ginr  = r_ginr
      ir_grnr  = r_grnr
      ir_ponr  = r_ponr
      ir_gidat = r_gidat
      ir_grdat = r_grdat
    ).

*    lo_columns->set_optimize( abap_true ).

  endmethod. " constructor


  method display.

    if t_alv is initial.

      " No matching data available.
      message s251(zf24gr05_message)
        display like 'I'
        .

    else.

      " build alv
      me->build_display( ).

      " display
      lo_alv->display( ).

    endif.

  endmethod. " display


  method fetch_data.

    data: lt_alv type standard table of ty_s_alv.

    " Main Query
    select distinct
       likp~vbeln                as delivery,                    " Delivery Document Number
       gi_mseg~mblnr             as goods_issue,                 " GI number
       gi_mseg~bwart             as goods_issue_type,            " GI Movement Type
       gi_matdoc~cancelled       as goods_issue_status,
       gr_mseg~mblnr             as goods_receipt,               " GR number
       gr_mseg~bwart             as goods_receipt_type,          " GR Movement Type
       gr_matdoc~cancelled       as goods_receipt_status,
       lips~matnr                as product,                     " Material Number
       lips~charg                as batch,                       " Batch Number
       lips~lgort                as sloc,                        " Storage Location
       lips~ormng                as delivery_quantity,           " Delivery Quantity (Original Quantity of Delivery Item)
       lips~vrkme                as delivery_uom,                " Delivery Unit of Measure
       lips~lfimg                as picked_quantity,             " Picked Quantity (Actual quantity delivered (in sales units))
       lips~vrkme                as picked_uom,                  " Picked Unit of Measure
       mchb~clabs                as available_quantity,          " Available Quantity in Stock (Valuated Unrestricted-Use Stock)
       mara~meins                as available_uom,               " Available Unit of Measure
       likp~kodat                as picking_date,                " Picking Date
       ekpo~werks                as receiving_plant,             " Receiving Plant
       lips~werks                as supplying_plant,             " Shipping Point / Receiving Point
       ekpo~ebeln                as po_number,                   " From the reference document (PO) linked in VBFA
       marc~trame                as stock_in_transit,            " Stock in Transit Quantity
       mara~meins                as stock_in_transit_uom,        " Stock in Transit Unit of Measure
       likp~vstel                as shipping_point,              " Shipping Point / Receiving Point
       likp~wadat                as planned_goods_movement_date, " Planned Goods Movement Date
       kna1~kunnr                as ship_to_party,               " Customer Number
       kna1~name1                as ship_to_party_name,          "
       lips~posnr                as delivery_item,
       lips~arktx                as product_name

     from likp                                                   " Table SD Document: Delivery Header Data
       inner join lips                                           " Table SD document: Delivery: Item data
           on likp~vbeln = lips~vbeln

       inner join ekpo
            on ekpo~ebeln = lips~vgbel

       left join mseg as gi_mseg                                 " Table Document Segment: Material
           on      likp~vbeln = gi_mseg~vbeln_im
               and gi_mseg~bwart in ('641',
                                     '647', '648')
       left join mseg as gr_mseg                                 " Table Document Segment: Material
           on (
                likp~vbeln = gr_mseg~vbeln_im                    " Add fallback to use other fields for GR
             or likp~vbeln = gr_mseg~lfbnr                       " Use Delivery Document as fallback)
             or ekpo~ebeln = gr_mseg~ebeln                       " Use Purchase Order as fallback
           )
               and gr_mseg~bwart in ('101', '102',
                                     '647', '648')

       left join matdoc as gi_matdoc
           on gi_matdoc~mblnr = gi_mseg~mblnr
       left join matdoc as gr_matdoc
           on gr_matdoc~mblnr = gr_mseg~mblnr

       left join mchb
          on      lips~matnr = mchb~matnr
              and lips~werks = mchb~werks
              and lips~lgort = mchb~lgort
              and lips~charg = mchb~charg

       inner join mara                                            " Table General Material Data
           on lips~matnr = mara~matnr

       inner join marc                                            " Table Plant Data for Material
           on      lips~matnr = marc~matnr
               and ekpo~werks = marc~werks

       inner join kna1                                            " Table General Data in Customer Master
           on likp~kunnr = kna1~kunnr

     where
           lips~matnr    in @ir_matnr                             " Find with range Material Number
       and gi_mseg~mblnr in @ir_ginr                              " Filter for GI numbers
       and gr_mseg~mblnr in @ir_grnr                              " Filter for GR numbers
       and likp~vstel    in @ir_splnt                             " Filter for supplying plant
       and lips~werks    in @ir_rplnt                             " Filter for receiving plant
       and lips~lgort    in @ir_sloc                              " Find with range Storage Location
       and ekpo~ebeln    in @ir_ponr                              " Find with range PO number
       and likp~wadat    in @ir_gidat                             " Find with range Planned Goods Movement Date
       and likp~kodat    in @ir_grdat                             " Find with range Picking Date

     order by
         likp~vbeln descending,
         gi_matdoc~cancelled ascending,
         gr_matdoc~cancelled ascending

     into corresponding fields of table @lt_alv.

    " get calculate picked quant in VL02N
    loop at lt_alv into data(wa).

      data: lv_pikmg type pikmg.

      try.

          call function 'WB2_GET_PICK_QUANTITY'
            exporting
              i_vbeln             = wa-delivery
              i_posnr             = wa-delivery_item
            importing
              e_pikmg             = lv_pikmg
            exceptions
              document_read_error = 1
              others              = 2.

          " Hanlde fallback data
          if lv_pikmg is initial.

          else.

            wa-picked_quantity = lv_pikmg.

            modify lt_alv
              from wa
              transporting picked_quantity.

          endif.

        catch cx_root into data(ls_error).

          message ls_error->get_longtext( )
            type 'S'
            display like 'E'.

      endtry.

    endloop.

    " remove duplicate data but different cancel status
    data: lt_tmp like lt_alv.

    loop at lt_alv into wa.

      if wa-goods_issue_status = abap_true.
        " get cancelled data
        append wa to lt_tmp.
      endif.

    endloop.

    " delete duplcate non-cancel
    loop at lt_tmp into wa.

      delete lt_alv
        where delivery = wa-delivery
          and goods_issue = wa-goods_issue
          and goods_issue_status <> abap_true.

    endloop.

    " return
    rt_table = lt_alv.

  endmethod. " fetch_data


  method get_t_alv.

    " build alv
    me->build_display( ).

    " return
    rt_table = t_alv.

  endmethod. " get_t_alv


  method on_after_function.

    " get selected col index
    data(lt_selected_col) = lo_alv->get_selections( )->get_selected_columns( ).

    read table lt_selected_col
      into data(ls_col)
      index 1.

    " convert lo_col to string
    data(col_name) = ls_col && ''.

    " re-build layout
    loop at t_alv into data(wa).

      clear: wa-cell_color.
      modify t_alv from wa .

    endloop.

    me->build_layout(
      iv_group_column = col_name
    ).

*    " refresh ALV
    lo_alv->refresh(
      refresh_mode = if_salv_c_refresh=>full
    ).
    cl_gui_cfw=>flush( ).

  endmethod. "on_after_function


  method on_double_click.

    " get current row data
    read table t_alv
      into data(ls_alv_row)
      index row.

    case column.

      when 'DELIVERY'.
        " call BDC
        if sy-subrc = 0 and
           ls_alv_row-delivery is not initial.

          " Go to tcode VL02N with Outbound Delivery: &1.
          message i400(zf24gr05_message)
            with ls_alv_row-delivery
            display like 'I'
            .

          data: ld_vbeln_001 type bdcdata-fval.
          ld_vbeln_001 = ls_alv_row-delivery.

          data(lo_bdc_vl02n) = new zf24gr05_cl_alv_bdc_vl02n( ).
          lo_bdc_vl02n->execute( ld_vbeln_001 ).

        endif.

      when 'GOODS_RECEIPT'.
        " call BDC
        if sy-subrc = 0 and
           ls_alv_row-goods_receipt is not initial.

          " Go to tcode MIGO with Document Number: &1.
          message i401(zf24gr05_message)
            with ls_alv_row-goods_receipt
            display like 'I'
            .

          data: ld_mat_doc type bdcdata-fval.
          ld_mat_doc = ls_alv_row-goods_receipt.

          data(lo_bdc_migo) = new zf24gr05_cl_alv_bdc_migo( ).
*          lo_bdc_migo->execute( ld_mat_doc ).
          lo_bdc_migo->fm_migo_dialog( ls_alv_row-goods_receipt ).


        endif.

      when others.

    endcase.

    clear: t_alv.

    " re-fetch data
    t_alv = fetch_data(
      ir_matnr = r_matnr
      ir_splnt = r_splnt
      ir_rplnt = r_rplnt
      ir_sloc  = r_sloc
      ir_ginr  = r_ginr
      ir_grnr  = r_grnr
      ir_ponr  = r_ponr
      ir_gidat = r_gidat
      ir_grdat = r_grdat
    ).

    sort t_alv descending by delivery.

    " re-build layout
    loop at t_alv into data(wa).

      clear: wa-cell_color.
      modify t_alv from wa.

    endloop.

    " re-build layout
    me->build_layout( ).

    " refresh ALV
    lo_alv->refresh(
      refresh_mode = if_salv_c_refresh=>full
    ).
    cl_gui_cfw=>flush( ).

*    me->refresh( ).

  endmethod.


  method on_function.

    " define local type
    types: begin of lty_extra,
             delivery type zf24gr05_cl_bapi_root=>ty_delivery,
             status   type ty_s_raw-status,
           end of lty_extra.

    types: lty_t_extra type standard table of lty_extra.

    data: lt_extra type lty_t_extra.

    " get selected delevery number
    data: lt_delivery type zf24gr05_cl_bapi_root=>ty_t_delivery. " array delevery number

    " get selected rows index
    data(lt_selected_rows) = lo_alv->get_selections( )->get_selected_rows( ).

    " check is empty
    if lt_selected_rows[] is initial.
      " 0 row(s) selected. Please select at least 1 row(s) to proceed.
      message w250(zf24gr05_message).
      return.
    endif.

    loop at lt_selected_rows into data(wa).

      " get selected row data
      read table t_alv
        index wa
        into data(ls_data).

      " save delivery
      append ls_data-delivery to lt_delivery.

      " save status for handle default error message
      data: ls_wa like line of lt_extra.

      ls_wa-delivery = ls_data-delivery.
      ls_wa-status = ls_data-status.

      append ls_wa to lt_extra.

    endloop.

    " remove duplicate item
    sort lt_delivery.
    delete adjacent duplicates
      from lt_delivery
      comparing all fields.

    sort lt_extra.
    delete adjacent duplicates
      from lt_extra
      comparing delivery.

    " Custom button handle
    case e_salv_function.

      when '&PGI'.
        post_gi( lt_delivery ).

      when '&PGR'.
        data(lt_message) = post_gr( lt_delivery ).

        " modify default maessage return by BAPI
        " handle case msgno = 897
        loop at lt_message into data(wa_msg).

          loop at lt_extra into data(wa_ex).

            if wa_msg-delivery = wa_ex-delivery.

              if wa_ex-status = stt-close && ''.

*               Outbound delivery { wa_ex-delivery } has already posted Goods Receipt
                message e476(zf24gr05_message)
                  with wa_ex-delivery
                  into wa_msg-msgtxt
                  .

              elseif wa_ex-status = stt-open && ''.

                " Outbound delivery { wa_ex-delivery } has not posted Goods Issue yet
                message e477(zf24gr05_message)
                  with wa_ex-delivery
                  into wa_msg-msgtxt
                  .

              endif.

            endif.

            modify lt_message
              from wa_msg
              transporting msgtxt.

          endloop.

        endloop.

        " display message
        data(lo_pgr) = new zf24gr05_cl_bapi_pgr(  ).
        lo_pgr->display_msg(
          it_messages = lt_message
          is_display = abap_true
        ).

      when others.
        " Functioncode: &1
        message w004(zf24gr05_message)
          with e_salv_function.

    endcase.

    " re-fetch data
    t_alv = fetch_data(
      ir_matnr = r_matnr
      ir_splnt = r_splnt
      ir_rplnt = r_rplnt
      ir_sloc  = r_sloc
      ir_ginr  = r_ginr
      ir_grnr  = r_grnr
      ir_ponr  = r_ponr
      ir_gidat = r_gidat
      ir_grdat = r_grdat
    ).

    sort t_alv descending by delivery.

    " re-build layout
    me->build_layout( ).

    " refresh ALV
    lo_alv->refresh(
      refresh_mode = if_salv_c_refresh=>full
    ).
    cl_gui_cfw=>flush( ).

*    me->refresh(  ).

  endmethod. " on_function


  method post_gi.

    " create instance
    data(lo_pgi) = new zf24gr05_cl_bapi_pgi( ).

    " get post GI message
    data(lt_messages) = lo_pgi->post_gi_delivery(
      it_delivery = it_delivery
    ).

    " get success deli no
    data(lt_success) = lo_pgi->get_success_deliveries( ).

    " get failed deli no
    data(lt_failed) = lo_pgi->get_failed_deliveries( ).

  endmethod. " post_gi


  method post_gr.

    " create instance
    data(lo_pgr) = new zf24gr05_cl_bapi_pgr( ).

    " get post GR message
    data(lt_messages) = lo_pgr->post_gr_delivery(
      it_delivery = it_delivery
      iv_display = abap_false
    ).

    " get success deli no
    data(lt_success) = lo_pgr->get_success_deliveries( ).

    " get failed deli no
    data(lt_failed) = lo_pgr->get_failed_deliveries( ).

    " return
    rt_message = lt_messages.

  endmethod. " post_gr


  method refresh.

    " re-fetch data
    t_alv = fetch_data(
      ir_matnr = r_matnr
      ir_splnt = r_splnt
      ir_rplnt = r_rplnt
      ir_sloc = r_sloc
      ir_ginr = r_ginr
      ir_grnr = r_grnr
      ir_ponr = r_ponr
      ir_gidat = r_gidat
      ir_grdat = r_grdat
    ).

    sort t_alv descending by delivery.

    " re-build layout
    me->build_layout( ).

    " refresh ALV
    lo_alv->refresh(
      refresh_mode = if_salv_c_refresh=>full
    ).
    cl_gui_cfw=>flush( ).

  endmethod. " refresh
ENDCLASS.

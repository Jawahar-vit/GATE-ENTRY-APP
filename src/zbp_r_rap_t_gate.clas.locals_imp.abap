CLASS LHC_ZR_RAP_T_GATE DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:


      get_instance_features FOR INSTANCE FEATURES
            IMPORTING keys REQUEST requested_features FOR ZrRapTGate RESULT result.

          METHODS acceptTransit FOR MODIFY
            IMPORTING keys FOR ACTION ZrRapTGate~acceptTransit RESULT result.

          METHODS validate_po FOR VALIDATE ON SAVE
            IMPORTING keys FOR ZrRapTGate~validate_po.
          METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
            IMPORTING keys REQUEST requested_authorizations FOR ZrRapTGate RESULT result.
ENDCLASS.

CLASS LHC_ZR_RAP_T_GATE IMPLEMENTATION.

  METHOD get_instance_features.

  "Read status of GATE Pass
 READ ENTITIES OF ZR_RAP_T_GATE IN LOCAL MODE
  ENTITY ZrRapTGate
          FIELDS ( GateStatus ) WITH CORRESPONDING #( keys )
        RESULT DATA(members)
        FAILED failed.

   result =
      VALUE #(
        FOR member IN members
" When Gate Status = Opened then enable Set active button
            LET status =   COND #( WHEN member-GateStatus = 'O'
                                      THEN if_abap_behv=>fc-o-enabled
                                      ELSE if_abap_behv=>fc-o-disabled

                                      )

                                      IN


            ( %tky                 = member-%tky
              %action-acceptTransit = status
             ) ).
  ENDMETHOD.

  METHOD acceptTransit.
  MODIFY ENTITIES OF ZR_RAP_T_GATE IN LOCAL MODE
        ENTITY ZrRapTGate
          UPDATE
            FIELDS (  GateStatus )
            WITH VALUE #( FOR key IN keys
                           ( %tky         = key-%tky
                             GateStatus = 'A'

                             ) )

       FAILED failed
       REPORTED reported.
  ENDMETHOD.

  METHOD validate_po.

  DATA: gv_web  TYPE string VALUE 'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/',
          go_http TYPE REF TO if_web_http_client,
          r_json TYPE string,
          lv_status_code TYPE i,
          lv_po type ztgate_001-purchase_order.

  TYPES: BEGIN OF ty_purchase_order,
         purchase_order TYPE string,
       END OF ty_purchase_order.

TYPES: BEGIN OF ty_metadata,
         id   TYPE string,
         uri  TYPE string,
         type TYPE string,
       END OF ty_metadata.

TYPES: BEGIN OF ty_d,
         metadata      TYPE ty_metadata,
         purchase_order TYPE string,
       END OF ty_d.

DATA: lt_d TYPE  ty_d.

          TRY.
              go_http = cl_web_http_client_manager=>create_by_http_destination(
                            i_destination = cl_http_destination_provider=>create_by_url( gv_web ) ).
            CATCH cx_web_http_client_error cx_http_dest_provider_error.
              "handle exception
          ENDTRY.

 "GET_REQUEST
DATA(LO_REQ) = go_http->get_http_request(  ).

"SET_HEADER
LO_REQ->set_header_fields( VALUE #(
     ( name = 'Content-Type' value = 'application/json' )
     ( name = 'Accept' value = 'application/json' )
     ( name = 'APIKey' value = 'qh9INkrrZWGls2Ey7edfTSxSnlXVay86' ) ) ).

*lv_po = '4500000005'.
"SET_WEB_PATH
*lo_req->set_uri_path( i_uri_path = gv_web &&
*                      'API_PURCHASEORDER_PROCESS_SRV/A_PurchaseOrder("4500000005")?$select=PurchaseOrder' ).

" HTTP call to Remote API with PO as parameter
*lo_req->set_uri_path(
*  i_uri_path = |{ gv_web }API_PURCHASEORDER_PROCESS_SRV/A_PurchaseOrder('4500000005')?$select=PurchaseOrder&$format=json|
*).

*lo_req->set_uri_path(
*  i_uri_path = |{ gv_web }API_PURCHASEORDER_PROCESS_SRV/A_PurchaseOrder('{ lv_po }')?$select=PurchaseOrder&$format=json|
*).


  READ ENTITIES OF ZR_RAP_T_GATE IN LOCAL MODE
  ENTITY ZrRapTGate
    FIELDS ( PurchaseOrder )
    WITH CORRESPONDING #( keys )
    RESULT DATA(carriers).

  LOOP AT carriers INTO DATA(carrier).
  if carrier-PurchaseOrder is NOT INITIAL.
  lv_po = carrier-PurchaseOrder.
  lo_req->set_uri_path(
  i_uri_path = |{ gv_web }API_PURCHASEORDER_PROCESS_SRV/A_PurchaseOrder('{ lv_po }')?$select=PurchaseOrder&$format=json|
).
try.
    data(lv_response) = go_http->execute( i_method = if_web_http_client=>get )->get_text( ).
    data(lv_stat) = go_http->execute( i_method = if_web_http_client=>get )->get_status( ).
  catch cx_web_http_client_error cx_web_message_error.
    "handle exception
endtry.

r_json = lv_response.


   TRY.
    /ui2/cl_json=>deserialize(
      EXPORTING
        json = r_json
      CHANGING
        data = lt_d
    ).
  CATCH cx_sxml_parse_error INTO DATA(lx_parse_error).

ENDTRY.

*      SELECT SINGLE purchase_order FROM ztpurchase_order
*          WHERE purchase_order = @carrier-Purchase_Order
*          INTO @DATA(ls_po).
      IF lv_stat-code ne '200'.
        APPEND VALUE #( %key = carrier-%key
                  %update = if_abap_behv=>mk-on ) TO failed-ZrRapTGate.
  APPEND VALUE #( %key = carrier-%key
                  %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                text = lv_po && ' Purchase order is not valid' )
                  %update = if_abap_behv=>mk-on
                  %element-PurchaseOrder = if_abap_behv=>mk-on
                 ) TO reported-ZrRapTGate.
      ENDIF.
      endif.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.

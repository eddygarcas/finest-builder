# frozen_string_literal: true

require 'test_helper'
require 'json'

class Transform
  include Finest::Builder

end

class Finest::BuilderTest < Minitest::Test

  def test_that_it_has_a_version_number
    refute_nil ::Finest::Builder::VERSION
  end

  def test_complex_json
    element = Transform.new(
      {
        'client' => {
          'IMEI' => 1,
          'id' => 3434,
          'WiFiMAC' => 'dd:45:dd:22:dd:44:fg',
          'ManagementType' => 'iOSUnsupervised'
        },
        'lines' => [
          {
            'id' => 1,
            'name' => 'line1'
          },
          {
            'id' => 2,
            'name' => 'line2'
          }
        ]
      }
    )
    assert_equal element.client.id, 3434
    assert_equal element.client.management_type, 'iOSUnsupervised'
    assert_equal element.client.wifimac, 'dd:45:dd:22:dd:44:fg'
    assert_equal element.lines.first.id, 1
    assert_equal element.lines.first.name, 'line1'
  end

  def test_complex_get_client_only_json
    element = Transform.new(
      {

        'client' => {
          'meta' => {
            '@odata.count' => 212
          },
          'IMEI' => 1,
          'id' => 3434,
          'WiFiMAC' => 'dd:45:dd:22:dd:44:fg',
          'ManagementType' => 'iOSUnsupervised',
          '1' => 'test',
          '2' => 'second test'
        },
        'lines' => [
          {
            'id' => 1,
            'name' => 'line1'
          },
          {
            'id' => 2,
            'name' => 'line2'
          }
        ]
      },
      ['client']
    )
    assert_equal element.client.id, 3434
    assert_equal element.client.management_type, 'iOSUnsupervised'
    assert_equal element.client.wifimac, 'dd:45:dd:22:dd:44:fg'
    assert_equal element.client.meta._odata_count, 212
    assert_equal element.client._1, 'test'
    assert_equal element.lines&.first&.id, nil
    assert_equal element.lines&.first&.name, nil
  end

  def test_complex_json
    response = { "salesOrderId": "53a63a51-3a46-4e3e-9132-992a319137f6", "amountPaid": "22489.92000", "assignedToTeamMemberId": "b106e0e7-2f31-4c9f-a34d-33ca156bc5be", "balance": "0.00000", "billingAddress": { "address1": "", "address2": "", "city": "", "state": "", "country": "", "postalCode": "", "remarks": "", "addressType": nil }, "calculateTax2OnTax1": false, "confirmerTeamMemberId": nil, "contactName": "Laurène GUEDE", "currencyId": "d7807fa7-657b-4214-976b-c8b5087e8e7f", "customerId": "539440d8-423a-4a0a-8312-0dd7ffd8ab27", "customFields": { "custom1": "Leasing", "custom2": "BNP leasing", "custom3": "OUI", "custom4": "FREEMIUM", "custom5": "0", "custom6": "", "custom7": "", "custom8": "oui", "custom9": "", "custom10": "" }, "dueDate": nil, "email": "laurene.guede@deepki.com", "exchangeRate": "1.0000000000", "externalId": "", "inventoryStatus": "fulfilled", "invoicedDate": "2022-05-31T22:21:40+02:00", "isCancelled": false, "isCompleted": true, "isInvoiced": true, "isQuote": false, "isTaxInclusive": false, "lastModifiedById": "fc726f6b-f63a-4abf-a717-02eafb7b5d85", "locationId": "f3c832ed-e143-431d-9ae9-a77369044613", "needsConfirmation": false, "nonCustomerCost": { "value": "0.00000", "isPercent": false }, "orderDate": "2022-05-30T22:52:50+02:00", "orderFreight": "0.00000", "orderNumber": "SO-000001", "orderRemarks": "", "packRemarks": "", "paymentStatus": "paid", "paymentTermsId": nil, "phone": "+33786389326", "pickRemarks": "", "poNumber": "", "pricingSchemeId": "0c173f33-604b-486f-b6a0-2fffe35a4100", "requestedShipDate": nil, "restockRemarks": "", "returnFee": "0.00000", "returnFreight": "0.00000", "returnRemarks": "", "salesRep": "", "salesRepTeamMemberId": nil, "sameBillingAndShipping": false, "shippingAddress": { "address1": "", "address2": "", "city": "", "state": "", "country": "", "postalCode": "", "remarks": "", "addressType": nil }, "shipRemarks": "", "shipToCompanyName": "", "showShipping": true, "source": "inFlowWeb", "subTotal": "18741.60000", "tax1": "3748.32000", "tax1Name": "French", "tax1OnShipping": false, "tax1Rate": "20.00000", "tax2": "0.00000", "tax2Name": "", "tax2OnShipping": false, "tax2Rate": "0.00000", "taxingSchemeId": "e6d1074f-2c59-4dd8-9d4d-974e44d4cef7", "timestamp": "0000000000013CF1", "total": "22489.92000", "lines": [{ "salesOrderLineId": "9a9d9b32-ee3e-409d-b6ac-d71b3bda96b6", "description": "Apple MacBook Pro - Écran 36,1 cm (14,2\") - Apple M1 Pro Octa-core (8 Core) - 16 Go Total RAM - 512 Go SSD - Gris - Apple M1 Pro Chip - macOS Monterey - Écran retina, Technologie True Tone - 17 Autonomie de batterie ", "discount": { "value": "0.00000", "isPercent": true }, "isDiscarded": false, "productId": "e2b75f8b-51a9-4db7-8635-112b9fb506cd", "quantity": { "standardQuantity": "10.0000", "uomQuantity": "10.0000", "uom": "", "serialNumbers": ["SC19FXC4J9P", "SDK9W33VVQH", "SGCXJVG2P03", "SJHGP77RR70", "SK001V2D2JX", "SN29CYVQNC2", "SPGFM3X7PPQ", "ST99DJ47XH4", "SX4VGWLK74G", "SX9V6Y7W3RW"] }, "returnDate": nil, "serviceCompleted": nil, "subTotal": "18741.60000", "tax1Rate": "20.00000", "tax2Rate": "0.00000", "taxCodeId": "b88a7dc5-916a-4fb7-9877-b858d0f56204", "timestamp": "0000000000013CF3", "unitPrice": "1874.16000", "product": { "productId": "e2b75f8b-51a9-4db7-8635-112b9fb506cd", "barcode": "", "categoryId": "a9d5e19f-bc1a-4bdd-b442-e91ce4150c09", "customFields": { "custom1": "16", "custom2": "512", "custom3": "M1 Pro", "custom4": "14\"", "custom5": "2021", "custom6": "New", "custom7": "fr_FR", "custom8": "APPLE", "custom9": "", "custom10": "" }, "description": "Apple MacBook Pro - Écran 36,1 cm (14,2\") - Apple M1 Pro Octa-core (8 Core) - 16 Go Total RAM - 512 Go SSD - Gris - Apple M1 Pro Chip - macOS Monterey - Écran retina, Technologie True Tone - 17 Autonomie de batterie ", "height": nil, "hsTariffNumber": "", "isActive": true, "itemType": "stockedProduct", "lastModifiedById": "b106e0e7-2f31-4c9f-a34d-33ca156bc5be", "lastVendorId": "bbf6ae9c-2dc5-40b0-8476-6e76d7abd90a", "length": nil, "name": "MacBook Pro 14\", M1 Pro, RAM 16Go, SSD 512 Go, 2021, Sp.Gr, New", "originCountry": "", "purchasingUom": nil, "remarks": "", "salesUom": nil, "sku": "MKGP3FN/A_FR", "standardUomName": "", "timestamp": "00000000000514E2", "trackSerials": true, "weight": nil, "width": nil } }], "location": { "locationId": "f3c832ed-e143-431d-9ae9-a77369044613", "address": { "address1": "8 RUE DES PIROGUES DE BERCY", "address2": "", "city": "PARIS", "state": "", "country": "France", "postalCode": "75012", "remarks": "", "addressType": "commercial" }, "isActive": true, "isDefault": true, "name": "Paris - WeWork", "timestamp": "000000000001558A" }, "shipLines": [{ "salesOrderShipLineId": "fe4fe1bc-6383-44ed-8a3d-6c2963c7b81c", "carrier": "", "containers": ["1"], "easyPostConfirmationEmailAddress": "", "easyPostShipmentId": "", "easyPostShipmentStatus": "manual", "shippedDate": "2022-05-31T22:22:07+02:00", "timestamp": "0000000000013CF9", "trackingNumber": "" }] }
    element = Transform.new(response)
    assert_equal element.inventory_status, 'fulfilled'
    assert_equal element.lines.first.quantity.serial_numbers.size, 10
    assert_equal element.lines.first.is_discarded, false
    assert_equal element.ship_lines.first.shipped_date, '2022-05-31T22:22:07+02:00'
  end
end

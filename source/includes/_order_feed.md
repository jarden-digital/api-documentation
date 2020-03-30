# Order Feed

The order feed exposes the events associated with orders place on the Jarden platform, and the associated state transitions.


REST Feed properties:

+ working set; `/order_feed`

> Sample request

```shell
GET order_feed
host: order.api.jarden.io
Authorization: Bearer <id_token>
```

> Sample Response

```json
{
  "items": [
    {"id": "https://order.api.uat.jarden.io/orders/{id}", "orderId": "3005046"},
  ],
  "links": {
    "self": "https://order.api.uat.jarden.io/order_feed/{id}",
    "prev": "https://order.api.uat.jarden.io/order_feed/{id}"
  }
}
```

Each feed item is a reference to a specific order event which can be retrieved through a `GET` on the link associated with the `id` key.  The definition of the Order feed resource is described in the Order Domain Resources section.

## Order Resource

The following marked-up JSON structure describes the properties of an Order.

```json
{
  "//": "A pseudo-schema for a Transformed SE Order.",
  "_type": "clientOrder",
  "identifiers": [
    {
      "_type": "orderIdentifier",
      "id": "{ string ex(2675231) }"
    },
    {
      "_type": "orderReference",
      "id": "{ string ex(AW5318278) }"
    }
  ],
  "orderOriginator": "ASSETWATCH",
  "state": "{ enum(created | allocated | confirmed | placed | part_filled | filled | expired | deleted | rejected) }",
  "timestamps": {
    "createdTime": "{ISO8601_time}",
    "lastModifiedTime": "{ISO8601_time}"
  },
  "financialInstrument": {
    "instrumentCode": "{string ex(AIA)}",
    "marketId": "{ JAR_CUSTOM_MIC ex(NZX) }"
  },
  "narratives": [
    {"_type": "{ enum(contractNoteComment | dealingComment | settlementComment) }", "text": "{string}"}
  ],
  "specification": {
    "orderSide": "{enum(buy | sell)}",
    "orderDate": "{ISO8601_date}",
    "orderQuantity": {
      "unitCode": "{ enum(unit | rate) }",
      "value": "{ number }"
    },
    "holdQuantity": {
      "unitCode": "{ enum(unit) }",
      "value": "{ number }"
    },
    "canWorkOrder": "{ bool }",
    "participatingClientClass": "{enum(retail | principal | wholesale | marketMaker | prescribedPerson)}",
    "executionStrategy": {
      "//": "Defines the execution basis for the order.  A market order does not have a yield or price specification.  Limit and stopLimit is defined as per instrument valuation method",
      "_type": "{enum(urn:order:executionStrategy:stopLimit | urn:order:executionStrategy:market | urn:order:executionStrategy:limit)}",
      "basis": "{ enum(unitPrice | yield | pricePer100) ex(unitPrice) }",
      "yieldSpecifications": [
        {
          "yieldType": "{ enum(yieldRate | limitYield) }",
          "yield": "{ string }",
          "eligibleQuantity": {
            "unitCode": "{ enum(unit | percentage)}"
          }
        }
      ],
      "priceSpecifications": [
        {
          "priceType": "{enum(triggerPrice | limitPrice)}",
          "price": "{string ex(12.50)}",
          "priceCurrency": "{ISO4217_currency}",
          "eligibleQuantity": {
            "unitCode": "{enum(unitPrice | pricePer100)}"
          }
        }
      ]
    },
    "inForceStrategy": {
      "type": "{ enum(urn:order:inForceStrategy:fillOrKill | urn:order:inForceStrategy:day | urn:order:inForceStrategy:goodTillCancel) }",
      "expiresAt": "{ ISO8601_time | ISO8601_date }"
    }
  },
  "settlementInstructions": {
    "settlementInstrument": {
      "instrumentCode": "{ string ex(AIA) }",
      "marketId": "{ JAR_CUSTOM_MIC ex(NZX) }"
    },
    "cashInstructions": {
      "settlementCurrency": "{ ISO4217_currency }"
    }
  },
  "brokerage": {
    "//": "Either scheduleCode or price, where price takes precedence",
    "priceScheduleCode": "CONS",
    "price": {
      "priceType": "{ enum(triggerPrice | limitPrice) }",
      "price": "12.50",
      "priceCurrency": "{ ISO4217_currency }"
    }
  },
  "orderExecution": {
    "workingOrder": "{ bool }",
    "quantityBooked": {
      "unitCode": "{ enum(unit | rate) ex(unit) }",
      "value": "{ integer ex(100) }"
    }
  },
  "orderParties": [
    {
      "_type": "clientParty",
      "identifiers": [
        {
          "_type": "counterPartyCode",
          "id": "FNZWRAP"
        },
        {
          "_type": "counterPartyAccount",
          "id": "01"
        }
      ]
    },
    {
      "_type": "settlementParty",
      "identifiers": [
        {
          "_type": "commonShareholderNumber",
          "id": "333082527"
        }
      ],
      "partyExtensions": [
        {
          "//": "registry must be 6 items of String",
          "_type": "registryAuthorisation",
          "registrationLines": ["{ string | null }"]
        }
      ]
    },
    {
      "_type": "observingParty",
        "identifiers": [
          {
            "_type": "legacyPartyIdentity",
            "id": "FNZ"
          }
          {
            "//": "fnz_client_id if maintained by services",
            "_type": "externalClientReference",
            "id": "{ counterparty_code | fnz_client_id }"
          }
        ]
      },
    {
      "_type": "advisorParty",
      "identifiers": [
        {
          "_type": "advisorRef",
          "id": "WRAP"
        }
      ]
    }
  ]
}
```

# Order Feed

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
    {
      "id": "https://order.api.uat.jarden.io/orders/{id}",
      "identifiers": [
        {
          "_type": "orderIdentifier",
          "id": "3105773"
        },
        {
          "_type": "orderIdentifierVersion",
          "id": "3"
        },
        {
          "_type": "orderReference",
          "id": "3105773"
        }
      ]
    }
  ],
  "links": {
    "self": "https://order.api.uat.jarden.io/order_feed/{id}",
    "prev": "https://order.api.uat.jarden.io/order_feed/{id}"
  }
}
```

The order feed exposes the events associated with orders place on the Jarden platform, and the associated state transitions.

REST Feed properties:

+ working set; `/order_feed`


Each feed item is a reference to a specific order event which can be retrieved through a `GET` on the link associated with the `id` key.  The definition of the Order feed resource is described in the Order Domain Resources section.

## Order Resource

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

The JSON structure describes the properties of an Order.



| Property/Object         | Type    |  Description_of_the_Interface_Property |
| ---------               | -----   |  -----------  |
|`_type`            | string   | Always `clientOrder`   |
|`identifiers`      | Array  |  |
|`identifiers.*._type`    | string |  |
|`identifiers.*.id`       | string |  |
|`orderOriginator`    | string  |  |
|`state`    | string  | Enumeration of order states; created, allocated, confirmed, placed, part_filled, filled, expired, deleted, rejected)  |
|`timestamps`    | Array |  |
|`timestamps.createdTime`    | ISO8601_Time | The time the order was created within the OMS.  |
|`timestamps.lastModifiedTime`    | ISO8601_Time | Time of modification of the order.  |
|`timestamps.expiresAt`    | ISO8601_Time | The order expiry time. |
|`financialInstrument`    | Object | Instrument microformat |
|`financialInstrument.instrumentCode`    | string  |  |
|`financialInstrument.marketId`          | string |  |
|`specification`    |  |  |
|`specification.orderSide`    |  |  |
|`specification.orderDate`    |  |  |
|`specification.orderQuantity`    |  |  |
|`specification.canWorkOrder`    |  |  |
|`specification.participatingClientClass`    |  |  |
|`specification.executionStrategy`    |  |  |
|`specification.executionStrategy._type`    |  |  |
|`specification.executionStrategy.basis`    |  |  |
|`specification.inForceStrategy`    |  |  |
|`settlementInstructions`    |  |  |
|`settlementInstructions.settlementCurrency`   |  |  |
|`settlementInstructions.settlementInstrument` |  |  |
|`brokerage`                                   |  |  |
|`brokerage.priceScheduleCode`                 |  |  |
|`orderExecution`                              |  |  |
|`orderExecution.workingOrder`                 |  |  |
|`orderExecution.quantityBooked`    |  |  |
|`orderExecution.quantityBooked.unitCode`    |  |  |
|`orderExecution.quantityBooked.value`    |  |  |
|`orderParties`    |  |  |
|`orderParties.*._type`    |  |  |
|`orderParties.*.identifiers`    |  |  |
|`orderParties.*.identifiers.*._type`    |  |  |
|`orderParties.*.identifiers.*.id`    |  |  |
|`orderParties.*.partyExtensions` |  |  |
|`.partyExtensions.*._type` |  |  |
|`.partyExtensions.*.registrationLines` |  |  |
|`.partyExtensions.*.registrationCountryCode` |  |  |

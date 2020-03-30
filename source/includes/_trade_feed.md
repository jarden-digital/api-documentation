# Trade Feed

The client trade feed exposes the events associated with the state transitions of a client's settlement obligations resulting from 1..* trades (filled orders).

REST Feed properties:

+ working set; `/client_trade_feed`

> Sample request

```shell
GET client_trade_feed
host: trade.api.jarden.io
Authorization: Bearer <id_token>
```

> Sample Response

```json
{
  "items": [
    {"id": "https://trade.api.uat.jarden.io/client_trades/{id}", "tradeId": "28806116"},
    {"id": "https://trade.api.uat.jarden.io/client_trades/{id}", "tradeId": "28806131"},
    {"id": "https://trade.api.uat.jarden.io/client_trades/{id}", "tradeId": "28806114"},
  ],
  "links": {
    "self": "https://trade.api.uat.jarden.io/client_trade_feed/{id}",
    "prev": "https://trade.api.uat.jarden.io/client_trade_feed/{id}"
  }
}
```

Each feed item is a reference to a specific trade event, which can be retrieved through a `GET` on the link associated with the `id` key.  The definition of the trade can be found in the Trade section of Domain Resources.

## Trade Resource

The following marked-up JSON structure describes the properties of an Trade.

```json
{
  "timestamps": {
    "publishedTime": "2020-02-10T00:26:55Z"
  },
  "identifiers": [
    {
      "_type": "contractNoteReference",
      "id": "28806116"
    }
  ],
  "payload": {
    "cashState": "UNPAID",
    "tradeParties": [
      {
        "_type": "adviserParty"
      },
      {
        "_type": "clientParty",
        "identifiers": [
          {
            "_type": "counterPartyCode",
            "id": "POOL_RETAIL"
          },
          {
            "_type": "counterPartyAccount",
            "id": "01"
          }
        ]
      },
      {
        "_type": "settlementParty",
        "partyExtensions": [
          {
            "_type": "registryAuthorisation",
            "registrationLines": [
              null,
              null,
              null,
              null,
              null,
              null
            ]
          }
        ]
      }
    ],
    "identifiers": [
      {
        "_type": "contractNoteReference",
        "id": "28806116"
      },
      {
        "_type": "contractNoteVersion",
        "id": "1"
      },
      {
        "_type": "counterTradeReference",
        "id": "28806115"
      },
      {
        "_type": "instructionOriginReference",
        "id": "BANCS_SETTLEMENT"
      },
      {
        "_type": "tradeOrderId",
        "id": "266168"
      }
    ],
    "financialInstrument": {
      "instrumentCode": "EBO",
      "marketId": "NZX",
      "marketInstrumentCode": "EBO",
      "instrumentType": "EQUITY",
      "instrumentName": "Ebos Group Limited Ordinary Shares",
      "issuerCode": "EBO",
      "instrumentSettlementType": "BANCS_FULL"
    },
    "_type": "trade",
    "state": "TRADED",
    "timestamps": {
      "createdTime": "2020-02-10T01:10:28",
      "tradedTime": "2020-02-05T00:00:00",
      "settledTime": "2020-02-10T00:00:00"
    },
    "trade": {
      "buySell": "SELL",
      "tradeBasisSpecification": {
        "basis": "unit_price",
        "basisValue": {
          "unitCode": "unit"
        },
        "basisNetValue": {
          "unitCode": "unit",
          "value": 0.0
        }
      },
      "tradeQuantity": {
        "unitCode": "unit",
        "value": 24.0
      },
      "tradePrices": [
        {
          "priceType": "totalSettlementValue",
          "price": 397.92,
          "priceCurrency": "NZD"
        },
        {
          "priceType": "tradeMarketCurrencyPrice",
          "price": 16.58,
          "priceTradeCurrency": "NZD",
          "baseCurrency": "NZD",
          "eligibleQuantity": {
            "unitCode": "fxExchangeRate",
            "exchangeRate": 1.0
          }
        },
        {
          "priceType": "tradePrice",
          "price": 16.58,
          "priceCurrency": "NZD",
          "eligibleQuantity": {
            "unitCode": "bondPriceUnit",
            "value": 24.0
          }
        },
        {
          "priceType": "settlementValue",
          "price": 397.92,
          "priceCurrency": "NZD"
        },
        {
          "priceType": "brokerage",
          "price": 0.0,
          "priceCurrency": "NZD"
        },
        {
          "priceType": "aggregateAdditionalCharges",
          "price": 0.0,
          "priceCurrency": "NZD"
        },
        {
          "priceType": "rebate",
          "price": 0.0,
          "priceCurrency": "NZD"
        },
        {
          "priceType": "tradeFee",
          "price": 0.0,
          "priceCurrency": "NZD"
        },
        {
          "priceType": "applicationMoney",
          "price": 0.0,
          "priceCurrency": "NZD"
        }
      ]
    },
    "financialInstrumentState": "UNDELIVERED",
    "narratives": [
      {
        "_type": "tradeDescription",
        "id": "BANCS Netting trade 266168 for 24 NZX.EBO @ 16.58"
      }
    ],
    "_subType": "controlACTrade"
  }
}
```

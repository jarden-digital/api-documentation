# SSS Legacy API Services

## Introduction

The current integration between FNZ and SSS (based on proprietary sockets and direct DB protocols) is to be phased out as part of the Jarden-FNZ Ordering roadmap.  This will be implemented in 2 phases; the first is the decoupling FNZ and SSS, and second is the strategic evolution of the Order service.  This specification defines the 1st phase only.

## Order API

The current SSS order API is a custom sockets protocol based on a name/value pair format.  The objective for this service is to reimplement the API format using HTTP as the application protocol.

### SSS Message Format

An example of the existing format is as follows (line feeds are for readability only):

```
#EORNU00000000[order_source-'WEB_BROKER',
cp_code-'EDWARDS_JA',
cp_account_id-'01',
buy_sell_indicator-'BUY',
is_contra_order,boolean(false),
market_id-'NZSE',
market_instrument_code-'AAA',
quantity-'1000',
brokerage_code-'INTERNET_CASH',
order_basis-'MARKET',
order_expiry-t7(2003, 12, 20, 18, 0, 0, 0),
order_expiry_method-'GOOD_TILL_DATE',
order_reference-'DT00000001',
alternate_registration_details-registration_details('Mr and Mrs Egg','7 Planet Place','Masterton','','','', 'NZL', '6000'),
dealing_comment-'Fast execution requested.',
settlement_comment-'Send payment to CMT asap.',
contract_note_comment-‘Stand in Market',
settlement_date-t7(2003, 12, 23, 0, 0, 0, 0),
settlement_currency_code-'NZD',
check_trading_limit-boolean(false),
check_credit_limit-boolean(false)].\n
```

That header is formed as follows

```
#MMMTCSSSSSSSSP
```

+ `#` is the start of message indicator
+ `MMM` is the message type
+ `T` is the message sub-type
+ `C` is the compression flag, in this case always 'U' (uncompressed)
+ `SSSSSSSS` is the message length in base 10 as ASCII digits with leading zeroes.
+ `P` is the (payload) message itself.

### SE Order Protocol over HTTP

The sockets protocol will be replaced by an HTTP POST.  The two versions have similar protocol properties (both are stateless).  The HTTP API is defined as follows:

+ Request:
  - HTTP Method: `post`
  - HTTP Content-Type: `text/plain`
  - HTTP Message-Id: any universally unique identifier for the message (such as a UUID); when the client resends a message the same id MUST be used.
  - Params : SSS text encoded order format.
+ Response:
  - Status Codes:
    - `201 Created`; sync create of the order in SSS.
    - `202 Accepted`; async create of the order in SSS.
    - `401 Unauthorized`; service authentication failures.
    - `422 Unprocessable` Entity; for any error status returned by SSS.
    - `500..504`; for the various service non-functional failures.

The response body may either define a success or a failure with a reason.

On success:
```
#EOACU00000010A<TAB><SE Order Number>
```

On failure:

```
#EOACU00000040E<TAB><error_code><TAB><error_description>
```

Example cURL request

```
curl -d "#MMMTCSSSSSSSSbbbbbbbbbb"
     -H "Content-Type: text/plain"
     -H "Authorization: Bearer <token>"
     -H "Message-Id: 12dc1406-5290-4b1b-87a2-ec32a2b62719"
     -X POST https://api.jarden.io/order
```

### Security Considerations

+ HTTP over TLS, with server-side authentication required only.
+ Clients must provide an `Authorization` header containing a `Bearer` token obtained from the Jarden Authorisation Service.  The Oauth2 client credentials grant flow will be used to obtain the bearer token (an ID Token in JWT form).  Client ids and secrets will be provided out-of-band.  See [Oauth2 Flows](#oauth2-flows).

## Feeds

### Feed Styles

####  REST Feed

All feeds are in the ATOM-feed style.  Requesting the feed root resource provides the current working set; a mutating time-ordered list of events.  The working set also has a unique unique resource URL (e.g. `order/trade_feed/{id}`). The current working set is archived at some point, resulting in the instance of the set becoming immutable.  A new working set is opened and becomes the current working set.   

The collection of feed "archives" (that is, the current working set and the archives) are a time-ordered set of feed resources.  To navigate through the feed use the `next` and `prev` links available in each archive.

The feed provides a reference to the trade resource (as referenced by the `id` property in the feed `items` collection).

The `timestamps` object indicate the date/time in which the trade first entered a particular state in the state model.

#### GraphQL Feed

Not implemented.

### Trades Feed

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


### Order Feed

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

## Domain Resources

### Mini-Schema Markup

+ Comments use the `"//"` key.
+ Values which have schema markup use the format `"{ <markup }"`.  Regardless of the value type, its always marked up as a string
+ The markup format may include the following schema markup:
  - JSON Type:  `string | integer | number | float | bool`
  - Special String Types: For example `ISO8601_time` or non-elaborated enumerations (such as `JAR_CUSTOM_MIC`)
  - Enumerations: `enum(<string> | <string> | .. )`
  - Examples: `ex(<example string>)`

### Order

The following marked-up JSON structure describes the properties of an Order.

```
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
          "//": "registry must be 6 items of String"
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
            "//": "fnz_client_id if maintained by services"
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

## Trade

```
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
    "naratives": [
      {
        "_type": "tradeDescription",
        "id": "BANCS Netting trade 266168 for 24 NZX.EBO @ 16.58"
      }
    ],
    "_subType": "controlACTrade"
  }
}
```

## Oauth2 Authorisation Flows

### Client Credentials Grant

The API Client uses the [OAuth2 Client Credentials Grant Flow](https://tools.ietf.org/html/rfc6749#section-4.4) to obtain a token for use with the Jarden APIs.

This flow requires that the client be registered with the Jarden Authorisation Service, resulting in the issue of a `client_id` and `client_secret` for the client.

#### Token Flow

__Sample Client Credentials Grant Token Request__

```shell
POST /oauth/token HTTP/1.1
Host: jarden-uat.au.auth0.com
Authentication: Basic Basic {{client_id}} {{client_secret}}
Content-Type: application/x-www-form-urlencoded

audience=https://api.jarden.io&
grant_type=client_credentials&
&scopes=openid
```

__Sample Client Credentials Grant Token Response__

```
HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Cache-Control: no-store
Pragma: no-cache

{
  "access_token": "eyJ0e...IPf4rCLZLEww",
  "expires_in": 86400,
  "token_type": "Bearer"
}
```

A request is made to the `/oauth/token` endpoint, with a body that includes the `grant_type` `client_credentials`.


Parameter     |  Description
---------     |  -----------
grant_type    | `client_credentials`
scope         | `openid`
audience      | `https://api.jarden.io`  

The token response returns an OAuth2 `access_token` (which is an OpenId Connect `id_token`), a JSON Web Token to be provided on API requests.

### Validating the Token

The token returned includes a signature and should be validated by the API Client.  This requires the public key used to sign the token.  This can be retrieved from the `JWKS` endpoint.

```
GET .well-known/jwks.json HTTP/1.1
Host: jarden-uat.au.auth0.com
```

The response from the `jwks` request is a [JSON Web Key Set](https://tools.ietf.org/html/rfc7517), indexed by `kid`.  The access token contains the `"kid"` which references the JSON Web Key used to sign the token in the JWT header.


### Making API Requests using the Token

The token is carried in the HTTP `AUTHORIZATION` header as a **bearer**.  The structure of the bearer token in an HTTP request looks like this:

```
GET /resource HTTP/1.1
Host: https://api.jarden.io
Authorization: Bearer <token>
```

## Microformats

### identifiers

Objects may have a specific _identity_ in the context of the service, representing the persistent and universal identifier of the object through time.  Objects may also have "other" _identifiers_, which (perhaps) acts as an _identity_ within the context of another authority/namespace.  For example, a `financialInstrument` has a `id` property (as a UUID) provided as an _identity_ by the service.  It may also have a number of other _identifiers_ managed by other authorities (such as an ISIN or a SEDOL).  These other _identifiers_ may be identities in the context of the authority/namespace, but not in the context of the service; hence they become _identifiers_

Identifies have 2 formats:

+ The structured URN format; the identifier type is provided in the URN; e.g. `urn:jar:instrument:id:isin:US0378331005`
+ The type/value object format; an object with `id` and `_type` properties, e.g.

```json
{"_type": "urn:jar:instrument:id:isin", "id": "US0378331005"},
```

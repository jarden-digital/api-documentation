# Jarden Legacy Order API

This service retires the existing custom sockets protocol, while maintaining the same legacy order representation.  The service is provided over HTTP and is secured with Jarden OpenId Connect tokens.

## Order Message Format

```shell
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
contract_note_comment-'Stand in Market',
settlement_date-t7(2003, 12, 23, 0, 0, 0, 0),
settlement_currency_code-'NZD',
check_trading_limit-boolean(false),
check_credit_limit-boolean(false)].\n
```

An example of the existing format is as follows (line feeds are for readability only).

The header is formed as follows:

+ `#` is the start of message indicator
+ `MMM` is the message type
+ `T` is the message sub-type
+ `C` is the compression flag, in this case always 'U' (uncompressed)
+ `SSSSSSSS` is the message length in base 10 as ASCII digits with leading zeroes.
+ `P` is the (payload) message itself.

## Order Protocol over HTTP

> On success:

```shell
#EOACU00000010A<TAB><SE Order Number>
```

> On failure:

```shell
#EOACU00000040E<TAB><error_code><TAB><error_description>
```

> Example cURL request

```shell
curl -d "#MMMTCSSSSSSSSbbbbbbbbbb"
     -H "Content-Type: text/plain"
     -H "Authorization: Bearer <token>"
     -H "Message-Id: 12dc1406-5290-4b1b-87a2-ec32a2b62719"
     -X POST https://order.api.jarden.io
```

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


### Security Considerations

+ HTTP over TLS, with server-side authentication required only.
+ Clients must provide an `Authorization` header containing a `Bearer` token obtained from the Jarden Authorisation Service.  The Oauth2 client credentials grant flow will be used to obtain the bearer token (an ID Token in JWT form).  Client ids and secrets will be provided out-of-band.  See [Oauth2 Flows](#authorisation-flows).

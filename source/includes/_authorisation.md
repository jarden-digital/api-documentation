# Authentication and Authorisation

This section describes the approach for authentication and authorisation of 3rd party/partner applications wishing to obtain access to APIs.  Before you begin using the APIs, you need to contact us to obtain and configuration for your Oauth Clients.

The Jarden APIs support [OAuth2](https://tools.ietf.org/html/rfc6749) for authorisation, and [OpenID Connect JSON Web Tokens](http://openid.net/specs/openid-connect-core-1_0.html) to represent access tokens.

We support 1 of the Oauth2 authorisation flows:

+ [OAuth2 Client Credentials Grant Flow](https://tools.ietf.org/html/rfc6749#section-4.4).  In some circumstances, the Relying Party can be provided with this flow, when the required APIs are not specific to an individual customer.  Contact us if you need this level of API access.  


The purpose of the authorisation flow is to obtain a "scoped" identity token (`id_token`) that can then be used to call Jarden APIs.  The `id_token` is in the form of an OpenIdConnect JWT.

<aside class="notice">A Relying Party is the OpenId Connect term for an Oauth2 Client.  This is the system which is requesting access to a user's information.  Relying Parties must be configured with Jarden before any authorisation requests can be made.</aside>

## Host

The authorisation services are all available via the `https://identity.mindainfo.io`.  If you are using the acceptance sandpit, the url is `https://identity.accp.mindainfo.io`

## Relying Party Registration

Registration of the partner relying party will be performed "out-of-band" by Jarden.  A client_id and a client_secret to be used for authentication, authorisation, and obtaining tokens.


## Authorisation Flows

The partner may request access to the [OAuth2 Client Credentials Grant Flow](#client-credentials-grant-flow) to obtain access more general access to APIs.

### Client Credentials Grant Flow

The Client Credentials Grant flow is suited to B2B integration scenarios where developers want to access APIs when there is no specific Jarden client involved.

This flow requires that the developer obtain a separate set of client application credentials to authorise their application.  Those client credentials come in the form of a `client_id` and a `client_secret`, which are directly exchanged for a token, which is used in the same way as tokens obtained through other flows.

#### Token

> Sample Client Credentials Grant Token Request

```shell
POST /oauth/token HTTP/1.1
Host: jarden.au.auth0.com
Authentication: Basic Basic {{client_id}} {{client_secret}}
Content-Type: application/x-www-form-urlencoded

audience=https://api.jarden.io&grant_type=client_credentials&&scopes=openid
```

> Sample Client Credentials Grant Token Response


```shell
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

A request is made to the `/oauth/token` endpoint, with a body that includes the `grant_type` 'client_credentials'.


Parameter     |  Description
---------     |  -----------
grant_type    | `client_credentials`
scope         | Must include `openid`.  Scopes are a collection of space-delimited, case-sensitive strings containing valid Jarden scopes.

<aside class="success">
The clients credentials are included in the request as 'HTTP Basic Authentication' header, where the <code>client_id</code> is the username, and the <code>client_secret</code> is the password.
</aside>

The token response returns an OAuth2 `access_token` which is an OpenId Connect `id_token`.


## Identity Token

In all cases, the Identity Service will issue an [OpenId Connect ID Token](http://openid.net/specs/openid-connect-core-1_0.html#Claims).  The ID Token is structured as follows (and is serialised in a format known as a [JSON Web Token or JWT](https://tools.ietf.org/html/rfc7519))


### Validating the Token

```shell
curl -G https://jarden.au.auth0.com/.well-known/jwks.json
```

It is recommended that the relying party validate the token's signature.  The public key can be obtained through the [public key API](#public-key).  The signature is generated using `RSASSA-PKCS1-v1_5` with the `SHA-256` hash algorithm, known in the token as `RS256`

### Structure of the Token

> Sample decoded ID Token

```json
{
  "typ": "JWT",
  "alg": "RS256",
  "kid": "MTRCMzYxRjBGRTQ2QkI1MUVGNUVGMzk0ODM0OUM3MzM2RTQ2QTlDRQ"
}
```

```json
{
  "iss": "https://jarden.au.auth0.com/",
  "sub": "aOQ3...vL6m@clients",
  "aud": "https://api.jarden.io",
  "iat": 1584934625,
  "exp": 1585021025,
  "azp": "aOQ3...vL6m",
  "gty": "client-credentials"
}
```

The ID Token is an OpenID Connect token, containing claims.  It also includes a signature.  The `id_token` is used on all subsequent API requests.


## Making API Requests using the Token

The id_token is carried in the HTTP `AUTHORIZATION` header as a **bearer** token.  The structure of the bearer token in an HTTP request looks like this:

```shell
GET /resource HTTP/1.1
Host: api.jarden.io
Authorization: Bearer <id_token>
```

## Public Key

> Sample Request

```shell
GET .well-known/jwks.json
Host: https://jarden.au.auth0.com
```

> Sample Response

```json
{
  "keys": [
    {
      "alg": "RS256",
      "kty": "RSA",
      "use": "sig",
      "n": "8DEMKBJSmVRoofbCfb_KoXq2BWsCbr4W8a1dC4yQCzPTE6hTbAsCzjbMwBZv1bB5fqc_eYB4AkL1zsvydNv0thO0cteHwBDvq1cGYVvFHDgklVvt9PFnGSQmLM8yMZNC_CBDF4J_aiCmqI8yFHqxBXIvSbPRUhcD900epa7im62s4IxHQliqacey4QNYKEHlhzD7PI_iPY7frGEadqnoiUm29J6hduQaaF7Lco0e7hjgiPDr0X3BUtkpqURYwIAeeDQvy3eUb35RRGEc-XHAB0KisKm_UzN6kuJan8inlnT0UCZFhmXRxLmOYMJtJDPU4I2GVO6u9C0HGsorTW1VvQ",
      "e": "AQAB",
      "kid": "MTRCMzYxRjBGRTQ2QkI1MUVGNUVGMzk0ODM0OUM3MzM2RTQ2QTlDRQ",
      "x5t": "MTRCMzYxRjBGRTQ2QkI1MUVGNUVGMzk0ODM0OUM3MzM2RTQ2QTlDRQ",
      "x5c": [
        "MIIDCTCCAfGgAwIBAgIJUFHFSRSs3eaoMA0GCSqGSIb3DQEBCwUAMCIxIDAeBgNVBAMTF2phcmRlbi11YXQuYXUuYXV0aDAuY29tMB4XDTE5MDQyMzA1MTY0M1oXDTMyMTIzMDA1MTY0M1owIjEgMB4GA1UEAxMXamFyZGVuLXVhdC5hdS5hdXRoMC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDwMQwoElKZVGih9sJ9v8qherYFawJuvhbxrV0LjJALM9MTqFNsCwLONszAFm/VsHl+pz95gHgCQvXOy/J02/S2E7Ry14fAEO+rVwZhW8UcOCSVW+308WcZJCYszzIxk0L8IEMXgn9qIKaojzIUerEFci9Js9FSFwP3TR6lruKbrazgjEdCWKppx7LhA1goQeWHMPs8j+I9jt+sYRp2qeiJSbb0nqF25BpoXstyjR7uGOCI8OvRfcFS2SmpRFjAgB54NC/Ld5RvflFEYRz5ccAHQqKwqb9TM3qS4lqfyKeWdPRQJkWGZdHEuY5gwm0kM9TgjYZU7q70LQcayitNbVW9AgMBAAGjQjBAMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFK3mvmbp8m/i9vnYB6wzvYikDKtyMA4GA1UdDwEB/wQEAwIChDANBgkqhkiG9w0BAQsFAAOCAQEAmvQ4MCyCXlJ/LXfKDY1rq5X6yPPR8YnKk2+YFihVP6Sj5RyHtJ2nOsovuz5S5e5kOdYKVN+b+eIifOqFamb4aZ9ezqzqTVDEMR8tjzYYkrEOJaFDzbSjJ/M5UkZBSpfsyll6B+idRZ/5m0oPKYfq6Qwj9LUNZcOoh17rYOHlBo6akv/ZwUxmsRMb78onHSSzL9RoV8ATkP7AnuXksN5L1VDS+M9MWg8PQQyvwd9QvrmUvoZanl7VWiErAYynSNtd+BELRADLC18buToihJsKSBleOfYANyIzTje7HWSXQgBiSoDyM3nj7IEdsv59jzeiAUSgOFGUBVvYfoapvtfoqg=="
      ]
    }
  ]
}
```

Each token is issued with a `kid` in the header.  Public keys are published at the `.well-known/jwks.json` in the form of the [JSON Web Key Set format](https://tools.ietf.org/html/rfc7517).  The majority of JWT client libraries are able to validate a JWT using a JWK.  

# Feeds

## Feed Styles

###  REST Feed

All feeds are in the ATOM-feed style.  Requesting the feed root resource provides the current working set; a mutating time-ordered list of events.  The working set also has a unique unique resource URL (e.g. `trade_feed/{id}`). The current working set is archived at some point, resulting in the instance of the set becoming immutable.  A new working set is opened and becomes the current working set.   

The collection of feed "archives" (that is, the current working set and the archives) are a time-ordered set of feed resources.  To navigate through the feed use the `next` and `prev` links available in each archive.

> Example Trade item Identifiers

```json
{
  "identifiers": [
    {
      "_type": "contractNoteReference",
      "id": "abc123"
    },
    {
      "_type": "contractNoteVersion",
      "id": "1"
    },
    {
      "_type": "contractNoteReference",
      "id": "28804708"
    }
  ],
}
```

> Example Trade item Feed structure

```json
{
  "id": "https://trade.api.uat.jarden.io/client_trades/7cf7fe78-e3de-4aa9-a36f-c8c24b1ef79e",
  "identifiers": [
    {
      "_type": "contractNoteReference",
      "id": "abc123"
    },
    {
      "_type": "contractNoteVersion",
      "id": "1"
    },
    {
      "_type": "contractNoteReference",
      "id": "28804708"
    }
  ]
}
```

The feed provides identifiers from the item within the feed items collection.

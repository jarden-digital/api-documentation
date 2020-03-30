# Feeds

## Feed Styles

###  REST Feed

All feeds are in the ATOM-feed style.  Requesting the feed root resource provides the current working set; a mutating time-ordered list of events.  The working set also has a unique unique resource URL (e.g. `trade_feed/{id}`). The current working set is archived at some point, resulting in the instance of the set becoming immutable.  A new working set is opened and becomes the current working set.   

The collection of feed "archives" (that is, the current working set and the archives) are a time-ordered set of feed resources.  To navigate through the feed use the `next` and `prev` links available in each archive.

The feed provides a reference to the trade resource (as referenced by the `id` property in the feed `items` collection).

The `timestamps` object indicate the date/time in which the trade first entered a particular state in the state model.

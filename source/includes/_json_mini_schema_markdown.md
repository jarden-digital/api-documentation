# JSON Mini-Schema Markdown

+ Comments use the `"//"` key.
+ Values which have schema markup use the format `"{ <markup }"`.  Regardless of the value type, its always marked up as a string
+ The markup format may include the following schema markup:
  - JSON Type:  `string | integer | number | float | bool`
  - Special String Types: For example `ISO8601_time` or non-elaborated enumerations (such as `JAR_CUSTOM_MIC`)
  - Enumerations: `enum(<string> | <string> | .. )`
  - Examples: `ex(<example string>)`

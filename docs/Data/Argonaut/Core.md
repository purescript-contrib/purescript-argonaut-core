## Module Data.Argonaut.Core

#### `JBoolean`

``` purescript
type JBoolean = Boolean
```

#### `JNumber`

``` purescript
type JNumber = Number
```

#### `JString`

``` purescript
type JString = String
```

#### `JAssoc`

``` purescript
type JAssoc = Tuple String Json
```

#### `JArray`

``` purescript
type JArray = Array Json
```

#### `JObject`

``` purescript
type JObject = StrMap Json
```

#### `JNull`

``` purescript
data JNull :: *
```

##### Instances
``` purescript
instance eqJNull :: Eq JNull
instance ordJNull :: Ord JNull
instance showJNull :: Show JNull
```

#### `Json`

``` purescript
data Json :: *
```

##### Instances
``` purescript
instance eqJson :: Eq Json
instance ordJson :: Ord Json
instance showJson :: Show Json
```

#### `foldJson`

``` purescript
foldJson :: forall a. (JNull -> a) -> (JBoolean -> a) -> (JNumber -> a) -> (JString -> a) -> (JArray -> a) -> (JObject -> a) -> Json -> a
```

#### `foldJsonNull`

``` purescript
foldJsonNull :: forall a. a -> (JNull -> a) -> Json -> a
```

#### `foldJsonBoolean`

``` purescript
foldJsonBoolean :: forall a. a -> (JBoolean -> a) -> Json -> a
```

#### `foldJsonNumber`

``` purescript
foldJsonNumber :: forall a. a -> (JNumber -> a) -> Json -> a
```

#### `foldJsonString`

``` purescript
foldJsonString :: forall a. a -> (JString -> a) -> Json -> a
```

#### `foldJsonArray`

``` purescript
foldJsonArray :: forall a. a -> (JArray -> a) -> Json -> a
```

#### `foldJsonObject`

``` purescript
foldJsonObject :: forall a. a -> (JObject -> a) -> Json -> a
```

#### `isNull`

``` purescript
isNull :: Json -> Boolean
```

#### `isBoolean`

``` purescript
isBoolean :: Json -> Boolean
```

#### `isNumber`

``` purescript
isNumber :: Json -> Boolean
```

#### `isString`

``` purescript
isString :: Json -> Boolean
```

#### `isArray`

``` purescript
isArray :: Json -> Boolean
```

#### `isObject`

``` purescript
isObject :: Json -> Boolean
```

#### `toNull`

``` purescript
toNull :: Json -> Maybe JNull
```

#### `toBoolean`

``` purescript
toBoolean :: Json -> Maybe JBoolean
```

#### `toNumber`

``` purescript
toNumber :: Json -> Maybe JNumber
```

#### `toString`

``` purescript
toString :: Json -> Maybe JString
```

#### `toArray`

``` purescript
toArray :: Json -> Maybe JArray
```

#### `toObject`

``` purescript
toObject :: Json -> Maybe JObject
```

#### `fromNull`

``` purescript
fromNull :: JNull -> Json
```

#### `fromBoolean`

``` purescript
fromBoolean :: JBoolean -> Json
```

#### `fromNumber`

``` purescript
fromNumber :: JNumber -> Json
```

#### `fromString`

``` purescript
fromString :: JString -> Json
```

#### `fromArray`

``` purescript
fromArray :: JArray -> Json
```

#### `fromObject`

``` purescript
fromObject :: JObject -> Json
```

#### `jsonNull`

``` purescript
jsonNull :: Json
```

#### `jsonTrue`

``` purescript
jsonTrue :: Json
```

#### `jsonFalse`

``` purescript
jsonFalse :: Json
```

#### `jsonZero`

``` purescript
jsonZero :: Json
```

#### `jsonEmptyArray`

``` purescript
jsonEmptyArray :: Json
```

#### `jsonEmptyObject`

``` purescript
jsonEmptyObject :: Json
```

#### `jsonSingletonArray`

``` purescript
jsonSingletonArray :: Json -> Json
```

#### `jsonSingletonObject`

``` purescript
jsonSingletonObject :: String -> Json -> Json
```



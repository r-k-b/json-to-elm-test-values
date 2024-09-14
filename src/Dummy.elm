module Dummy exposing (data)

import Json.Encode as JE


data =
    [ [ ( "description", JE.string "." )
      , ( "products"
        , []
            |> JE.list identity
        )
      , ( "coverTypes"
        , []
            |> JE.list identity
        )
      , ( "states"
        , []
            |> JE.list identity
        )
      , ( "id", JE.float 0 )
      , ( "endDate", JE.string "2999-12-31T23:59:59.999+11:00" )
      , ( "startDate", JE.string "1900-01-01T00:00:00+10:00" )
      ]
        |> JE.object
    ]
        |> JE.list identity
        |> JE.encode 2

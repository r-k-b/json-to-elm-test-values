module Main exposing (main)

import Browser
import Dummy
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import Json.Value exposing (JsonValue(..))
import Result.Extra


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( { inputJson = Dummy.data }, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { inputJson : String }


type Msg
    = InputChanged String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputChanged newVal ->
            ( { model | inputJson = newVal }, Cmd.none )


{-| Wrapping in a `let` block allows intellij-elm to collapse the code properly;
handy for large json.
-}
view : Model -> H.Html Msg
view model =
    H.div [ HA.class "taGrid" ]
        [ H.textarea [ HE.onInput InputChanged ] [ H.text model.inputJson ]
        , H.textarea []
            [ "(let\n  collapsible = (\n"
                ++ (model.inputJson
                        |> JD.decodeString Json.Value.decoder
                        |> Result.Extra.unpack JD.errorToString asElmCode
                   )
                ++ "\n |> JE.encode 2)\nin collapsible\n)"
                |> H.text
            ]
        ]


indentWidth =
    4


indent : String -> String
indent s =
    let
        ind =
            String.repeat indentWidth " "
    in
    s |> String.replace "\n" ("\n" ++ ind)


asElmCode : JsonValue -> String
asElmCode val =
    case val of
        ObjectValue fields ->
            "\n(["
                ++ (fields
                        |> List.map
                            (\( name, v ) ->
                                "(\""
                                    ++ name
                                    ++ "\", "
                                    ++ asElmCode v
                                    ++ ")"
                            )
                        |> String.join "\n,"
                   )
                ++ "\n] |> JE.object)"
                |> indent

        ArrayValue vals ->
            "\n(["
                ++ (vals |> List.map asElmCode |> String.join "\n ,")
                ++ "]\n |> JE.list identity)"
                |> indent

        BoolValue bool ->
            "(JE.bool "
                ++ (if bool then
                        "True"

                    else
                        "False"
                   )
                ++ ")"
                |> indent

        NullValue ->
            "JE.null"
                |> indent

        NumericValue float ->
            "(JE.float "
                ++ String.fromFloat float
                ++ ")"
                |> indent

        StringValue string ->
            "(JE.string \""
                ++ (string
                        |> String.replace "\\" "\\u{005c}"
                        |> String.replace "\"" "\\u{0022}"
                        |> String.replace "\n" "\\n"
                   )
                ++ "\")"
                |> indent

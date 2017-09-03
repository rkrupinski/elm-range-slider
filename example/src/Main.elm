module Main exposing (..)

import Html exposing (..)
import Slider.Core as Slider
import Slider.Helpers exposing (..)


type Msg
    = SliderAMsg Slider.Msg
    | SliderBMsg Slider.Msg


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { sliderA : Slider.Model
    , sliderB : Slider.Model
    , valuesA : Slider.Values
    , valuesB : Slider.Values
    }


rangeA : Slider.Range
rangeA =
    ( -5, 5 )


rangeB : Slider.Range
rangeB =
    ( 13, 44.75 )


configA : Slider.Config
configA =
    let
        parseValue : Float -> Float
        parseValue =
            valueParser rangeA

        parseStep : Float -> Float
        parseStep =
            stepParser rangeA
    in
        { size = Just 200
        , values = Just ( parseValue 0, parseValue 5 )
        , step = Just <| parseStep 1
        }


configB : Slider.Config
configB =
    { size = Nothing
    , values = Nothing
    , step = Nothing
    }


init : ( Model, Cmd Msg )
init =
    let
        sliderA : Slider.Model
        sliderA =
            Slider.init configA

        sliderB : Slider.Model
        sliderB =
            Slider.init configB
    in
        ( Model
            sliderA
            sliderB
            (Slider.getValues sliderA)
            (Slider.getValues sliderB)
        , Cmd.none
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SliderAMsg sliderMsg ->
            let
                ( sliderA, cmd ) =
                    Slider.update sliderMsg model.sliderA
            in
                { model
                    | sliderA = sliderA
                    , valuesA = Slider.getValues model.sliderA
                }
                    ! [ Cmd.map SliderAMsg cmd ]

        SliderBMsg sliderMsg ->
            let
                ( sliderB, cmd ) =
                    Slider.update sliderMsg model.sliderB
            in
                { model
                    | sliderB = sliderB
                    , valuesB = Slider.getValues model.sliderB
                }
                    ! [ Cmd.map SliderBMsg cmd ]


view : Model -> Html Msg
view { sliderA, sliderB, valuesA, valuesB } =
    div
        []
        [ Html.map SliderAMsg <| Slider.view sliderA
        , dl []
            [ dt [] [ text "Values A:" ]
            , dd [] [ renderValues rangeA valuesA ]
            ]
        , Html.map SliderBMsg <| Slider.view sliderB
        , dl []
            [ dt [] [ text "Values B:" ]
            , dd [] [ renderValues rangeB valuesB ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions { sliderA, sliderB } =
    Sub.batch
        [ Sub.map SliderAMsg <| Slider.subscriptions sliderA
        , Sub.map SliderBMsg <| Slider.subscriptions sliderB
        ]


renderValues : Slider.Range -> Slider.Values -> Html Msg
renderValues range ( left, right ) =
    let
        formatValue : Float -> String
        formatValue =
            valueFormatter range >> toString

        left_ : String
        left_ =
            formatValue left

        right_ : String
        right_ =
            formatValue right
    in
        text <| left_ ++ ", " ++ right_

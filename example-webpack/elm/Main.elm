module Main exposing (..)

import Html exposing (..)
import Slider.Core as Slider
import Slider.Helpers exposing (..)


type Msg
    = SliderMsg Slider.Msg


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { slider : Slider.Model
    , values : Slider.Values
    }


range : Slider.Range
range =
    ( -5, 5 )


config : Slider.Config
config =
    let
        parseValue : Float -> Float
        parseValue =
            valueParser range

        parseStep : Float -> Float
        parseStep =
            stepParser range
    in
        { size = Just 300
        , values = Just ( parseValue 0, parseValue 5 )
        , step = Just <| parseStep 1
        }


init : ( Model, Cmd Msg )
init =
    let
        slider : Slider.Model
        slider =
            Slider.init config
    in
        ( Model slider <| Slider.getValues slider
        , Cmd.none
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SliderMsg sliderMsg ->
            let
                ( slider, cmd ) =
                    Slider.update sliderMsg model.slider

                values : Slider.Values
                values =
                    Slider.getValues model.slider
            in
                { model
                    | slider = slider
                    , values = values
                }
                    ! [ Cmd.map SliderMsg cmd ]


view : Model -> Html Msg
view { slider, values } =
    div
        []
        [ Html.map SliderMsg <| Slider.view slider
        , dl []
            [ dt [] [ text "Values:" ]
            , dd [] [ renderValues range values ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions { slider } =
    Sub.batch
        [ Sub.map SliderMsg <| Slider.subscriptions slider
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

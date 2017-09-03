module Slider.Core exposing (Config, Msg, Model, Values, Range, init, update, view, subscriptions, getValues)

{-| Slider component

# Types
@docs Config, Msg, Model, Values, Range

# Configuration
@docs init

# State
@docs getValues

# Update
@docs update

# Subscriptions
@docs subscriptions

# View
@docs view
-}

import Html exposing (..)
import Html.Events exposing (onWithOptions)
import Html.Attributes exposing (style)
import Json.Decode as Json
import Mouse
import Css exposing (..)
import Html.CssHelpers
import Slider.ClassNames as ClassNames


{ class, classList } =
    Html.CssHelpers.withNamespace "slider"


styles : List Style -> Attribute msg
styles =
    asPairs >> Html.Attributes.style


{-| Slider values
-}
type alias Values =
    ( Float, Float )


{-| Slider range
-}
type alias Range =
    ( Float, Float )


type Knob
    = LeftKnob
    | RightKnob


{-| Internal slider messages
-}
type Msg
    = DragStart Knob Int
    | Drag Int
    | DragStop


{-| Slider config
-}
type alias Config =
    { size : Maybe Int
    , values : Maybe Values
    , step : Maybe Float
    }


{-| Slider model
-}
type Model
    = Model
        { dragging : Maybe Knob
        , offset : Maybe Int
        , step : Maybe Float
        , size : Int
        , left : Float
        , right : Float
        , tmpLeft : Float
        , tmpRight : Float
        }


{-| Initializes the slider
-}
init : Config -> Model
init { size, values, step } =
    let
        sliderSize : Int
        sliderSize =
            Maybe.withDefault 150 size

        sliderValues : Values
        sliderValues =
            Maybe.withDefault ( 0, 1 ) values

        ( left, right ) =
            sliderValues
    in
        Model
            { dragging = Nothing
            , offset = Nothing
            , step = step
            , size = sliderSize
            , left = left
            , right = right
            , tmpLeft = left
            , tmpRight = right
            }


toStep : Float -> Float -> Float
toStep step value =
    value
        |> flip (/) step
        |> Basics.round
        |> toFloat
        |> (*) step


constraint : Knob -> Float -> Maybe Float -> Float -> Float
constraint knob other step value =
    case knob of
        LeftKnob ->
            case step of
                Just stepVal ->
                    value
                        |> toStep stepVal
                        |> clamp 0 other

                Nothing ->
                    clamp 0 other value

        RightKnob ->
            case step of
                Just stepVal ->
                    value
                        |> toStep stepVal
                        |> clamp other 1

                Nothing ->
                    clamp other 1 value


{-| Updates slider model based on a message
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    let
        { dragging, offset, step, size, left, right, tmpLeft, tmpRight } =
            model
    in
        case msg of
            DragStart knob pos ->
                ( Model
                    { model
                        | dragging = Just knob
                        , offset = Just pos
                    }
                , Cmd.none
                )

            Drag x ->
                let
                    knobOffset : Int
                    knobOffset =
                        Maybe.withDefault 0 offset

                    delta : Float
                    delta =
                        x
                            |> flip (-) knobOffset
                            |> toFloat
                            |> flip (/) (toFloat size)

                    leftPos : Float
                    leftPos =
                        case dragging of
                            Just LeftKnob ->
                                left
                                    |> flip (+) delta
                                    |> constraint LeftKnob right step

                            _ ->
                                left

                    rightPos : Float
                    rightPos =
                        case dragging of
                            Just RightKnob ->
                                right
                                    |> flip (+) delta
                                    |> constraint RightKnob left step

                            _ ->
                                right
                in
                    ( Model
                        { model
                            | tmpLeft = leftPos
                            , tmpRight = rightPos
                        }
                    , Cmd.none
                    )

            DragStop ->
                ( Model
                    { model
                        | dragging = Nothing
                        , offset = Nothing
                        , left = tmpLeft
                        , right = tmpRight
                    }
                , Cmd.none
                )


{-| Renders the slider
-}
view : Model -> Html Msg
view (Model { size, tmpLeft, tmpRight }) =
    let
        sliderSize : Css.Px
        sliderSize =
            size
                |> toFloat
                |> px

        leftOffset : Float
        leftOffset =
            size
                |> toFloat
                |> (*) tmpLeft

        rightOffset : Float
        rightOffset =
            size
                |> toFloat
                |> (*) tmpRight
    in
        div
            [ styles [ width sliderSize ]
            , class [ ClassNames.Slider ]
            ]
            [ renderKnob LeftKnob leftOffset
            , renderRange size tmpLeft tmpRight
            , renderKnob RightKnob rightOffset
            ]


renderKnob : Knob -> Float -> Html Msg
renderKnob knob x =
    div
        [ styles [ Css.left <| px x ]
        , classList
            [ ( ClassNames.Knob, True )
            , ( ClassNames.LeftKnob, knob == LeftKnob )
            , ( ClassNames.RightKnob, knob == RightKnob )
            ]
        , onMouseDown <| DragStart knob
        ]
        []


renderRange : Int -> Float -> Float -> Html Msg
renderRange size left right =
    let
        rangeWidth : Css.Px
        rangeWidth =
            right
                |> flip (-) left
                |> (*) (toFloat size)
                |> px

        rangePos : Css.Px
        rangePos =
            left
                |> (*) (toFloat size)
                |> px
    in
        div
            [ styles
                [ Css.width rangeWidth
                , Css.left rangePos
                ]
            , class [ ClassNames.Range ]
            ]
            []


{-| Subscriptions required by the slider to work
-}
subscriptions : Model -> Sub Msg
subscriptions (Model { dragging }) =
    case dragging of
        Just knob ->
            Sub.batch
                [ Mouse.moves (\{ x } -> Drag x)
                , Mouse.ups <| always DragStop
                ]

        Nothing ->
            Sub.none


{-| Retrieves the currently selected values
-}
getValues : Model -> Values
getValues (Model { tmpLeft, tmpRight }) =
    ( tmpLeft, tmpRight )


onMouseDown : (Int -> msg) -> Attribute msg
onMouseDown message =
    onWithOptions
        "mousedown"
        { stopPropagation = False
        , preventDefault = True
        }
    <|
        Json.map message <|
            Json.field "clientX" Json.int

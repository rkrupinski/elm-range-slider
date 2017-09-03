module Slider.Styles exposing (styles)

{-| Default slider styles

@docs styles
-}

import Css exposing (..)
import Css.Colors exposing (..)
import Css.Namespace exposing (namespace)
import Slider.ClassNames exposing (..)


{-| Default styles
-}
styles : Stylesheet
styles =
    (stylesheet << namespace "slider")
        [ class Slider
            [ height <| px 5
            , margin2 (em 1) zero
            , position relative
            , backgroundColor silver
            ]
        , class Knob
            [ width <| px 5
            , height <| px 5
            , position absolute
            , backgroundColor black
            , cursor pointer
            ]
        , class LeftKnob
            [ marginLeft <| px -5
            ]
        , class RightKnob
            []
        , class Range
            [ height <| px 5
            , position absolute
            , top zero
            , backgroundColor gray
            ]
        ]

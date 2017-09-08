module CustomStyles exposing (styles)

import Css exposing (..)
import Css.Colors exposing (..)
import Css.Namespace exposing (namespace)
import Slider.ClassNames exposing (..)


styles : Stylesheet
styles =
    (stylesheet << namespace "slider")
        [ class Slider
            [ height <| px 10
            , margin <| em 1
            , position relative
            , borderRadius <| px 5
            , backgroundColor orange
            ]
        , class Knob
            [ width <| px 10
            , height <| px 10
            , position absolute
            , borderRadius <| px 5
            , backgroundColor blue
            , cursor pointer
            ]
        , class LeftKnob
            [ marginLeft <| px -10
            ]
        , class RightKnob
            []
        , class Range
            [ height <| px 10
            , position absolute
            , top zero
            , borderRadius <| px 5
            , backgroundColor green
            ]
        ]

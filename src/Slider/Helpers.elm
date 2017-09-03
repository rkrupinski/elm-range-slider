module Slider.Helpers exposing (..)

{-| Helpers for interacting with the slider

# Value
@docs valueFormatter, valueParser

# Step
@docs stepParser
-}

import Slider.Core exposing (Range)


{-| Maps a `Float` within `( 0, 1 )` range to a `Float` within the given range

    valueFormatter ( 0, 10 ) 0.5 == 5
-}
valueFormatter : Range -> Float -> Float
valueFormatter ( left, right ) value =
    let
        diff =
            (-) right left
    in
        value
            |> (*) diff
            |> (+) left


{-| Maps a `Float` within the given range to a `Float` within `( 0, 1 )` range

    valueParser ( 0, 10 ) 5 == 0.5
-}
valueParser : Range -> Float -> Float
valueParser ( left, right ) value =
    let
        diff =
            (-) right left
    in
        value
            |> flip (-) left
            |> flip (/) diff


{-| Converts a `Float` to a `Float` within `( 0, 1 )` range based on the given range

    stepParser ( -5, 10 ) 5 == 0.3333333333333333
-}
stepParser : Range -> Float -> Float
stepParser ( left, right ) value =
    let
        diff =
            (-) right left
    in
        (/) value diff

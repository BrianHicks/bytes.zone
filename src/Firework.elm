module Firework exposing (..)

import Color
import Colors
import Particle exposing (Particle)
import Random exposing (Generator)
import Random.Float exposing (normal)
import Svg exposing (Svg)
import Svg.Attributes as SAttrs


type alias Firework =
    ()


fizzler : Generator (Particle Firework)
fizzler =
    Particle.init (Random.constant ())
        |> Particle.withDirection (Random.map degrees (Random.float 0 360))
        |> Particle.withSpeed (Random.map (clamp 0 200) (normal 100 100))
        |> Particle.withLifetime (normal 1.25 0.1)


at : Float -> Float -> Generator (List (Particle Firework))
at x y =
    fizzler
        |> Particle.withLocation (Random.constant { x = x, y = y })
        |> Particle.withGravity 50
        |> Particle.withDrag
            (\_ ->
                { coefficient = 1
                , density = 0.015
                , area = 2
                }
            )
        |> Random.list 100


view : Particle Firework -> Svg msg
view particle =
    let
        length =
            max 2 (Particle.speed particle / 15)

        maxLuminance =
            100

        lifetime =
            Particle.lifetimePercent particle

        opacity =
            if lifetime < 0.1 then
                lifetime * 10

            else
                1
    in
    Svg.ellipse
        [ -- location within the burst
          SAttrs.cx (String.fromFloat (length / 2))
        , SAttrs.cy "0"

        -- size, smeared by motion
        , SAttrs.rx (String.fromFloat length)
        , SAttrs.ry "2"
        , SAttrs.transform ("rotate(" ++ String.fromFloat (Particle.directionDegrees particle) ++ ")")

        -- color!
        , SAttrs.opacity (String.fromFloat opacity)
        , SAttrs.fill (Color.toCssString Colors.greenLightest)
        ]
        []

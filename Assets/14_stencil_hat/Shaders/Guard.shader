Shader "14/Guard"
{
    SubShader
    {
        Tags
        {
            "Queue" = "Geometry-1"
        }

        Pass
        {
            Stencil
            {
                Ref 0
                Comp Always
                Pass Replace
            }
            ZWrite Off
            ColorMask 0
        }

    }
}

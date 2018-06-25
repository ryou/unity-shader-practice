Shader "14/DeleteHead"
{
    SubShader
    {
        Tags
        {
            "Queue" = "Geometry-2"
        }

        Pass
        {
            Stencil
            {
                Ref 1
                Comp Always
                Pass Replace
            }
            ZWrite Off
            ColorMask 0
        }

    }
}

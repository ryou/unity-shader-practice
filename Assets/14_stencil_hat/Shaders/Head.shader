Shader "14/Head"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo(RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        Stencil
        {
            Ref 1
            Comp NotEqual
        }

        CGPROGRAM
        #pragma surface surf Standard

        half4 _Color;
        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o) {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex) * _Color.rgb;
        }
        ENDCG
    }
    Fallback "Diffuse"
}

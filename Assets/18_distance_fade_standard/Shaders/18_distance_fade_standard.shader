Shader "18/distance_fade_standard"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo(RGB)", 2D) = "white" {}
        [Normal] _NormalMap ("NormalMap(RGB)", 2D) = "bump" {}
        _AOMap ("AOMap(Grayscale)", 2D) = "white" {}
        _MetallicMap ("Metallic(GrayScale)", 2D) = "black" {}
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _FadeStart ("FadeStart", Float) = 1.0
        _FadeEnd ("FadeEnd", Float) = 2.0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
        }

        CGPROGRAM
        #pragma surface surf Standard alpha:fade

        half4 _Color;
        sampler2D _MainTex;
        sampler2D _NormalMap;
        sampler2D _AOMap;
        sampler2D _MetallicMap;
        half _Smoothness;
        float _FadeStart;
        float _FadeEnd;

        float rgb2grayscale(float3 color)
        {
            return color.r*0.299 + color.g*0.587 + color.b*0.114;
        }

        struct Input {
            float2 uv_MainTex;
            float2 uv_NormalMap;
            float2 uv_AOMap;
            float2 uv_MetallicMap;
            float3 worldPos;
        };

        void surf (Input IN, inout SurfaceOutputStandard o) {
           float d = distance(IN.worldPos, _WorldSpaceCameraPos);

            o.Albedo = tex2D(_MainTex, IN.uv_MainTex) * _Color.rgb;
            o.Alpha = 1 - smoothstep(_FadeStart, _FadeEnd, d);

            o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
            o.Occlusion = tex2D(_AOMap, IN.uv_AOMap);
            o.Metallic = rgb2grayscale(tex2D(_MetallicMap, IN.uv_MetallicMap));
            o.Smoothness = _Smoothness;
        }
        ENDCG
    }
    Fallback "Diffuse"
}

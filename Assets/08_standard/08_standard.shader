Shader "08/standard"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo(RGB)", 2D) = "white" {}
        [Normal] _NormalMap ("NormalMap(RGB)", 2D) = "bump" {}
        _AOMap ("AOMap(Grayscale)", 2D) = "white" {}
        _MetallicMap ("Metallic(GrayScale)", 2D) = "black" {}
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        CGPROGRAM
        #pragma surface surf Standard

        half4 _Color;
        sampler2D _MainTex;
        sampler2D _NormalMap;
        sampler2D _AOMap;
        sampler2D _MetallicMap;
        half _Smoothness;

        float rgb2grayscale(float3 color)
        {
            return color.r*0.299 + color.g*0.587 + color.b*0.114;
        }

        struct Input {
            float2 uv_MainTex;
            float2 uv_NormalMap;
            float2 uv_AOMap;
            float2 uv_MetallicMap;
        };

        void surf (Input IN, inout SurfaceOutputStandard o) {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex) * _Color.rgb;

            o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
            o.Occlusion = tex2D(_AOMap, IN.uv_AOMap);
            o.Metallic = rgb2grayscale(tex2D(_MetallicMap, IN.uv_MetallicMap));
            o.Smoothness = _Smoothness;
        }
        ENDCG
    }
    Fallback "Diffuse"
}

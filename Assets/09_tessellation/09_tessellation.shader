Shader "09/tessellation"
{
    // ディスプレイスメント・テッセレーション（頂点分割&頂点変化）のシェーダー
    // 詳細は以下の記事にわかりやすくまとめられている。
    // [Unity シェーダーチュートリアル　　ディスプレイスとテッセレーション – Tsumiki Tech Times|積木製作](http://tsumikiseisaku.com/blog/shader-tutorial-displace/)

    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo(RGB)", 2D) = "white" {}
        [Normal] _NormalMap ("NormalMap(RGB)", 2D) = "bump" {}
        _AOMap ("AOMap(Grayscale)", 2D) = "white" {}
        _MetallicMap ("Metallic(GrayScale)", 2D) = "black" {}
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5

        [Space(40)]

        /****************************************
        * ここからディスプレイスメントマップ用の記述
        ****************************************/
        [NoScaleOffset] _DisplacementMap ("DisplacementMap(GrayScale)", 2D) = "black" {}
        _DisplacementTiling ("Displacement Tiling", Vector) = (1, 1, 0, 0)
        _Height ("Height", Range(0, 1)) = 0.5
        _EdgeLength  ("Edge length" , Range(1, 50)) = 10
        /****************************************
        * ここまでディスプレイスメントマップ用の記述
        ****************************************/
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        CGPROGRAM
        // 「addshadow vertex:disp tessellate:tessEdge」を追加
        #pragma surface surf Standard addshadow vertex:disp tessellate:tessEdge

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

        /****************************************
        * ここからディスプレイスメントマップ用の記述
        ****************************************/
        #include "Tessellation.cginc"

        sampler2D _DisplacementMap;
        half _Height;
        float _EdgeLength;
        float4 _DisplacementTiling;

        struct appdata {
            float4 vertex    : POSITION;
            float4 tangent   : TANGENT;
            float3 normal    : NORMAL;
            float2 texcoord  : TEXCOORD0;
            float2 texcoord1 : TEXCOORD1;
            float2 texcoord2 : TEXCOORD2;
        };

        float4 tessEdge (appdata v0, appdata v1, appdata v2) {
            return UnityEdgeLengthBasedTessCull(
                v0.vertex,
                v1.vertex,
                v2.vertex,
                _EdgeLength,
                _Height * 1.5f
             );
        }

        void disp(inout appdata v)
        {
            float2 displacementUV = v.texcoord.xy * _DisplacementTiling.xy + _DisplacementTiling.zw;
            float3 mapColor = tex2Dlod(_DisplacementMap, float4(displacementUV, 0, 0)).rgb;
            float height = rgb2grayscale(mapColor);
            height *= _Height;

            v.vertex.xyz += v.normal * height;
        }
        /****************************************
        * ここまでディスプレイスメントマップ用の記述
        ****************************************/

        ENDCG
    }
    Fallback "Diffuse"
}

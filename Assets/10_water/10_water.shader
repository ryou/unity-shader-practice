Shader "10/water"
{
    /*
    水面の表現に関しては以下記事を参考にした。
    コードもほぼ記事のまま。
    [Unity シェーダーチュートリアル　　屈折表現 – Tsumiki Tech Times|積木製作](http://tsumikiseisaku.com/blog/shader-tutorial-refraction/)
    */
    Properties
    {
        _NormalTex  ("Normal Tex", 2D   ) = "bump" {}
        _Distortion ("Distortion", Range(0, 10)) = 1
        _Flow ("Flow Rate", Range(0, 10)) = 1
    }

    SubShader
    {
        Tags
        {
            "Queue"      = "Transparent"
            "RenderType" = "Transparent"
        }

        GrabPass {}
        
        CGPROGRAM
            #pragma target 3.0
            #pragma surface surf Standard fullforwardshadows

            sampler2D _GrabTexture;

            sampler2D _NormalTex;
            float _Distortion;
            float _Flow;

            struct Input
            {
                float2 uv_NormalTex;
                float4 screenPos;
            };

            void surf (Input IN, inout SurfaceOutputStandard o)
            {
                float2 grabUV = (IN.screenPos.xy / IN.screenPos.w);
                
                float2 normalUV = IN.uv_NormalTex;
                normalUV += _Time.x * _Flow;
                half4 normalColor = tex2D(_NormalTex, normalUV);
                fixed2 normalTex = UnpackNormal(normalColor).rg;
                grabUV += normalTex * _Distortion;

                fixed3 grab = tex2D(_GrabTexture, grabUV).rgb;

                o.Emission = grab;
                o.Albedo   = fixed3(0, 0, 0);
            }
        ENDCG
    }

    FallBack "Transparent/Diffuse"
}
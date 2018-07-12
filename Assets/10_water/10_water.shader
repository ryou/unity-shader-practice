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

        _Color ("Color", Color) = (1, 1, 1, 1)

        _LightDir ("Light Direction", Vector) = (10, -5, 10, 0)
        _SpecularPow ("Specular Pow", Int) = 100
        _SpecularIntensity ("Specular Intensity", Range(0, 1)) = 1
    }

    SubShader
    {
        Tags
        {
            "Queue"      = "Transparent+1"
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
            fixed3 _Color;
            int _SpecularPow;
            float _SpecularIntensity;
            float4 _LightDir;

            struct Input
            {
                float2 uv_NormalTex;
                float4 screenPos;

                float3 viewDir;
                float3 worldNormal;
            };

            void surf (Input IN, inout SurfaceOutputStandard o)
            {
                float2 grabUV = (IN.screenPos.xy / IN.screenPos.w);
                float2 normalUV = IN.uv_NormalTex;
                normalUV += _Time.x * _Flow;
                half4 normalColor = tex2D(_NormalTex, normalUV);
                normalUV.y += 0.1;
                half4 normalColor2 = tex2D(_NormalTex, normalUV + _Time.x*1.1 *_Flow);
                // 波のランダム感を出すために２つ足す
                normalColor = (normalColor + normalColor2) *0.5;

                float3 normal = UnpackNormal(normalColor);
                fixed2 normalTex = normal.rg;
                grabUV += normalTex * _Distortion;

                fixed3 grab = tex2D(_GrabTexture, grabUV).rgb;

                o.Emission = grab;
                o.Albedo   = _Color;

                // 反射の計算
                float3 halfVec = normalize(normalize(_LightDir.xyz) + normalize(IN.viewDir));
                float specular = saturate(dot(halfVec, normal));
                specular = saturate(pow(specular, _SpecularPow));
                o.Emission += specular * _SpecularIntensity;
            }
        ENDCG
    }

    FallBack "Transparent/Diffuse"
}

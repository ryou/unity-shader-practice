// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "06/lambert_multi_light_fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {

            Tags {
                // ライティングの際に必要なタグ。詳細は以下。
                // https://docs.unity3d.com/ja/current/Manual/SL-PassTags.html
                // https://docs.unity3d.com/ja/current/Manual/RenderTech-ForwardRendering.html
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM

            /**************************************
            定数
            ***************************************/
            #define IS_BASE 1

            /**************************************
            pragma宣言
            ***************************************/
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog


            /**************************************
            include
            ***************************************/
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            #include "lambert_fog.cginc"

            ENDCG
        }

        // 追加ライトの処理に関してはこちらが参考になる
        // https://qiita.com/edo_m18/items/1b90932a284fb8e89156
        Pass
        {
            Tags {
                "LightMode" = "ForwardAdd"
            }
            Blend One One

            CGPROGRAM

            /**************************************
            定数
            ***************************************/
            #define IS_BASE 0

            /**************************************
            pragma宣言
            ***************************************/
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fog


            /**************************************
            include
            ***************************************/
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            #include "lambert_fog.cginc"

            ENDCG

        }
    }
}
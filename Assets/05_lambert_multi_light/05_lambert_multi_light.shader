// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "05/lambert_multi_light"
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
            // Baseライティングなら1, そうでないなら0
            #define IS_BASE 1


            /**************************************
            pragma宣言
            ***************************************/
            #pragma vertex vert
            #pragma fragment frag


            /**************************************
            include
            ***************************************/
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            #include "lambert.cginc"
            ENDCG
        }

        Pass
        {

            Tags {
                // ライティングの際に必要なタグ。詳細は以下。
                // https://docs.unity3d.com/ja/current/Manual/SL-PassTags.html
                // https://docs.unity3d.com/ja/current/Manual/RenderTech-ForwardRendering.html
                "LightMode" = "ForwardAdd"
            }
            Blend One One

            CGPROGRAM

            /**************************************
            定数
            ***************************************/
            // Baseライティングなら1, そうでないなら0
            #define IS_BASE 0


            /**************************************
            pragma宣言
            ***************************************/
            #pragma vertex vert
            #pragma fragment frag


            /**************************************
            include
            ***************************************/
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            #include "lambert.cginc"
            ENDCG
        }
    }
}
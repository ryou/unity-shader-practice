// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "15/shader_gradient"
{
    // Propertiesでは、インスペクタで調整可能な変数の指定を行う
    // https://docs.unity3d.com/jp/current/Manual/SL-Properties.html
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1)
        _FadeInStart ("Fade In Start", Range(0, 1)) = 0
        _FadeInEnd ("Fade In End", Range(0, 1)) = 0.1
        _FadeOutStart ("Fade Out Start", Range(0, 1)) = 0.9
        _FadeOutEnd ("Fade Out End", Range(0, 1)) = 1.0
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderMode" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            CGPROGRAM

            /**************************************
            pragma宣言
            ***************************************/
            #pragma vertex vert
            #pragma fragment frag


            /**************************************
            include
            ***************************************/
            #include "UnityCG.cginc"


            /**************************************
            Propertiesで宣言した変数を使用するための宣言
            ***************************************/
            fixed4 _Color;
            float _FadeInStart;
            float _FadeInEnd;
            float _FadeOutStart;
            float _FadeOutEnd;


            /**************************************
            構造体定義
            ***************************************/
            struct appdata
            {
                float4 vertex : POSITION; // 頂点位置
                float2 texcoord : TEXCOORD0; // テクスチャ座標
            };

            struct v2f
            {
                float2 uv : TEXCOORD0; // テクスチャ座標
                float4 vertex : SV_POSITION; // クリップスペース位置
            };


            /**************************************
            シェーダ処理
            ***************************************/
            // 頂点シェーダー
            v2f vert (appdata v)
            {
                v2f o;

                // クリップスペースへの変換位置
                // (モデル*ビュー*プロジェクション行列で乗算)
                // (SV_POSITION（今回の場合o.vertex）は、fragmentシェーダで使用しない場合でも返り値に含める必要があるっぽい)
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = v.texcoord;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = _Color;

                float2 uv = i.uv;
                // テクスチャの中心からの距離を計算
                float distanceFromCenter = distance(float2(0.5, 0.5), uv); // 0 ~ 0.5
                distanceFromCenter *= 2; // 0 ~ 1
                if (distanceFromCenter < _FadeInEnd)
                {
                    color.a = smoothstep(_FadeInStart, _FadeInEnd, distanceFromCenter);
                }
                else
                {
                    color.a = 1 - smoothstep(_FadeOutStart, _FadeOutEnd, distanceFromCenter);
                }

                return color;
            }
            ENDCG
        }
    }
}
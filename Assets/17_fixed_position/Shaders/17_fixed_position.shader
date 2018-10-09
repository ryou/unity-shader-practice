﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "17/fixed_position"
{
    // Propertiesでは、インスペクタで調整可能な変数の指定を行う
    // https://docs.unity3d.com/jp/current/Manual/SL-Properties.html
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Position ("Position", Vector) = (0, 0, 0, 0)
        _Scale ("Scale", Float) = 1.0
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
            sampler2D _MainTex;
            float4 _Position;
            float _Scale;


            /**************************************
            その他変数宣言
            ***************************************/
            // 「TRANSFORM_TEX」を使用する際に必須
            float4 _MainTex_ST;


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
                float s = _Scale; // 拡大率
                float4 p = _Position;
                float4x4 viewMatrix = float4x4(
                    s, 0, 0, p.x,
                    0, s, 0, p.y,
                    0, 0, s, -0.35, // CameraのデフォルトNearClipが0.3なので、-0.35あたりにして切れないように
                    0, 0, 0, 1
                );
                float4x4 tmpMatrix = mul(UNITY_MATRIX_P, viewMatrix);
                o.vertex = mul(tmpMatrix, v.vertex);

                // インスペクタで指定したTiling/Offsetを反映させる
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // テクスチャをサンプリングして、それを返します
                fixed4 color = tex2D(_MainTex, i.uv);

                return color;
            }
            ENDCG
        }
    }
}
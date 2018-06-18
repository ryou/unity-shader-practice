﻿Shader "11/beat_wave"
{
    // Propertiesでは、インスペクタで調整可能な変数の指定を行う
    // https://docs.unity3d.com/jp/current/Manual/SL-Properties.html
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Seed ("Seed", Range(1000, 10000)) = 1000
        _Distortion ("Distortion", Range(0, 1)) = 0.5
    }
    SubShader
    {
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
            float _Seed;
            float _Distortion;


            /**************************************
            その他変数宣言
            ***************************************/
            // 「TRANSFORM_TEX」を使用する際に必須
            float4 _MainTex_ST;
            static const float PI = 3.14159265f;


            /**************************************
            構造体定義
            ***************************************/
            struct appdata
            {
                float4 vertex : POSITION; // 頂点位置
                float2 texcoord : TEXCOORD0; // テクスチャ座標
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0; // テクスチャ座標
                float4 vertex : SV_POSITION; // クリップスペース位置
            };


            /**************************************
            シェーダ処理
            ***************************************/
            float2 bezier(float2 start, float2 control, float2 end, float time)
            {
                float2 o;
                
                o.x = (time * time * end.x) + (2 * time * (1 - time) * control.x) + ((1 - time) * (1 - time) * start.x);
                o.y = (time * time * end.y) + (2 * time * (1 - time) * control.y) + ((1 - time) * (1 - time) * start.y);

                return o;
            }

            // 頂点シェーダー
            v2f vert (appdata v)
            {
                v2f o;

                // クリップスペースへの変換位置
                // (モデル*ビュー*プロジェクション行列で乗算)
                // (SV_POSITION（今回の場合o.vertex）は、fragmentシェーダで使用しない場合でも返り値に含める必要があるっぽい)

                float lengthXZ = length(float3(v.vertex.x, 0, v.vertex.z)); // xz平面上における長さ
                float lengthY = abs(v.vertex.y);
                float rad = atan2(lengthXZ, lengthY);
                float rand1 = floor((_Seed * floor(_Time.w)) % 100);
                float a = sin(rad*rand1 * 10) + sin(rad*rand1);
                a = a * 0.5 + 0.5;
                v.vertex *= 1 + (a * _Distortion);

                float2 bezierVal = bezier(float2(0, 0), float2(0.01, 2), float2(100000, 0), _Time.w % 1);
                v.vertex *= bezierVal.y;

                o.vertex = UnityObjectToClipPos(v.vertex);

                // インスペクタで指定したTiling/Offsetを反映させる
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // テクスチャをサンプリングして、それを返します
                fixed4 color = tex2D(_MainTex, i.uv);

                return fixed4(1.4, 1.4, 1.4, 0.7);
            }
            ENDCG
        }
    }
}

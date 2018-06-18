﻿Shader "11/beat_wave"
{
    // Propertiesでは、インスペクタで調整可能な変数の指定を行う
    // https://docs.unity3d.com/jp/current/Manual/SL-Properties.html
    Properties
    {
        _Seed ("Seed", Range(1000, 10000)) = 1000
        _Distortion ("Distortion", Range(0, 1)) = 0.5
        _BeatSpeed("Beat Speed", Float) = 1.0
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
            float _Seed;
            float _Distortion;
            float _BeatSpeed;


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
            };

            struct v2f
            {
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

                // y軸に対し成す角を算出
                float lengthXZ = length(float3(v.vertex.x, 0, v.vertex.z)); // xz平面上における長さ
                float lengthY = abs(v.vertex.y);
                float rad = atan2(lengthXZ, lengthY);

                // 頂点変形
                float currentTime = _Time.w * _BeatSpeed;
                float seed = _Seed * floor(currentTime);
                float a = sin(rad * seed * 10) + sin(rad * seed);
                a = a * 0.5 + 0.5;
                v.vertex *= 1 + (a * _Distortion);

                // ビートを刻む処理
                float2 bezierVal = bezier(float2(0, 0), float2(0.01, 2), float2(100000, 0), currentTime % 1);
                v.vertex *= bezierVal.y;

                // クリップスペースへの変換位置
                // (モデル*ビュー*プロジェクション行列で乗算)
                // (SV_POSITION（今回の場合o.vertex）は、fragmentシェーダで使用しない場合でも返り値に含める必要があるっぽい)
                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(1, 1, 1, 1);
            }
            ENDCG
        }
    }
}

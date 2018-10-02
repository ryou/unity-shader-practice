// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "16/circle_animation_1pass"
{
    // Propertiesでは、インスペクタで調整可能な変数の指定を行う
    // https://docs.unity3d.com/jp/current/Manual/SL-Properties.html
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderMode" = "Transparent"
        }
        Blend SrcAlpha One
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
            sampler2D _MainTex;


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
                o.vertex = UnityObjectToClipPos(v.vertex);

                // インスペクタで指定したTiling/Offsetを反映させる
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            bool isInDonut(float distanceFromCenter, float insideDiameter, float outsideDiameter)
            {
                return distanceFromCenter >= insideDiameter && distanceFromCenter <= outsideDiameter;
            }

            bool isInFan(float radian, float fanEndRadian)
            {
                return radian <= fanEndRadian;
            }

            bool isInLackedDonut(float2 targetCoord, float insideDiameter, float outsideDiameter, float fanEndRadian)
            {
                const float PI = 3.14159;

                float distanceFromCenter = distance(float2(0, 0), targetCoord);
                float radian = atan2(targetCoord.y, targetCoord.x) + PI;

                return isInDonut(distanceFromCenter, insideDiameter, outsideDiameter) && isInFan(radian, fanEndRadian);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = fixed4(0, 0, 0, 1);
                float2 coord = i.uv - 0.5;

                {
                    // 回転
                    float rt = _Time.z * 0.79;
                    float2x2 rotateMatrix = float2x2(cos(rt), -sin(rt), sin(rt), cos(rt));
                    float2 targetCoord = mul(rotateMatrix, coord);

                    if (isInLackedDonut(targetCoord, 0.45, 0.5, 2 + 1.0*sin(_Time.z * 0.79))) color.rgb += _Color.rgb * _Color.a;
                }

                {
                    // 回転
                    float rt = _Time.z * -1.0;
                    float2x2 rotateMatrix = float2x2(cos(rt), -sin(rt), sin(rt), cos(rt));
                    float2 targetCoord = mul(rotateMatrix, coord);

                    if (isInLackedDonut(targetCoord, 0.4, 0.5, 3.14 + 1.5*sin(_Time.z * 0.79))) color.rgb += _Color.rgb * _Color.a;
                }

                {
                    // 回転
                    float rt = _Time.z * 1.27;
                    float2x2 rotateMatrix = float2x2(cos(rt), -sin(rt), sin(rt), cos(rt));
                    float2 targetCoord = mul(rotateMatrix, coord);

                    if (isInLackedDonut(targetCoord, 0.3, 0.45, 4 + 1.3*sin(_Time.z * 0.8))) color.rgb += _Color.rgb * _Color.a;
                }

                {
                    // 回転
                    float rt = _Time.z * 1.9;
                    float2x2 rotateMatrix = float2x2(cos(rt), -sin(rt), sin(rt), cos(rt));
                    float2 targetCoord = mul(rotateMatrix, coord);

                    if (isInLackedDonut(targetCoord, 0.25, 0.35, 2 + 1.0*sin(_Time.z * 1.48))) color.rgb += _Color.rgb * _Color.a;
                }

                {
                    // 回転
                    float rt = _Time.z * -1.2;
                    float2x2 rotateMatrix = float2x2(cos(rt), -sin(rt), sin(rt), cos(rt));
                    float2 targetCoord = mul(rotateMatrix, coord);

                    if (isInLackedDonut(targetCoord, 0.225, 0.275, 2.5 + 2.5*sin(_Time.z * 0.4))) color.rgb += _Color.rgb * _Color.a;
                }

                // Line01
                {
                    // 回転
                    float rt = _Time.z * 1.51;
                    float2x2 rotateMatrix = float2x2(cos(rt), -sin(rt), sin(rt), cos(rt));
                    float2 targetCoord = mul(rotateMatrix, coord);

                    if (isInLackedDonut(targetCoord, 0.445, 0.455, 4.0 + 1.0*sin(_Time.z * 1.0))) color.rgb += _Color.rgb * _Color.a;
                }

                // Line02
                {
                    // 回転
                    float rt = _Time.z * 1.0;
                    float2x2 rotateMatrix = float2x2(cos(rt), -sin(rt), sin(rt), cos(rt));
                    float2 targetCoord = mul(rotateMatrix, coord);

                    if (isInLackedDonut(targetCoord, 0.395, 0.405, 3.0 + 1.0*sin(_Time.z * 1.0))) color.rgb += _Color.rgb * _Color.a;
                }

                return color;
            }
            ENDCG
        }
    }
}
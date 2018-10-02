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
                float2 coord = i.uv - 0.5;

                // 回転
                float rt = _Time.w;
                float2x2 rotateMatrix = float2x2(cos(rt), -sin(rt), sin(rt), cos(rt));
                coord = mul(rotateMatrix, coord);

                if (!isInLackedDonut(coord, 0.2, 0.4, 3 + 2*sin(rt))) discard;

                return _Color;
            }
            ENDCG
        }
    }
}
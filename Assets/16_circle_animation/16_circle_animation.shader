// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "16/circle_animation"
{
    // Propertiesでは、インスペクタで調整可能な変数の指定を行う
    // https://docs.unity3d.com/jp/current/Manual/SL-Properties.html
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1)

        _Diameter ("Diameter", Float) = 0.5
        _Width ("Width", Float) = 0.1
        _Length ("Length", Float) = 3.14
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
            float _Diameter;
            float _Width;
            float _Length;

            static const float PI = 3.14159265f;


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

                // 回転を設定
                float angle = _Time.z * 1.5;
                // 回転行列
                float2x2 rotate = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
                // 回転UVを設定
                float2 pivot_uv = float2(0.5, 0.5);
                float2 r = v.texcoord.xy - pivot_uv;
                o.uv = mul(rotate, r) + pivot_uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = _Color;

                float2 uv = i.uv;
                // テクスチャの中心からの距離を計算
                float distanceFromCenter = distance(float2(0.5, 0.5), uv); // 0 ~ 0.5
                distanceFromCenter *= 2; // 0 ~ 1

                color.a = 0;
                if (distanceFromCenter > _Diameter && distanceFromCenter < (_Diameter + _Width))
                {
                    float2 coord = uv - 0.5;
                    float rad = atan2(coord.y, coord.x) + PI;
                    _Length += sin(_Time.z * 1.1);
                    if (rad < _Length)
                    {
                        color.a = 0.5;
                    }
                }

                return color;
            }
            ENDCG
        }
    }
}
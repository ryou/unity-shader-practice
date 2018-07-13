// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "16/circle_animation_vertex"
{
    // Propertiesでは、インスペクタで調整可能な変数の指定を行う
    // https://docs.unity3d.com/jp/current/Manual/SL-Properties.html
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1)

        _Diameter ("Diameter", Float) = 0.5
        _Width ("Width", Float) = 0.1
        _Length ("Length", Float) = 3.14

        _RotationSpeed ("Rotation Speed", Float) = 1.0
        _Distortion ("Distortion", Float) = 1.0
        _DistortionInterval ("Distortion Interval", Float) = 1.0
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
            fixed _Diameter;
            fixed _Width;
            fixed _Length;
            fixed _RotationSpeed;
            fixed _Distortion;
            fixed _DistortionInterval;

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
                fixed4 color : COLOR;
            };


            /**************************************
            シェーダ処理
            ***************************************/
            // 頂点シェーダー
            v2f vert (appdata v)
            {
                v2f o;

                float rad = atan2(v.vertex.y, v.vertex.x) + PI;
                _Length += sin(_Time.z * _DistortionInterval) * _Distortion;
                if (rad > _Length)
                {
                    o.color = fixed4(1, 1, 1, 0);
                }
                else
                {
                    o.color = fixed4(1, 1, 1, 0.45);
                }

                // 回転を設定
                float angle = _Time.z * _RotationSpeed;
                // 回転行列
                float2x2 rotate = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
                float2 rotateXY = mul(rotate, v.vertex.xy);
                float3 newVertex = float3(rotateXY, v.vertex.z);

                // クリップスペースへの変換位置
                // (モデル*ビュー*プロジェクション行列で乗算)
                // (SV_POSITION（今回の場合o.vertex）は、fragmentシェーダで使用しない場合でも返り値に含める必要があるっぽい)
                o.vertex = UnityObjectToClipPos(newVertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = _Color * i.color;

                return color;
            }
            ENDCG
        }
    }
}
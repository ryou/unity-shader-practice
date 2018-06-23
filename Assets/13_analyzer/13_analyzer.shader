// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "13/analyzer"
{
    // Propertiesでは、インスペクタで調整可能な変数の指定を行う
    // https://docs.unity3d.com/jp/current/Manual/SL-Properties.html
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _BorderColor ("Border Color", Color) = (0, 0, 0, 0)
        _BorderWidth ("Border Width", Vector) = (0.01, 0.005, 0)
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
            fixed4 _BorderColor;
            fixed3 _BorderWidth;


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
                o.vertex = UnityObjectToClipPos(v.vertex);

                // インスペクタで指定したTiling/Offsetを反映させる
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = i.uv;
                fixed4 color = fixed4(0, 0, 0, 0);

                // X値計算
                float xVal = floor(uv.x * 10) + 1; // 0 ~ 10

                // Y値計算
                float yVal = (sin((10 / xVal) * _Time.w) + sin(_Time.z * xVal * 0.96)) * 0.25; // -0.5 ~ 0.5
                yVal *= 0.5; // -0.25 ~ 0.25
                yVal += 0.75; // 0.5 ~ 1.00
                yVal = floor(yVal * 20) * 0.05;

                if (uv.y < yVal) color = tex2D(_MainTex, i.uv) * _Color;

                // 枠線指定
                float tmpX = uv.x % 0.1;
                if (tmpX < _BorderWidth.x || tmpX > (0.1 - _BorderWidth.x)) color = _BorderColor;

                float tmpY = uv.y % 0.05;
                if (tmpY < _BorderWidth.y || tmpY > (0.05 - _BorderWidth.y)) color = _BorderColor;

                return color;
            }
            ENDCG
        }
    }
}
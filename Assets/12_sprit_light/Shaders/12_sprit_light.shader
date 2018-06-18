Shader "12/sprit_light"
{
    // Propertiesでは、インスペクタで調整可能な変数の指定を行う
    // https://docs.unity3d.com/jp/current/Manual/SL-Properties.html
    Properties
    {
        [HDR]_Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _LineNum ("Line Num", Float) = 10.0
        _LineWidth ("Line Width", Float) = 0.4
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "Queue" = "Transparent"
                "RenderMode" = "Transparent"
            }
            Blend SrcAlpha One // 加算
            ZWrite Off
            Cull Off

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
            float4 _Color;
            float _LineNum;
            float _LineWidth;


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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0; // テクスチャ座標
                float4 vertex : SV_POSITION; // クリップスペース位置
                fixed4 alpha : COLOR0; // 現在の頂点の透明度、他に適切なセマンティクスがあればいいんだけど…
            };


            /**************************************
            シェーダ処理
            ***************************************/
            // 頂点シェーダー
            v2f vert (appdata v)
            {
                v2f o;

                // 透明度を計算
                if (v.vertex.y == 0 && v.vertex.x == 0)
                {
                    o.alpha = fixed4(1, 1, 1, 1);
                }
                else
                {
                    float rad = atan2(v.vertex.y, v.vertex.x) + PI; // 0 ~ 2PI
                    float lineInterval = (2*PI) / _LineNum;
                    float diffFromLineCenter = rad % lineInterval;

                    if (diffFromLineCenter < _LineWidth || diffFromLineCenter > lineInterval - _LineWidth)
                    {
                        float diffFromLineEdge = 0;
                        if (diffFromLineCenter < _LineWidth)
                        {
                            diffFromLineEdge = _LineWidth - diffFromLineCenter;
                        }
                        else
                        {
                            diffFromLineEdge = abs((lineInterval - _LineWidth) - diffFromLineCenter);
                        }
                        diffFromLineEdge = diffFromLineEdge / _LineWidth;
                        o.alpha = fixed4(1, 1, 1, diffFromLineEdge);
                    }
                    else
                    {
                        o.alpha = fixed4(1, 1, 1, 0);
                    }
                }

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
                // テクスチャをサンプリングして、それを返します
                fixed4 color = tex2D(_MainTex, i.uv) * _Color;

                color.a *= i.alpha.a;

                return color;
            }
            ENDCG
        }
    }
}
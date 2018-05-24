// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "03/normal"
{
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
            構造体定義
            ***************************************/
            struct appdata
            {
                float4 vertex : POSITION; // 頂点位置
                float3 normal : NORMAL; // 法線
            };

            struct v2f
            {
                float4 vertex : SV_POSITION; // クリップスペース位置
                float3 worldNormal : NORMAL; // 法線
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

                // 法線ベクトルをオブジェクト空間からワールド空間へ変換
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color;

                // 法線は各座標-1.0~1.0の値を取るため、0~1.0の範囲に収まるようにする
                color.rgb = i.worldNormal / 2 + 0.5;

                color.a = 1;

                return color;
            }
            ENDCG
        }
    }
}
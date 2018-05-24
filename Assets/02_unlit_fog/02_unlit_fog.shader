// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/****************************************
フォグを適用する場合は、
+ カメラにPostProcessingBehaviourを追加しProfileを適用
+ Ligting > OtherSettingのフォグをON
の操作をする必要があるので注意
****************************************/
Shader "02/unlit_fog"
{
    // Propertiesでは、インスペクタで調整可能な変数の指定を行う
    // https://docs.unity3d.com/jp/current/Manual/SL-Properties.html
    Properties
    {
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
            #pragma multi_compile_fog


            /**************************************
            include
            ***************************************/
            #include "UnityCG.cginc"


            /**************************************
            Propertiesで宣言した変数を使用するための宣言
            ***************************************/
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

                // フォグを使用する際に必要
                // やってる内容は以下と同じっぽい。
                // float2 fogCoord : TEXCOORD1;
                UNITY_FOG_COORDS(1)
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

                // フォグに必要な処理
                // やってる内容はo.fogCoordに座標を設定してるっぽい
                // （uvの設定と似たような処理）
                UNITY_TRANSFER_FOG(o, o.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // テクスチャをサンプリングして、それを返します
                fixed4 color = tex2D(_MainTex, i.uv);

                // フォグカラーを設定
                UNITY_APPLY_FOG(i.fogCoord, color);

                return color;
            }
            ENDCG
        }
    }
}
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "05/lambert_multi_light"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {

            Tags {
                // ライティングの際に必要なタグ。詳細は以下。
                // https://docs.unity3d.com/ja/current/Manual/SL-PassTags.html
                // https://docs.unity3d.com/ja/current/Manual/RenderTech-ForwardRendering.html
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM

            /**************************************
            pragma宣言
            ***************************************/
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase


            /**************************************
            include
            ***************************************/
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"


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
                float3 normal : NORMAL; // 法線
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION; // クリップスペース位置
                float3 worldNormal : NORMAL;
                float2 uv : TEXCOORD0;
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

                // インスペクタで指定したTiling/Offsetを反映させる
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);

                // diffuseの計算
                float nl = max(0, dot(i.worldNormal, _WorldSpaceLightPos0.xyz));
                float4 diffuse = nl * _LightColor0;

                // この処理をしないと陰影が強くつきすぎる
                // https://docs.unity3d.com/ja/current/Manual/SL-VertexFragmentShaderExamples.html
                // の「アンビエントを使った拡散ライティング」を参考
                diffuse.rgb += ShadeSH9(half4(i.worldNormal, 1));

                color *= diffuse;

                return color;
            }

            ENDCG
        }

        // 追加ライトの処理に関してはこちらが参考になる
        // https://qiita.com/edo_m18/items/1b90932a284fb8e89156
        Pass
        {
            Tags {
                "LightMode" = "ForwardAdd"
            }
            Blend One One

            CGPROGRAM

            /**************************************
            pragma宣言
            ***************************************/
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd


            /**************************************
            include
            ***************************************/
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
                float3 lightDir : TEXCOORD2;
                float3 normal   : TEXCOORD1;
                LIGHTING_COORDS(3, 4)
            };

            v2f vert(appdata_tan v) {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy;

                o.lightDir = ObjSpaceLightDir(v.vertex);

                o.normal = v.normal;
                TRANSFER_VERTEX_TO_FRAGMENT(o);

                return o;
            }

            sampler2D _MainTex;
            fixed4 _LightColor0;

            fixed4 frag(v2f i) : COLOR {
                i.lightDir = normalize(i.lightDir);
                fixed atten = LIGHT_ATTENUATION(i);
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed3 normal = i.normal;
                fixed diff = saturate(dot(normal, i.lightDir));

                fixed4 c;
                c.rgb = (tex.rgb * _LightColor0.rgb * diff) * (atten * 2);
                c.a = tex.a;

                return c;
            }

            ENDCG

        }
    }
}
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
struct v2f
{
    float4 pos : SV_POSITION; // クリップスペース位置
    float3 worldNormal : NORMAL;
    float2 uv : TEXCOORD0;
    LIGHTING_COORDS(1, 2)
};


/**************************************
シェーダ処理
***************************************/
// 頂点シェーダー
v2f vert (appdata_tan v)
{
    v2f o;

    // クリップスペースへの変換位置
    // (モデル*ビュー*プロジェクション行列で乗算)
    // (SV_POSITION（今回の場合o.vertex）は、fragmentシェーダで使用しない場合でも返り値に含める必要があるっぽい)
    o.pos = UnityObjectToClipPos(v.vertex);

    // 法線ベクトルをオブジェクト空間からワールド空間へ変換
    o.worldNormal = UnityObjectToWorldNormal(v.normal);

    // インスペクタで指定したTiling/Offsetを反映させる
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    // ライト情報をフラグメントシェーダに渡すための処理を行う
    // 座標空間の変換等をライトの種類に応じて行っている模様
    TRANSFER_VERTEX_TO_FRAGMENT(o);

    return o;
}

fixed4 frag (v2f i) : SV_Target
{
    fixed4 color = tex2D(_MainTex, i.uv);

    // diffuseの計算
    float nl = max(0, dot(i.worldNormal, _WorldSpaceLightPos0.xyz));
    float4 diffuse = nl * _LightColor0;

    // 減衰適用
    fixed atten = LIGHT_ATTENUATION(i);
    diffuse *= atten;

    if (IS_BASE)
    {
        // この処理をしないと陰影が強くつきすぎる
        // https://docs.unity3d.com/ja/current/Manual/SL-VertexFragmentShaderExamples.html
        // の「アンビエントを使った拡散ライティング」を参考
        diffuse.rgb += ShadeSH9(half4(i.worldNormal, 1));
    }

    color *= diffuse;

    return color;
}

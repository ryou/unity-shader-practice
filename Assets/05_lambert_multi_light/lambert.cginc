/**************************************
Properties�Ő錾�����ϐ����g�p���邽�߂̐錾
***************************************/
sampler2D _MainTex;


/**************************************
���̑��ϐ��錾
***************************************/
// �uTRANSFORM_TEX�v���g�p����ۂɕK�{
float4 _MainTex_ST;


/**************************************
�\���̒�`
***************************************/
struct appdata
{
    float4 vertex : POSITION; // ���_�ʒu
    float3 normal : NORMAL; // �@��
    float2 texcoord : TEXCOORD0;
};

struct v2f
{
    float4 vertex : SV_POSITION; // �N���b�v�X�y�[�X�ʒu
    float3 worldNormal : NORMAL;
    float2 uv : TEXCOORD0;
};


/**************************************
�V�F�[�_����
***************************************/
// ���_�V�F�[�_�[
v2f vert (appdata v)
{
    v2f o;

    // �N���b�v�X�y�[�X�ւ̕ϊ��ʒu
    // (���f��*�r���[*�v���W�F�N�V�����s��ŏ�Z)
    // (SV_POSITION�i����̏ꍇo.vertex�j�́Afragment�V�F�[�_�Ŏg�p���Ȃ��ꍇ�ł��Ԃ�l�Ɋ܂߂�K�v��������ۂ�)
    o.vertex = UnityObjectToClipPos(v.vertex);

    // �@���x�N�g�����I�u�W�F�N�g��Ԃ��烏�[���h��Ԃ֕ϊ�
    o.worldNormal = UnityObjectToWorldNormal(v.normal);

    // �C���X�y�N�^�Ŏw�肵��Tiling/Offset�𔽉f������
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

    return o;
}

fixed4 frag (v2f i) : SV_Target
{
    fixed4 color = tex2D(_MainTex, i.uv);

    // diffuse�̌v�Z
    float nl = max(0, dot(i.worldNormal, _WorldSpaceLightPos0.xyz));
    float4 diffuse = nl * _LightColor0;

    if (IS_BASE)
    {
        // ���̏��������Ȃ��ƉA�e��������������
        // https://docs.unity3d.com/ja/current/Manual/SL-VertexFragmentShaderExamples.html
        // �́u�A���r�G���g���g�����g�U���C�e�B���O�v���Q�l
        diffuse.rgb += ShadeSH9(half4(i.worldNormal, 1));
    }

    color *= diffuse;

    return color;
}

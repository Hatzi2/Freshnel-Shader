Shader "Unlit/Freshnel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // The Freshenl strength and Ramp is made so that the shader is controlable in the viewport
        _FreshnelStrength("Freshnel Strenght", Range(0,10)) = 0
        _FreshnelRamp("Freshnel Ramp", Range(0,10)) = 0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                //For the freshnel effect it is needed to know the normal information
                //and the view direction of the camera
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _FreshnelStrength;
            float _FreshnelRamp;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //Getting normal and view direction data from unity
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                //The freshnel is calculated by taking the dot product of the normal and viewdirection.
                // adding the 1- in the beginning of the calculations flips it and gives the desired effect.
                //Adding "Max(0)" ensures that the data will always be positive, which makes sure it works in more situations.
                float fresnelAmount =  max(0, dot(i.normal, i.viewDir));
                //float fresnelinv = max(0, dot(i.normal, i.viewDir));
                //This calculation gives more control, making it possible to control how much of the effect is desired in the viewport.
                //_FreshnelRamp = _FreshnelRamp * _Time;
                //_FreshnelStrength = sin(_FreshnelStrength * (_Time*50));
                fresnelAmount = pow(fresnelAmount, _FreshnelRamp) * _FreshnelStrength;
                //fresnelAmount = fresnelAmount * sin(_Time*50);
                //return fresnelAmount;
                return lerp(float4(1,0,0,1),float4(0,0.5,0,0), fresnelAmount);
                
            }
            ENDCG
        }
    }
}

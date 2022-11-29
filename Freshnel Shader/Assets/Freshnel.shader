Shader "Unlit/Freshnel"
{

    Properties
    {
        // The Freshnel strength, Ramp and animationVal is made so that the shader is controlable in the viewport
        _FreshnelStrength("Freshnel Strenght", Range(0.2,1)) = 0
        _FreshnelRamp("Freshnel Ramp", Range(0.2,10)) = 0
        _fresnelAnimaterVal("Animation Speed", Range(0,100)) = 0
    }


    SubShader
    {
        //Creates transparency
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
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
                float3 normal : NORMAL;
            };


            struct v2f //Vertex to fragments
            {
                float4 vertex : SV_POSITION;//System value positionl
                //For the freshnel effect it is needed to know the normal information and the view direction of the camera
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            //Creating values that can be manipulated from the viewport.
            float _FreshnelStrength;
            float _FreshnelRamp;
            float _fresnelAnimaterVal;
            

            v2f vert (appdata v)
            {
                v2f o;
                //Getting normal and view direction data from unity
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }


            float4 frag (v2f i) : SV_Target
            {
                //Sintime is a function I created to make it possible to control the animation speed from the editor
                float sinTime = max(-0.8, sin(_Time*_fresnelAnimaterVal));
                //The freshnel is calculated by taking the dot product of the normal and viewdirection.
                // adding the 1- in the beginning of the calculations flips it and gives the desired effect.
                //Adding "Max(0)" ensures that the data will always be positive, which makes sure it works in more situations.
                float fresnelAmount =  max(0, dot(i.normal, i.viewDir));
             
                //This calculation gives more control, making it possible to control how much of the effect is desired in the viewport.
                fresnelAmount = pow(fresnelAmount, _FreshnelRamp) * _FreshnelStrength;

                //Adding the animation value to the freshnel amount.
                float fresnelAnimater = fresnelAmount * sinTime;
                
                //Add colors to the black and white mask of the fresnel for some extra effect.
                return lerp(float4(1,0,0,1),float4(0,0.5,0,0), max(-0.8, fresnelAmount+fresnelAnimater));          
            }
            ENDCG
        }
    }
}
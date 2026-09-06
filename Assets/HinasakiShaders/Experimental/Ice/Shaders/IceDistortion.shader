/**
 * @fileoverview Shader to express the tear effect
 * @author hjcud
 * @version 1.0.0
 */

Shader "Yoiko/Ice"
{
    Properties
    {
        [Header(Ice)]
        [Space(10)]
        [Header(Noise Texture)]
        [NoScaleOffset]_NoiseTex ("Texture", 2D) = "white" {}
        _NoiseSize ("Noise Texture Size", Range(0, 20)) = 2.3
        _NoiseAlpha ("Noise Texture Alpha", Range(0, 1)) = 1
        _RefPower ("Refraction Power", Range(0, 1)) = 0.15

        [Header(Distortion)]
        _DistortionF ("Distortion (Face)", Range(0, 1)) = 0
        _DistortionE ("Distortion (Edge)", Range(0, 1)) = 0
    }
 
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        
        GrabPass{}

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"

            struct appdata
            { 
                float4 vertex : POSITION;
                float2 uv_NoiseTex : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : POSITION;
                float2 uv_NoiseTex : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            sampler2D _GrabTexture; // stores frame buffer textures captured by GrabPass
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _NoiseSize, _NoiseAlpha, _RefPower;
            float _DistortionF, _DistortionE;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_NoiseTex = TRANSFORM_TEX(v.uv_NoiseTex, _NoiseTex);
                o.screenPos = ComputeGrabScreenPos(o.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = 0;

                // The rgb value of screenPos is divided by the depth value a to obtain a normalized screen UV regardless of distance
                float2 screenUV = i.screenPos.rgb / i.screenPos.a;
                screenUV = float2(screenUV.r, screenUV.g);

                fixed4 noiseTexUV = tex2D(_NoiseTex, i.uv_NoiseTex * _NoiseSize);

                // 왜곡 효과 추가
                float3 offset = i.screenPos.xyz * (lerp(_DistortionF, _DistortionE, i.uv_NoiseTex.r) * (1 / i.screenPos.a));

                // Refraction effect UV 계산에 왜곡을 추가
                float2 colUV = (screenUV) + (noiseTexUV.r * (_RefPower * 0.1)) + offset.xy;
                col += tex2D(_GrabTexture, colUV);
                return col;
            }
            ENDCG
        }
    }
    // Clear the shadow
    FallBack "Regacy shaders/Transparent/Diffuse"
}
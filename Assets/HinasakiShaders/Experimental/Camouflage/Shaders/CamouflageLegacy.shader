/**
 * @fileoverview Shader to express the tear effect
 * @author hjcud
 * @version 1.0.0
 */

Shader "Hinasaki/Camouflage"
{
    Properties
    {
		[Header(HINASAKI SFX SHADER)]
		[Space(10)]
        [Header(Main Texture)]
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _Size ("Size", Range(0, 20)) = 20
        _TexPower ("Texture Power", Range(0, 1)) = 0.5
        _RefPower ("Refraction Power", Range(0, 1)) = 0.15
		[Space(10)]
        [Header(Noise Texture)]
        [NoScaleOffset]_NoiseTex ("Texture", 2D) = "white" {}
        _NoiseSize ("Noise Texture Size", Range(0, 20)) = 2.3
        _NoiseSpeed ("NoiseSpeed", Range(0, 10)) = 0.01
		[Space(10)]
        [Header(Mosaic Texture)]
        [NoScaleOffset]_MosaicTex ("Texture", 2D) = "white" {}
        _MosaicTexSize ("Mosaic Texture Size", Range(0, 20)) = 20
        _Dissolve ("Dissolve Effect", Range(0, 1)) = 0
    }
 
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        
        GrabPass{}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            { 
                float4 vertex : POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_NoiseTex : TEXCOORD1;
                float2 uv_MosaicTex : TEXCOORD2;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_NoiseTex : TEXCOORD1;
                float2 uv_MosaicTex : TEXCOORD2;
                float4 screenPos : TEXCOORD3;
            };

            sampler2D _GrabTexture; // stores frame buffer textures captured by GrabPass
            sampler2D _MainTex, _NoiseTex, _MosaicTex;
            float4 _MainTex_ST;
            float4 _NoiseTex_ST;
            float4 _MosaicTex_ST;
            float _Size, _TexPower, _RefPower, _NoiseSize, _NoiseSpeed, _MosaicTexSize, _Dissolve;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //o.uv_MainTex = ComputeGrabScreenPos(o.vertex);
                o.uv_MainTex = TRANSFORM_TEX(v.uv_MainTex, _MainTex);
                o.uv_NoiseTex = TRANSFORM_TEX(v.uv_MainTex, _NoiseTex);
                o.uv_MosaicTex = TRANSFORM_TEX(v.uv_MainTex, _MosaicTex);
                // When capturing textures with GrabPass, calculate the screen coordinates of the current vertex
                o.screenPos = ComputeGrabScreenPos(o.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = 0;

                // Change texture scale(uv) by time
                float timeY = _Time.y;

                // Set main texture with calculated UV
                fixed4 mainTexUV = tex2D(_MainTex, i.uv_MainTex * _Size);

                // noiseTexUV is noise texture for refraction effects
                float2 noiseUV = i.uv_NoiseTex;
                noiseUV.y += timeY * _NoiseSpeed;
                fixed4 noiseTexUV = tex2D(_NoiseTex, noiseUV * _NoiseSize);

                // mosaicTexUV is noise texture for fade-out effects
                fixed4 mosaicTexUV = tex2D(_MosaicTex, i.uv_MosaicTex * _MosaicTexSize);
                float dissolveAmount = step(mosaicTexUV, _Dissolve);

                // The rgb value of screenPos is divided by the depth value a to obtain a normalized screen UV regardless of distance
                float2 screenUV = i.screenPos.rgb / i.screenPos.a;
                screenUV = float2(screenUV.r, screenUV.g);

                // Make object have refraction effect and texture color. noiseUV, maskTexUV is used here
                float2 colUV = (screenUV * dissolveAmount) + ((mainTexUV.r * (_RefPower * 0.1)) * noiseTexUV * dissolveAmount); // UV calculation for refraction effect
                float4 colAdd = ((-(mainTexUV) * _TexPower) * (1 - dissolveAmount)); // Set camouflage color
                
                // If dissolveAmount is 0 leave col at 0
                if (dissolveAmount > 0)
                    col += tex2D(_GrabTexture, colUV) + colAdd;

                return col;
            }
            ENDCG
        }
    }
    // Clear the shadow
    FallBack "Regacy shaders/Transparent/Diffuse"
}
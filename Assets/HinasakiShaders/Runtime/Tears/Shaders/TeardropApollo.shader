/**
 * @fileoverview Shader to express the tear effect
 * @author hjcud
 * @version 1.1.0
 */

Shader "Hinasaki/Teardrop_APOLLO"
{
    Properties
    {
		[Header(HINASAKI SFX SHADER)]
		[Space(10)]
        [Header(Drop Texture)]
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _MainMask ("Mask Texture", 2D) = "white" {}
        [Header(Drop Setting (Green Line))]
        _DropPosX ("X Position", Range(-0.5, 0.5)) = -0.285
        _Randwidth ("Random Width", Range(0, 0.9)) = 0.118
        _DropWaveFreq ("Wave Frequency", Range(0, 10)) = 3
        _DropWaveWidth ("Wave Width", Range(0, 10)) = 1.5
		[Space(10)]
        [Header(Tear Texture)]
        [NoScaleOffset] _SecondTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _SecondNoise ("Noise Texture", 2D) = "white" {}
        [Header(Tear Setting (Yellow Line))]
        _TearPosX ("X Position", Range(-0.5, 0.5)) = -0.15
        _TearPosY ("Y Position", Range(-0.5, 0.5)) = 0.45
        _NoiseSize ("Noise Texture Size", Range(0, 20)) = 2.3
        _NoiseSpeed ("Noise Speed", Range(0, 10)) = 0.18
        _NoisePower ("Noise Power", Range(0, 1)) = 1
		[Space(10)]
        [Header(UruUru Texture)]
        [NoScaleOffset] _UruUruMask ("Mask Texture", 2D) = "white" {}
        [Header(UruUru Setting (Blue Line))]
        _UruPosY ("Y Position", Range(0, 1)) = 0.55
        _UruSize ("Noise Size", Range(0, 20)) = 0.3
        _UruSpeed ("Noise Speed", Range(0, 10)) = 0.8
        _UruPower ("Noise Power", Range(0, 1)) = 0.5
		[Space(10)]
        [Header(Effect Setting)]
        _TexPower ("Texture Power", Range(0, 1)) = 0.5
        _RefPower ("Refraction Power", Range(0, 1)) = 0.6
        _DropSpeed ("Drop Speed", Range(0.01, 3)) = 1
		[Space(10)]
        [Header(Debug Mode)]
        [KeywordEnum(None, Transparent, Black)] _gridModeToggle ("Grid Mode Toggle", float) = 0
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
                float2 uv_MainMask : TEXCOORD1;
                float2 uv_SecondTex : TEXCOORD2;
                float2 uv_SecondNoise : TEXCOORD3;
                float2 uv_UruUruMask : TEXCOORD4;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_MainMask : TEXCOORD1;
                float2 uv_SecondTex : TEXCOORD2;
                float2 uv_SecondNoise : TEXCOORD3;
                float2 uv_UruUruMask : TEXCOORD4;
				float4 screenPos : TEXCOORD5;
			};

            sampler2D _GrabTexture; // stores frame buffer textures captured by GrabPass
            sampler2D _MainTex, _MainMask, _SecondTex, _SecondNoise, _UruUruMask;
            float4 _MainTex_ST, _MainMask_ST;
            float4 _SecondTex_ST, _SecondNoise_ST, _UruUruMask_ST;
            float _DropPosX, _Randwidth, _DropWaveFreq, _DropWaveWidth;
            float _TearPosX, _TearPosY, _NoiseSize, _NoiseSpeed, _NoisePower, _TexPower, _RefPower, _UruPosY, _UruSize, _UruSpeed, _UruPower, _DropSpeed, _gridModeToggle;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_MainTex = TRANSFORM_TEX(v.uv_MainTex, _MainTex);
                o.uv_MainMask = TRANSFORM_TEX(v.uv_MainTex, _MainMask);
                o.uv_SecondTex = TRANSFORM_TEX(v.uv_MainTex, _SecondTex);
                o.uv_SecondNoise = TRANSFORM_TEX(v.uv_MainTex, _SecondNoise);
                o.uv_UruUruMask = TRANSFORM_TEX(v.uv_MainTex, _UruUruMask);
                // When capturing textures with GrabPass, calculate the screen coordinates of the current vertex
				o.screenPos = ComputeGrabScreenPos(o.vertex);

				return o;
			}

            float RandomFloat(float2 seed)
            {
                // Returns a pseudo-random number value based on input Seed
                float2 ran = frac(sin(dot(seed, float2(12.9898, 78.233)))* 43758.5453);
                return frac(ran.x * ran.y);
            }

			fixed4 frag (v2f i) : SV_Target
			{
                fixed4 col = 0;

                // Loop timer using the remainder of the division (Calibrates Random Value Errors)
                float timeY = fmod(_Time.y, 3600); 
                
                // Set user-controlled distance for each UV
                float2 uvScale = float2(2, 1);

                // Set main UV scale and UV scroll speed. also set uv origin
                float2 mainUV = i.uv_MainTex * uvScale;
                mainUV.y += timeY * _DropSpeed; // Slide Down
                float2 refPoint = frac(mainUV) - 0.5;
                float2 secondUV = i.uv_SecondTex * uvScale;
                float2 refPoint2 = frac(secondUV) - 0.5;

                // Get random number (mainUV for seed) and add random number to timeY. This makes a difference in the starting point(Y).
                float ran = RandomFloat(floor(mainUV));
                timeY = (timeY * _DropSpeed) + (ran * 6.2831);
                
                // Sets the XY and W coordinates of the texture. using graphs for linear movements
                float texScrollW = i.uv_MainTex.y * 2; // Linear transformation of the X coordinates is influenced by _Size
                float texScrollX = (ran - 0.5) * _Randwidth; // Controls the range of values in the X coordinates to _Randwidth
                texScrollX += (0.4 - abs(texScrollX)) * sin(_DropWaveFreq * texScrollW) * (sin(texScrollW) * (_DropWaveWidth * ran)) * 0.05;
                float texScrollY = (-1) * sin((2 * timeY) + sin((2 * timeY) + sin((2 * timeY)) * 0.4)) * 0.3; // Last 0.3 limits the Y-axis movement of the texture

                // mainMaskUV is mask texture for fade-out effects
                fixed4 mainMaskUV = tex2D(_MainMask, i.uv_MainMask);

                // noiseTexUV is noise texture for refraction effects
                float2 secondNoiseUV = i.uv_SecondNoise;
                secondNoiseUV.y += timeY * _NoiseSpeed;
                fixed4 secondNoiseTexUV = tex2D(_SecondNoise, secondNoiseUV * _NoiseSize);

                // UruUruMask is mask texture for SecondNoise texture
                fixed4 uruUruMaskUV = tex2D(_UruUruMask, i.uv_UruUruMask);

                // Eye refraction effect for APOLO _ same as noiseTexUV
                float2 apoloEyeUV = i.uv_SecondNoise;
                apoloEyeUV.y += timeY * _UruSpeed;
                fixed4 apoloEyeTexUV = tex2D(_SecondNoise,  apoloEyeUV * _UruSize);
                if (i.uv_MainTex.y < (_TearPosY + _UruPosY)) apoloEyeTexUV = 0;

                // Based on random generated X and Y coordinate values, the UV reference point is changed to express the position of the texture as if it had changed
                float2 mainUVX = 0;
                if (i.uv_MainTex.x < 0.5) 
                    mainUVX = (((refPoint - float2(texScrollX + _DropPosX, texScrollY))) / uvScale) + 0.5;
                else
                    mainUVX = (((refPoint - float2(texScrollX - _DropPosX, texScrollY))) / uvScale) + 0.5;
                fixed4 mainTexUV = tex2D(_MainTex, mainUVX);
                
                // secondTexUV is mask texture for fade-out effects
                float2 secondUVX = 0;
                if (i.uv_MainTex.x < 0.5) 
                    secondUVX = ((refPoint2 - float2(_TearPosX, _TearPosY)) / uvScale) + 0.5;
                else
                    secondUVX = ((refPoint2 - float2(-_TearPosX, _TearPosY)) / uvScale) + 0.5;
                fixed4 secondTexUV = tex2D(_SecondTex, secondUVX);

                // The rgb value of screenPos is divided by the depth value a to obtain a normalized screen UV regardless of distance
                float2 screenUV = i.screenPos.rgb / i.screenPos.a;
                screenUV = float2(screenUV.x, screenUV.y);

                // Mask Y
                if (i.uv_MainTex.y > _TearPosY + 0.5) mainTexUV = 0;
                if (secondTexUV.r) mainTexUV = secondTexUV;

                // Make object have refraction effect and texture color. mainMaskUV is used here
                float2 colUV = screenUV + ((((mainTexUV + (secondTexUV * (secondNoiseTexUV * _NoisePower))) * (_RefPower * 0.1)) + ((apoloEyeTexUV * uruUruMaskUV) * (_UruPower * 0.1))) * mainMaskUV);
                float4 colAdd = ((mainTexUV + secondTexUV) * _TexPower) * mainMaskUV;
                col += tex2D(_GrabTexture, colUV) + colAdd;
                
                // Show grid mode (Debug Mode)
                if (_gridModeToggle > 0) {
                    if (_gridModeToggle > 1) { // Black background
                        col = 0;
                    }
                    // UruUru (Blue)
                    if (i.uv_MainTex.y > (_TearPosY + _UruPosY) - 0.0025 && i.uv_MainTex.y < (_TearPosY + _UruPosY) + 0.0025) col = float4(0, 0, 1, 1);

                    // Tear (Yellow)
                    if (i.uv_MainTex.x < 0.5 && refPoint2.x > _TearPosX - 0.005 && refPoint2.x < _TearPosX + 0.005) col = float4(1, 1, 0, 1);
                    if (i.uv_MainTex.x > 0.5 && refPoint2.x < -(_TearPosX) + 0.005 && refPoint2.x > -(_TearPosX) - 0.005) col = float4(1, 1, 0, 1);
                    if (refPoint2.y > _TearPosY - 0.0025 && refPoint2.y < _TearPosY + 0.0025) col = float4(1, 1, 0, 1);

                    // Drop (Green)
                    if (i.uv_MainTex.x < 0.5 && refPoint.x > _Randwidth + _DropPosX - 0.005 && refPoint.x < _Randwidth + _DropPosX + 0.005) col = float4(0, 1, 0, 1);
                    if (i.uv_MainTex.x < 0.5 && refPoint.x < -(_Randwidth) + _DropPosX + 0.005 && refPoint.x > -(_Randwidth) + _DropPosX  -  0.005) col = float4(0, 1, 0, 1);
                    if (i.uv_MainTex.x > 0.5 && refPoint.x > _Randwidth - _DropPosX - 0.005 && refPoint.x < _Randwidth - _DropPosX +  0.005) col = float4(0, 1, 0, 1);
                    if (i.uv_MainTex.x > 0.5 && refPoint.x < -(_Randwidth) - _DropPosX + 0.005 && refPoint.x > -(_Randwidth) - _DropPosX  -  0.005) col = float4(0, 1, 0, 1);

                    // UV Outline (Red / White)
                    if (refPoint.x > 0.495 || refPoint.x < -0.495) col = float4(1, 0, 0, 1);
                    if (refPoint.y > 0.495) col = float4(1, 1, 1, 1);
                }

                return col;
			}
			ENDCG
        }
    }
    // Clear the shadow
    FallBack "Regacy shaders/Transparent/Diffuse"
}
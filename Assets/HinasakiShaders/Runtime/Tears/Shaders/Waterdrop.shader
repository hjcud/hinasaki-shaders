/**
 * @fileoverview Shader to express the water drop effect
 * @author hjcud
 * @version 1.0.0
 */

Shader "Hinasaki/Waterdrop"
{
    Properties
    {
		[Header(HINASAKI SFX SHADER)]
		[Space(10)]
        [Header(Drop Texture)]
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _NoiseTex ("Mask Texture", 2D) = "white" {}
        [Header(UV Setting)]
        _GridSize ("Grid Size", Range(1, 10)) = 1
        _GridWidth ("Grid Width", Range(1, 10)) = 10
		[Space(10)]
        [Header(Drop Setting (Green Line))]
        _Randwidth ("Random Width", Range(0, 0.9)) = 0.2
        _DropWaveFreq ("Wave Frequency", Range(0, 10)) = 5
        _DropWaveWidth ("Wave Width", Range(0, 10)) = 0.1
		[Space(10)]
        [Header(Noise Setting)]
        _NoiseSize ("Noise Texture Size", Range(0, 20)) = 1
        _NoiseSpeed ("Noise Speed", Range(0, 10)) = 0.01
        _NoisePower ("Noise Power", Range(0, 1)) = 0.1
		[Space(10)]
        [Header(Effect Setting)]
        _TexPower ("Texture Power", Range(0, 1)) = 0.5
        _RefPower ("Refraction Power", Range(0, 1)) = 0.5
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
                float2 uv_NoiseTex : TEXCOORD1;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_NoiseTex : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
			};

            sampler2D _GrabTexture; // stores frame buffer textures captured by GrabPass
            sampler2D _MainTex, _NoiseTex;
            float4 _MainTex_ST;
            float4 _NoiseTex_ST;
            float _GridSize, _GridWidth, _Randwidth, _DropWaveFreq, _DropWaveWidth;
            float _NoiseSize, _NoiseSpeed, _NoisePower, _TexPower, _RefPower, _DropSpeed, _gridModeToggle;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_MainTex = TRANSFORM_TEX(v.uv_MainTex, _MainTex);
                o.uv_NoiseTex = TRANSFORM_TEX(v.uv_MainTex, _NoiseTex);
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
                float2 uvScale = float2(_GridWidth, 1);

                // Set main UV scale and UV scroll speed. also set uv origin
                float2 mainUV = i.uv_MainTex * _GridSize * uvScale;
                mainUV.y += timeY * _DropSpeed;
                float2 refPoint = frac(mainUV) - 0.5;
                
                // Get random number (mainUV for seed) and add random number to timeY. This makes a difference in the starting point(Y).
                float ran = RandomFloat(floor(mainUV));
                timeY = (timeY * _DropSpeed) + (ran * 6.2831);
                
                // Sets the XY and W coordinates of the texture. using graphs for linear movements
                float texScrollW = i.uv_MainTex.y * (_GridSize + 1); // Linear transformation of the X coordinates is influenced by _Size
                float texScrollX = (ran - 0.5) * _Randwidth; // Controls the range of values in the X coordinates to _Randwidth
                texScrollX += (0.4 - abs(texScrollX)) * sin(_DropWaveFreq * texScrollW) * (sin(texScrollW) * (_DropWaveWidth * ran )) * (0.05 * _GridSize);
                float texScrollY = (-1) * sin((2 * timeY) + sin((2 * timeY) + sin((2 * timeY)) * 0.4)) * 0.3; // Last 0.3 limits the Y-axis movement of the texture

                // NoiseTexUV is mask texture for fade-out effects
                float2 noiseUV = i.uv_NoiseTex;
                noiseUV.y += timeY * _NoiseSpeed;
                fixed4 NoiseTexUV = tex2D(_NoiseTex, i.uv_NoiseTex * _NoiseSize);

                // Based on random generated X and Y coordinate values, the UV reference point is changed to express the position of the texture as if it had changed
                fixed4 mainTexUV = tex2D(_MainTex, (((refPoint - float2(texScrollX, texScrollY))) / uvScale) + 0.5);

                // The rgb value of screenPos is divided by the depth value a to obtain a normalized screen UV regardless of distance
                float2 screenUV = i.screenPos.rgb / i.screenPos.a;
                screenUV = float2(screenUV.x, screenUV.y);

                // Make object have refraction effect and texture color. NoiseTexUV is used here
                col += tex2D(_GrabTexture, screenUV + ((mainTexUV.r * (_RefPower * 0.1)) + (mainTexUV * (NoiseTexUV * _NoisePower)))) + ((mainTexUV * _TexPower));
                
                // Show grid mode (Debug Mode)
                if (_gridModeToggle > 0) {
                    if (_gridModeToggle > 1) { // Black background
                        col = 0;
                    }
                    
                    // Drop (Green)
                    if (i.uv_MainTex.x < 0.5 && refPoint.x > _Randwidth - 0.005 && refPoint.x < _Randwidth + 0.005) col = float4(0, 1, 0, 1);
                    if (i.uv_MainTex.x < 0.5 && refPoint.x < -(_Randwidth) + 0.005 && refPoint.x > -(_Randwidth) -  0.005) col = float4(0, 1, 0, 1);
                    if (i.uv_MainTex.x > 0.5 && refPoint.x > _Randwidth - 0.005 && refPoint.x < _Randwidth +  0.005) col = float4(0, 1, 0, 1);
                    if (i.uv_MainTex.x > 0.5 && refPoint.x < -(_Randwidth) + 0.005 && refPoint.x > -(_Randwidth) -  0.005) col = float4(0, 1, 0, 1);

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
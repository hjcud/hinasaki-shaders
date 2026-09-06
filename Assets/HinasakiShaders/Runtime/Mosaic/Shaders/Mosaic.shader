/**
 * @fileoverview Shader for screen mosaic
 * @author hjcud
 * @version 1.0.0
 */

Shader "Hinasaki/Mosaic"
{
    Properties
    {
		[Header(HINASAKI SFX SHADER)]
		[Space(10)]
        [Header(Mosaic Effect)]
        _MosaicPercentage ("Percentage", Range(0, 1)) = 0.5
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
			};

			struct v2f
			{
				float4 screenPos : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

            sampler2D _GrabTexture; // stores frame buffer textures captured by GrabPass
            float _MosaicPercentage;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                // When capturing textures with GrabPass, calculate the screen coordinates of the current vertex
				o.screenPos = ComputeGrabScreenPos(o.vertex);

				return o;
			}


			fixed4 frag (v2f i) : SV_Target
			{
                // Calculation formula for limiting the range of mosaic size from 0 to 1
                float _MosaicSize = (_MosaicPercentage * 500) + 1;

                // The rgb value of screenPos is divided by the depth value a to obtain a normalized screen UV regardless of distance
                float2 screenUV = i.screenPos.rgb / i.screenPos.a;
                screenUV = float2(screenUV.r, screenUV.g);

                // UV is divided into _MosaicSize to give a mosaic effect
                float2 mosaic_uv = screenUV * _MosaicSize;
                mosaic_uv = floor(mosaic_uv) / _MosaicSize;

                fixed4 col = tex2D(_GrabTexture, mosaic_uv);
                return col;
			}
			ENDCG
        }
    }
    // Clear the shadow
    FallBack "Regacy shaders/Transparent/Diffuse"
}
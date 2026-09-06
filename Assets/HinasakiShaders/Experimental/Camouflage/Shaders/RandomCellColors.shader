/**
 * @fileoverview Shader to express the tear effect
 * @author hjcud
 * @version 1.0.0
 */

Shader "Hinasaki/Camouflage_v3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _HexSize ("Hex Size", Float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
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
            };
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HexSize;

            // Function to generate a random float value based on 2D coordinates
            float random(float2 st)
            {
                return frac(sin(dot(st.xy, float2(12.9898,78.233))) * 43758.5453123);
            }
            
            // Function to get the color of a hexagon based on UV coordinates
            float3 hexColor(float2 uv)
            {
                float2 hexUV = uv / _HexSize;
                float2 hexC = floor(hexUV);
                float3 color = float3(random(hexC), random(hexC + 1.0), random(hexC + 2.0));
                return color;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float3 color = hexColor(uv);
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
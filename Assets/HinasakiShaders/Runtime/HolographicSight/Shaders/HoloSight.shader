/**
 * @fileoverview Shader to express Holographic Sight
 * @author hjcud
 * @version 1.1.0
 */

Shader "Hinasaki/HoloSight"
{
    Properties {
		[Header(HINASAKI SFX SHADER)]
		[Space(10)]
        [Header(Main Texture)]
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1, 0, 0, 1)
        _Distance ("Distance", Range(0, 25)) = 8.5
        _MainAlpa ("Main Alpa", Range(0, 1)) = 1
        _Emission ("Emission", Range(1, 10)) = 1
		[Space(10)]
        [Header(Mask Texture)]
        [NoScaleOffset]_MaskTex ("Texture", 2D) = "white" {}
        _MaskSize ("Mask Size", Range(0.01, 10)) = 0.75
        _MaskPower ("Mask Power", Range(0, 1)) = 1
    }
    SubShader {
        Tags {"Queue"="Transparent" "RenderType"="Opaque"}
        LOD 100

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_MaskTex : TEXCOORD1;
                float3 scrNormal : NORMAL;
                float3 scrTangent : TANGENT;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_MaskTex : TEXCOORD1;
                float3 scrPos : TEXCOORD2;
                float3 scrNormal : NORMAL;
                float3 scrTangent : TANGENT;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;
            float4 _MainTex_ST;
            float4 _MaskTex_ST;
			float4 _Color;
            float _Distance, _MainAlpa, _Emission, _MaskSize, _MaskPower;

            v2f vert (appdata v) {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
				o.scrPos = UnityObjectToViewPos(v.vertex);
                // Model-View Inverse Transpose > Normal, Tangent of screen
                o.scrNormal = mul(UNITY_MATRIX_IT_MV, v.scrNormal);
                o.scrTangent = mul(UNITY_MATRIX_IT_MV, v.scrTangent);
                
                // Main texture UV is not required
                o.uv_MaskTex = TRANSFORM_TEX(v.uv_MainTex, _MaskTex);

                // Edit size of Mask Texture. it changes x, y coordinate of uv to keep the Mask Texture in the center
                o.uv_MaskTex *= _MaskSize;
                o.uv_MaskTex.y -= (_MaskSize - 1) / 2;
                o.uv_MaskTex.x -= (_MaskSize - 1) / 2;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                // normalize vector
                float3 viewNormal = normalize(i.scrNormal);
                float3 viewTangent = normalize(i.scrTangent);
                float3 viewDir = normalize(i.scrPos);
                
                // TBN matrix: transeform viewPos into tangent space (Used to adjust texture rotation)
                float3x3 mat = float3x3(
                    viewTangent,
                    cross(viewNormal, viewTangent), // Vector product of normal and tengent
                    viewNormal
                );
                
                // 'viewDir + viewNormal' is to move reticle according to the screen
                float3 viewPos = mul(mat, viewDir + viewNormal);
                viewPos = viewPos * _Distance; // Set reticle distance

                // Set main texture using viewPos 
                fixed4 col = tex2D(_MainTex, (viewPos) + float2(0.5, 0.5)) * _Color;
                col.a *= _MainAlpa;
                
                // Move Mask Texture to hide the retical that is close to frame
                float2 MaskUV = i.uv_MaskTex - (viewPos * ((_MaskSize - 1) * 2));
                fixed4 maskTexUV = tex2D(_MaskTex, MaskUV);
                col.a *= maskTexUV.a * _MaskPower;
                col.rgb *= _Emission;

                return col;
            }
            ENDCG
        }
    }
    // Clear the shadow
    FallBack "Regacy shaders/Transparent/Diffuse"
}
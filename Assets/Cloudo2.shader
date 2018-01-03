Shader "Unlit/Cloudo2" {
	Properties {
        _Volume ("Texture", 3D) = "" {}
	}
	SubShader {
        Tags {"Queue"="Transparent" "RenderType"="Transparent" }
		LOD 100
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

		Pass {
        CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
			
			#include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
            };

            uniform sampler3D _Volume;

            #define STEP_COUNT 100
            #define STEP_SIZE 0.02

            float evalCloud(float3 pos)
            {
                return tex3D(_Volume, 0.5*pos + float3(0.5,0.5,0.5)); // *clamp(1 - length(pos), 0, 1);
            }

            float integrate(float3 ro, float3 rd)
            {
                float accum = 0;
                float3 pos = ro;

                for (int i = 0; i < STEP_COUNT; i++) {
                    accum += evalCloud(pos);
                    pos += STEP_SIZE * rd;
                }

                return accum / STEP_COUNT;
            }

            v2f vert(appdata v) 
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target 
            {
                float3 dir = normalize(i.worldPos.xyz - _WorldSpaceCameraPos);
                float linearDensity = integrate(i.worldPos.xyz, dir);
                float transmittance = exp(-linearDensity);
                return fixed4(1, 1, 1, 1-transmittance);
            }

        ENDCG
		}
	}
}
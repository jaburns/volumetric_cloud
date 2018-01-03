// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Cloudo" {
	Properties {
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
        /*
            float4 permute(float4 x){ return fmod(((x*34.0)+1.0)*x, 289.0); }
            float4 taylorInvSqrt(float4 r){ return 1.79284291400159 - 0.85373472095314 * r; }
            float snoise(float3 v) { 
                const float2 C = float2(1.0/6.0, 1.0/3.0) ;
                const float4 D = float4(0.0, 0.5, 1.0, 2.0);
                float3 i  = floor(v + dot(v, C.yyy) );
                float3 x0 =   v - i + dot(i, C.xxx) ;
                float3 g = step(x0.yzx, x0.xyz);
                float3 l = 1.0 - g;
                float3 i1 = min( g.xyz, l.zxy );
                float3 i2 = max( g.xyz, l.zxy );
                float3 x1 = x0 - i1 + 1.0 * C.xxx;
                float3 x2 = x0 - i2 + 2.0 * C.xxx;
                float3 x3 = x0 - 1. + 3.0 * C.xxx;
                i = fmod(i, 289.0 ); 
                float4 p = permute( permute( permute( 
                         i.z + float4(0.0, i1.z, i2.z, 1.0 ))
                       + i.y + float4(0.0, i1.y, i2.y, 1.0 )) 
                       + i.x + float4(0.0, i1.x, i2.x, 1.0 ));
                float n_ = 1.0/7.0;
                float3  ns = n_ * D.wyz - D.xzx;
                float4 j = p - 49.0 * floor(p * ns.z *ns.z);
                float4 x_ = floor(j * ns.z);
                float4 y_ = floor(j - 7.0 * x_ );
                float4 x = x_ *ns.x + ns.yyyy;
                float4 y = y_ *ns.x + ns.yyyy;
                float4 h = 1.0 - abs(x) - abs(y);
                float4 b0 = float4( x.xy, y.xy );
                float4 b1 = float4( x.zw, y.zw );
                float4 s0 = floor(b0)*2.0 + 1.0;
                float4 s1 = floor(b1)*2.0 + 1.0;
                float4 sh = -step(h, float4(0.0, 0,0,0));
                float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
                float4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;
                float3 p0 = float3(a0.xy,h.x);
                float3 p1 = float3(a0.zw,h.y);
                float3 p2 = float3(a1.xy,h.z);
                float3 p3 = float3(a1.zw,h.w);
                float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
                p0 *= norm.x;
                p1 *= norm.y;
                p2 *= norm.z;
                p3 *= norm.w;
                float4 m = max(0.6 - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
                m = m * m;
                return 42.0 * dot( m*m, float4( dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3) ) );
            }
            */
float3 random3(float3 c) {
	float j = 4096.0*sin(dot(c,float3(17.0, 59.4, 15.0)));
	float3 r;
	r.z = frac(512.0*j);
	j *= .125;
	r.x = frac(512.0*j);
	j *= .125;
	r.y = frac(512.0*j);
	return r-0.5;
}

/* skew constants for 3d simplex functions */
const float F3 =  0.3333333;
const float G3 =  0.1666667;

/* 3d simplex noise */
float snoise(float3 p) {
	 /* 1. find current tetrahedron T and it's four vertices */
	 /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
	 /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/
	 
	 /* calculate s and x */
	 float3 s = floor(p + dot(p, float3(F3,F3,F3)));
	 float3 x = p - s + dot(s, float3(G3,G3,G3));
	 
	 /* calculate i1 and i2 */
	 float3 e = step(float3(0,0,0), x - x.yzx);
	 float3 i1 = e*(1.0 - e.zxy);
	 float3 i2 = 1.0 - e.zxy*(1.0 - e);
	 	
	 /* x1, x2, x3 */
	 float3 x1 = x - i1 + G3;
	 float3 x2 = x - i2 + 2.0*G3;
	 float3 x3 = x - 1.0 + 3.0*G3;
	 
	 /* 2. find four surflets and store them in d */
	 float4 w, d;
	 
	 /* calculate surflet weights */
	 w.x = dot(x, x);
	 w.y = dot(x1, x1);
	 w.z = dot(x2, x2);
	 w.w = dot(x3, x3);
	 
	 /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
	 w = max(0.6 - w, 0.0);
	 
	 /* calculate surflet components */
	 d.x = dot(random3(s), x);
	 d.y = dot(random3(s + i1), x1);
	 d.z = dot(random3(s + i2), x2);
	 d.w = dot(random3(s + 1.0), x3);
	 
	 /* multiply d by w^4 */
	 w *= w;
	 w *= w;
	 d *= w;
	 
	 /* 3. return the sum of the four surflets */
	 return dot(d, float4(52.0,52.0,52.0,52));
}
            float distfunc(float3 p) 
            {
                return length(p) - 1;
            }

            #define MAX_ITER 50
            #define MAX_DIST 30.0
            #define EPSILON 0.01

            bool march (float3 ro, float3 rd, out float3 pos)
            {
                float totalDist = 0.0;
                pos = ro;
                float dist = EPSILON;

                for (int i = 0; i < MAX_ITER; i++) {
                    if (dist < EPSILON || totalDist > MAX_DIST) break;
                    dist = distfunc(pos);
                    totalDist += dist;
                    pos += dist * rd;
                }

                return dist < EPSILON;
            }

            struct appdata {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
            };

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
                float3 pos;
                bool marched = march(
                    _WorldSpaceCameraPos,
                    normalize(i.worldPos.xyz - _WorldSpaceCameraPos),
                    pos
                );

                if (marched) {
                    float val = 0.5 + 0.5*snoise(10*pos + float3(0,0,_Time.z));
                    return fixed4(val, val, val, 1);
                }

                return fixed4(i.worldPos.xyz, 0.2);
            }

        ENDCG
		}
	}
}
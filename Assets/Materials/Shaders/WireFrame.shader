// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Dustin/Wireframe"
{
	Properties
	{
		_MainTex("Texture 1", 2D) = "white" {}
		_SecTex("Texture 2", 2D) = "white" {}
		[PowerSlider(3.0)]
		_WireframeVal("Wireframe width", Range(0., 0.34)) = 0.05
		_BumpItOffset("Bump it amount", Range(0., 2.0)) = 0.2
		_WireColor("Wire color", color) = (1., 1., 1., 1.)
		_BaseColor("Base color", color) = (1., 1., 1., 1.)
		_Displacement("Displacement Amount", Float) = 2.0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }


			Pass
			{
				Cull Off
				CGPROGRAM
				#pragma 4.0
				#pragma vertex vert
				#pragma fragment frag
				#pragma geometry geom
				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : NORMAL;
				};

				struct v2g {
					float4 pos : SV_POSITION;
					float4 vert: TEXCOORD1;
				};

				struct g2f {
					float4 pos : SV_POSITION;
					float3 bary : TEXCOORD0;
					float4 vert: TEXCOORD1;
				};

				////////////////////////////////

				sampler2D _MainTex;
				float4 _MainTex_ST;

				sampler2D _SecTex;
				float4 _SecTex_ST;

				float _Displacement;
				uniform float _BumpIt;
				float _BumpItOffset;

				float4 displace(float3 normal, float2 uv, float2 uv2) {

					float2 uvOffset = float2(uv.x + _Time.x / 10 , uv.y + _Time.x / 2);
					float2 uvOffset2 = float2(uv2.x + _Time.x / 10 , uv2.y + _Time.x /1.2);
					fixed4 col = tex2Dlod(_MainTex, float4(uvOffset, 0, 0));
					fixed4 col2 = tex2Dlod(_SecTex, float4(uvOffset2, 0, 0));

					return float4(normal * ((col.r*2 + col2.r/2) * _Displacement + ((_BumpIt * _BumpItOffset)/ col2.r*5)), 0);
				}

				v2g vert(appdata v) {

					float2 uv = TRANSFORM_TEX(v.uv, _MainTex);
					float2 uv2 = TRANSFORM_TEX(v.uv, _SecTex);
					float3 normalToWorld = normalize(mul(v.normal, unity_WorldToObject).xyz);
					float4 displacedVert = (v.vertex) + displace(v.normal, uv, uv2);


					v2g o;
					o.pos = UnityObjectToClipPos(displacedVert);
					o.vert = displacedVert;
					return o;
				}

				[maxvertexcount(3)]
				void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream) {
					g2f o;
					o.pos = IN[0].pos;
					o.vert = IN[0].vert;
					o.bary = float3(1., 0., 0.);
					triStream.Append(o);
					o.pos = IN[1].pos;
					o.vert = IN[1].vert;
					o.bary = float3(0., 0., 1.);
					triStream.Append(o);
					o.pos = IN[2].pos;
					o.vert = IN[2].vert;
					o.bary = float3(0., 1., 0.);
					triStream.Append(o);
				}

				float _WireframeVal;
				fixed4 _WireColor;
				fixed4 _BaseColor;

				fixed4 frag(g2f i) : SV_Target {

					float3 lightDir = normalize(float3(0.3,1,0));
					float wire = 0;

					if (any(bool3(i.bary.x < _WireframeVal, i.bary.y < _WireframeVal, i.bary.z < _WireframeVal))) {
						wire = 1;
					}



					float3 dpdx = ddx(mul(unity_ObjectToWorld, i.vert));
					float3 dpdy = ddy(mul(unity_ObjectToWorld, i.vert));
					float3 flatNormal = normalize(cross(dpdy, dpdx));

					float3 directLight = pow(38,dot(flatNormal, lightDir));

					return float4(_BaseColor * directLight * (1-wire) + (0.15+ _WireColor) * wire,0);
				}

				ENDCG
			}

		}
}
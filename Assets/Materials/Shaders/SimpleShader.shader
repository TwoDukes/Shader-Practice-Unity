Shader "Unlit/SimpleShader"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,0)
		_Gloss("Gloss", Float) = 1
		_GlossPower("Gloss", Float) = 1

		_WaterShallow("Water Shallow", Color) = (1,1,1,0)
		_WaterDeep("Water Deep", Color) = (1,1,1,0)
		_WaveColor("Wave", Color) = (1,1,1,0)
        _ShoreLineTex ("Shorline Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			// Uses standard buffers
            struct vertexInput
            {
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				float2 uv0 : TEXCOORD0;

				//float4 colors : COLOR;
				//float4 tangent : TANGENT;
				//float2 uv1 : TEXCOORD1;
            };

			// Uses interpolating buffers
            struct vertexOutput
            {
                float4 clipSpacePos : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
            };

            sampler2D _ShoreLineTex;

			uniform float4 _Color;
			uniform float _Gloss;
			uniform float _GlossPower;

			uniform float3 _MousePos;

			uniform float3 _WaterShallow;
			uniform float3 _WaterDeep;
			uniform float3 _WaveColor;


			vertexOutput vert (vertexInput v)
            {
				vertexOutput o;
				o.uv0 = v.uv0;
				o.normal = normalize(mul(v.normal, unity_WorldToObject).xyz); // Lets you rotate object without shader rotating as well
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.clipSpacePos = UnityObjectToClipPos(v.vertex);
                return o;
            }

			// gets the percentage (0-1) of the location of the input value between a and b
			float invLerp(float a, float3 b, float value) {
				return (value - a) / (b - a);
			}

			float3 MyLerp(float3 a, float3 b, float t) {
				return t * b + (1.0 - t)*a;
			}

			float Posterize(float steps, float value) {
				return floor(value * steps) / steps;
			}

            fixed4 frag (vertexOutput o) : SV_Target
            {
				// ISLAND WAVE GENERATOR //
				float shorline = tex2D(_ShoreLineTex, o.uv0).x;

				float waveSize = 0.04;

				float shape = shorline;

				
				float waveAmp = (sin(shape / waveSize + _Time.y * 2) + 1) * 0.5;
				waveAmp *= shorline;

				float3 waterColor = lerp(_WaterDeep, _WaterShallow, shorline);

				float3 waterWithWaves = lerp(waterColor, _WaveColor, waveAmp);

				waterWithWaves *= (shorline - 1) * -1;
				waterWithWaves += shorline * float3(0.9, 0.8, 0.4);

				//return float4(waterWithWaves,0);

				// ISLAND WAVE GENERATOR END // 



				 // POSTERIZATION NONSENSE //
				float2 uv = o.uv0;
				float3 colorA = float3(0.1, 0.8, 1);
				float3 colorB = float3(1, 0.1, 0.8);
				float t = uv.y; 

				t = Posterize(16, t);

				//return t;

				float3 blend = MyLerp(colorA, colorB, t);

				//return float4(blend, 0);

				 // END POSTERIZATION NONSENSE //





				// REAL SHADER CODE BELOW //

				// Glow from cursor
				float distToCursor = distance(_MousePos, o.worldPos);
				float glow = saturate(1 - distToCursor) * 1;


				float3 normal = normalize(o.normal);

				// Unity Light Input
				float3 lightDir = _WorldSpaceLightPos0.xyz; //normalize(float3(1, 1, 1));
				float3 lightCol = _LightColor0.rgb; //float3(0.9, 0.82, .76);

				float lightDistance = length(lightDir);

				// Diffuse Light structure //

				// Direct Diffuse Light
				float lightFalloff = max(0, dot(lightDir, normal));
				//lightFalloff = Posterize(3, lightFalloff);
				float3 directDiffuseLight = lightCol * lightFalloff;

				//Ambient Light
				float3 ambientLight = float3(0.2, 0.2, 0.2);


				// Specular Light structure //

				// Direct Specular Light
				float3 camPos = _WorldSpaceCameraPos;
				float3 fragToCamera = camPos - o.worldPos;
				float3 viewDir = normalize(fragToCamera);
				float3 viewReflect = reflect(-viewDir, normal);
				float specularFalloff = max(0,dot(viewReflect, lightDir));
				specularFalloff = pow(specularFalloff, _Gloss);
				//specularFalloff = Posterize(3, specularFalloff);

				
				float3 directSpecular = specularFalloff * lightCol;

				//float outline = step(0.25, dot(viewDir, normal));

				// Modify Gloss


				// Composite 
				float3 diffuseLight = ambientLight + directDiffuseLight;
				float3 finalSurfaceColor = diffuseLight * _Color.rgb + (directSpecular * _GlossPower / lightDistance) + glow;

                return float4(finalSurfaceColor,0);
            }
            ENDCG
        }
    }
}


// NOTES

/* floating point precision in order of precision
float; -alot -> alot // Mainly used for high end
half; -32000 -> 32000 // mostly used for mobile
fixed; -1 -> 1 // mostly used for mobile
*/
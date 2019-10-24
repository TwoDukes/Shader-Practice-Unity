// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/PerlinWaves"
{
    Properties
    {
		_MainTex("Displacement Map", 2D) = "white" {}
		_Displacement ("Displacement Amount", Float) = 2.0

		_TopColor ("Top color", Color) = (1, 0.1, 0.8, 1)
		_BottomColor("Bottom color", Color) = (0.1, 0.8, 1,1)

		_ColorShiftStrength("Color shift strength", Float) = 20
		_ColorShiftOffset("Color shift Offset", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        //LOD 100
		cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float4 worldPos: TEXCOORD1;
				float3 normal : TEXCOORD2;
				float4 nonClipVert: TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			float4 _BottomColor;
			float4 _TopColor;

			float _ColorShiftStrength;
			float _ColorShiftOffset;

			float _Displacement;
			uniform float _BumpIt;

			float4 displace(float3 normal, float2 uv) {
				
				float2 uvOffset = float2(uv.x + _Time.x/1.5 , uv.y + _Time.x/1.5);
				fixed4 col = tex2Dlod(_MainTex, float4(uvOffset,0,0));

				return float4(normal * (-col.r * _Displacement), 0);
			}

            v2f vert (appdata v)
            {
                v2f o;
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float2 uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 normalToWorld = normalize(mul(v.normal, unity_WorldToObject).xyz);
                float4 displacedVert = (v.vertex) + displace(v.normal,uv);


				o.nonClipVert = displacedVert;
				o.vertex = UnityObjectToClipPos(displacedVert);
				o.worldPos = mul(unity_ObjectToWorld, displacedVert);
				o.uv = uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

				fixed4 finalCol = lerp(_BottomColor,_TopColor , pow(length(i.nonClipVert), _ColorShiftStrength) - _ColorShiftOffset + _BumpIt / 0.1);

                return finalCol;
            }
            ENDCG
        }
    }
}

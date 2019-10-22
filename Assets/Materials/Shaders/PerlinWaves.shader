Shader "Unlit/PerlinWaves"
{
    Properties
    {
		_MainTex("Displacement Map", 2D) = "white" {}
		_Displacement ("Displacement Amount", Float) = 2.0
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float4 worldPos: TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _Displacement;
			float _BumpIt;

			float4 displace(float4 vec, float2 uv) {
				
				float2 uvOffset = float2(uv.x + _Time.x/1.5 + _BumpIt / 60, uv.y + _Time.x/1.5);
				fixed4 col = tex2Dlod(_MainTex, float4(uvOffset,0,0));
				return float4(0, -col.r * _Displacement, 0, 0);
			}

            v2f vert (appdata v)
            {
                v2f o;
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float2 uv = TRANSFORM_TEX(v.uv, _MainTex);
                float4 displacedVert = (v.vertex) + displace(worldPos,uv);
				//displacedVert.y += (worldPos.y * (_BumpIt / 30));

				o.vertex = UnityObjectToClipPos(displacedVert);
				o.worldPos = mul(unity_ObjectToWorld, displacedVert);
				o.uv = uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

				//return -(i.uv.x + i.worldPos.x)/50;

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

				float4 topCol = float4(0.1, 0.8, 1,1);
				float4 bottomCol = float4(1, 0.1, 0.8,1);
				fixed4 finalCol = lerp(topCol, bottomCol, i.worldPos.y*1.5 + _BumpIt/ 1.0);
				//return i.worldPos;


                return finalCol;
            }
            ENDCG
        }
    }
}

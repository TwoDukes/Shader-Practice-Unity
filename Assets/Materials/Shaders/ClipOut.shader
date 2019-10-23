Shader "DustinP/ClipOut"
{
    Properties
    {
		_Color("Color Top", Color) = (0.086, 0.407, 1, 0.749)
		_Color2("Color Bottom", Color) = (0.086, 0.407, 1, 0.749)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
		//cull Off

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
				float3 normal : TEXCOORD1;
            };

			float4 _Color;
			float4 _Color2;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
				o.normal = normalize(mul(v.normal, unity_WorldToObject).xyz);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

				float3 lightDir = float3(0,1,0);
				float directLight = dot(i.normal, lightDir);
				//return float4(directLight, 0);

				float rings = -cos((i.uv.y * (50 + pow(60, i.uv.y))) + _Time.w) + step(0.45,1-i.uv.y);
				clip(rings);		
				return lerp(_Color2, _Color, directLight+0.1);
            }
            ENDCG
        }
    }
}

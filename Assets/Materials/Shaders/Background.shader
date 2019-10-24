Shader "DustinP/Background"
{
    Properties
    {
		_Color("Color Top", Color) = (0.086, 0.407, 1, 1)
		_Color2("Color Bottom", Color) = (0.086, 0.407, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
            };

			float4 _Color;
			float4 _Color2;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float4 output = lerp(_Color, _Color2, pow(i.uv.y + 0.4,15));
				return output * ((abs(pow(i.uv.y,0.2) - 0.9)));
            }
            ENDCG
        }
    }
}

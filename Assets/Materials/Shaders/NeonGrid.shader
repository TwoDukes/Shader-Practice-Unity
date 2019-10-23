Shader "DustinP/NeonGrid"
{
	Properties
	{
		//_MainTex ("Texture", 2D) = "white" {}

		//_LineWidth("Line Width", Float) = 0.85
		//_LineSmoothness("Line Smoothness", Float) = 0.1
		_Color("Line Color Top", Color) = (0.086, 0.407, 1, 0.749)
		_Color2("Line Color Bottom", Color) = (0.086, 0.407, 1, 0.749)
		_Width("Line Width", Float) = 10
		_Height("Line Height", Float) = 10
		_XTile("X Tile", Float) = 0
		_YTile("Y Tile", Float) = 0
		_XOffset("X Offset", Float) = 0
		_YOffset("Y Offset", Float) = 0

    }
    SubShader
    {
        Tags { "Queue"="Transparent" }

		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		cull Off
        LOD 100

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

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

			float _LineWidth;
			float _LineSmoothness;
			fixed4 _Color;
			fixed4 _Color2;

			float _Width;
			float _Height;

			float _XTile;
			float _YTile;

			float _YOffset;
			float _XOffset;

			uniform float _BumpIt;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;// TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);



				float LineWidth = 0.98;
				float LineSmoothness = 0.02;

				float2 uv = i.uv += float2(_XOffset + _Time.x,_YOffset);

				fixed4 xGrid = smoothstep(LineWidth, LineWidth+LineSmoothness, ((uv.x * _XTile) % 0.1) * (_Width + 10 + _BumpIt * 2));
				fixed4 yGrid = smoothstep(LineWidth, LineWidth + LineSmoothness,((uv.y * _YTile) % 0.1) * (_Height + 10 + _BumpIt * 2));

				fixed4 rXGrid = smoothstep(1.0 - LineWidth, 1.0 - LineWidth - LineSmoothness, ((uv.x * _XTile) % 0.1) * (10-_Width - _BumpIt*2));
				fixed4 rYGrid = smoothstep(1.0 - LineWidth, 1.0-LineWidth- LineSmoothness, ((uv.y * _YTile) % 0.1) * (10 - _Height - _BumpIt * 2));


				fixed4 grids = rXGrid + rYGrid + xGrid + yGrid;
				return grids * lerp(_Color, _Color2, i.uv.y);
            }
            ENDCG
        }
    }
}

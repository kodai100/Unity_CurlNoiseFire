// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/CurlNoise" {
	Properties{
		_MainTex("Source", 2D) = "white" {}
	_Size("Size", Float) = 1
	}
		SubShader{
		ZTest Always
		Cull Off
		ZWrite Off
		Fog{ Mode Off }

		Pass{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag

		#include "UnityCG.cginc"
		#include "./SimplexNoise3D.cginc"

		struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	v2f vert(appdata_img v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, v.texcoord.xy);
		return o;
	}

	sampler2D _MainTex;
	float _Size;

	float3 curlNoise(float3 p) {
		const float e = 0.0009765625;
		const float e2 = 2.0 * e;

		float3 dx = float3(e, 0.0, 0.0);
		float3 dy = float3(0.0, e, 0.0);
		float3 dz = float3(0.0, 0.0, e);

		float3 p_x0 = snoise3D(p - dx);
		float3 p_x1 = snoise3D(p + dx);
		float3 p_y0 = snoise3D(p - dy);
		float3 p_y1 = snoise3D(p + dy);
		float3 p_z0 = snoise3D(p - dz);
		float3 p_z1 = snoise3D(p + dz);

		float x = p_y1.z - p_y0.z - p_z1.y + p_z0.y;
		float y = p_z1.x - p_z0.x - p_x1.z + p_x0.z;
		float z = p_x1.y - p_x0.y - p_y1.x + p_y0.x;

		return normalize(float3(x, y, z) / e2);
	}

	fixed4 frag(v2f i) : SV_TARGET{
		// float2 delta = _Size / _ScreenParams.xy;
		// float2 uv = (floor(i.uv / delta) + 0.5) * delta;


		return fixed4(curlNoise(float3(i.uv,0)), 1);
	}
		ENDCG
	}
	}
		FallBack Off
}
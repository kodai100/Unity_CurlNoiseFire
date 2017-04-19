Shader "Custom/PBD3D" {
	Properties{
		_MainTex("Texture", 2D) = "white" {}
		_KelvinTex("Kelvin Texture", 2D) = "white" {}
		_ParticleRad("ParticleRadius", Range(0.03, 1)) = 0.5
		_Flip("Scale Flip Position (t)", Range(0.1, 0.8)) = 0.4
	}

	SubShader{
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass{
			CGPROGRAM

			#pragma target 5.0
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _KelvinTex;
			float _ParticleRad;
			float _Flip;

			struct Particle {
				float3 birthPos;
				float3 pos;
				float time;
				float life;
			};

			StructuredBuffer<Particle> _Particles;

			struct v2g {
				float4 pos : SV_POSITION;
				float2 tex : TEXCOORD0;
				float4 col : COLOR;
			};

			v2g vert(uint id : SV_VertexID) {
				v2g output;
				output.pos = float4(_Particles[id].pos, 1);
				output.tex = float2(0, 0);

				float t = _Particles[id].time / _Particles[id].life;
				float transparency = 0;
				if (t < _Flip) {
					float map = t * (1 / _Flip);
					transparency = map * (2 - map);
				}
				else {
					float map = (t - _Flip) / (1 - _Flip);
					transparency = 1 - (-2 * map* map* map + 3 * map * map);
				}
				
				output.col = float4(t, 1, 1, transparency);	// transparency

				return output;
			}

			[maxvertexcount(4)]
			void geom(point v2g input[1], inout TriangleStream<v2g> outStream) {
				v2g output;

				float4 pos = input[0].pos;
				float4 col = input[0].col;

				for (int x = 0; x < 2; x++) {
					for (int y = 0; y < 2; y++) {
						float4x4 billboardMatrix = UNITY_MATRIX_V;
						billboardMatrix._m03 =
							billboardMatrix._m13 =
							billboardMatrix._m23 =
							billboardMatrix._m33 = 0;

						float2 tex = float2(x, y);
						output.tex = tex;

						output.pos = pos + mul(float4((tex * 2 - float2(col.w, col.w)) * _ParticleRad, 0, 1), billboardMatrix);
						output.pos = mul(UNITY_MATRIX_VP, output.pos);

						output.col = col;

						outStream.Append(output);
					}
				}

				outStream.RestartStrip();
			}

			fixed4 frag(v2g i) : COLOR{
				float4 col = tex2D(_MainTex, i.tex) * tex2D(_KelvinTex, float2(0,i.col.x)) * float4(1,1,1,i.col.w);
				return col;
			}

			ENDCG
		}
	}
}
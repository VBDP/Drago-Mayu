// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Furality/SomnaNocturna"
{
	Properties
	{
		_DialTex("DialTex", 2D) = "white" {}
		_Background("Background", 2D) = "black" {}
		_BackgroundColor("Background Color", Color) = (0.2567138,0,0.2924528,0)
		_MainTex("MainTex", 2D) = "white" {}
		[Normal]_Normal("Normal", 2D) = "bump" {}
		_Metallic("Metallic", 2D) = "white" {}
		[HideInInspector] _texcoord3( "", 2D ) = "white" {}
		[HideInInspector] _texcoord4( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardBRDF.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 5.0
		#define ASE_VERSION 19801
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float4 ase_positionOS4f;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv3_texcoord3;
			float2 uv4_texcoord4;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float4 _BackgroundColor;
		uniform sampler2D _Background;
		uniform float4 _Background_ST;
		uniform sampler2D _DialTex;
		uniform float _Udon_FuralityEclipse_Time;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _Metallic;
		uniform float4 _Metallic_ST;


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		float2 planeRayIntersect141( float3 rayOriginWS, float3 rayDirWS, float planeHeight, float uvScale, out float3 wPos )
		{
			    float3 planeNormal = float3(0, 1, 0); // Upward facing
			    float denom = dot(planeNormal, rayDirWS);
			    // Avoid divide-by-zero or parallel rays
			    if (abs(denom) < 1e-5)
			        return float2(-1, -1); // No intersection
			    float t = (planeHeight - rayOriginWS.y) / denom;
			    if (t < 0)
			        return float2(-1, -1); // Intersection behind the ray origin
			    float3 hitPoint = rayOriginWS + rayDirWS * t;
			    // Project to XZ plane and scale UVs
			    float2 uv = hitPoint.xz * uvScale;
			    //return frac(uv); // Repeat every 1 unit
			wPos = hitPoint;
			return uv;
		}


		float3 ASESafeNormalize(float3 inVec)
		{
			float dp3 = max(1.175494351e-38, dot(inVec, inVec));
			return inVec* rsqrt(dp3);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_positionOS4f = v.vertex;
			o.ase_positionOS4f = ase_positionOS4f;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float temp_output_159_0 = radians( -90.0 );
			float3 ase_positionOS = i.ase_positionOS4f.xyz;
			float3 rotatedValue158 = RotateAroundAxis( float3( 0,0,0 ), ase_positionOS, float3( 1,0,0 ), temp_output_159_0 );
			float3 rayOriginWS141 = rotatedValue158;
			float3 ase_positionWS = i.worldPos;
			float3 ase_viewVectorWS = ( _WorldSpaceCameraPos.xyz - ase_positionWS );
			float3 ase_viewDirWS = normalize( ase_viewVectorWS );
			float3 worldToObjDir157 = normalize( mul( unity_WorldToObject, float4( ase_viewDirWS, 0.0 ) ).xyz );
			float3 rotatedValue160 = RotateAroundAxis( float3( 0,0,0 ), -worldToObjDir157, float3( 1,0,0 ), temp_output_159_0 );
			float3 rayDirWS141 = rotatedValue160;
			float planeHeight141 = -0.003;
			float uvScale141 = 10.0;
			float3 wPos141 = float3( 0,0,0 );
			float2 localplaneRayIntersect141 = planeRayIntersect141( rayOriginWS141 , rayDirWS141 , planeHeight141 , uvScale141 , wPos141 );
			float mulTime172 = _Time.y * 0.4;
			float cos171 = cos( radians( mulTime172 ) );
			float sin171 = sin( radians( mulTime172 ) );
			float2 rotator171 = mul( (localplaneRayIntersect141*_Background_ST.xy + _Background_ST.zw) - float2( 0,0 ) , float2x2( cos171 , -sin171 , sin171 , cos171 )) + float2( 0,0 );
			float4 tex2DNode166 = tex2D( _Background, rotator171 );
			float temp_output_2_0_g17 = pow( ( 1.0 / 2.71828 ) , pow( ( -( 1.0 - 62.0 ) * max( ( length( ( wPos141 - float3(0.03,0,-0.03) ) ) + -0.06 ) , 0.0 ) ) , 2.0 ) );
			float3 lerpResult170 = lerp( _BackgroundColor.rgb , tex2DNode166.rgb , ( tex2DNode166.a * temp_output_2_0_g17 ));
			float temp_output_705_0_g18 = 0.25;
			float3 ase_normalWS = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normalWSNorm = normalize( ase_normalWS );
			float3 ase_viewDirSafeWS = Unity_SafeNormalize( ase_viewVectorWS );
			float3 normalizeResult190 = normalize( float3(-1.2,-0.5,-1.12) );
			float3 normalizeResult450_g16 = normalize( ( normalizeResult190 + ase_viewDirWS ) );
			float3 normalizeResult447_g16 = ASESafeNormalize( ( ase_viewDirSafeWS + normalizeResult450_g16 ) );
			float dotResult178_g16 = dot( ase_normalWSNorm , normalizeResult447_g16 );
			float temp_output_670_0_g18 = ( max( max( dotResult178_g16 , 1E-37 ) , 0.01 ) * max( max( dotResult178_g16 , 1E-37 ) , 0.01 ) );
			float temp_output_666_0_g18 = ( max( temp_output_705_0_g18 , 0.002 ) / ( temp_output_670_0_g18 * ( ( ( 1.0 - temp_output_670_0_g18 ) / temp_output_670_0_g18 ) + ( temp_output_705_0_g18 * temp_output_705_0_g18 ) ) ) );
			float2 uv3_TexCoord2 = i.uv3_texcoord3 * float2( 1,0.6 ) + float2( 0,0.4 );
			float Global113 = _Udon_FuralityEclipse_Time;
			float2 appendResult38 = (float2(Global113 , 0.12));
			float2 temp_output_34_0 = ( ( ( uv3_TexCoord2 * float2( 1,0.9 ) ) + float2( -0.0605,0 ) ) + appendResult38 );
			float smoothstepResult204 = smoothstep( 0.0 , ( 0.0 + 0.001 ) , temp_output_34_0.x);
			float smoothstepResult203 = smoothstep( ( 1.0 + 0.001 ) , 1.0 , temp_output_34_0.x);
			float4 Main115 = ( tex2D( _DialTex, temp_output_34_0 ) * min( smoothstepResult204 , smoothstepResult203 ) );
			float2 appendResult74 = (float2(Global113 , 0.0));
			float2 _Vector6 = float2(0.1,1);
			float2 uv3_TexCoord52 = i.uv3_texcoord3 * float2( 1,0.6 ) + float2( 0,0.4 );
			float2 FireworkUV123 = ( ( ( appendResult74 / _Vector6 ) + ( uv3_TexCoord52 + float2( -0.019,0.02 ) ) ) * _Vector6 );
			float smoothstepResult100 = smoothstep( 0.7782 , 0.78 , FireworkUV123.x);
			float smoothstepResult101 = smoothstep( ( 1.004 + 0.001 ) , 1.004 , FireworkUV123.x);
			float2 appendResult61 = (float2(0.0075 , 1.0));
			float2 fmodResult66 = frac(FireworkUV123/appendResult61)*appendResult61;
			float4 Fireworks122 = tex2Dlod( _DialTex, float4( ( ( ( fmodResult66 * float2( 1,0.9 ) ) / _Vector6 ) + float2( 0.033,0.11 ) ), 0, 0.0) );
			float2 appendResult43 = (float2(1.0 , 2.0));
			float2 appendResult44 = (float2(0.0 , 0.185));
			float2 uv4_TexCoord45 = i.uv4_texcoord4 * appendResult43 + appendResult44;
			float smoothstepResult105 = smoothstep( 0.0 , 0.025 , uv4_TexCoord45.y);
			float smoothstepResult106 = smoothstep( 1.0 , 0.975 , uv4_TexCoord45.y);
			float4 lerpResult73 = lerp( Main115 , ( min( smoothstepResult100 , smoothstepResult101 ) * Fireworks122 ) , min( smoothstepResult105 , smoothstepResult106 ));
			float2 appendResult18 = (float2(1.0 , 1.0));
			float2 appendResult21 = (float2(0.0 , 0.0));
			float2 uv4_TexCoord9 = i.uv4_texcoord4 * appendResult18 + appendResult21;
			float temp_output_3_0_g11 = ( uv4_TexCoord9.y - 0.0 );
			float temp_output_3_0_g12 = ( 1.0 - uv4_TexCoord9.y );
			float DialMask119 = min( saturate( ( temp_output_3_0_g11 / fwidth( temp_output_3_0_g11 ) ) ) , saturate( ( temp_output_3_0_g12 / fwidth( temp_output_3_0_g12 ) ) ) );
			float3 lerpResult108 = lerp( ( lerpResult170 + ( _BackgroundColor.rgb * max( ( 0.3183099 * ( temp_output_666_0_g18 * temp_output_666_0_g18 ) ) , 0.0 ) ) ) , (lerpResult73).rgb , (( lerpResult73 * DialMask119 )).a);
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float temp_output_30_0 = ( 1.0 - DialMask119 );
			float3 lerpResult112 = lerp( lerpResult108 , tex2D( _MainTex, uv_MainTex ).rgb , temp_output_30_0);
			o.Albedo = lerpResult112;
			float3 lerpResult213 = lerp( lerpResult108 , float3( 0,0,0 ) , temp_output_30_0);
			o.Emission = lerpResult213;
			float2 uv_Metallic = i.uv_texcoord * _Metallic_ST.xy + _Metallic_ST.zw;
			float4 lerpResult215 = lerp( float4( 0,0,0,0 ) , tex2D( _Metallic, uv_Metallic ) , temp_output_30_0);
			o.Metallic = (lerpResult215).r;
			o.Smoothness = (lerpResult215).a;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 customPack1 : TEXCOORD1;
				float4 customPack2 : TEXCOORD2;
				float2 customPack3 : TEXCOORD3;
				float4 tSpace0 : TEXCOORD4;
				float4 tSpace1 : TEXCOORD5;
				float4 tSpace2 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack2.xyzw = customInputData.ase_positionOS4f;
				o.customPack1.zw = customInputData.uv3_texcoord3;
				o.customPack1.zw = v.texcoord2;
				o.customPack3.xy = customInputData.uv4_texcoord4;
				o.customPack3.xy = v.texcoord3;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.ase_positionOS4f = IN.customPack2.xyzw;
				surfIN.uv3_texcoord3 = IN.customPack1.zw;
				surfIN.uv4_texcoord4 = IN.customPack3.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.RangedFloatNode;35;-5834.563,-295.8156;Inherit;False;Global;_Udon_FuralityEclipse_Time;_Udon_FuralityEclipse_Time;15;0;Create;False;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;-5233.601,-285.049;Inherit;False;Global;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;129;-5618.093,46.87497;Inherit;False;Constant;_Vector7;Vector 7;3;0;Create;True;0;0;0;False;0;False;0,0.4;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;128;-5626.093,-123.125;Inherit;False;Constant;_Vector5;Vector 5;3;0;Create;True;0;0;0;False;0;False;1,0.6;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;68;-5301.864,-5.774472;Inherit;False;Constant;_Vector2;Vector 2;4;0;Create;True;0;0;0;False;0;False;-0.019,0.02;-0.019,0.02;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;74;-4996.311,-281.3891;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;96;-5217.749,125.1579;Inherit;False;Constant;_Vector6;Vector 6;3;0;Create;True;0;0;0;False;0;False;0.1,1;0.1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-5312.756,-148.109;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-4958.959,-98.5477;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;97;-4829.273,-247.6216;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;131;1427.847,1552.353;Inherit;False;Constant;_Vector8;Vector 7;3;0;Create;True;0;0;0;False;0;False;0,0.4;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;132;1419.847,1382.353;Inherit;False;Constant;_Vector9;Vector 5;3;0;Create;True;0;0;0;False;0;False;1,0.6;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;98;-4703.868,-103.634;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;56;2150.379,1774.349;Inherit;False;Constant;_Vector1;Vector 1;7;0;Create;True;0;0;0;False;0;False;1,0.9;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;2104.329,1650.863;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;138;-3835.508,-857.6371;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;62;-4604.908,215.7539;Inherit;False;Constant;_Float13;Float 13;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-4605.908,146.754;Inherit;False;Constant;_Float14;Float 14;3;0;Create;True;0;0;0;False;0;False;0.0075;0.0075;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-4535.668,-63.71381;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;53;2237.762,2055.611;Inherit;False;Constant;_Float12;Float 12;7;0;Create;True;0;0;0;False;0;False;0.12;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;2342.379,1662.349;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;24;2454.379,1822.349;Inherit;False;Constant;_Vector0;Vector 0;4;0;Create;True;0;0;0;False;0;False;-0.0605,0;-0.0605,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;114;2256.658,1941.619;Inherit;False;113;Global;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;157;-3220.138,-864.1255;Inherit;False;World;Object;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;162;-3410.597,-1211.954;Inherit;False;Constant;_Float23;Float 23;7;0;Create;True;0;0;0;False;0;False;-90;-90;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;61;-4402.908,168.7539;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;123;-4393.926,-49.93412;Inherit;False;FireworkUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;38;2469.998,1947.242;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;2646.379,1726.349;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RadiansOpNode;159;-3198.604,-1208.723;Inherit;False;1;0;FLOAT;90;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;161;-2918.618,-876.0894;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;156;-3236.889,-1123.77;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;69;-4146.838,150.9347;Inherit;False;Constant;_Vector3;Vector 3;5;0;Create;True;0;0;0;False;0;False;1,0.9;1,0.9;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimplifiedFModOpNode;66;-4183.908,40.75399;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;2887.525,1878.211;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;198;2775.298,2488.058;Inherit;False;Constant;_Float25;Float 20;3;0;Create;True;0;0;0;False;0;False;0.001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;199;2780.348,2369.956;Inherit;False;Constant;_Float26;Float 19;3;0;Create;True;0;0;0;False;0;False;1;1.004;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;201;2788.524,2284.086;Inherit;False;Constant;_Float27;Float 4;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;158;-2931.779,-1221.884;Inherit;False;False;4;0;FLOAT3;1,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;160;-2758.285,-949.0775;Inherit;False;False;4;0;FLOAT3;1,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-2667.502,-790.5777;Inherit;False;Constant;_Float21;Float 21;6;0;Create;True;0;0;0;False;0;False;-0.003;-0.003;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;142;-2665.816,-709.4804;Inherit;False;Constant;_SurfaceTile;Surface Tile;5;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-138.2852,1690.286;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-134.2852,1790.286;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;1;1.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-180.2852,1933.286;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-3954.839,38.93484;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;200;2922.718,2166.655;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;202;2976.298,2461.058;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;208;2997.204,2293.066;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;141;-2282.467,-1225.077;Inherit;False;    float3 planeNormal = float3(0, 1, 0)@ // Upward facing$    float denom = dot(planeNormal, rayDirWS)@$$    // Avoid divide-by-zero or parallel rays$    if (abs(denom) < 1e-5)$        return float2(-1, -1)@ // No intersection$$    float t = (planeHeight - rayOriginWS.y) / denom@$$    if (t < 0)$        return float2(-1, -1)@ // Intersection behind the ray origin$$    float3 hitPoint = rayOriginWS + rayDirWS * t@$$    // Project to XZ plane and scale UVs$    float2 uv = hitPoint.xz * uvScale@$    //return frac(uv)@ // Repeat every 1 unit$wPos = hitPoint@$return uv@;2;Create;5;True;rayOriginWS;FLOAT3;0,0,0;In;;Inherit;False;True;rayDirWS;FLOAT3;0,0,0;In;;Inherit;False;True;planeHeight;FLOAT;0;In;;Inherit;False;True;uvScale;FLOAT;0;In;;Inherit;False;True;wPos;FLOAT3;0,0,0;Out;;Inherit;False;planeRayIntersect;True;False;0;;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;2;FLOAT2;0;FLOAT3;5
Node;AmplifyShaderEditor.Vector3Node;212;-2568.733,-612.4943;Inherit;False;Constant;_Vector11;Vector 11;9;0;Create;True;0;0;0;False;0;False;0.03,0,-0.03;0.03,0,-0.03;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;18;51.71511,1730.286;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;10.71511,1889.286;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-3259.608,332.2041;Inherit;False;Constant;_Float7;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-3255.608,432.2042;Inherit;False;Constant;_Float8;Float 8;3;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-3301.607,575.2041;Inherit;False;Constant;_Float9;Float 9;6;0;Create;True;0;0;0;False;0;False;0.185;0.185;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;71;-3698.739,163.7348;Inherit;False;Constant;_Vector4;Vector 4;2;0;Create;True;0;0;0;False;0;False;0.033,0.11;0.033,0.11;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;99;-3744.231,43.76284;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;191;-2311.886,-457.6932;Inherit;False;Constant;_Vector10;Vector 10;5;0;Create;True;0;0;0;False;0;False;-1.2,-0.5,-1.12;-1.2,-0.51,-1.13;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;124;-3322.424,-372.744;Inherit;False;123;FireworkUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-3277.709,-65.73544;Inherit;False;Constant;_Float20;Float 20;3;0;Create;True;0;0;0;False;0;False;0.001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-3272.659,-183.8371;Inherit;False;Constant;_Float19;Float 19;3;0;Create;True;0;0;0;False;0;False;1.004;1.004;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;203;3163.444,2392.413;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1.056;False;2;FLOAT;0.78;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;204;3154.752,2204.759;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.78;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;210;-2243.733,-713.8943;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;9;252.7453,1725.072;Inherit;False;3;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,3;False;1;FLOAT2;0,-2;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;322.7573,1928.495;Inherit;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;302.9582,1589.094;Inherit;False;Constant;_Float4;Float 4;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;43;-3069.609,372.2041;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;44;-3110.609,531.2042;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-3461.739,69.73485;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureTransformNode;168;-2263.597,-1088.891;Inherit;False;166;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RangedFloatNode;182;-1912.842,-645.0347;Inherit;False;Constant;_Float22;Float 22;8;0;Create;True;0;0;0;False;0;False;-0.06;-0.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;172;-1930.735,-948.7181;Inherit;False;1;0;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;190;-2031.886,-477.6932;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;196;-2095.157,-724.9826;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;89;-3130.289,-387.1378;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;84;-3264.483,-269.7066;Inherit;False;Constant;_Float18;Float 4;3;0;Create;True;0;0;0;False;0;False;0.7782;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;126;-3076.709,-92.73544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;205;3414.594,2245.012;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;3067.431,1861.623;Inherit;True;Property;_DialTex;DialTex;0;0;Create;True;0;0;0;False;0;False;-1;None;4c63aa1ae6755244bb4aeee8e0aca718;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.FunctionNode;25;563.9583,1630.094;Inherit;False;Step Antialiasing;-1;;11;2a825e80dfb3290468194f83380797bd;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;26;560.9583,1855.095;Inherit;False;Step Antialiasing;-1;;12;2a825e80dfb3290468194f83380797bd;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;45;-2868.576,366.9899;Inherit;False;3;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,3;False;1;FLOAT2;0,-2;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;47;-2798.564,570.4129;Inherit;False;Constant;_Float11;Float 3;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;167;-1956.828,-1232.38;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RadiansOpNode;173;-1685.735,-960.7181;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;180;-1743.043,-781.3063;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;187;-1812.881,-480.3762;Inherit;False;NdotH;-1;;16;8cedaf44c4bc3e1488a3e3ce525a9ccf;8,491,0,27,0,482,2,451,0,463,0,460,1,461,1,452,0;6;480;FLOAT;1E-37;False;230;FLOAT3;0,0,1;False;443;FLOAT3;0,0,0;False;462;FLOAT3;0,0,0;False;454;FLOAT3;0,1,0;False;453;FLOAT3;0,0,0;False;1;FLOAT;109
Node;AmplifyShaderEditor.SmoothstepOpNode;101;-2889.563,-161.3805;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1.056;False;2;FLOAT;0.78;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;100;-2898.255,-349.0338;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.78;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;3671.641,1864.882;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;75;-3174.656,39.72346;Inherit;True;Property;_MainTex1;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;4c63aa1ae6755244bb4aeee8e0aca718;True;0;False;white;Auto;False;Instance;1;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMinOpNode;15;1112.445,1743.671;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;122;-2775.588,28.56616;Inherit;False;Fireworks;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;105;-2559.254,253.8309;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.025;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;106;-2556.628,488.3103;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.99;False;2;FLOAT;0.975;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;171;-1539.735,-1076.718;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;178;-1680.563,-656.4037;Inherit;False;Constant;_Float6;Float 6;7;0;Create;True;0;0;0;False;0;False;62;60.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;181;-1595.956,-745.6161;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;192;-1739.432,-388.8388;Inherit;False;Constant;_Float24;Float 24;5;0;Create;True;0;0;0;False;0;False;0.25;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;195;-1582.132,-483.7388;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;88;-2568.213,-324.3815;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;3863.586,1865.139;Inherit;False;Main;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;1250.539,1743.523;Inherit;False;DialMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-2175.215,-1.461354;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;116;-2150.889,-89.04121;Inherit;False;115;Main;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMinOpNode;50;-2285.915,365.7752;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;166;-1191.083,-998.5635;Inherit;True;Property;_Background;Background;1;0;Create;True;0;0;0;False;0;False;-1;None;9a8c1154a3909514a8695398bcb49c60;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.FunctionNode;177;-1444.063,-716.1036;Inherit;False;ExponentialSquared_Blend;-1;;17;efb3460b844852b4dbb4ae0ca3ca7cf2;1,7,0;2;12;FLOAT;0;False;9;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;186;-1450.735,-469.8169;Inherit;True;NDF GGX;-1;;18;188193def285b4249aa21de449cf0c25;2,675,1,676,1;2;571;FLOAT;0;False;705;FLOAT;0.11;False;1;FLOAT;272
Node;AmplifyShaderEditor.LerpOp;73;-1801.525,-18.57938;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;109;-1127.233,-1198.038;Inherit;False;Property;_BackgroundColor;Background Color;2;0;Create;True;0;0;0;False;0;False;0.2567138,0,0.2924528,0;0.04404546,0,0.051,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-915.4473,-753.1741;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;-1147.449,106.6465;Inherit;False;119;DialMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;193;-1158.333,-466.8388;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;170;-770.6987,-842.2346;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-943.4642,21.47013;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-811.3005,-506.6857;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-567.9601,349.9934;Inherit;False;119;DialMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;17;-801.4643,21.47013;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;76;-807.7588,-72.07793;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;188;-548.9006,-492.2856;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;30;-378.1445,345.7072;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;216;-367.052,587.4291;Inherit;True;Property;_Metallic;Metallic;6;0;Create;True;0;0;0;False;0;False;-1;None;90f172ec5e402474a999b461fb0fd751;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;214;-576.2268,97.88942;Inherit;True;Property;_MainTex;MainTex;3;0;Create;True;0;0;0;False;0;False;-1;None;90ba55903eb1e0642b79a3d4c459f04d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.LerpOp;215;24.24788,257.2291;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;108;-160.1019,-61.84995;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-5838.28,-212.4229;Inherit;False;Property;_DebugValue;Debug Value;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;222;-826.4521,427.7738;Inherit;True;Property;_Emission;Emission;5;0;Create;True;0;0;0;False;0;False;-1;None;4edd8c84d802d514ca44d895b87cdef5;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.DistanceOpNode;175;-1921.904,-794.2708;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-5696.291,704.9028;Inherit;False;Constant;_Float15;Float 0;1;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-5738.29,947.9027;Inherit;False;Constant;_Float16;Float 16;7;0;Create;True;0;0;0;False;0;False;-1.7;-1.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-5692.291,804.9029;Inherit;False;Constant;_Float17;Float 17;3;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;81;-5506.293,744.9028;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;82;-5547.292,903.9029;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;83;-5395.111,738.3063;Inherit;False;3;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,3;False;1;FLOAT2;0,-2;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;46;-5902.579,720.7147;Inherit;False;Constant;_Float10;Float 4;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FmodOpNode;77;-4158.501,-70.05287;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;197;2730.583,2181.049;Inherit;False;123;FireworkUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;112;108.8215,-46.80499;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-387.782,269.0239;Inherit;False;Constant;_Float5;Float 5;1;0;Create;True;0;0;0;False;0;False;0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;213;113.773,78.58942;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;219;177.6479,210.429;Inherit;False;FLOAT;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;220;172.4478,287.1292;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;221;-13.65222,-260.2262;Inherit;True;Property;_Normal;Normal;4;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;c7f9a397029314642a5b7752dad47d7c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ToggleSwitchNode;36;-5501.637,-260.1017;Inherit;False;Property;_GlobalDebug;Global Debug;7;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;625.9257,-21;Float;False;True;-1;7;AmplifyShaderEditor.MaterialInspector;0;0;Standard;Furality/SomnaNocturna;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;113;0;35;0
WireConnection;74;0;113;0
WireConnection;52;0;128;0
WireConnection;52;1;129;0
WireConnection;67;0;52;0
WireConnection;67;1;68;0
WireConnection;97;0;74;0
WireConnection;97;1;96;0
WireConnection;98;0;97;0
WireConnection;98;1;67;0
WireConnection;2;0;132;0
WireConnection;2;1;131;0
WireConnection;95;0;98;0
WireConnection;95;1;96;0
WireConnection;54;0;2;0
WireConnection;54;1;56;0
WireConnection;157;0;138;0
WireConnection;61;0;63;0
WireConnection;61;1;62;0
WireConnection;123;0;95;0
WireConnection;38;0;114;0
WireConnection;38;1;53;0
WireConnection;23;0;54;0
WireConnection;23;1;24;0
WireConnection;159;0;162;0
WireConnection;161;0;157;0
WireConnection;66;0;123;0
WireConnection;66;1;61;0
WireConnection;34;0;23;0
WireConnection;34;1;38;0
WireConnection;158;1;159;0
WireConnection;158;3;156;0
WireConnection;160;1;159;0
WireConnection;160;3;161;0
WireConnection;70;0;66;0
WireConnection;70;1;69;0
WireConnection;200;0;34;0
WireConnection;202;0;199;0
WireConnection;202;1;198;0
WireConnection;208;0;201;0
WireConnection;208;1;198;0
WireConnection;141;0;158;0
WireConnection;141;1;160;0
WireConnection;141;2;144;0
WireConnection;141;3;142;0
WireConnection;18;0;19;0
WireConnection;18;1;20;0
WireConnection;21;1;22;0
WireConnection;99;0;70;0
WireConnection;99;1;96;0
WireConnection;203;0;200;0
WireConnection;203;1;202;0
WireConnection;203;2;199;0
WireConnection;204;0;200;0
WireConnection;204;1;201;0
WireConnection;204;2;208;0
WireConnection;210;0;141;5
WireConnection;210;1;212;0
WireConnection;9;0;18;0
WireConnection;9;1;21;0
WireConnection;43;0;40;0
WireConnection;43;1;41;0
WireConnection;44;1;42;0
WireConnection;72;0;99;0
WireConnection;72;1;71;0
WireConnection;190;0;191;0
WireConnection;196;0;210;0
WireConnection;89;0;124;0
WireConnection;126;0;85;0
WireConnection;126;1;127;0
WireConnection;205;0;204;0
WireConnection;205;1;203;0
WireConnection;1;1;34;0
WireConnection;25;1;28;0
WireConnection;25;2;9;2
WireConnection;26;1;9;2
WireConnection;26;2;27;0
WireConnection;45;0;43;0
WireConnection;45;1;44;0
WireConnection;167;0;141;0
WireConnection;167;1;168;0
WireConnection;167;2;168;1
WireConnection;173;0;172;0
WireConnection;180;0;196;0
WireConnection;180;1;182;0
WireConnection;187;454;190;0
WireConnection;101;0;89;0
WireConnection;101;1;126;0
WireConnection;101;2;85;0
WireConnection;100;0;89;0
WireConnection;100;1;84;0
WireConnection;209;0;1;0
WireConnection;209;1;205;0
WireConnection;75;1;72;0
WireConnection;15;0;25;0
WireConnection;15;1;26;0
WireConnection;122;0;75;0
WireConnection;105;0;45;2
WireConnection;106;0;45;2
WireConnection;106;1;47;0
WireConnection;171;0;167;0
WireConnection;171;2;173;0
WireConnection;181;0;180;0
WireConnection;195;0;187;109
WireConnection;88;0;100;0
WireConnection;88;1;101;0
WireConnection;115;0;209;0
WireConnection;119;0;15;0
WireConnection;125;0;88;0
WireConnection;125;1;122;0
WireConnection;50;0;105;0
WireConnection;50;1;106;0
WireConnection;166;1;171;0
WireConnection;177;12;181;0
WireConnection;177;9;178;0
WireConnection;186;571;195;0
WireConnection;186;705;192;0
WireConnection;73;0;116;0
WireConnection;73;1;125;0
WireConnection;73;2;50;0
WireConnection;179;0;166;4
WireConnection;179;1;177;0
WireConnection;193;0;186;272
WireConnection;170;0;109;5
WireConnection;170;1;166;5
WireConnection;170;2;179;0
WireConnection;16;0;73;0
WireConnection;16;1;121;0
WireConnection;189;0;109;5
WireConnection;189;1;193;0
WireConnection;17;0;16;0
WireConnection;76;0;73;0
WireConnection;188;0;170;0
WireConnection;188;1;189;0
WireConnection;30;0;120;0
WireConnection;215;1;216;0
WireConnection;215;2;30;0
WireConnection;108;0;188;0
WireConnection;108;1;76;0
WireConnection;108;2;17;0
WireConnection;175;0;141;5
WireConnection;175;1;156;0
WireConnection;81;0;78;0
WireConnection;81;1;80;0
WireConnection;82;1;79;0
WireConnection;83;0;81;0
WireConnection;83;1;82;0
WireConnection;112;0;108;0
WireConnection;112;1;214;5
WireConnection;112;2;30;0
WireConnection;213;0;108;0
WireConnection;213;2;30;0
WireConnection;219;0;215;0
WireConnection;220;0;215;0
WireConnection;36;0;35;0
WireConnection;36;1;37;0
WireConnection;0;0;112;0
WireConnection;0;1;221;0
WireConnection;0;2;213;0
WireConnection;0;3;219;0
WireConnection;0;4;220;0
ASEEND*/
//CHKSM=9E6EDFD9F10956D5D28C9D34F5C840CA5FBC47B3
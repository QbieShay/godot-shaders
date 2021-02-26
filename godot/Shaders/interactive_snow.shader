shader_type spatial;

uniform sampler2D mask_texture: hint_white;
uniform vec2 mask_texture_world_size = vec2(20.0);
uniform sampler2D snow_texture: hint_albedo;
uniform sampler2D snow_texture_normal: hint_normal;
uniform sampler2D snow_texture_roughness;
uniform sampler2D dirt_texture: hint_albedo;
uniform sampler2D dirt_texture_normal: hint_normal;
uniform sampler2D dirt_texture_roughness;
uniform sampler2D blend_texture;
uniform float snow_height = 0.3;
uniform float snow_sharpness: hint_range(0.01, 20.0) = 3.0;
uniform vec2 textures_tiling = vec2(10.0);

varying vec2 world_uv;
varying float height;

void vertex(){
	world_uv = VERTEX.xz;
	world_uv /= mask_texture_world_size;
	world_uv += vec2(0.5);
	vec2 texture_increment = vec2(1.0)/ vec2(textureSize(mask_texture, 0));
	height = 1.0 - texture(mask_texture, world_uv).a;
	
	float height_up = 1.0 - texture(mask_texture, world_uv + vec2(0.0, texture_increment.y)).a;
	float height_left = 1.0 - texture(mask_texture, world_uv + vec2(-texture_increment.x, 0.0)).a;
	float height_down = 1.0 - texture(mask_texture, world_uv + vec2(0.0, -texture_increment.y)).a;
	float height_right = 1.0 - texture(mask_texture, world_uv + vec2(texture_increment.x, 0.0)).a;
	BINORMAL = normalize(vec3(1.0, (height_right - height_left) * snow_height, 0.0));
	TANGENT = normalize(vec3(0.0, (height_up - height_down) * snow_height, 1.0));
	NORMAL = normalize(vec3(cross(TANGENT, BINORMAL)));
	
	VERTEX.y += snow_height * height;
	
}

void fragment(){
	vec2 world_uv_tiled = UV * textures_tiling;
	float mask = 1.0 - texture(mask_texture, UV).a;
//	mask = smoothstep()
	vec4 snow_color = texture(snow_texture,world_uv_tiled);
	vec4 dirt_color = texture(dirt_texture, world_uv_tiled);
	vec3 snow_normal = texture(snow_texture_normal, world_uv_tiled).rgb;
	vec3 dirt_normal = texture(dirt_texture_normal, world_uv_tiled).rgb;
	float snow_rougness = texture(snow_texture_roughness, world_uv_tiled).r;
	float dirt_roughness = texture(dirt_texture_roughness, world_uv_tiled).r;
	float noise_interp = texture(blend_texture, world_uv_tiled * 1.3).r;
	float snow_interp = mix(
		mask * noise_interp * 2.0,
		1.0 - 2.0 * (1.0 - mask) * (1.0 - noise_interp),
		step(0.5, mask)
	);
	snow_interp = 1.0 - pow(1.0 - snow_interp, snow_sharpness);
	snow_interp = clamp(snow_interp, 0.0, 1.0);
	ALBEDO = mix(dirt_color.rgb, snow_color.rgb, snow_interp);
	NORMALMAP = mix(dirt_normal, snow_normal, snow_interp);
	ROUGHNESS = mix(dirt_roughness, snow_rougness, snow_interp);
}
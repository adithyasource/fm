#version 150

layout(std140) uniform Fog {
    vec4 FogColor;
    float FogEnvironmentalStart;
    float FogEnvironmentalEnd;
    float FogRenderDistanceStart;
    float FogRenderDistanceEnd;
    float FogSkyEnd; // unused
    float FogCloudsEnd; // unused
};

// helper functions for fog distance
float fog_spherical_distance(vec3 pos) {
    return length(pos);
}

float fog_cylindrical_distance(vec3 pos) {
    float distXZ = length(pos.xz);
    float distY = abs(pos.y);
    return max(distXZ, distY);
}

// overwriting default linear fog
float linear_fog_value(float vertexDistance, float fogStart, float fogEnd) {
    float chunksValue = clamp(fogEnd / 16.0, 2.0, 32.0);
    float startMultiplier = mix(0.2, 0.001, (chunksValue - 16.0) / (32.0 - 2.0));
    float customFogStart = fogStart * startMultiplier;
    float linearFog = smoothstep(customFogStart, fogEnd, vertexDistance);
    return clamp(pow(linearFog, 0.35), 0.0, 1.0);
}

// combining both cylindrical and spherical fog in the final render
float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmantalEnd, float renderDistanceStart, float renderDistanceEnd) {
    return max(linear_fog_value(sphericalVertexDistance, environmentalStart, environmantalEnd), linear_fog_value(cylindricalVertexDistance, renderDistanceStart, renderDistanceEnd));
}

// final function to apply fog
// also used in sky.fsh to add fog to sky
vec4 apply_fog(vec4 inColor, float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmantalEnd, float renderDistanceStart, float renderDistanceEnd, vec4 fogColor) {
    float fogValue = total_fog_value(sphericalVertexDistance, cylindricalVertexDistance, environmentalStart, environmantalEnd, renderDistanceStart, renderDistanceEnd);
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

#version 150

// ===== fog configuration =====
#define FOG_START_MULTIPLIER 0.01
#define FOG_END_MULTIPLIER 1.0
#define FOG_DENSITY 1.0
#define FOG_CURVE_POWER 0.4
// ==============================

layout(std140) uniform Fog {
    vec4 FogColor;
    float FogEnvironmentalStart;
    float FogEnvironmentalEnd;
    float FogRenderDistanceStart;
    float FogRenderDistanceEnd;
    float FogSkyEnd;
    float FogCloudsEnd;
};

#ifndef PREVENT_NO_FOG_OVERRIDES
float applyFogCurve(float t) {
    return pow(t, FOG_CURVE_POWER); // Configurable curve
}

float linear_fog_value(float vertexDistance, float fogStart, float fogEnd) {
    float customFogStart = fogStart * FOG_START_MULTIPLIER;
    float customFogEnd = fogEnd * FOG_END_MULTIPLIER;
    float linearFog = smoothstep(customFogStart, customFogEnd, vertexDistance);
    return clamp(applyFogCurve(linearFog) * FOG_DENSITY, 0.0, 1.0);
}
#endif

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmantalEnd, float renderDistanceStart, float renderDistanceEnd) {
    return max(linear_fog_value(sphericalVertexDistance, environmentalStart, environmantalEnd), linear_fog_value(cylindricalVertexDistance, renderDistanceStart, renderDistanceEnd));
}

vec4 apply_fog(vec4 inColor, float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmantalEnd, float renderDistanceStart, float renderDistanceEnd, vec4 fogColor) {
    float fogValue = total_fog_value(sphericalVertexDistance, cylindricalVertexDistance, environmentalStart, environmantalEnd, renderDistanceStart, renderDistanceEnd);
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

float fog_spherical_distance(vec3 pos) {
    return length(pos);
}

float fog_cylindrical_distance(vec3 pos) {
    float distXZ = length(pos.xz);
    float distY = abs(pos.y);
    return max(distXZ, distY);
}

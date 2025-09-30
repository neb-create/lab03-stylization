void GetMainLight_float(float3 WorldPos, out float3 Color, out float3 Direction, out float DistanceAtten, out float ShadowAtten) {
#ifdef SHADERGRAPH_PREVIEW
    Direction = normalize(float3(0.5, 0.5, 0));
    Color = 1;
    DistanceAtten = 1;
    ShadowAtten = 1;
#else
    #if SHADOWS_SCREEN
        float4 clipPos = TransformWorldToClip(WorldPos);
        float4 shadowCoord = ComputeScreenPos(clipPos);
    #else
        float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
    #endif

    Light mainLight = GetMainLight(shadowCoord);
    Direction = mainLight.direction;
    Color = mainLight.color;
    DistanceAtten = mainLight.distanceAttenuation;
    ShadowAtten = mainLight.shadowAttenuation;
#endif
}

void ChooseColor_float(float3 Highlight, float3 Shadow, float Diffuse, float Threshold, out float3 OUT)
{
    
    if (Diffuse < Threshold)
    {
        OUT = Shadow;
    }
    else
    {
        OUT = Highlight;
    }
}

void SmoothChooseColor_float(float3 Highlight, float3 Shadow, float Diffuse, float Threshold, float smooth, out float3 OUT)
{

    float bound_min = max(0.0f, Threshold - smooth);
    float bound_max = min(1.0f, Threshold + smooth);

    if (bound_max - bound_min == 0.0) {
        ChooseColor_float(Highlight, Shadow, Diffuse, Threshold, OUT);
    } else {

        Diffuse = max(Diffuse, bound_min);
        Diffuse = min(Diffuse, bound_max);
        float blend_u = (Diffuse - bound_min) / (bound_max - bound_min);
        OUT = (1.0 - blend_u) * Shadow + blend_u * Highlight;
    }
    
}

void ThreeWaySmoothChooseColor_float(float3 Highlight, float3 Midtone, float3 Shadow, float Diffuse, float ThresholdHighlight, float ThresholdShadow, float smooth, out float3 OUT)
{

    float sep = (ThresholdShadow + ThresholdHighlight) / 2.0;

    if (Diffuse < sep)
    {
        smooth = min(sep - Diffuse, smooth);
        SmoothChooseColor_float(Midtone, Shadow, Diffuse, ThresholdShadow, smooth, OUT);
    }
    else 
    {
        smooth = min(Diffuse - sep, smooth);
        SmoothChooseColor_float(Highlight, Midtone, Diffuse, ThresholdHighlight, smooth, OUT);
    }

    
}